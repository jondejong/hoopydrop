//
//  CollisionHandler.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/11/12.
//
//

#import "CollisionHandler.h"
#import "Box2D.h"
#import "HoopyDrop.h"
#import "cocos2d.h"

@implementation CollisionHandler {
    @private
    CCSprite* _sprite;
    
}

-(void) handleCollision: (b2Body*) body {
    
}

-(CCSprite*) sprite {
    return _sprite;
}
-(void) setSprite: (CCSprite*) sprite {
    _sprite = sprite;
}

@end

@implementation YellowThingHandler

-(void) handleCollision: (b2Body*) body {
    [[GameManager sharedInstance] removeYellowThingFromGame: [self sprite]];
    [[GameManager sharedInstance] markBodyForDeletion: body];
    [[GameManager sharedInstance] addToScore:5];
}
@end

@implementation GreenThingHandler

-(void) handleCollision: (b2Body*) body {
    [[GameManager sharedInstance] removeGreenThingFromGame: [self sprite]];
    [[GameManager sharedInstance] markBodyForDeletion: body];
    [[GameManager sharedInstance] addToScore:10];
}

@end

@implementation PurpleThingHandler

-(void) handleCollision: (b2Body*) body {
    [[GameManager sharedInstance] removePurpleThingFromGame: [self sprite]];
    [[GameManager sharedInstance] markBodyForDeletion: body];
    [[GameManager sharedInstance] addToScore:15];
}

@end