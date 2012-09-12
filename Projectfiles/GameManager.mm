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

- (id)init
{
    self = [super init];
    if (self) {
        _sharedInstance = self;
    }
    return self;
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
    [[CCDirector sharedDirector] pushScene: [PhysicsLayer node]];
    
}

-(void) handlePause {
    
}

-(void) handleStart {
    
}

@end
