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

@implementation GameManager {
    
@private
    uint _score;
    uint _yellowTargetPoints;
    uint _greenTargetPoints;
    uint _purpleTargetPoints;
    uint _allTimeHighScore;
}
GameManager* _sharedGameManager;

@synthesize textOverlayLayer;
@synthesize physicsLayer;
@synthesize pauseLayer;
@synthesize timerLayer;
@synthesize gamePlayRootScene;

- (id)init
{
    self = [super init];
    if (self) {
        _sharedGameManager = self;
        _score = 0;
        _yellowTargetPoints = YELLOW_POINTS;
        _greenTargetPoints = GREEN_POINTS;
        _purpleTargetPoints = PURPLE_POINTS;
        
        NSString * highScoreString = [[PDKeychainBindings sharedKeychainBindings] stringForKey:HIGH_SCORE_KEYCHAIN_KEY];
        _allTimeHighScore = 0;
        if(highScoreString) {
            _allTimeHighScore = [highScoreString intValue];
        }
    }
    return self;
}

-(void)updateTimer: (int) time {
    [textOverlayLayer updateTimer:time];
}

-(int)getRemainingTime {
    return [timerLayer remainingTime];
}

-(void) removeYellowThingFromGame: (CCSprite*) sprite {
    [physicsLayer removeYellowThing:sprite];
}

-(void) removeGreenThingFromGame: (CCSprite*) sprite {
    [physicsLayer removeGreenThing:sprite];
}

-(void) removePurpleThingFromGame: (CCSprite*) sprite {
    [physicsLayer removePurpleThing:sprite];
}

-(void) markBodyForDeletion: (b2Body*) body {
    
    DeletableBody* db = [[DeletableBody alloc] init];
    db.body = body;
    
    [[physicsLayer deletableBodies] addObject:db];
}

+(GameManager*) sharedInstance {
    return _sharedGameManager;
}

+(bool) isRetina {
    return [UIScreen mainScreen].scale > 1;
}

-(void) handleAbandon {
    _score = 0;
    [self handleEnd];
}

-(void) handleEnd {
    if(_score > _allTimeHighScore) {
        _allTimeHighScore = _score;
        [self flushAllTimeHighScore];

    }
    [[HDStartLayer sharedInstance] refreshDisplay];
    [[CCDirector sharedDirector] popScene];
}

-(void) startGame {
    
    _score = 0;
    
    self.gamePlayRootScene = [HDGamePlayRootScene node];
    
    self.timerLayer = [HDTimer node];
    self.physicsLayer = [PhysicsLayer node];
    self.textOverlayLayer = [TextOverlayLayer node];
    self.pauseLayer = [PauseLayer node];
    self.textOverlayLayer = [TextOverlayLayer node];
    
    [gamePlayRootScene addChild:[BackgroundLayer node] z:BACKGROUND_Z];
    
    [gamePlayRootScene addChild:timerLayer];
	[gamePlayRootScene addChild:textOverlayLayer z:TEXT_Z];
    [gamePlayRootScene addChild:pauseLayer z:OVERLAY_Z];
    
    [gamePlayRootScene addChild:physicsLayer z:OBJECTS_Z];
    
    [[CCDirector sharedDirector] pushScene: gamePlayRootScene];
    [timerLayer start];

}

-(void) handlePause {
    [physicsLayer handlePause];
    [timerLayer pause];
}

-(void) handleUnpause {
    [physicsLayer handleUnpause];
    [timerLayer unpause];
}

-(void) addToScore: (int) points {
    _score += points;
    [textOverlayLayer updateScore:_score];
}

-(uint) allTimeHighScore {
    return _allTimeHighScore;
}

-(void) resetAllTimeHighScore {
    _allTimeHighScore = 0;
    [self flushAllTimeHighScore];
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

-(void) flushAllTimeHighScore  {
    [[PDKeychainBindings sharedKeychainBindings] setString:[NSString stringWithFormat:@"%i", _score] forKey:HIGH_SCORE_KEYCHAIN_KEY];
    [[HDStartLayer sharedInstance] refreshDisplay];
}

@end
