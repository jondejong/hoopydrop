//
//  AboutLayer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/21/12.
//
//

#import "HoopyDrop.h"

@implementation AboutLayer

- (id)init
{
    self = [super init];
    if (self) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite* banner = [CCSprite spriteWithFile:@"about_banner.png"];
        banner.position = ccp(size.width/2, (size.height - HELP_TOP_OFFSET)/2 + HELP_TOP_OFFSET);
        [self addChild:banner z:OBJECTS_Z];
        
        CCSprite* info = [CCSprite spriteWithFile:@"about_page.png"];
        info.anchorPoint = ccp(0,0);
        info.position = ccp(0, HELP_SCREEN_Y_POINTS);
        [self addChild:info z:OBJECTS_Z];
        
        CCMenuItemFont* goBackMenuItem = [CCMenuItemFont itemWithString:@"Go Home" target:self selector:@selector(handleGoBack)];
        
        [goBackMenuItem setFontSize:20];
        [goBackMenuItem setFontName:@"Marker Felt"];
        
        CCMenu* resetMenu = [CCMenu menuWithItems:goBackMenuItem, nil];
        resetMenu.position = ccp(size.width/2, NAV_MENU_BOTTOM_OFFSET);
        [self addChild:resetMenu z:OBJECTS_Z];
        
        [self addChild:[BackgroundLayer node] z:BACKGROUND_Z];
        
    }
    return self;
}

-(void) handleGoBack {
    [[CCDirector sharedDirector] popScene];
}

@end
