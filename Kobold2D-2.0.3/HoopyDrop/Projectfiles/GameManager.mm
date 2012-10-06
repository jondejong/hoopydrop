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
#include "SimpleAudioEngine.h"

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
@synthesize orbTimer;

- (id)init
{
    self = [super init];
    if (self) {
        _sharedGameManager = self;
        _score = 0;
        NSString * highScoreString = [[PDKeychainBindings sharedKeychainBindings] stringForKey:HIGH_SCORE_KEYCHAIN_KEY];
        _allTimeHighScore = 0;
        if(highScoreString) {
            _allTimeHighScore = [highScoreString intValue];
        }
        // Set Up Audio
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"alarm.aif"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"game_over.aif"];
    }
    return self;
}

-(void) returnToMenu {
    if(_score > _allTimeHighScore) {
        _allTimeHighScore = _score;
        [self flushAllTimeHighScore];
        
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

-(void) removeOrbFromGame: (CCSprite*)sprite {
    [orbTimer handleOrbCollected];
    [physicsLayer removeOrb: sprite];
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
    return _allTimeHighScore;
}

-(void) resetAllTimeHighScore {
    _allTimeHighScore = 0;
    [self flushAllTimeHighScore];
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

-(void) flushAllTimeHighScore  {
    [[PDKeychainBindings sharedKeychainBindings] setString:[NSString stringWithFormat:@"%i", _score] forKey:HIGH_SCORE_KEYCHAIN_KEY];
    [[HDStartLayer sharedInstance] refreshDisplayWith:NO];
}

-(int) currentGameTime {
    return [orbTimer currentGameTime];
}

-(int) orbCollectionFrequency {
    return [orbTimer frequency];
}

@end
