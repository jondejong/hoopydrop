//
//  HDPersistantData.h
//  HoopyDrop
//
//  Created by Jon DeJong on 10/9/12.
//
//

#import "CCLayer.h"

@interface HDPersistantData : CCLayer

@property (nonatomic, retain) NSMutableArray* highScores;

-(bool) isSoundEffectsOn;
-(void) setSoundEffectsOff;
-(void) setSoundEffectsOn;

@end
