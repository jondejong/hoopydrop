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
-(void) handleCollision: (b2Body*) body;

@end

@interface YellowThingHandler : CollisionHandler @end
@interface GreenThingHandler : CollisionHandler @end
