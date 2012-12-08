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
    @private
    bool _scoreOnScreen;
}

HDStartLayer* _sharedHDStartLayer;

- (id)init
{
    self = [super init];
    if (self) {
        _scoreOnScreen = NO;
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite* startSprite = [CCSprite spriteWithFile:@"start.png"];
        CCSprite* startSpriteSelected = [CCSprite spriteWithFile:@"start-sel.png"];
        
        CCMenuItemSprite * startButton = [CCMenuItemSprite itemWithNormalSprite:startSprite selectedSprite:startSpriteSelected target:self selector:@selector(handleStart)];
        
        CCSprite* banner = [CCSprite spriteWithFile:@"start_banner.png"];
        banner.position = ccp(size.width/2, (size.height - HELP_TOP_OFFSET)/2 + HELP_TOP_OFFSET);
        [self addChild:banner z:OBJECTS_Z];
        
        CCSprite* settingsBorderSprite = [CCSprite spriteWithFile:@"border.png"];
        settingsBorderSprite.anchorPoint = ccp(0, 0);
        settingsBorderSprite.position = ccp(0, HELP_SCREEN_Y_POINTS);
        
        [self addChild:settingsBorderSprite z:OBJECTS_Z tag:kSettingsBorderTag];
        
		CCMenu *menu = [CCMenu menuWithItems:startButton, nil];
        
		[menu alignItemsHorizontallyWithPadding:20];
        
        _sharedHDStartLayer = self;
        
		menu.position =  ccp(size.width/2, HELP_SCREEN_Y_POINTS + 185);
        
        CCSprite * questionButtonSprite = [CCSprite spriteWithFile:@"question_button.png"];
        CCSprite * questionButtonSelectedSprite = [CCSprite spriteWithFile:@"question_button_sel.png"];
        
        CCMenuItemSprite* questionButton = [CCMenuItemSprite itemWithNormalSprite:questionButtonSprite selectedSprite:questionButtonSelectedSprite target:self selector:@selector(handleHelpButtonPress)];
        
        CCSprite * settingsButtonSprite = [CCSprite spriteWithFile:@"gear_button.png"];
        CCSprite * settingsButtonSelectedSprite = [CCSprite spriteWithFile:@"gear_button_sel.png"];
        
        CCMenuItemSprite* settingsButton = [CCMenuItemSprite itemWithNormalSprite:settingsButtonSprite selectedSprite:settingsButtonSelectedSprite target:self selector:@selector(handleSettingsButtonPress)];
        settingsButton.position = ccp(80, 0);
        
        CCSprite * leaderBoardSprite = [CCSprite spriteWithFile:@"leader_board.png"];
        CCSprite * leaderBoardSelectedSprite = [CCSprite spriteWithFile:@"leader_board_sel.png"];
        
        CCMenuItemSprite* leaderBoardButton = [CCMenuItemSprite itemWithNormalSprite:leaderBoardSprite selectedSprite:leaderBoardSelectedSprite target:self selector:@selector(handleLeaderboardButtonPress)];
        leaderBoardButton.position = ccp(160, 0);
        
        CCSprite * creditsSprite = [CCSprite spriteWithFile:@"credits.png"];
        CCSprite * creditsSelectedSprite = [CCSprite spriteWithFile:@"credits_sel.png"];
        
        CCMenuItemSprite* aboutButton = [CCMenuItemSprite itemWithNormalSprite:creditsSprite selectedSprite:creditsSelectedSprite target:self selector:@selector(handleAboutButtonPress)];
        aboutButton.position = ccp(240, 0);
        
        CCMenu* optionsMenu = [CCMenu menuWithItems:questionButton, settingsButton,leaderBoardButton, aboutButton, nil];
        optionsMenu.position = ccp(40, 30);
        
        [self addChild:[BackgroundLayer node] z:BACKGROUND_Z];
		[self addChild: menu z:OBJECTS_Z];
        [self addChild:optionsMenu z:OBJECTS_Z tag:3];
        
        CCSprite* buttonBack = [CCSprite spriteWithFile:@"button-back.png"];
        buttonBack.position = ccp(size.width/2, 25);
        [self addChild: buttonBack z:BACKGROUND_Z+1];
        
        isTouchEnabled_ = NO;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    return self;
    
}

-(void) handleSettingsButtonPress  {
    [[CCDirector sharedDirector] pushScene:[HDSettingsLayer node]];
}

-(void) handleHelpButtonPress {
    [[CCDirector sharedDirector] pushScene:[HelpLayer node]];
}

-(void) handleLeaderboardButtonPress {
    [[CCDirector sharedDirector] pushScene:[LeaderBoardLayer node]];
}

-(void) handleAboutButtonPress {
    [[CCDirector sharedDirector] pushScene:[AboutLayer node]];
}

-(void) handleStart {
    [[GameManager sharedInstance] startGame];
}

+(HDStartLayer*) sharedInstance {
    return _sharedHDStartLayer;
}

-(void) refreshDisplayWith:(bool)finishedGameFlag {

    if(_scoreOnScreen) {
        [self removeChildByTag:kLastScore1Tag cleanup:YES];
        [self removeChildByTag:kLastScore2Tag cleanup:YES];
    }
    if(finishedGameFlag){

        _scoreOnScreen = YES;
        CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:@"Last Game:" fntFile:@"hdfont-full-small.fnt"];
        [scoreLabel setString:[NSString stringWithFormat:@"Last Game:"]];
        NSString* score = [NSString stringWithFormat:@"%i", [[GameManager sharedInstance] getScore]];
        CCLabelBMFont* scoreText = [CCLabelBMFont labelWithString:score fntFile:@"hdfont-full-small.fnt"];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        scoreLabel.position = ccp(size.width/2, HELP_SCREEN_Y_POINTS + 280);
        scoreText.position = ccp(size.width/2, HELP_SCREEN_Y_POINTS + 255);
        
        [self addChild:scoreLabel z:OBJECTS_Z tag:kLastScore1Tag];
        [self addChild:scoreText z:OBJECTS_Z tag:kLastScore2Tag];
    }

}



@end
