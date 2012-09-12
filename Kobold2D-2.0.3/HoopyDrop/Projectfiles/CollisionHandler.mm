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
    [[GameManager sharedInstance] removeSpriteFromGame: [self sprite]];
    [[GameManager sharedInstance] markBodyForDeletion: body];
}

@end
