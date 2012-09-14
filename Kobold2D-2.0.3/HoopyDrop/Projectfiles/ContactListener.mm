/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "ContactListener.h"
#import "CollisionHandler.h"
#import "cocos2d.h"

void ContactListener::BeginContact(b2Contact* contact)
{
	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	CollisionHandler* colA = (__bridge CollisionHandler*)bodyA->GetUserData();
	CollisionHandler* colB = (__bridge CollisionHandler*)bodyB->GetUserData();
    
    if(colA != nil) {
        [colA handleCollision: bodyA];
    }
    
    if(colB != nil) {
        [colB handleCollision: bodyB];
    }

}

void ContactListener::EndContact(b2Contact* contact)
{
    //Not used right now
}
