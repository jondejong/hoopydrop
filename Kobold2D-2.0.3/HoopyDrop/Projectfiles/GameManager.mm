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
    bool _freezeCountdownOn;
    
}
GameManager* _sharedGameManager;

@synthesize textOverlayLayer;
@synthesize physicsLayer;
@synthesize pauseLayer;
@synthesize timerLayer;
@synthesize gamePlayRootScene;
@synthesize orbTimer;
@synthesize persistantData;
@synthesize freezeTimer;

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
        _freezeCountdownOn = NO;
        
        NSString* dataString = [[PDKeychainBindings sharedKeychainBindings] objectForKey:PERSISTANT_DATA_KEYCHAIN_KEY];
        
        self.persistantData = [self parsePersistantData:dataString];

        // Set Up Audio
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"alarm.aif"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"game_over.aif"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pop-low.aif"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pop-med.aif"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pop-hi.aif"];
    }
    return self;
}

-(void) handleUnfreeze
{
    [self updateFreezeImage:0];
    [timerLayer unpause];
    [orbTimer handleUnpause];
    
    CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:1.6 opacity:0];
    
    CCCallFunc* doneHandler = [CCCallFunc actionWithTarget:self selector:@selector(cleanupFreezeImage)];
    
    [[gamePlayRootScene getChildByTag:kFreezeImageNode] runAction:[CCSequence actions:fadeOut, doneHandler, nil]];
    _freezeCountdownOn = NO;
}

-(void) cleanupFreezeImage
{
    [gamePlayRootScene removeChildByTag:kFreezeImageNode cleanup:YES];
}

-(void) updateFreezeImage:(int) count
{
    if(_freezeCountdownOn) {
        [gamePlayRootScene removeChildByTag:kFreezeImageNode cleanup:YES];
    }
    CCSprite* sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"frozen_%i.png", count]];
    sprite.position = ccp(60, 60);
    [gamePlayRootScene addChild:sprite z:OBJECTS_Z tag:kFreezeImageNode];
    _freezeCountdownOn = YES;
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
        [orbTimer handlePause];
        self.freezeTimer = [HDFreezeTimer node];
        [gamePlayRootScene addChild:freezeTimer];
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
        
        //ZEBUG
        CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:.5 opacity:170];
        CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:.5 opacity:0];
        
        CCCallFunc* doneHandler = [CCCallFunc actionWithTarget:self selector:@selector(cleanupFreezeImage)];
        
        CCSequence* sequence = [CCSequence actions:fadeIn, fadeOut, doneHandler, nil];
        
        CCSprite* sprite = [CCSprite spriteWithFile:@"plus_five.png"];
        CGSize size = [CCDirector sharedDirector].winSize;
        sprite.position = ccp(size.width/2, 100);
        sprite.opacity = 0;
        [gamePlayRootScene addChild:sprite z:OBJECTS_Z tag:kPlusFiveAnimNode];
        [sprite runAction:sequence];
    }
}

-(void) removePlusFiveAnimation {
    [gamePlayRootScene removeChildByTag:kPlusFiveAnimNode cleanup:YES];
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
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void) updateTimer: (int) time
{
    [textOverlayLayer updateTimer:time];
}

-(int) getRemainingTime
{
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
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

}

-(void) handlePause {
    [physicsLayer handlePause];
    
    if(_freezeCountdownOn) {
        [self.freezeTimer pause];
    } else {
        [orbTimer handlePause];
        [timerLayer pause];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void) handleUnpause {
    if(_freezeCountdownOn) {
        [self.freezeTimer unpause];
    } else {
        [orbTimer handleUnpause];
        [timerLayer unpause];
    }
    [physicsLayer handleUnpause];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
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

-(void) flushPersistantData
{
    NSMutableString* dataString = [[NSMutableString alloc] init];
    [dataString appendFormat:@"%s:", [persistantData isSoundEffectsOn] ? "YES" : "NO" ];
    
    for(NSNumber * score in [persistantData highScores]) {
        [dataString appendFormat:@"%i:", [score integerValue]];
    }
    
    [[PDKeychainBindings sharedKeychainBindings] setObject: dataString forKey:PERSISTANT_DATA_KEYCHAIN_KEY];
    [[HDStartLayer sharedInstance] refreshDisplayWith:NO];
}

-(int) currentGameTime
{
    return [orbTimer currentGameTime];
}

-(int) orbCollectionFrequency
{
    return [orbTimer frequency];
}

-(void) resetOrbCollectionFrequency
{
    [orbTimer resetFrequency];
}

-(void) fireSound:(int)soundTag
{
    if([persistantData isSoundEffectsOn]) {
        switch (soundTag) {
            case kHDSoundAlarm:
                [[SimpleAudioEngine sharedEngine] playEffect:@"alarm.aif"];
                break;
                
            case kHDSoundGameOver:
                [[SimpleAudioEngine sharedEngine] playEffect:@"game_over.aif"];
                break;
                
            case kHDSoundPopLow:
                [[SimpleAudioEngine sharedEngine] playEffect:@"pop-low.aif"];
                break;
                
            case kHDSoundPopMed:
                [[SimpleAudioEngine sharedEngine] playEffect:@"pop-med.aif"];
                break;
                
            case kHDSoundPopHi:
                [[SimpleAudioEngine sharedEngine] playEffect:@"pop-hi.aif"];
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
