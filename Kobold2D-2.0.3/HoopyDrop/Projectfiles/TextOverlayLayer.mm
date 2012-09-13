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
	int countTime;
	double lastUpdateTime;
	int score;
}

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init])) {
        score = 0;
        
        // create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Pause" fontName:@"Marker Felt" fontSize:12];
        
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		label.position =  ccp(size.width/2, size.height/2);
        
        //        fader.anchorPoint = ccp(0,0);
        //        fader.position = ccp(0,0);
        //        [self addChild: fader];
        
		// add the label as a child to this Layer
		//[self addChild: label];
        
        // Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		
		//score
		CCLabelBMFont *scoreText = [CCLabelBMFont labelWithString:@"Score: 0" fntFile:@"hd-font.fnt"];
		[scoreText setTag:1];
		scoreText.position =  ccp(size.width - (.8*size.width), size.height - (.05*size.height));
		
		//timer
        countTime = SECONDS_PER_GAME;
        NSString * timerString = [NSString stringWithFormat:@"Timer: %i", countTime];
		CCLabelBMFont *timerText = [CCLabelBMFont labelWithString:timerString fntFile:@"hd-font.fnt"];
		[timerText setTag:2];
		timerText.position =  ccp(size.width - (.2*size.width), size.height - (.05*size.height));		
		
		lastUpdateTime = CACurrentMediaTime();
		
		[self addChild: scoreText];
		[self addChild: timerText];
	    [self schedule: @selector(tick:) interval:1.0];
		//
		//		CCMenuItem *resume = [CCMenuItemFont itemWithString:@"Resume Game" target:self selector:@selector(handleUnpause)];
		//        CCMenuItem *endGame = [CCMenuItemFont itemWithString:@"End Level" target:self selector:@selector(handleEndLevel)];
		//
		//        CCMenu *menu = [CCMenu menuWithItems:resume, endGame, nil];
		
		//		[menu alignItemsHorizontallyWithPadding:20];
		//		[menu setPosition:ccp( size.width/2, size.height/2 - 50)];
		//		[self addChild:menu];
        
    }
    return self;
}

-(void) tick: (ccTime) dt
{	
	CCLabelBMFont *timerText = (CCLabelBMFont *)[self getChildByTag:2];
	
	if (CACurrentMediaTime() - lastUpdateTime >= 1) {
		countTime--;
		[timerText setString:[NSString stringWithFormat:@"Timer: %i", countTime]];
	}
	
	if (countTime == 0) {
        [self unschedule: @selector(tick:)];
        [[GameManager sharedInstance] handleEnd];
    }

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
