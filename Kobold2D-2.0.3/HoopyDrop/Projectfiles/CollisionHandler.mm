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
    int _removeTime;
    int _type;
}

- (id)init
{
    self = [super init];
    if (self) {
        _removed = NO;
        _removeTime = 0;
        _type = -1;
    }
    return self;
}

-(void) setType: (int)type {
    _type = type;
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
    if(0 == _removeTime) {
        _removeTime = [[GameManager sharedInstance] currentGameTime];
    }
    _removed = YES;
}

-(int) removeTime {
    return _removeTime;
}

-(void) removeThisTarget
{
    if(!_removed) {
        [[GameManager sharedInstance] removeOrbFromGame: [self sprite]];
        [[GameManager sharedInstance] markBodyForDeletion: _body];
        [self markRemoved];
    }
}

-(void) removeThisTargetWithColor: (NSString*) baseSpriteName
{
    if(!_removed) {
        [[GameManager sharedInstance] removeOrbFromGame: [self sprite] withColor:baseSpriteName];
        [[GameManager sharedInstance] markBodyForDeletion: _body];
        [self markRemoved];
    }
}

@end

@implementation BombIconHandler

-(void) handleCollision: (b2Body*) body
{
    [self removeThisTarget];
    [[GameManager sharedInstance] handleBombTargetHit];
}

-(void) removeThisTarget
{
    if(![self isRemoved]) {
        [[GameManager sharedInstance] markBodyForDeletion:[self body]];
        [[GameManager sharedInstance] removeBombTargetSprite];
        [self markRemoved];
    }
}

@end

@implementation YellowThingHandler

-(void) handleCollision: (b2Body*) body
{
    if(![self isRemoved]) {
        [[GameManager sharedInstance] addToScore:[[GameManager sharedInstance] yellowTargetPoints]];
        [self removeMe];
    }
#if DEBUG
    else {
        CCLOG(@"Handled a collision on a removed YELLOW target. This shouldn't happen.");
        CCLOG(@"Added at %i. First removed at %i. It is now %i.", [self createTime], [self removeTime], [[GameManager sharedInstance] currentGameTime]);
    }
#endif
}

-(void) removeMe
{
    [self removeThisTargetWithColor:@"yellow"];
}
@end

@implementation GreenThingHandler

-(void) handleCollision: (b2Body*) body {
    if(![self isRemoved]) {
        [[GameManager sharedInstance] addToScore:[[GameManager sharedInstance] greenTargetPoints]];
        [self removeMe];
    }
#if DEBUG
    else {
        CCLOG(@"Handled a collision on a removed YELLOW target. This shouldn't happen.");
        CCLOG(@"Added at %i. First removed at %i. It is now %i.", [self createTime], [self removeTime], [[GameManager sharedInstance] currentGameTime]);
    }
#endif

}
-(void) removeMe
{
    [self removeThisTargetWithColor:@"green"];
}
@end

@implementation PurpleThingHandler

-(void) handleCollision: (b2Body*) body {
    if(![self isRemoved]) {
        [[GameManager sharedInstance] addToScore:[[GameManager sharedInstance] purpleTargetPoints]];
        [self removeMe];
    }
#if DEBUG
    else {
        CCLOG(@"Handled a collision on a removed YELLOW target. This shouldn't happen.");
        CCLOG(@"Added at %i. First removed at %i. It is now %i.", [self createTime], [self removeTime], [[GameManager sharedInstance] currentGameTime]);
    }
#endif
}

-(void) removeMe
{
    [self removeThisTargetWithColor:@"purple"];
}
@end