//
//  TextOverlayLayer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/11/12.
//
//

#import "TextOverlayLayer.h"
#import "HoopyDrop.h"

@implementation TextOverlayLayer {
	int score;
}

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init])) {
        score = 0;
    
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		[CCMenuItemFont setFontSize:28];
		
		
		//score
		CCLabelBMFont *scoreText = [CCLabelBMFont labelWithString:@"Score: 0" fntFile:@"hd-font.fnt"];
		[scoreText setTag:1];
		scoreText.position =  ccp(size.width - (.8*size.width), size.height - (.05*size.height));
		
		//timer
        NSString * timerString = [NSString stringWithFormat:@"Timer: %i", [[GameManager sharedInstance] getRemainingTime]];
		CCLabelBMFont *timerText = [CCLabelBMFont labelWithString:timerString fntFile:@"hd-font.fnt"];
		[timerText setTag:2];
		timerText.position =  ccp(size.width - (.2*size.width), size.height - (.05*size.height));		
		
		
		[self addChild: scoreText];
		[self addChild: timerText];

    }
    return self;
}

-(void) updateTimer:(int) time {
    CCLabelBMFont *timerText = (CCLabelBMFont *)[self getChildByTag:2];
    [timerText setString:[NSString stringWithFormat:@"Timer: %i", time]];
}

-(void) addToScore: (int) sc
{
	CCLabelBMFont *scoreText = (CCLabelBMFont *)[self getChildByTag:1];
	score += sc;
	[scoreText setString:[NSString stringWithFormat:@"Score: %i", score]];
}

-(int) getScore {
    return score;
}

@end
