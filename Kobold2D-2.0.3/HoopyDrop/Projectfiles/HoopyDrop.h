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
#import "CollisionHandler.h"

#define HIGH_SCORE_KEYCHAIN_KEY @"hoopyDropAllTimeHighScore"

#ifndef HOOPY_DROP_H
#define HOOPY_DROP_H

#define DRAW_DEBUG_OUTLINE 0
#define SECONDS_PER_GAME 60

#define UPDATE_TIMER_LOOP_SECONDS .1

// Odd are 1/_FREQ that each will appear in a give loop, which occurs every REDRAW_LOOP_SECONDS
#define REDRAW_LOOP_SECONDS .5
#define YELLOW_FREQ 20
#define GREEN_FREQ 50
#define PURPLE_FREQ 300

#define YELLOW_MINIMUM_SECONDS_BUFFER 1
#define GREEN_MINIMUM_SECONDS_BUFFER 1
#define PURPLE_MINIMUM_SECONDS_BUFFER 2

#define YELLOW_POINTS 1
#define GREEN_POINTS 10
#define PURPLE_POINTS 40

#define YELLOW_EXPIRE_SECONDS 60
#define GREEN_EXPIRE_SECONDS 30
#define PURPLE_EXPIRE_SECONDS 20

#define MAX_TARGET_EMPTY_SECONDS .6

#define BASE_SCORE_MULTIPLIER_SCORE 25
#define YELLOW_SCORE_INCREMENTS 2
#define GREEN_SCORE_INCREMENTS 5
#define PURPLE_SCORE_INCREMENTS 10

#define BASE_SPEED_MULTIPLIER_SCORE 125
#define YELLOW_SPEED_INCREMENTS 5
#define GREEN_SPEED_INCREMENTS 4
#define PURPLE_SPEED_INCREMENTS 3

#define BASE_FREQUENCY_MULTIPLIER 75
#define YELLOW_FREQUENCY_INCREMENTS 2
#define GREEN_FREQUENCY_INCREMENTS 5
#define PURPLE_FREQUENCY_INCREMENTS 30

#define MINIMUM_YELLOW_FREQ 2
#define MINIMUM_GREEN_FREQ 4
#define MINIMUM_PURPLE_FREQ 6

#define MINIMUM_EXPIRE_TIME 3

#define TARGET_RADIUS .25

#define BACKGROUND_Z 0
#define TEXT_Z 10
#define OBJECTS_Z 5
#define OVERLAY_Z 20

@interface HDOrbTimer : CCScene
@property (nonatomic, retain) NSMutableArray* existingYellows;
@property (nonatomic, retain) NSMutableArray* existingGreens;
@property (nonatomic, retain) NSMutableArray* existingPurples;
-(void) start;
-(void) handlePause;
-(void) handleUnpause;
-(void) decrementTargets;
-(void) handleTargetAdded;
@end

@interface BackgroundLayer : CCLayer @end
@interface PauseLayer : CCLayer @end

@interface HDGamePlayRootScene : CCScene @end

@interface HDTimer : CCLayer

-(void) start;
-(void) pause;
-(void) unpause;
-(int) remainingTime;
@end

@interface HDStartLayer : CCLayer <UIAlertViewDelegate> {
}
+(HDStartLayer*) sharedInstance;
-(void) refreshDisplayWith:(bool)finishedGameFlag;
@end

@interface GameManager : NSObject {
}

@property (nonatomic, retain) TextOverlayLayer* textOverlayLayer;
@property (nonatomic, retain) PhysicsLayer* physicsLayer;
@property (nonatomic, retain) PauseLayer* pauseLayer;
@property (nonatomic, retain) HDTimer* timerLayer;
@property (nonatomic, retain) HDGamePlayRootScene* gamePlayRootScene;
@property (nonatomic, retain) HDOrbTimer* orbTimer;

-(void) decrementTargets;

-(uint) allTimeHighScore;
-(void) resetAllTimeHighScore;

-(void) handleTargetAdded;

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

-(void) addTarget:(CollisionHandler*) handler andBaseSprite: (NSString*)baseSpriteName andParentNode: (int) parentNodeTag andTrackedBy: (NSMutableArray*) trackingArray at: (uint)createTime;

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
