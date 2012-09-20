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

// SCORING CONSTANTS
#define BASE_YELLOW_SCORE 1.0
#define BASE_GREEN_SCORE 5.0
#define BASE_PURPLE_SOCRE 15.0
#define SCORE_CHANGE_PERCENTAGE .50

// THRESHOLD CONSTANTS
#define BASE_THRESHOLD_BOTTOM 20    // (in 1/10s)
#define BASE_THRESHOLD_TOP 300    // (in 1/10s)
#define THRESHOLD_CHANGE_LEVEL 5.0    // orbs collected
#define THESHOLD_CHANGE_PERCENTAGE .5
#define THESHOLD_LEVEL_CHANGE_PERCENTAGE .25
#define MIN_THRESHOLD_BOTTOM 2
#define MIN_THRESHOLD_TOP 4

// HOW LONG DO ORBS STAY ON THE SCREEN?
#define BASE_EXPIRE_TIME 100 // (in 1/10s)
#define MIN_EXPIRE_TIME 25 // (in 1/10s)
#define EXPIRE_TIME_CHANGE_PERCENTAGE .2

// WHAT ARE EACH COLOR'S ODDS (add up 100)
#define YELLOW_ODDS 60
#define GREEN_ODDS 30
#define PURPLE_ODDS 10

#define TARGET_RADIUS .3

#define BACKGROUND_Z 0
#define TEXT_Z 10
#define OBJECTS_Z 5
#define OVERLAY_Z 20

@interface HDSettingsLayer : CCLayer <UIAlertViewDelegate> @end
@interface HelpLayer : CCLayer @end

@interface HDOrbTimer : CCScene
@property (nonatomic, retain) NSMutableArray* existingOrbs;

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

@interface HDStartLayer : CCLayer  {
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
