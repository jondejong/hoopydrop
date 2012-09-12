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

- (id)init
{
    self = [super init];
    if (self) {
        _sharedInstance = self;
        physicsLayer = [PhysicsLayer node];		
		textOverlayLayer = [TextOverlayLayer node];
    }
    return self;
}

-(void) removeYellowThingGame: (CCSprite*) sprite {
    [physicsLayer removeYellowThing:sprite];
}

-(void) removeGreenThingGame: (CCSprite*) sprite {
    [physicsLayer removeGreenThing:sprite];
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

-(void) initGame {
    
}

-(void) startGame {
	[physicsLayer addChild:textOverlayLayer];
    [[CCDirector sharedDirector] pushScene: physicsLayer];
    [physicsLayer addYellowThing];
    [physicsLayer addGreenThing];
}

-(void) handlePause {
    
}

-(void) handleStart {
    
}

@end
