//
//  GameManager.h
//  HoopyDrop
//
//  Created by Jon DeJong on 9/11/12.
//
//

#import <Foundation/Foundation.h>
#import "TextOverlayLayer.h"

#ifndef HOOPY_DROP_H
#define HOOPY_DROP_H

#define DRAW_DEBUG_OUTLINE 0

@interface GameManager : NSObject

@property (nonatomic, retain) TextOverlayLayer* textOverlayLayer;

-(void) handlePause;
-(void) handleStart;
-(void) startGame;
-(void) initGame;
+(GameManager*) sharedInstance;
+(bool) isRetina;

@end


@interface HDStartLayer : CCLayer

@end

#endif
