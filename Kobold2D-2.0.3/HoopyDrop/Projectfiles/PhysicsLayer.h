/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

#import "ContactListener.h"
#import "CollisionHandler.h"

enum
{
	kTagBatchNode,
    kYellowThingNode,
    kGreenThingNode,
    kPurpleThingNode,
};

@interface PhysicsLayer : CCScene
{
	b2World* world;
	ContactListener* contactListener;
	GLESDebugDraw* debugDraw;
}

@property (nonatomic, retain) NSMutableArray* deletableBodies;


-(void) handlePause;
-(void) handleUnpause;
-(void) removeYellowThing: (CCSprite*) sprite;
-(void) removeGreenThing: (CCSprite*) sprite;
-(void) removePurpleThing: (CCSprite*) sprite;
-(void) addTarget:(CollisionHandler*) handler andBaseSprite: (NSString*)baseSpriteName andParentNode: (int) parentNodeTag andTrackedBy: (NSMutableArray*) trackingArray at: (uint) createTime;

@end
