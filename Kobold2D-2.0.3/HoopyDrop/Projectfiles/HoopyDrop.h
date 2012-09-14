//
//  GameManager.h
//  HoopyDrop
//
//  Created by Jon DeJong on 9/11/12.
//
//

#import <Foundation/Foundation.h>
#import "TextOverlayLayer.h"
#import "Box2D.h"
#import "PhysicsLayer.h"

#ifndef HOOPY_DROP_H
#define HOOPY_DROP_H

#define DRAW_DEBUG_OUTLINE 0
#define SECONDS_PER_GAME 60

#define YELLOW_FREQ 200
#define GREEN_FREQ 400
#define PURPLE_FREQ 600

#define YELLOW_EXPIRE_SECONDS 10
#define GREEN_EXPIRE_SECONDS 7
#define PURPLE_EXPIRE_SECONDS 4

#define TARGET_RADIUS .25

@interface PauseLayer : CCLayer

@end

@interface GameManager : NSObject

@property (nonatomic, retain) TextOverlayLayer* textOverlayLayer;
@property (nonatomic, retain) PhysicsLayer* physicsLayer;
@property (nonatomic, retain) PauseLayer* pauseLayer;

-(void) removeYellowThingFromGame: (CCSprite*) sprite;
-(void) removeGreenThingFromGame: (CCSprite*) sprite;
-(void) removePurpleThingFromGame: (CCSprite*) sprite;

-(void) handlePause;
-(void) handleUnpause;
-(void) startGame;
-(void) handleEnd;
-(void) markBodyForDeletion: (b2Body*) body;
-(void) addToScore: (int) points;
-(int) getScore;

+(GameManager*) sharedInstance;
+(bool) isRetina;

@end


@interface HDStartLayer : CCLayer

@end

@interface DeletableBody : NSObject

-(b2Body*) body;
-(void) setBody: (b2Body*) body;
-(void) markDeleted;
-(bool) isAlreadyDeleted;

@end

#endif
