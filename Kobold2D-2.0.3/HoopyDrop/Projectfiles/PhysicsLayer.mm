/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "PhysicsLayer.h"
#import "HoopyDrop.h"
#import "Box2DDebugLayer.h"
#import "CollisionHandler.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
const float PTM_RATIO = 32.0f;

const int TILESIZE = 32;
const int TILESET_COLUMNS = 9;
const int TILESET_ROWS = 19;


@interface PhysicsLayer (PrivateMethods)
-(void) enableBox2dDebugDrawing;
-(void) addSomeJoinedBodies:(CGPoint)pos;
-(void) addNewSpriteAt:(CGPoint)p;
-(b2Vec2) toMeters:(CGPoint)point;
-(CGPoint) toPixels:(b2Vec2)vec;
@end

@implementation PhysicsLayer {
    @private
    bool paused;
    NSMutableArray* userDataReferences;
}

@synthesize deletableBodies;

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@ init", NSStringFromClass([self class]));
        
        paused = false;
        userDataReferences = [NSMutableArray arrayWithCapacity: 10];
        self.deletableBodies = [NSMutableArray arrayWithCapacity:10];

		glClearColor(0.1f, 0.0f, 0.2f, 1.0f);
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
		world = new b2World(gravity);
		world->SetAllowSleeping(NO);
		//world->SetContinuousPhysics(YES);
		
		// uncomment this line to draw debug info
#if DRAW_DEBUG_OUTLINE
		[self enableBox2dDebugDrawing];
#endif

		contactListener = new ContactListener();
		world->SetContactListener(contactListener);
		
		// for the screenBorder body we'll need these values
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		float widthInMeters = screenSize.width / PTM_RATIO;
		float heightInMeters = screenSize.height / PTM_RATIO;
		b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
		b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0);
		b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
		b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
		
		// Define the static container body, which will provide the collisions at screen borders.
		b2BodyDef screenBorderDef;
		screenBorderDef.position.Set(0, 0);
		b2Body* screenBorderBody = world->CreateBody(&screenBorderDef);
		b2EdgeShape screenBorderShape;
		
		// Create fixtures for the four borders (the border shape is re-used)
		screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
		screenBorderBody->CreateFixture(&screenBorderShape, 0);
		screenBorderShape.Set(lowerRightCorner, upperRightCorner);
		screenBorderBody->CreateFixture(&screenBorderShape, 0);
		screenBorderShape.Set(upperRightCorner, upperLeftCorner);
		screenBorderBody->CreateFixture(&screenBorderShape, 0);
		screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
		screenBorderBody->CreateFixture(&screenBorderShape, 0);
		
		CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:@"goodball.png" capacity:1];
		[self addChild:batch z:0 tag:kTagBatchNode];
        
        CCSpriteBatchNode* yellowThing = [CCSpriteBatchNode batchNodeWithFile:@"yellow_thing.png" capacity:15];
		[self addChild:yellowThing z:0 tag:kYellowThingNode];
		
        [self addNewSpriteAt:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
        
//        [self addYellowThing];
	
		[self scheduleUpdate];
		
		[KKInput sharedInput].accelerometerActive = YES;
	}

	return self;
}

-(void) dealloc
{
	delete contactListener;
	delete world;

#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}

-(void) enableBox2dDebugDrawing
{
	// Using John Wordsworth's Box2DDebugLayer class now
	// The advantage is that it draws the debug information over the normal cocos2d graphics,
	// so you'll still see the textures of each object.
	const BOOL useBox2DDebugLayer = YES;

	
	float debugDrawScaleFactor = 1.0f;
#if KK_PLATFORM_IOS
	debugDrawScaleFactor = [[CCDirector sharedDirector] contentScaleFactor];
#endif
	debugDrawScaleFactor *= PTM_RATIO;

	UInt32 debugDrawFlags = 0;
	debugDrawFlags += b2Draw::e_shapeBit;
	debugDrawFlags += b2Draw::e_jointBit;
	//debugDrawFlags += b2Draw::e_aabbBit;
	//debugDrawFlags += b2Draw::e_pairBit;
	//debugDrawFlags += b2Draw::e_centerOfMassBit;

	if (useBox2DDebugLayer)
	{
		Box2DDebugLayer* debugLayer = [Box2DDebugLayer debugLayerWithWorld:world
																  ptmRatio:PTM_RATIO
																	 flags:debugDrawFlags];
		[self addChild:debugLayer z:100];
	}
	else
	{
		debugDraw = new GLESDebugDraw(debugDrawScaleFactor);
		if (debugDraw)
		{
			debugDraw->SetFlags(debugDrawFlags);
			world->SetDebugDraw(debugDraw);
		}
	}
}

-(CCSprite*) addRandomSpriteAt:(CGPoint)pos
{
	CCSpriteBatchNode* batch = (CCSpriteBatchNode*)[self getChildByTag:kTagBatchNode];

	CCSprite* sprite = [CCSprite spriteWithTexture:batch.texture];
	sprite.batchNode = batch;
	sprite.position = pos;
	[batch addChild:sprite];
	
	return sprite;
}

-(void) bodyCreateFixture:(b2Body*)body
{
    // Define another box shape for our dynamic body.
    b2CircleShape ballShape;
    ballShape.m_radius = .88f;
	
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &ballShape;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    fixtureDef.restitution = 0.7f;
    
    body->CreateFixture(&fixtureDef);
	
}

-(void) addNewSpriteAt:(CGPoint)pos
{
	// Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	
	// position must be converted to meters
	bodyDef.position = [self toMeters:pos];
	
	// assign the sprite as userdata so it's easy to get to the sprite when working with the body
    CCSprite* sprite = [self addRandomSpriteAt:pos];
    CollisionHandler* handler = [[CollisionHandler alloc] init];
    [handler setSprite:sprite];
	bodyDef.userData = (__bridge void*)handler;
    [userDataReferences addObject:handler];
	b2Body* body = world->CreateBody(&bodyDef);
	
	[self bodyCreateFixture:body];
}

-(void) update:(ccTime)delta
{
	CCDirector* director = [CCDirector sharedDirector];

    KKInput* input = [KKInput sharedInput];
    if (director.currentDeviceIsSimulator == NO)
    {
        KKAcceleration* acceleration = input.acceleration;
        //CCLOG(@"acceleration: %f, %f", acceleration.rawX, acceleration.rawY);
        b2Vec2 gravity = 10.0f * b2Vec2(acceleration.rawX, acceleration.rawY);
        world->SetGravity(gravity);
    }
    
    if (input.anyTouchEndedThisFrame)
    {
        
        //            TODO: Handle Pauses :P
        //            if(paused) {
        //                paused = false;
        //                [self resumeSchedulerAndActions];
        //            } else {
        //                paused = true;
        //                [self pauseSchedulerAndActions];
        //            }
    }
	
	
	// The number of iterations influence the accuracy of the physics simulation. With higher values the
	// body's velocity and position are more accurately tracked but at the cost of speed.
	// Usually for games only 1 position iteration is necessary to achieve good results.
	float timeStep = 0.03f;
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	world->Step(timeStep, velocityIterations, positionIterations);
	
	// for each body, get its assigned sprite and update the sprite's position
    
    
    for (uint i = 0; i < [deletableBodies count]; i++)
	{
        DeletableBody* db = [deletableBodies objectAtIndex: i];
        if(![db isAlreadyDeleted]) {
            [db markDeleted];
            world->DestroyBody([db body]);
        }
    }

	for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
	{
		CollisionHandler* handler = (__bridge CollisionHandler*)body->GetUserData();
        if(handler != NULL) {
            CCSprite* sprite = [handler sprite];
            if (sprite != NULL)
            {
                // update the sprite's position to where their physics bodies are
                sprite.position = [self toPixels:body->GetPosition()];
                float angle = body->GetAngle();
                sprite.rotation = CC_RADIANS_TO_DEGREES(angle) * -1;
            }
        }
	}
}


// convenience method to convert a CGPoint to a b2Vec2
-(b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// convenience method to convert a b2Vec2 to a CGPoint
-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

-(void) addYellowThing {
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CGPoint pos = CGPointMake(screenSize.width / 1.5, screenSize.height / 1.5);
    
    // Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
	
	// position must be converted to meters
	bodyDef.position = [self toMeters:pos];
    
    CCSpriteBatchNode* yellowThing = (CCSpriteBatchNode*)[self getChildByTag:kYellowThingNode];
    
	CCSprite* sprite = [CCSprite spriteWithTexture:yellowThing.texture];
	sprite.batchNode = yellowThing;
	sprite.position = pos;
	[yellowThing addChild:sprite];
	
	// assign the sprite as userdata so it's easy to get to the sprite when working with the body
    
    CollisionHandler* handler = [[YellowThingHandler alloc] init];
    [handler setSprite:sprite];
	bodyDef.userData = (__bridge void*)handler;
    
    [userDataReferences addObject:handler];
    
    b2Body* body = world->CreateBody(&bodyDef);
    
    // Define another box shape for our dynamic body.
    b2CircleShape ballShape;
    ballShape.m_radius = .35f;
	
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &ballShape;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    fixtureDef.restitution = 0.7f;
    fixtureDef.isSensor = true;
    
    body->CreateFixture(&fixtureDef);
	
}

-(void) removeYellowThing: (CCSprite*) sprite {
    CCSpriteBatchNode* yellowThing = (CCSpriteBatchNode*)[self getChildByTag:kYellowThingNode];
    [yellowThing removeChild:sprite cleanup:YES];
}


#if DEBUG
-(void) draw
{
	[super draw];

	if (debugDraw)
	{
		ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
		kmGLPushMatrix();
		world->DrawDebugData();	
		kmGLPopMatrix();
	}
}
#endif

@end
