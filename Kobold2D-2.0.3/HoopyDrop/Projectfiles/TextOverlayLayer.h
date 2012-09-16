//
//  TextOverlayLayer.h
//  HoopyDrop
//
//  Created by Jon DeJong on 9/11/12.
//
//

#import "CCLayer.h"

@interface TextOverlayLayer : CCLayer
-(void) updateScore: (int) sc;
-(void) updateTimer:(int) time;
@end
