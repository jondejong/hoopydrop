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
    
}

- (id)init
{
    self = [super init];
    if (self) {
        _removed = false;
        _removeTime = 0;
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
    [[GameManager sharedInstance] removeOrbFromGame: [self sprite]];
    [[GameManager sharedInstance] markBodyForDeletion: _body];
    [self markRemoved];
}

-(void) removeThisTargetWithColor: (NSString*) baseSpriteName
{
    [[GameManager sharedInstance] removeOrbFromGame: [self sprite] withColor:baseSpriteName];
    [[GameManager sharedInstance] markBodyForDeletion: _body];
    [self markRemoved];
}

@end

@implementation BombIconHandler

-(void) handleCollision: (b2Body*) body
{
    [[GameManager sharedInstance] markBodyForDeletion:[self body]];
    [[GameManager sharedInstance] handleBombTargetHit];
}

@end

@implementation YellowThingHandler

-(void) handleCollision: (b2Body*) body
{
    if(![self isRemoved]) {
        [self markRemoved];
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
    [[GameManager sharedInstance] addToScore:[[GameManager sharedInstance] greenTargetPoints]];
    [self removeMe];
}
-(void) removeMe
{
    [self removeThisTargetWithColor:@"green"];
}
@end

@implementation PurpleThingHandler

-(void) handleCollision: (b2Body*) body {
    [[GameManager sharedInstance] addToScore:[[GameManager sharedInstance] purpleTargetPoints]];
    [self removeMe];
}

-(void) removeMe
{
    [self removeThisTargetWithColor:@"purple"];
}
@end