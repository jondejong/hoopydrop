//
//  LeaderBoardLayer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/21/12.
//
//

#import "HoopyDrop.h"

@implementation LeaderBoardLayer

- (id)init
{
    self = [super init];
    if (self) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF *screenLabel = [CCLabelTTF labelWithString:@"High Scores:" fontName:@"Marker Felt" fontSize:24];
        screenLabel.position = ccp(size.width/2, size.height - 50);
        
        CCMenuItemFont* goBackMenuItem = [CCMenuItemFont itemWithString:@"Go Back" target:self selector:@selector(handleGoBack)];
        
        [goBackMenuItem setFontSize:20];
        [goBackMenuItem setFontName:@"Marker Felt"];
        
        CCMenu* resetMenu = [CCMenu menuWithItems:goBackMenuItem, nil];
        resetMenu.position = ccp(size.width/2, 50);
        
        [resetMenu alignItemsVerticallyWithPadding:15];
        
        [self addChild:[BackgroundLayer node] z:BACKGROUND_Z];
        [self addChild:resetMenu z:OBJECTS_Z];
        [self addChild:screenLabel z:OBJECTS_Z];
        
    }
    return self;
}

-(void) handleGoBack {
    [[CCDirector sharedDirector] popScene];
}

@end
