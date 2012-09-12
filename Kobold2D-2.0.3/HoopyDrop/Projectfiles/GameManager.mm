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

- (id)init
{
    self = [super init];
    if (self) {
        _sharedInstance = self;
        self.textOverlayLayer = [TextOverlayLayer node];
    }
    return self;
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
    [[CCDirector sharedDirector] pushScene:[HDStartLayer node]];
}

-(void) startGame {
    self.physicsLayer = [PhysicsLayer node];
    self.textOverlayLayer = [TextOverlayLayer node];
    self.pauseLayer = [PauseLayer node];
    
	[physicsLayer addChild:textOverlayLayer];
    [physicsLayer addChild:pauseLayer];
    [[CCDirector sharedDirector] pushScene: physicsLayer];
    [physicsLayer addYellowThing];
    [physicsLayer addGreenThing];
    [physicsLayer addPurpleThing];
}

-(void) handlePause {
    [physicsLayer pauseSchedulerAndActions];
    [textOverlayLayer pauseSchedulerAndActions];
}

-(void) handleUnpause {
    [physicsLayer resumeSchedulerAndActions];
    [textOverlayLayer resumeSchedulerAndActions];
}

-(void) addToScore: (int) points {
    [textOverlayLayer addToScore:points];
}

-(int) getScore {
    return [textOverlayLayer getScore];
}

@end
