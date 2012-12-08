//
//  HDSettingsLayer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/19/12.
//
//

#import "HoopyDrop.h"

@implementation HDSettingsLayer
{
    @private
    CCMenuItemFont* _goBackMenuItem;
    CCMenuItemFont* _resetHighScoreMenuItem;
}

@synthesize soundsOffMenuItem, soundsOnMenuItem, resetMenu, goHomeMenu;

- (id)init
{
    self = [super init];
    if (self) {
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite* banner = [CCSprite spriteWithFile:@"settings_banner.png"];
        banner.position = ccp(size.width/2, (size.height - HELP_TOP_OFFSET)/2 + HELP_TOP_OFFSET);
        [self addChild:banner z:OBJECTS_Z];
        
        CCSprite* settingsBorderSprite = [CCSprite spriteWithFile:@"border.png"];
        settingsBorderSprite.anchorPoint = ccp(0, 0);
        settingsBorderSprite.position = ccp(0, HELP_SCREEN_Y_POINTS);
        
        [self addChild:[BackgroundLayer node] z:BACKGROUND_Z];
        [self addChild:settingsBorderSprite z:OBJECTS_Z tag:kSettingsBorderTag];
                
        [self createMenu];

    }
    return self;
}

-(void) createMenu
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    _resetHighScoreMenuItem = [CCMenuItemFont itemWithString:@"Reset High Scores" target:self selector:@selector(handleHighScoreReset)];
    self.soundsOnMenuItem = [CCMenuItemFont itemWithString:@"Turn Sounds On" target: self selector:@selector(toggleSounds)];
    self.soundsOffMenuItem = [CCMenuItemFont itemWithString:@"Turn Sounds Off" target: self selector:@selector(toggleSounds)];
    
    [soundsOnMenuItem setFontSize:20];
    [soundsOnMenuItem setFontName:@"Marker Felt"];
    
    [soundsOffMenuItem setFontSize:20];
    [soundsOffMenuItem setFontName:@"Marker Felt"];
    
    [_resetHighScoreMenuItem setFontSize:20];
    [_resetHighScoreMenuItem setFontName:@"Marker Felt"];

    CCMenuItem* soundItem = [[GameManager sharedInstance] isSoundOn] ? soundsOffMenuItem : soundsOnMenuItem;
    self.resetMenu = [CCMenu menuWithItems:soundItem, _resetHighScoreMenuItem, nil];
    
    resetMenu.position = ccp(size.width/2, HELP_SCREEN_Y_POINTS + 160);
    
    [resetMenu alignItemsVerticallyWithPadding:15];
    [self addChild:resetMenu z:OBJECTS_Z];
    
    _goBackMenuItem = [CCMenuItemFont itemWithString:@"Go Home" target:self selector:@selector(handleGoBack)];
    
    [_goBackMenuItem setFontSize:20];
    [_goBackMenuItem setFontName:@"Marker Felt"];
    
    self.goHomeMenu = [CCMenu menuWithItems:_goBackMenuItem, nil];
    goHomeMenu.position = ccp(size.width/2, NAV_MENU_BOTTOM_OFFSET);
    [self addChild:goHomeMenu z:OBJECTS_Z];
    
}

-(void) toggleSounds
{
    [[GameManager sharedInstance] toggleSounds];
    [self removeChild:resetMenu cleanup:YES];
    [self createMenu];
    
}

-(void) handleGoBack
{
    [[CCDirector sharedDirector] popScene];
}

-(void)handleHighScoreReset
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                    message:@"This will set your all time high score back to ZERO!!"
                                                   delegate:self
                                          cancelButtonTitle:@"NO!"
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"OK"])
    {
        [[GameManager sharedInstance]resetAllTimeHighScores];
    }
}

@end
