//
//  GameManager.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/11/12.
//
//

#import "HoopyDrop.h"
#import "PhysicsLayer.h"

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
    }
    return self;
}

-(void) markBodyForDeletion: (b2Body*) body {
    [[physicsLayer deletableBodies] addObject:body];
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
    [[CCDirector sharedDirector] pushScene: physicsLayer];
    
}

-(void) handlePause {
    
}

-(void) handleStart {
    
}

@end
