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
    int _createTime;
    b2Body* _body;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        _removed = false;
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

-(int) createTime {
    return _createTime;
}

-(void) setCreateTime: (int)time {
    _createTime = time;
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
    [[GameManager sharedInstance] addToScore:[[GameManager sharedInstance] yellowTargetPoints]];
    [self removeThisTarget];
}

-(void) removeThisTarget {
    [[GameManager sharedInstance] removeYellowThingFromGame: [self sprite]];
    [super removeThisTarget];
}
@end

@implementation GreenThingHandler

-(void) handleCollision: (b2Body*) body {
    [[GameManager sharedInstance] addToScore:[[GameManager sharedInstance] greenTargetPoints]];
    [self removeThisTarget];
}

-(void) removeThisTarget {
    [[GameManager sharedInstance] removeGreenThingFromGame: [self sprite]];
    [super removeThisTarget];
}

@end

@implementation PurpleThingHandler

-(void) handleCollision: (b2Body*) body {
    [[GameManager sharedInstance] addToScore:[[GameManager sharedInstance] purpleTargetPoints]];
    [self removeThisTarget];
}

-(void) removeThisTarget {
    [[GameManager sharedInstance] removePurpleThingFromGame: [self sprite]];
    [super removeThisTarget];
}

@end