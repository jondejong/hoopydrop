//
//  HDSettingsLayer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/19/12.
//
//

#import "HoopyDrop.h"

@implementation HDSettingsLayer

- (id)init
{
    self = [super init];
    if (self) {
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCMenuItemFont* resetHighScoreMenuItem = [CCMenuItemFont itemWithString:@"Reset High Score" target:self selector:@selector(handleHighScoreReset)];
        CCMenuItemFont* goBackMenuItem = [CCMenuItemFont itemWithString:@"Go Back" target:self selector:@selector(handleGoBack)];
        [resetHighScoreMenuItem setFontSize:20];
        [resetHighScoreMenuItem setFontName:@"Marker Felt"];
        
        [goBackMenuItem setFontSize:20];
        [goBackMenuItem setFontName:@"Marker Felt"];
        
        CCMenu* resetMenu = [CCMenu menuWithItems:resetHighScoreMenuItem, goBackMenuItem, nil];
        resetMenu.position = ccp(size.width/2, size.height/2);
        
        [resetMenu alignItemsVerticallyWithPadding:15];
        
        [self addChild:[BackgroundLayer node] z:BACKGROUND_Z];
        [self addChild:resetMenu z:OBJECTS_Z];
        
    }
    return self;
}

-(void) handleGoBack {
    [[CCDirector sharedDirector] popScene];
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
