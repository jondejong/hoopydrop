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
    kOrbNode,
    kHoopyNormalSprite,
    kHoopyFrustratedSprite,
    kHoopyExcitedSprite,
    kBombButtonSprite,
    kGoodiesSpriteSheet,
    kExtraSecondsSprite,
};

@interface PhysicsLayer : CCScene
{
	b2World* world;
	ContactListener* contactListener;
	GLESDebugDraw* debugDraw;
}

@property (nonatomic, retain) NSMutableArray* deletableBodies;

-(void) addExtraSecondsTargetWithTime: (uint) createTime;
-(void) removeExtraSecondsTargetSprite;
-(void) explodeExtraTimeTarget;

-(void) explodeBombTarget;
-(void) removeBombTarget;
-(void) removeTargetSprite: (CCSprite*) sprite;
-(void) addBombTargetWithTime: (uint) createTime;
-(CCNode*) bombButtonNode;
-(void) addBombButton;
-(void) removeBombButton;
-(void) handlePause;
-(void) handleUnpause;
-(void) removeOrb: (CCSprite*) sprite;
-(void) removeOrb: (CCSprite*) sprite withColor: (NSString*) baseSpriteName;
-(void) addTarget:(CollisionHandler*) handler andBaseSprite: (NSString*)baseSpriteName andTrackedBy: (NSMutableArray*) trackingArray at: (uint) createTime;

@end
