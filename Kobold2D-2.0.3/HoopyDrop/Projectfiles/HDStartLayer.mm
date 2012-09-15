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
        
        int score = [[GameManager sharedInstance] getScore];
        
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %i", score] fontName:@"Marker Felt" fontSize:24];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap Screen To Start" fontName:@"Marker Felt" fontSize:24];
        
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        scoreLabel.position = ccp(size.width/2, size.height/1.8);
		label.position =  ccp(size.width/2, size.height/2);
        //
		// add the label as a child to this Layer
        [self addChild:scoreLabel];
		[self addChild: label];
        isTouchEnabled_ = YES;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    return self;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[GameManager sharedInstance] startGame];
}

@end
