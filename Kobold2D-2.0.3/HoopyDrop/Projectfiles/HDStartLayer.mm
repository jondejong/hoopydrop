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
        CCLabelTTF *highScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"All Time High Score: %i", [[GameManager sharedInstance] allTimeHighScore]] fontName:@"Marker Felt" fontSize:24];
        

		CGSize size = [[CCDirector sharedDirector] winSize];
        
        scoreLabel.position = ccp(size.width/2, size.height/1.20);
        highScoreLabel.position = ccp(size.width/2, size.height/1.1);
		menu.position =  ccp(size.width/2, size.height/2);
        
        CCMenuItemFont* resetHighScoreMenuItem = [CCMenuItemFont itemWithString:@"Reset High Score" target:self selector:@selector(handleHighScoreReset)];
        [resetHighScoreMenuItem setFontSize:20];
        [resetHighScoreMenuItem setFontName:@"Marker Felt"];
        
        CCMenu* resetMenu = [CCMenu menuWithItems:resetHighScoreMenuItem, nil];
        resetMenu.position = ccp(size.width/2, 50);
        
        [self addChild:[BackgroundLayer node] z:BACKGROUND_Z];
        [self addChild:scoreLabel z:OBJECTS_Z tag:1];
		[self addChild: menu z:OBJECTS_Z];
        [self addChild:highScoreLabel z:OBJECTS_Z tag:2];
        [self addChild:resetMenu z:OBJECTS_Z tag:3];
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

-(void) refreshDisplayWith:(bool)finishedGameFlag {
    CCLabelTTF *scoreLabel = (CCLabelTTF*)[self getChildByTag:1];
    CCLabelTTF *highScoreLabel = (CCLabelTTF*)[self getChildByTag:2];
    
    if(finishedGameFlag) {
        [scoreLabel setString:[NSString stringWithFormat:@"Last Game Score: %i", [[GameManager sharedInstance]getScore]]];
    } else {
        [scoreLabel setString:@""];
    }
    [highScoreLabel setString:[NSString stringWithFormat:@"All Time High Score: %i", [[GameManager sharedInstance] allTimeHighScore]]];
    
}

-(void)handleHighScoreReset {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                    message:@"This will set your all time high score back to ZERO!!"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:@"NO!", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"OK"])
    {
        [[GameManager sharedInstance]resetAllTimeHighScore];
    }
}

@end
