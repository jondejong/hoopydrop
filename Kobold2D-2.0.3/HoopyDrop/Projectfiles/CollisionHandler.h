//
//  CollisionHandler.h
//  HoopyDrop
//
//  Created by Jon DeJong on 9/11/12.
//
//

#import "CCNode.h"

@interface CollisionHandler : CCNode

-(CCSprite*) sprite;
-(void) setSprite: (CCSprite*) sprite;
-(void) setBody: (b2Body*) body;
-(b2Body*) body;
-(void) handleCollisionWith: (CollisionHandler*) otherHandler;
-(void) doHandleCollisionWith: (CollisionHandler*) otherHandler;
-(int) createTime;
-(void) setCreateTime: (int)time;
-(bool) isRemoved;
-(void) markRemoved;
-(void) removeThisTarget;
-(void) removeThisTargetWithColor: (NSString*) baseSpriteName;
-(int) removeTime;
-(void) setType: (int)type;
-(int) bodyType;

@end

@interface YellowThingHandler : CollisionHandler @end
@interface GreenThingHandler : CollisionHandler @end
@interface PurpleThingHandler : CollisionHandler @end

@interface BombIconHandler : CollisionHandler @end
@interface ExtraSecondsIconHandler : CollisionHandler @end
@interface CherryIconHandler : CollisionHandler @end
@interface BoltIconHandler : CollisionHandler @end


