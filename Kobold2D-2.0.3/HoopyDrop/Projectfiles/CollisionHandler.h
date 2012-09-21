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
-(void) handleCollision: (b2Body*) body;
-(int) createTime;
-(void) setCreateTime: (int)time;
-(bool) isRemoved;
-(void) markRemoved;
-(void) removeThisTarget;


@end

@interface YellowThingHandler : CollisionHandler @end
@interface GreenThingHandler : CollisionHandler @end
@interface PurpleThingHandler : CollisionHandler @end

