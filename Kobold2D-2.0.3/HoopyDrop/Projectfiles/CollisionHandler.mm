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
    bool _removed;
    double _createTime;
    b2Body* _body;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        _removed = false;
        _createTime = CACurrentMediaTime();
    }
    return self;
}

-(void) handleCollision: (b2Body*) body {
}

-(void) setBody: (b2Body*) body {
    _body = body;
}

-(b2Body*) body {
    return _body;
}

-(CCSprite*) sprite {
    return _sprite;
}
-(void) setSprite: (CCSprite*) sprite {
    _sprite = sprite;
}

-(double) createTime {
    return _createTime;
}

-(bool) isRemoved {
    return _removed;
}

-(void) markRemoved {
    _removed = YES;
}

-(void) removeThisTarget{
    [[GameManager sharedInstance] markBodyForDeletion: _body];
    [self markRemoved];
}

@end

@implementation YellowThingHandler

-(void) handleCollision: (b2Body*) body {
    [[GameManager sharedInstance] addToScore:5];
    [self removeThisTarget];
}

-(void) removeThisTarget {
    [[GameManager sharedInstance] removeYellowThingFromGame: [self sprite]];
    [super removeThisTarget];
}
@end

@implementation GreenThingHandler

-(void) handleCollision: (b2Body*) body {
    [[GameManager sharedInstance] addToScore:10];
    [self removeThisTarget];
}

-(void) removeThisTarget {
    [[GameManager sharedInstance] removeGreenThingFromGame: [self sprite]];
    [super removeThisTarget];
}

@end

@implementation PurpleThingHandler

-(void) handleCollision: (b2Body*) body {
    [[GameManager sharedInstance] addToScore:15];
    [self removeThisTarget];
}

-(void) removeThisTarget {
    [[GameManager sharedInstance] removePurpleThingFromGame: [self sprite]];
    [super removeThisTarget];
}

@end