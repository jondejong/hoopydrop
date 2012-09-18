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

#define HIGH_SCORE_KEYCHAIN_KEY @"hoopyDropAllTimeHighScore"

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
#define PURPLE_POINTS 20

#define YELLOW_EXPIRE_SECONDS 25
#define GREEN_EXPIRE_SECONDS 20
#define PURPLE_EXPIRE_SECONDS 15

#define MAX_TARGET_EMPTY_SECONDS 1.0

#define BASE_SCORE_MULTIPLIER_SCORE 50
#define YELLOW_SCORE_INCREMENTS 5
#define GREEN_SCORE_INCREMENTS 10
#define PURPLE_SCORE_INCREMENTS 20

#define BASE_SPEED_MULTIPLIER_SCORE 100
#define YELLOW_SPEED_INCREMENTS 1
#define GREEN_SPEED_INCREMENTS 1
#define PURPLE_SPEED_INCREMENTS 1

#define BASE_FREQUENCY_MULTIPLIER 75
#define YELLOW_FREQUENCY_INCREMENTS 1
#define GREEN_FREQUENCY_INCREMENTS 1
#define PURPLE_FREQUENCY_INCREMENTS 1

#define MINIMUM_EXPIRE_TIME 2

#define TARGET_RADIUS .25

#define BACKGROUND_Z 0
#define TEXT_Z 10
#define OBJECTS_Z 5
#define OVERLAY_Z 20

@interface BackgroundLayer : CCLayer @end
@interface PauseLayer : CCLayer @end

@interface HDGamePlayRootScene : CCScene @end

@interface HDTimer : CCLayer

-(void)start;
-(void)pause;
-(void)unpause;
-(int)remainingTime;

@end

@interface HDStartLayer : CCLayer <UIAlertViewDelegate> {
}
+(HDStartLayer*) sharedInstance;
-(void) refreshDisplay;
@end

@interface GameManager : NSObject {
}

@property (nonatomic, retain) TextOverlayLayer* textOverlayLayer;
@property (nonatomic, retain) PhysicsLayer* physicsLayer;
@property (nonatomic, retain) PauseLayer* pauseLayer;
@property (nonatomic, retain) HDTimer* timerLayer;
@property (nonatomic, retain) HDGamePlayRootScene* gamePlayRootScene;

-(uint) allTimeHighScore;
-(void) resetAllTimeHighScore;

-(void) removeYellowThingFromGame: (CCSprite*) sprite;
-(void) removeGreenThingFromGame: (CCSprite*) sprite;
-(void) removePurpleThingFromGame: (CCSprite*) sprite;

-(void) handlePause;
-(void) handleUnpause;
-(void) startGame;
-(void) handleEnd;
-(void) handleAbandon;
-(void) markBodyForDeletion: (b2Body*) body;
-(void) addToScore: (int) points;
-(uint) getScore;

-(uint) yellowTargetPoints;
-(uint) greenTargetPoints;
-(uint) purpleTargetPoints;

-(void) setYellowTargetPoints: (uint) points;
-(void) setGreenTargetPoints: (uint) points;
-(void) setPurpleTargetPoints: (uint) points;

-(void) updateTimer: (int) time;
-(int) getRemainingTime;

+(GameManager*) sharedInstance;
+(bool) isRetina;

@end

@interface DeletableBody : NSObject

-(b2Body*) body;
-(void) setBody: (b2Body*) body;
-(void) markDeleted;
-(bool) isAlreadyDeleted;

@end

#endif
