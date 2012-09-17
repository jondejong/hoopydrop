//
//  HDStartLayer.m
//  HoopyDrop
//
//  This class really only exists to start shit
//  Created by Jon DeJong on 9/11/12.
//
//

#import "HoopyDrop.h"
#import "SneakyButton.h"

@implementation HDStartLayer {
    
}

HDStartLayer* _sharedHDStartLayer;

- (id)init
{
    self = [super init];
    if (self) {
        
        CCSprite* startSprite = [CCSprite spriteWithFile:@"start.png"];
        CCSprite* startSpriteSelected = [CCSprite spriteWithFile:@"start.png"];
        
        CCMenuItemSprite * startButton = [CCMenuItemSprite itemWithNormalSprite:startSprite selectedSprite:startSpriteSelected target:self selector:@selector(handleStart)];
        
		CCMenu *menu = [CCMenu menuWithItems:startButton, nil];
        
		[menu alignItemsHorizontallyWithPadding:20];
        
        _sharedHDStartLayer = self;
        
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
        

		CGSize size = [[CCDirector sharedDirector] winSize];
        
        scoreLabel.position = ccp(size.width/2, size.height/1.45);
		menu.position =  ccp(size.width/2, size.height/2);

        [self addChild:[BackgroundLayer node] z:BACKGROUND_Z];
        [self addChild:scoreLabel z:OBJECTS_Z tag:1];
		[self addChild: menu z:OBJECTS_Z];
        isTouchEnabled_ = NO;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    return self;
    
}

-(void) handleStart {
    [[GameManager sharedInstance] startGame];
}

+(HDStartLayer*) sharedInstance {
    return _sharedHDStartLayer;
}

-(void) refreshDisplay {
    CCLabelTTF *scoreLabel = (CCLabelTTF*)[self getChildByTag:1];
    [scoreLabel setString:[NSString stringWithFormat:@"Last Game Score: %i", [[GameManager sharedInstance]getScore]]];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [[GameManager sharedInstance] startGame];
}

@end
