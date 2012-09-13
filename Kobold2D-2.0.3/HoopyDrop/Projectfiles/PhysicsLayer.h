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

@property (nonatomic, retain) NSMutableArray* existingYellows;
@property (nonatomic, retain) NSMutableArray* existingGreens;
@property (nonatomic, retain) NSMutableArray* existingPurples;

-(void) addYellowThing;
-(void) removeYellowThing: (CCSprite*) sprite;
-(void) addGreenThing;
-(void) removeGreenThing: (CCSprite*) sprite;
-(void) addPurpleThing;
-(void) removePurpleThing: (CCSprite*) sprite;

@end
