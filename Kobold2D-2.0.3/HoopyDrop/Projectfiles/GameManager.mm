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

@implementation GameManager {

    
}

GameManager* _sharedInstance;

@synthesize textOverlayLayer;
@synthesize physicsLayer;
@synthesize pauseLayer;
@synthesize timerLayer;

- (id)init
{
    self = [super init];
    if (self) {
        _sharedInstance = self;
       
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
    return _sharedInstance;
}

+(bool) isRetina {
    return [UIScreen mainScreen].scale > 1;
}

-(void) handleEnd {
    [[CCDirector sharedDirector] popScene];
}

-(void) startGame {
    self.timerLayer = [HDTimer node];
    self.physicsLayer = [PhysicsLayer node];
    self.textOverlayLayer = [TextOverlayLayer node];
    self.pauseLayer = [PauseLayer node];
    self.textOverlayLayer = [TextOverlayLayer node];
    
    [physicsLayer addChild:timerLayer];
	[physicsLayer addChild:textOverlayLayer];
    [physicsLayer addChild:pauseLayer];
    [[CCDirector sharedDirector] pushScene: physicsLayer];
    [timerLayer start];

}

-(void) handlePause {
    [physicsLayer pauseSchedulerAndActions];
    [timerLayer pause];
}

-(void) handleUnpause {
    [physicsLayer resumeSchedulerAndActions];
    [timerLayer unpause];
}

-(void) addToScore: (int) points {
    [textOverlayLayer addToScore:points];
}

-(int) getScore {
    return [textOverlayLayer getScore];
}

@end
