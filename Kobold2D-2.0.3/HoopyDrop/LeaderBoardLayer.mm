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
        
        CCSprite* banner = [CCSprite spriteWithFile:@"high_scores_banner.png"];
        banner.position = ccp(size.width/2, (size.height - HELP_TOP_OFFSET)/2 + HELP_TOP_OFFSET);
        [self addChild:banner z:OBJECTS_Z];
        
        CCMenuItemFont* goBackMenuItem = [CCMenuItemFont itemWithString:@"Go Home" target:self selector:@selector(handleGoBack)];
        
        [goBackMenuItem setFontSize:20];
        [goBackMenuItem setFontName:@"Marker Felt"];
        
        CCMenu* resetMenu = [CCMenu menuWithItems:goBackMenuItem, nil];
        resetMenu.position = ccp(size.width/2, NAV_MENU_BOTTOM_OFFSET);
        [self addChild:resetMenu z:OBJECTS_Z];

        CCSpriteBatchNode* sepBar = [CCSpriteBatchNode batchNodeWithFile:@"score_sep.png" capacity:11];
        [self addChild:sepBar z:OBJECTS_Z];
        
        CCSpriteBatchNode* backBar = [CCSpriteBatchNode batchNodeWithFile:@"score-back.png" capacity:10];
        [self addChild:backBar z:OBJECTS_Z];
        
        float nextY = size.height/2 + 180;
        
        // Add side walls
        CCSpriteBatchNode* wallBatch = [CCSpriteBatchNode batchNodeWithFile:@"score_wall.png" capacity:2];
        [self addChild:wallBatch z:OBJECTS_Z];

        CCSprite * leftWall = [CCSprite spriteWithTexture:[wallBatch texture]];
        CCSprite * rightWall = [CCSprite spriteWithTexture:[wallBatch texture]];
        
        leftWall.position = ccp(size.width/2 - 130, nextY);
        leftWall.anchorPoint = ccp(1, 1);
        
        rightWall.position = ccp(size.width/2 + 130, nextY);
        rightWall.anchorPoint = ccp(0, 1);
        
        [wallBatch addChild:leftWall];
        [wallBatch addChild:rightWall];
        
        nextY -= 5;
        
        CCSprite* barSprite = [CCSprite spriteWithTexture:[sepBar texture]];
        barSprite.position = CGPointMake(size.width/2, nextY);
        
        barSprite.anchorPoint = CGPointMake(.5, 0);
        [sepBar addChild:barSprite z:OBJECTS_Z];
        nextY -= 30;
        
        for(int i=0; i<10; i++) {
            CCSprite* barSprite = [CCSprite spriteWithTexture:[sepBar texture]];
            CCSprite* backBarSprite = [CCSprite spriteWithTexture:[backBar  texture]];
            backBarSprite.position = CGPointMake(size.width/2, nextY);
            backBarSprite.anchorPoint = CGPointMake(.5, 0);
            nextY -= 5;
            barSprite.position = CGPointMake(size.width/2, nextY);
            barSprite.anchorPoint = CGPointMake(.5, 0);
            [sepBar addChild:barSprite z:OBJECTS_Z];
            [backBar addChild:backBarSprite z:OBJECTS_Z];
            nextY -= 30;
        }
        
        
        [self addChild:[BackgroundLayer node] z:BACKGROUND_Z];

        
        int count = 1;
        nextY = size.height/2 + 155;
        for(NSNumber* score in [[GameManager sharedInstance] highScores]) {
            NSString* scoreString = [NSString stringWithFormat:@"%i", [score integerValue]];
            CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:scoreString fntFile:@"hdfont-full-small.fnt"];
            
            [scoreLabel setAlignment:kCCTextAlignmentRight];
            scoreLabel.position = ccp(size.width/2 + 125, nextY);
            scoreLabel.anchorPoint = ccp(1, 0);
            
            NSString* numberString = [NSString stringWithFormat:@"%i:", count];
            CCLabelBMFont *numberLabel = [CCLabelBMFont labelWithString:numberString fntFile:@"hdfont-full-small.fnt"];

//            [numberLabel setAlignment:kCCTextAlignmentRight];
            numberLabel.position = ccp(size.width/1.8 - 125, nextY);
            numberLabel.anchorPoint = ccp(0, 0);
            
            nextY-=35;
            count++;
            [self addChild:scoreLabel z:OVERLAY_TEXT_Z];
            [self addChild:numberLabel z:OVERLAY_TEXT_Z];
        }
        
    }
    return self;
}

-(void) handleGoBack {
    [[CCDirector sharedDirector] popScene];
}

@end
