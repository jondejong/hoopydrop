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
        
        
        CCMenuItemFont* goBackMenuItem = [CCMenuItemFont itemWithString:@"GB" target:self selector:@selector(handleGoBack)];
        
        [goBackMenuItem setFontSize:20];
        [goBackMenuItem setFontName:@"Marker Felt"];
        
        CCMenu* resetMenu = [CCMenu menuWithItems:goBackMenuItem, nil];
        
        
//        [resetMenu alignItemsVerticallyWithPadding:15];
        
        CCSpriteBatchNode* sepBar = [CCSpriteBatchNode batchNodeWithFile:@"score_sep.png" capacity:11];
        [self addChild:sepBar z:OBJECTS_Z];
        
        CCSpriteBatchNode* backBar = [CCSpriteBatchNode batchNodeWithFile:@"score-back.png" capacity:10];
        [self addChild:backBar z:OBJECTS_Z];
        
        float nextY = 0;
        
        CCSprite* barSprite = [CCSprite spriteWithTexture:[sepBar texture]];
        barSprite.position = CGPointMake(0, nextY);
        barSprite.anchorPoint = CGPointMake(0, 0);
        [sepBar addChild:barSprite z:OBJECTS_Z];
        nextY += 5;
        
        for(int i=0; i<10; i++) {
            CCSprite* barSprite = [CCSprite spriteWithTexture:[sepBar texture]];
            CCSprite* backBarSprite = [CCSprite spriteWithTexture:[backBar  texture]];
            backBarSprite.position = CGPointMake(0, nextY);
            backBarSprite.anchorPoint = CGPointMake(0, 0);
            nextY += 35;
            barSprite.position = CGPointMake(0, nextY);
            barSprite.anchorPoint = CGPointMake(0, 0);
            [sepBar addChild:barSprite z:OBJECTS_Z];
            [backBar addChild:backBarSprite z:OBJECTS_Z];
            nextY += 5;
        }
        
        resetMenu.position = ccp(12, (size.height - nextY)/2 + nextY);
        screenLabel.position = ccp(size.width/2, (size.height - nextY)/2 + nextY);
        
        [self addChild:[BackgroundLayer node] z:BACKGROUND_Z];
        [self addChild:resetMenu z:OBJECTS_Z];
        [self addChild:screenLabel z:OBJECTS_Z];
        
        int count = 1;
        nextY -= 25;
        for(NSNumber* score in [[GameManager sharedInstance] highScores]) {
            NSString* scoreString = [NSString stringWithFormat:@"%i: %i", count, [score integerValue]];
            CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:scoreString fontName:@"Marker Felt" fontSize:24];
            scoreLabel.position = ccp(size.width/2, nextY);
            nextY-=40;
            count++;
            [self addChild:scoreLabel z:OVERLAY_TEXT_Z];
            
        }
        
    }
    return self;
}

-(void) handleGoBack {
    [[CCDirector sharedDirector] popScene];
}

@end
