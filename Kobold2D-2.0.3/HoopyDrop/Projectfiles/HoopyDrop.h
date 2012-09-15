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

#define YELLOW_MINIMUM_SECONDS_BUFFER 1
#define GREEN_MINIMUM_SECONDS_BUFFER 1
#define PURPLE_MINIMUM_SECONDS_BUFFER 2

#define YELLOW_POINTS 5
#define GREEN_POINTS 10
#define PURPLE_POINTS 15

#define YELLOW_EXPIRE_SECONDS 20
#define GREEN_EXPIRE_SECONDS 15
#define PURPLE_EXPIRE_SECONDS 10

#define MAX_TARGET_EMPTY_SECONDS 1.0

#define BASE_SCORE_MULTIPLIER_SCORE 50
#define BASE_SCORE_MULTIPLIER_PERCENTAGE 20

#define BASE_SPEED_MULTIPLIER_SCORE 50
#define BASE_SPEED_MULTIPLIER_PERCENTAGE 10

#define TARGET_RADIUS .25

@interface PauseLayer : CCLayer @end
@interface HDTimer : CCLayer

-(void)start;
-(void)pause;
-(void)unpause;
-(int)remainingTime;

@end

@interface GameManager : NSObject

@property (nonatomic, retain) TextOverlayLayer* textOverlayLayer;
@property (nonatomic, retain) PhysicsLayer* physicsLayer;
@property (nonatomic, retain) PauseLayer* pauseLayer;
@property (nonatomic, retain) HDTimer* timerLayer;

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

-(void)updateTimer: (int) time;
-(int)getRemainingTime;

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
