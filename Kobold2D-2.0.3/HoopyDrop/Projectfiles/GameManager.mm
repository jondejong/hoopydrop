//
//  GameManager.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/11/12.
//
//

#import "HoopyDrop.h"
#import "PhysicsLayer.h"
#import "TextOverlayLayer.h"
#import "PDKeychainBindings.h"
#import "SimpleAudioEngine.h"
#import "HDPersistantData.h" 

@implementation GameManager {
    
@private
    uint _score;
    uint _yellowTargetPoints;
    uint _greenTargetPoints;
    uint _purpleTargetPoints;
    bool _exploded;
    bool _extraTimeAdded;
    bool _cherryHitHandled;
    bool _boltTargetHit;
    bool _boltButtonPressed;
    
}
GameManager* _sharedGameManager;

@synthesize textOverlayLayer;
@synthesize physicsLayer;
@synthesize pauseLayer;
@synthesize timerLayer;
@synthesize gamePlayRootScene;
@synthesize orbTimer;
@synthesize persistantData;

- (id)init
{
    self = [super init];
    if (self) {
        _sharedGameManager = self;
        _score = 0;
        _exploded = NO;
        _extraTimeAdded = NO;
        _cherryHitHandled = NO;
        _boltButtonPressed = NO;
        
        NSString* dataString = [[PDKeychainBindings sharedKeychainBindings] objectForKey:PERSISTANT_DATA_KEYCHAIN_KEY];
        
        self.persistantData = [self parsePersistantData:dataString];

        // Set Up Audio
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"alarm.aif"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"game_over.aif"];
    }
    return self;
}

-(void) handleUnfreeze
{
    [timerLayer unpause];
}

-(void) addBoltTargetWithTime: (uint) createTime
{
    [physicsLayer addBoltWithTime:createTime];
}

-(void) handledBoltTargetHit
{
    if(!_boltTargetHit){
        _boltTargetHit = YES;
        [physicsLayer removeBoltSprite];
        [physicsLayer explodeBoltTarget];
        [self addBoltButton];
    }
}

-(void) removeBoltTarget
{
    [physicsLayer removeBoltTarget];
}

-(void) addBoltButton
{
    [pauseLayer addBoltButton];
    [physicsLayer addBoltButton];
}

-(CCNode*) boltButtonNode
{
    return [physicsLayer boltButtonNode];
}

-(void) handleBoltButtonPress
{
    if(!_boltButtonPressed) {
        _boltButtonPressed = YES;
        [physicsLayer handleBoltButtonPressed];
        [timerLayer pause];
        [orbTimer freeze];
    }
}

-(void) addCherryTargetWithTime: (uint)createTime
{
    [physicsLayer addCherryWithTime:createTime];
}

-(void) handledCherryTargetHit
{
    if(!_cherryHitHandled){
        _cherryHitHandled = YES;
        [physicsLayer removeCherrySprite];
        [physicsLayer explodeCherryTarget];
        [self collectAllExistingOrbs];
    }
    
}
-(void) removeCherryTarget
{
    [physicsLayer removeCherryTarget];
}

-(void)removeBombTarget
{
    [physicsLayer removeBombTarget];
}

-(void) removeBombTargetSprite: (CCSprite*) sprite{
    [physicsLayer removeTargetSprite: sprite];
}

-(CCNode*) bombButtonNode
{
    return [physicsLayer bombButtonNode];
}

-(void) addBombButton
{
    [physicsLayer addBombButton];
    [pauseLayer addBombButton];
}

-(void) addBombTargetWithTime: (uint) createTime
{
    [physicsLayer addBombTargetWithTime:0];
}

-(void) handleBombTargetHit
{
    [physicsLayer explodeBombTarget];
    [self addBombButton];
}

-(void) handleExtraTimeTargetHit
{
    if(!_extraTimeAdded){
        _extraTimeAdded = YES;
        [physicsLayer removeExtraSecondsTargetSprite];
        [physicsLayer explodeExtraTimeTarget];
        [timerLayer addTime:TIME_ADDED_IN_SECONDS];
    }
}

-(void) addExtraTimeTargetWithTime: (uint)createTime {
    [physicsLayer addExtraSecondsTargetWithTime:createTime];
}

-(void) removeExtraTimeTarget {
    [physicsLayer removeExtraSecondsTarget];
}

-(void) explodeBomb
{
    if(!_exploded)
    {
        _exploded = YES;
        [physicsLayer removeBombButton];
        [self collectAllExistingOrbs];
    }
}

-(HDPersistantData*) parsePersistantData: (NSString *) dataString {
    HDPersistantData* data = [[HDPersistantData alloc] init];
    CCLOG(@"datastring: %@", dataString);
    if(dataString) {
        NSArray* dataArray = [dataString componentsSeparatedByString:@":"];
        
        NSString* sounds = [dataArray objectAtIndex:1];
        if([sounds isEqualToString:@"YES"]) {
            [data setSoundEffectsOn];
        } else {
            [data setSoundEffectsOff];
        }
        
        NSMutableArray* scores = [NSMutableArray arrayWithCapacity:10];
        
        for(int i=1; i<11; i++) {
            NSString* score = [dataArray objectAtIndex:i];
            
            CCLOG(@"Object at %i: %@", i, score);
            
            [scores addObject:[NSNumber numberWithInt:[score integerValue]] ];
        }
        [data setHighScores:scores];
    }
    
    return data;
}

-(void) returnToMenu {
    
    NSNumber* lowestHighScore = [[persistantData highScores] objectAtIndex:9];
    
    if(_score > [lowestHighScore unsignedIntegerValue]) {

        bool scoreAdded = NO;
        int index=0;

        NSMutableArray * newScores = [NSMutableArray arrayWithCapacity:10];
        for(int count=0; count<10; count++) {
            NSNumber* score = (NSNumber*)[[persistantData highScores] objectAtIndex:index];
            if(!scoreAdded && _score >= [score unsignedIntegerValue]) {
                //OK, handle this
                scoreAdded = YES;
                [NSNumber numberWithInt:_score];
                [newScores addObject:[NSNumber numberWithInt:_score]];
            } else {
                index++;
                [newScores addObject: score];
            }
        }
        [persistantData setHighScores:newScores];
        [self flushPersistantData];
        
    }
    [[HDStartLayer sharedInstance] refreshDisplayWith:YES];
    [[CCDirector sharedDirector] popScene];
}

-(void)updateTimer: (int) time {
    [textOverlayLayer updateTimer:time];
}

-(int)getRemainingTime {
    return [timerLayer remainingTime];
}

-(void) removeOrbFromGame:(CCSprite *)sprite
{
    [orbTimer handleOrbCollected];
    [physicsLayer removeOrb: sprite];
}

-(void) removeOrbFromGame: (CCSprite*)sprite withColor: (NSString*) baseSpriteName
{
    [orbTimer handleOrbCollected];
    [physicsLayer removeOrb: sprite withColor:baseSpriteName];
}

-(void) markBodyForDeletion: (b2Body*) body {
    
    DeletableBody* db = [[DeletableBody alloc] init];
    db.body = body;
    
    [[physicsLayer deletableBodies] addObject:db];
}

-(void) handleTargetAdded {
    [orbTimer handleTargetAdded];
}

+(GameManager*) sharedInstance {
    return _sharedGameManager;
}

+(bool) isRetina {
    return [UIScreen mainScreen].scale > 1;
}

+(bool) is16x9 {
    return [CCDirector sharedDirector].winSize.height > 481;
}

-(void) handleAbandon {
    _score = 0;
    [self returnToMenu];
}

-(void) handleEnd {
    
    HDGameOverLayer* gameOverLayer = [HDGameOverLayer node];
    
    [gamePlayRootScene addChild:gameOverLayer z:OVERLAY_Z];
    
    [physicsLayer pauseSchedulerAndActions];
    [orbTimer pauseSchedulerAndActions];
    [pauseLayer removeTouchResponse];
    
    [gameOverLayer startTransition];
}

-(void) startGame {
    
    _score = 0;
    _exploded = NO;
    _extraTimeAdded = NO;
    _cherryHitHandled = NO;
    _boltTargetHit = NO;
    _boltButtonPressed = NO;
    
    self.gamePlayRootScene = [HDGamePlayRootScene node];
    
    self.timerLayer = [HDTimer node];
    self.physicsLayer = [PhysicsLayer node];
    self.textOverlayLayer = [TextOverlayLayer node];
    self.pauseLayer = [PauseLayer node];
    self.textOverlayLayer = [TextOverlayLayer node];
    self.orbTimer = [HDOrbTimer node];
    
    [gamePlayRootScene addChild:[HDGamePlayBackground node] z:BACKGROUND_Z];
    
    [gamePlayRootScene addChild:timerLayer];
    [gamePlayRootScene addChild:orbTimer];
	[gamePlayRootScene addChild:textOverlayLayer z:TEXT_Z];
    [gamePlayRootScene addChild:pauseLayer z:OVERLAY_Z];
    
    [gamePlayRootScene addChild:physicsLayer z:OBJECTS_Z];
    
    [[CCDirector sharedDirector] pushScene: gamePlayRootScene];
    [orbTimer start];
    [timerLayer start];

}

-(void) handlePause {
    [physicsLayer handlePause];
    [orbTimer handlePause];
    [timerLayer pause];
}

-(void) handleUnpause {
    [orbTimer handleUnpause];
    [physicsLayer handleUnpause];
    [timerLayer unpause];
}

-(void) addToScore: (int) points {
    _score += points;
    [textOverlayLayer updateScore:_score];
}

-(uint) allTimeHighScore {
    NSNumber* score =  (NSNumber*)[[persistantData highScores] objectAtIndex:0];
    return [score unsignedIntegerValue];
}

-(void) resetAllTimeHighScores {
    bool soundOn = [persistantData isSoundEffectsOn];
    self.persistantData = [[HDPersistantData alloc] init];
    if(soundOn) {
        [persistantData setSoundEffectsOn];
    } else {
        [persistantData setSoundEffectsOff];
    }
    [self flushPersistantData];
}

-(void) addTarget:(CollisionHandler*) handler andBaseSprite: (NSString*)baseSpriteName andTrackedBy: (NSMutableArray*) trackingArray at:(uint) createTime {
    [physicsLayer addTarget:handler andBaseSprite:baseSpriteName andTrackedBy:trackingArray at: createTime];
}

-(void) decrementTargets {
    [orbTimer decrementTargets];
}

-(uint) yellowTargetPoints { return _yellowTargetPoints; }
-(uint) greenTargetPoints {return _greenTargetPoints;}
-(uint) purpleTargetPoints {return _purpleTargetPoints;}

-(void) setYellowTargetPoints: (uint) points {
        _yellowTargetPoints = points;
}
-(void) setGreenTargetPoints: (uint) points {
    _greenTargetPoints = points;
}
-(void) setPurpleTargetPoints: (uint) points {
    _purpleTargetPoints = points;
}

-(uint) getScore {
    return _score;
}

-(void) flushPersistantData  {
    NSMutableString* dataString = [[NSMutableString alloc] init];
    [dataString appendFormat:@"%s:", [persistantData isSoundEffectsOn] ? "YES" : "NO" ];
    
    for(NSNumber * score in [persistantData highScores]) {
        [dataString appendFormat:@"%i:", [score integerValue]];
    }
    
    [[PDKeychainBindings sharedKeychainBindings] setObject: dataString forKey:PERSISTANT_DATA_KEYCHAIN_KEY];
    [[HDStartLayer sharedInstance] refreshDisplayWith:NO];
}

-(int) currentGameTime {
    return [orbTimer currentGameTime];
}

-(int) orbCollectionFrequency {
    return [orbTimer frequency];
}

-(void) fireSound:(int)soundTag {
    if([persistantData isSoundEffectsOn]) {
        switch (soundTag) {
            case kHDSoundAlarm:
                [[SimpleAudioEngine sharedEngine] playEffect:@"alarm.aif"];
                break;
                
            case kHDSoundGameOver:
                [[SimpleAudioEngine sharedEngine] playEffect:@"game_over.aif"];
                break;
        }
    }
}

-(bool) isSoundOn {
    return [persistantData isSoundEffectsOn];
}

-(void) toggleSounds {
    if([persistantData isSoundEffectsOn]) {
        [persistantData setSoundEffectsOff];
    } else {
        [persistantData setSoundEffectsOn];
    }
    [self flushPersistantData];
}

-(NSArray*) highScores {
    return  [persistantData highScores];
}

-(int) scorePosition {
    int count = 1;
    for(NSNumber* highScore in [persistantData highScores]) {
        if(_score >= [highScore unsignedIntValue]) {
            return count;
        }
        count++;
    }
    return -1;
}

-(void) collectAllExistingOrbs
{
    for(CollisionHandler* handler in[orbTimer existingOrbs])
    {
        if(![handler isRemoved])
        {
            CollisionHandler* fakeHoopyHandler = [[CollisionHandler alloc] init];
            [fakeHoopyHandler setType:kHoopyBodyType];
            [handler handleCollisionWith:fakeHoopyHandler];
        }
    }
}

@end
