//
//  HDStartLayer.m
//  HoopyDrop
//
//  This class really only exists to start shit
//  Created by Jon DeJong on 9/11/12.
//
//

#import "HoopyDrop.h"


@implementation HDStartLayer {
    
}

HDStartLayer* _sharedHDStartLayer;

- (id)init
{
    self = [super init];
    if (self) {
        
        int score = [[GameManager sharedInstance] getScore];
        
        _sharedHDStartLayer = self;
        
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %i", score] fontName:@"Marker Felt" fontSize:24];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap Screen To Start" fontName:@"Marker Felt" fontSize:24];
        
		// ask director the the window size1
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        scoreLabel.position = ccp(size.width/2, size.height/1.8);
		label.position =  ccp(size.width/2, size.height/2);
        //
		// add the label as a child to this Layer
        [self addChild:scoreLabel z:1 tag:1];
		[self addChild: label];
        isTouchEnabled_ = YES;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    return self;
    
}

+(HDStartLayer*) sharedInstance {
    return _sharedHDStartLayer;
}

-(void) refreshDisplay {
    CCLabelTTF *scoreLabel = (CCLabelTTF*)[self getChildByTag:1];
    [scoreLabel setString:[NSString stringWithFormat:@"Last Game Score: %i", [[GameManager sharedInstance]getScore]]];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[GameManager sharedInstance] startGame];
}

@end
