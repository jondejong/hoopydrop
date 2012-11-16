//
//  HoopyDrop.h
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
#import "HDPersistantData.h"

#ifndef HOOPY_DROP_H
#define HOOPY_DROP_H

#define PERSISTANT_DATA_KEYCHAIN_KEY @"HoopyDropPersistantData"

#define DRAW_DEBUG_OUTLINE 0
#define DRAW_CHERRY 1
#define DRAW_TNT 1
#define DRAW_EXTRA_TIME 1
#define DRAW_BOLT 1

#define SECONDS_PER_GAME 60

#define UPDATE_TIMER_LOOP_SECONDS .1

#define EXPRESSION_ANCHOR_POINT ccp(.5, .55)

#define SCREEN_BUFFER_PERCENTAGE .1

// Non-game Screen constants
#define HELP_SCREEN_MOVE_SECONDS .6
#define HELP_SCREEN_Y_POINTS 100
#define HELP_SCREEN_PAGE_COUNT 11
#define HELP_SCREEN_MENU_OFFSET 35
#define HELP_TOP_OFFSET 420
#define NAV_MENU_BOTTOM_OFFSET 50

// Goodie Targets
#define GOODIE_BEGIN_TIME 50
#define GOODIE_END_TIME 12
#define GOODIE_EXPIRE_SECONDS 2

#define TIME_ADDED_IN_SECONDS 5

#define CHERRY_BEGIN_TIME 15
#define CHERRY_END_TIME 5

#define FREEZE_TIME_AMOUNT 30 // 10ths of seconds

// End of game animation controls
#define OVERLAY_ALPHA_CHANNEL_INCREMENTS 5
#define OVERLAY_INTERVALS 40
#define SCORE_DROP_SECONDS 2
#define SCORE_LINESPACING 45
#define TOTAL_LOOPCOUNT 120

// Frequency constants to change Hoopy's expression
#define NORMAL_RANGE_LOW -2
#define NORMAL_RANGE_HIGH 2
#define FREQUENCY_DECREMENT 10 // 10ths of seconds
#define MIN_EXPRESSION_TIME 20 // 10ths of seconds

// Algorthm can be exponential or linear
#define PLACE_LINEAR_ALGORITHM 1

#define BASE_THRESHOLD_BOTTOM_LINEAR 15
#define BASE_THRESHOLD_TOP_LINEAR 25
#define THRESHOLD_BOTTOM_INCREMENT_LINEAR 2
#define THRESHOLD_TOP_INCREMENT_LINEAR 2
#define MIN_THRESHOLD_BOTTOM_LINEAR 2
#define MIN_THRESHOLD_TOP_LINEAR 4

#define THRESHOLD_CHANGE_LEVEL_LINEAR 5
#define THRESHOLD_CHANGE_INCREMENT_LINEAR 5

#define BASE_YELLOW_SCORE_LINEAR 10
#define BASE_GREEN_SCORE_LINEAR 50
#define BASE_PURPLE_SOCRE_LINEAR 100

#define YELLOW_SCORE_INCREMENT 10
#define GREEN_SCORE_INCREMENT 50
#define PURPLE_SCORE_INCREMENT 100

#define BASE_EXPIRE_TIME_LINEAR 100
#define EXPIRE_TIME_INCREMENT_LINEAR 10
#define MIN_EXPIRE_TIME_LINEAR 25

// SCORING CONSTANTS
#define BASE_YELLOW_SCORE_EXPONENTIAL 1.0
#define BASE_GREEN_SCORE_EXPONENTIAL 5.0
#define BASE_PURPLE_SOCRE_EXPONENTIAL 15.0
#define SCORE_CHANGE_PERCENTAGE_EXPONENTIAL .50

// THRESHOLD CONSTANTS
#define BASE_THRESHOLD_BOTTOM_EXPONENTIAL 20    // (in 1/10s)
#define BASE_THRESHOLD_TOP_EXPONENTIAL 300    // (in 1/10s)
#define THRESHOLD_CHANGE_LEVEL_EXPONENTIAL 5.0    // orbs collected
#define THESHOLD_CHANGE_PERCENTAGE .5
#define THESHOLD_LEVEL_CHANGE_PERCENTAGE .25
#define MIN_THRESHOLD_BOTTOM_EXPONENTIAL 2
#define MIN_THRESHOLD_TOP_EXPONENTIAL 4

// HOW LONG DO ORBS STAY ON THE SCREEN?
#define BASE_EXPIRE_TIME_EXPONENTIAL 100 // (in 1/10s)
#define MIN_EXPIRE_TIME_EXPONENTIAL 25 // (in 1/10s)
#define EXPIRE_TIME_CHANGE_PERCENTAGE .2

// WHAT ARE EACH COLOR'S ODDS (add up 100)
#define YELLOW_ODDS 60
#define GREEN_ODDS 30
#define PURPLE_ODDS 10

#define TARGET_RADIUS .33

#define BACKGROUND_Z 0
#define TEXT_Z 10
#define OBJECTS_Z 5
#define OVERLAY_Z 20
#define OVERLAY_TEXT_Z 25
#define BUTTON_Z 10

// Non-game page Page Tags
enum {
    kHelpPage1Tag,
    kHelpPage2Tag,
    kHelpPage3Tag,
    kHelpMenuTag,
    kSettingsBorderTag,
};

// Sounds
enum {
    kHDSoundAlarm,
    kHDSoundGameOver,
};

// Body Types
enum {
    kHoopyBodyType,
    kOrbBodyType,
    kGoodieBodyType,
};

// Layers and nodes
enum {
    kPauseMenuNode,
    kFreezeImageNode,
    kPlusFiveAnimNode,
};


@interface HDFreezeTimer : CCNode
-(void) pause;
-(void) unpause;
@end
@interface RemovableSprite : CCNode
@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic, retain) CCNode* parentNode;
-(void) remove;
@end

@interface HDGamePlayBackground : CCLayer @end
@interface HDSettingsLayer : CCLayer <UIAlertViewDelegate>
@property (nonatomic, retain) CCMenuItemFont* soundsOnMenuItem;
@property (nonatomic, retain) CCMenuItemFont* soundsOffMenuItem;
@property (nonatomic, retain) CCMenu* resetMenu;
@property (nonatomic, retain) CCMenu* goHomeMenu;
@end
@interface HelpLayer : CCLayer @end
@interface LeaderBoardLayer : CCLayer @end
@interface AboutLayer : CCLayer @end
@interface HDGameOverLayer : CCLayer
@property (nonatomic, retain) CCSprite* overlayTransitionSprite;
@property (nonatomic, retain) CCLabelBMFont* scoreLabelText;
@property (nonatomic, retain) CCLabelBMFont* scoreText;
-(void) startTransition;
@end

@interface HDOrbTimer : CCScene
@property (nonatomic, retain) NSMutableArray* existingOrbs;
-(void) start;
-(void) handlePause;
-(void) handleUnpause;
-(void) decrementTargets;
-(void) handleTargetAdded;
-(int) currentGameTime;
-(void) handleOrbCollected;
-(int) frequency;
@end

@interface BackgroundLayer : CCLayer @end
@interface PauseLayer : CCLayer
-(void) removeTouchResponse;
-(void) addBombButton;
-(void) addBoltButton;
-(void) removeBombButton;
@end

@interface HDGamePlayRootScene : CCScene @end

@interface HDTimer : CCLayer

-(void) start;
-(void) pause;
-(void) unpause;
-(int) remainingTime;
-(void) addTime: (int) time;
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
@property (nonatomic, retain) HDPersistantData* persistantData;
@property (nonatomic, retain) HDFreezeTimer* freezeTimer;

+(GameManager*) sharedInstance;

+(bool) isRetina;
+(bool) is16x9;

-(void) handleUnfreeze;
-(void) updateFreezeImage:(int) count;

-(void) addBoltTargetWithTime: (uint) createTime;
-(void) handledBoltTargetHit;
-(void) removeBoltTarget;
-(void) addBoltButton;
-(CCNode*) boltButtonNode;
-(void) handleBoltButtonPress;

-(void) addCherryTargetWithTime: (uint)createTime;
-(void) handledCherryTargetHit;
-(void) removeCherryTarget;

-(void) addExtraTimeTargetWithTime: (uint)createTime;
-(void) handleExtraTimeTargetHit;
-(void) removeExtraTimeTarget;

-(void) removeBombTargetSprite: (CCSprite*) sprite;
-(void) removeBombTarget;
-(void) addBombTargetWithTime: (uint) createTime;
-(void) handleBombTargetHit;
-(void) explodeBomb;
-(void) addBombButton;
-(CCNode*) bombButtonNode;

-(int) scorePosition;
-(NSArray*) highScores;
-(void) fireSound:(int) soundTag;

-(void) returnToMenu;

-(void) decrementTargets;

-(uint) allTimeHighScore;
-(void) resetAllTimeHighScores;

-(void) handleTargetAdded;

-(void) removeOrbFromGame: (CCSprite*)sprite;
-(void) removeOrbFromGame: (CCSprite*)sprite withColor: (NSString*) baseSpriteName;

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

-(int) orbCollectionFrequency;

-(void) addTarget:(CollisionHandler*) handler andBaseSprite: (NSString*)baseSpriteName andTrackedBy: (NSMutableArray*) trackingArray at: (uint)createTime;

-(bool)isSoundOn;
-(int) currentGameTime;
-(void) toggleSounds;
@end

@interface DeletableBody : NSObject

-(b2Body*) body;
-(void) setBody: (b2Body*) body;
-(void) markDeleted;
-(bool) isAlreadyDeleted;

@end

#endif
