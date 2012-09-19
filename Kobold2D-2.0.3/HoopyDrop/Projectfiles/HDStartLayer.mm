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
        
        CCSprite * questionButtonSprite = [CCSprite spriteWithFile:@"question_button.png"];
        CCSprite * questionButtonSelectedSprite = [CCSprite spriteWithFile:@"question_button_sel.png"];
        
        CCMenuItemSprite* questionButton = [CCMenuItemSprite itemWithNormalSprite:questionButtonSprite selectedSprite:questionButtonSelectedSprite target:self selector:@selector(handleHelpButtonPress)];
        
        CCSprite * settingsButtonSprite = [CCSprite spriteWithFile:@"gear_button.png"];
        CCSprite * settingsButtonSelectedSprite = [CCSprite spriteWithFile:@"gear_button_sel.png"];
        
        CCMenuItemSprite* settingsButton = [CCMenuItemSprite itemWithNormalSprite:settingsButtonSprite selectedSprite:settingsButtonSelectedSprite target:self selector:@selector(handleSettingsButtonPress)];
        settingsButton.position = ccp(80, 0);
        
        CCSprite * leaderBoardSprite = [CCSprite spriteWithFile:@"leader_board.png"];
        CCSprite * leaderBoardSelectedSprite = [CCSprite spriteWithFile:@"leader_board_sel.png"];
        
        CCMenuItemSprite* leaderBoardButton = [CCMenuItemSprite itemWithNormalSprite:leaderBoardSprite selectedSprite:leaderBoardSelectedSprite target:self selector:@selector(handleButtonPress)];
        leaderBoardButton.position = ccp(160, 0);
        
        CCSprite * creditsSprite = [CCSprite spriteWithFile:@"credits.png"];
        CCSprite * creditsSelectedSprite = [CCSprite spriteWithFile:@"credits_sel.png"];
        
        CCMenuItemSprite* aboutButton = [CCMenuItemSprite itemWithNormalSprite:creditsSprite selectedSprite:creditsSelectedSprite target:self selector:@selector(handleButtonPress)];
        aboutButton.position = ccp(240, 0);
        
        CCMenu* optionsMenu = [CCMenu menuWithItems:questionButton, settingsButton,leaderBoardButton, aboutButton, nil];
        optionsMenu.position = ccp(40, 40);
        
        [self addChild:[BackgroundLayer node] z:BACKGROUND_Z];
        [self addChild:scoreLabel z:OBJECTS_Z tag:1];
		[self addChild: menu z:OBJECTS_Z];
        [self addChild:highScoreLabel z:OBJECTS_Z tag:2];
//        [self addChild:resetMenu z:OBJECTS_Z tag:3];
        [self addChild:optionsMenu z:OBJECTS_Z tag:3];
        isTouchEnabled_ = NO;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    return self;
    
}

-(void) handleSettingsButtonPress  {
    [[CCDirector sharedDirector] pushScene:[HDSettingsLayer node]];
}

-(void) handleHelpButtonPress {
    [[CCDirector sharedDirector]pushScene:[HelpLayer node]];
}

-(void) handleButtonPress {
    CCLOG(@"BAZINGA!");
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



@end
