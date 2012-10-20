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

@synthesize soundsOffMenuItem, soundsOnMenuItem, resetMenu;

- (id)init
{
    self = [super init];
    if (self) {
        
        [self addChild:[BackgroundLayer node] z:BACKGROUND_Z];
        
        [self createMenu];
    }
    return self;
}

-(void) createMenu
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    _resetHighScoreMenuItem = [CCMenuItemFont itemWithString:@"Reset High Scores" target:self selector:@selector(handleHighScoreReset)];
    _goBackMenuItem = [CCMenuItemFont itemWithString:@"Go Back" target:self selector:@selector(handleGoBack)];
    self.soundsOnMenuItem = [CCMenuItemFont itemWithString:@"Turn Sounds On" target: self selector:@selector(toggleSounds)];
    self.soundsOffMenuItem = [CCMenuItemFont itemWithString:@"Turn Sounds Off" target: self selector:@selector(toggleSounds)];
    
    [soundsOnMenuItem setFontSize:20];
    [soundsOnMenuItem setFontName:@"Marker Felt"];
    
    [soundsOffMenuItem setFontSize:20];
    [soundsOffMenuItem setFontName:@"Marker Felt"];
    
    [_resetHighScoreMenuItem setFontSize:20];
    [_resetHighScoreMenuItem setFontName:@"Marker Felt"];
    
    [_goBackMenuItem setFontSize:20];
    [_goBackMenuItem setFontName:@"Marker Felt"];
    
    CCMenuItem* soundItem = [[GameManager sharedInstance] isSoundOn] ? soundsOffMenuItem : soundsOnMenuItem;
    self.resetMenu = [CCMenu menuWithItems:soundItem, _resetHighScoreMenuItem, _goBackMenuItem, nil];
    
    resetMenu.position = ccp(size.width/2, size.height/2);
    
    [resetMenu alignItemsVerticallyWithPadding:15];
    [self addChild:resetMenu z:OBJECTS_Z];
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
