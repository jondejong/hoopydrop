//
//  CollisionHandler.h
//  HoopyDrop
//
//  Created by Jon DeJong on 9/11/12.
//
//

#import "CCNode.h"

@interface CollisionHandler : CCNode

@property (nonatomic, retain) CCSprite * sprite;

-(void) handleCollision: (b2Body*) body;

@end

@interface YellowThingHandler : CollisionHandler

@end
