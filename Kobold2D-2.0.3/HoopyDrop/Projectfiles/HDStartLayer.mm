//
//  HDStartLayer.m
//  HoopyDrop
//
//  This class really only exists to start shit
//  Created by Jon DeJong on 9/11/12.
//
//

#import "HoopyDrop.h"


@implementation HDStartLayer

- (id)init
{
    self = [super init];
    if (self) {
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap Screen To Start" fontName:@"Marker Felt" fontSize:24];
        
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		label.position =  ccp(size.width/2, size.height/2);
        //
		// add the label as a child to this Layer
		[self addChild: label];
        isTouchEnabled_ = YES;
    }
    return self;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[GameManager sharedInstance] startGame];
}

@end
