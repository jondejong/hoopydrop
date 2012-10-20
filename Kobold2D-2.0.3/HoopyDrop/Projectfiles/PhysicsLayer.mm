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

@interface PhysicsLayer (PrivateMethods)
-(void) enableBox2dDebugDrawing;
-(void) addSomeJoinedBodies:(CGPoint)pos;
-(void) addNewSpriteAt:(CGPoint)p;
-(b2Vec2) toMeters:(CGPoint)point;
-(CGPoint) toPixels:(b2Vec2)vec;
@end

@implementation PhysicsLayer {
    @private
    NSMutableArray* userDataReferences;
    
    int _hoopyExpression;
    int _lastExpressionChangeGameTime;
    
    CollisionHandler* _hoopyHandler;
}

@synthesize deletableBodies;


-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@ init", NSStringFromClass([self class]));
        
        _hoopyExpression = kHoopyNormalSprite;
        _lastExpressionChangeGameTime = 0;
        
        userDataReferences = [NSMutableArray arrayWithCapacity: 10];
        
        self.deletableBodies = [NSMutableArray arrayWithCapacity:10];

		glClearColor(0.1f, 0.0f, 0.2f, 1.0f);
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
		world = new b2World(gravity);
		world->SetAllowSleeping(NO);
//		world->SetContinuousPhysics(YES);
		
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
		
//		CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:@"goodball.png" capacity:1];
//        CCSpriteBatchNode* hoopy = [CCSpriteBatchNode batchNodeWithFile:@"hoopy.plist" capacity:1];
        // Hoopy Himself
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hoopy.plist"];
        CCSpriteBatchNode* hoopy = [CCSpriteBatchNode batchNodeWithFile:@"hoopy.png"];

		[self addChild:hoopy z:0 tag:kTagBatchNode];

		// Orbs
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"orbs.plist"];
        CCSpriteBatchNode *orbSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"orbs.png"];
        [self addChild:orbSpriteSheet z:0 tag:kOrbNode];
        
        [self addNewSpriteAt:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
	
		[self scheduleUpdate];
		
		[KKInput sharedInput].accelerometerActive = YES;
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	}
    
	return self;
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
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"hoopy-normal.png"]];
    
	sprite.batchNode = batch;
	sprite.position = pos;
    sprite.anchorPoint = EXPRESSION_ANCHOR_POINT;
    
//    CCLOG(@"Anchor: (%f, %f)", sprite.anchorPoint.x, sprite.anchorPoint.y);
    
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
    _hoopyHandler = [[CollisionHandler alloc] init];
    [_hoopyHandler setSprite:sprite];
	bodyDef.userData = (__bridge void*)_hoopyHandler;
//    [userDataReferences addObject:_hoopyHandler];
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
    
    [self swapSprite];

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

-(CGPoint) createRandomPoint {
    CGSize screenSize = [CCDirector sharedDirector].winSize;

    int x = (arc4random() % ((int)screenSize.width - (int)PTM_RATIO)) + (int)(.5 * PTM_RATIO);
    int y = (arc4random() % ((int)screenSize.height - (int)PTM_RATIO)) + (int)(.5 * PTM_RATIO);
    return CGPointMake(x, y);
}

-(void) addTarget:(CollisionHandler*) handler andBaseSprite: (NSString*)baseSpriteName andTrackedBy: (NSMutableArray*) trackingArray at: (uint) createTime{
    NSMutableArray *animFrames = [NSMutableArray array];
    for(int i = 1; i <= 4; ++i) {
        [animFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%i.png", baseSpriteName, i]]];
    }
    
    [animFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@3.png", baseSpriteName]]];
    [animFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@2.png", baseSpriteName]]];
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.07f];
    
    CGPoint pos = [self createRandomPoint];
    
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@1.png", baseSpriteName]];
    
    sprite.position = pos;
    
    [sprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]]];
    [[self getChildByTag:kOrbNode] addChild:sprite];
    
    // Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
	
	// position must be converted to meters
	bodyDef.position = [self toMeters:pos];
    
    [handler setSprite:sprite];
    
	bodyDef.userData = (__bridge void*)handler;
    
    b2Body* body = world->CreateBody(&bodyDef);
    [handler setBody:body];
    [handler setCreateTime:createTime];
    
    [trackingArray addObject:handler];
    
    // Define another box shape for our dynamic body.
    b2CircleShape ballShape;
    ballShape.m_radius = TARGET_RADIUS;
	
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &ballShape;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    fixtureDef.restitution = 0.7f;
    fixtureDef.isSensor = true;
    
    body->CreateFixture(&fixtureDef);
    [[GameManager sharedInstance] handleTargetAdded];
}

-(void) handlePause {
    [self pauseSchedulerAndActions];
}

-(void) handleUnpause {
    [self resumeSchedulerAndActions];
}

-(void) removeOrb: (CCSprite*) sprite
{
    CCSpriteBatchNode* orbSprite = (CCSpriteBatchNode*)[self getChildByTag:kOrbNode];
    [orbSprite removeChild:sprite cleanup:YES];
    [[GameManager sharedInstance] decrementTargets];
}

-(void) removeOrb: (CCSprite*) sprite withColor: (NSString*) baseSpriteName
{
    CCSpriteBatchNode* orbSprite = (CCSpriteBatchNode*)[self getChildByTag:kOrbNode];
    
    CGPoint pos = sprite.position;
    
    [self removeOrb:sprite];
    
    NSMutableArray *animFrames = [NSMutableArray array];
    
    [animFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@4.png", baseSpriteName]]];
    [animFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@5.png", baseSpriteName]]];
    [animFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@6.png", baseSpriteName]]];
    [animFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@7.png", baseSpriteName]]];
    [animFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@8.png", baseSpriteName]]];
    [animFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@9.png", baseSpriteName]]];
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.03f];
    
    CCSprite *explodeSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@4.png", baseSpriteName]];
    
    explodeSprite.position = pos;
    
    [orbSprite addChild:explodeSprite];
    
    RemovableSprite* removeableSprite = [[RemovableSprite alloc] init];
    removeableSprite.sprite = explodeSprite;
    removeableSprite.parentNode = orbSprite;
    
    [self addChild:removeableSprite];
    
    CCCallFunc* doneHandler = [CCCallFunc actionWithTarget:removeableSprite selector:@selector(remove)];
    
//    CCAnimation* animation = [CCAnimate actionWithAnimation:animation];
    
    [explodeSprite runAction:[CCSequence actions: [CCAnimate actionWithAnimation:animation], doneHandler, nil]];
    
}

-(void) handleExplodeOver: (CCSprite*) sprite {
    CCSpriteBatchNode* orbSprite = (CCSpriteBatchNode*)[self getChildByTag:kOrbNode];
    
    [orbSprite removeChild:sprite cleanup:YES];
}

- (void)dealloc
{
    for (b2Body* b = world->GetBodyList(); b; /*b = b->GetNext()*/)  // remove GetNext() call
    {
        b2Body* next = b->GetNext();  // remember next body before *b gets destroyed
        world->DestroyBody(b); // do I need to destroy fixture as well(and how?) or it does that for me?
        b = next;  // go to next body
    }
    
    delete contactListener;
    contactListener = NULL;
    
	delete world;
	world = NULL;

}

-(void) swapSprite {
    int freq = [[GameManager sharedInstance] orbCollectionFrequency];
    
//    CCLOG(@"Frequency: %i", freq);
    
    if([[GameManager sharedInstance] currentGameTime] - _lastExpressionChangeGameTime >= MIN_EXPRESSION_TIME) {
    
        if((freq >= NORMAL_RANGE_LOW && freq < NORMAL_RANGE_HIGH) && kHoopyNormalSprite != _hoopyExpression) {
            [self changeHoopyTo:@"hoopy-normal.png" denotedBy:kHoopyNormalSprite];
        } else if (freq < NORMAL_RANGE_LOW && kHoopyFrustratedSprite != _hoopyExpression) {
            [self changeHoopyTo:@"hoopy-frustrated.png" denotedBy: kHoopyFrustratedSprite];
        } else if(freq >= NORMAL_RANGE_HIGH && kHoopyExcitedSprite != _hoopyExpression){
            [self changeHoopyTo:@"hoopy-excited.png" denotedBy: kHoopyExcitedSprite];
        }
    }
    
}

-(void) changeHoopyTo:(NSString*) frameName denotedBy: (NSInteger) expressionConstant {
    CCSprite* oldExpression = [_hoopyHandler sprite];
    CCSpriteBatchNode* batch = (CCSpriteBatchNode*)[self getChildByTag:kTagBatchNode];
    [batch removeChild:oldExpression cleanup:YES];
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    sprite.anchorPoint = EXPRESSION_ANCHOR_POINT;
    [batch addChild:sprite];
    [_hoopyHandler setSprite:sprite];
    _hoopyExpression = expressionConstant;
    _lastExpressionChangeGameTime = [[GameManager sharedInstance] currentGameTime];
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
