//
//  TextOverlayLayer.h
//  HoopyDrop
//
//  Created by Jon DeJong on 9/11/12.
//
//

#import "CCLayer.h"

@interface TextOverlayLayer : CCLayer
-(void) addToScore: (int) sc;
-(int) getScore;
-(void) updateTimer:(int) time;
@end
