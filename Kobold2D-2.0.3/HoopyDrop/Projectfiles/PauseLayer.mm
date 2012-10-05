//
//  PauseLayer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/12/12.
//
//

#import "HoopyDrop.h"
#import "HDUtil.h"

@implementation PauseLayer {
    @private
    bool paused;
    CCSprite* faderOverlay;
    CCMenu* menu;
    CCLabelTTF *pausedText;
}

- (id)init
{
    self = [super init];
    if (self) {
        paused = false;
        faderOverlay = [CCSprite spriteWithFile:[ScreenImage convertImageName:@"faderOverlay"]];
        faderOverlay.position = ccp(0,0);
        faderOverlay.anchorPoint = ccp(0,0);
        
        pausedText = [CCLabelTTF labelWithString:@"Paused" fontName:@"Marker Felt" fontSize:48];
        CGSize size = [[CCDirector sharedDirector] winSize];
        pausedText.position = ccp(size.width/2.0, size.height/1.2);
        
        CCSprite* abandonSprite = [CCSprite spriteWithFile:@"abandon.png"];
        CCSprite* abandonSpriteSelected = [CCSprite spriteWithFile:@"abandon.png"];
        
        CCMenuItemSprite * startButton = [CCMenuItemSprite itemWithNormalSprite:abandonSprite selectedSprite:abandonSpriteSelected target:self selector:@selector(handleEnd)];
        
        menu = [CCMenu menuWithItems:startButton, nil];
        menu.position = ccp(size.width/2.0, size.height/2.0);
        
        [self setIsTouchEnabled:YES];
        
        [self scheduleUpdate];
    }
    return self;
}

-(void) handleEnd {
    [[GameManager sharedInstance] handleAbandon];
}

-(void) handlePause {
    [self addChild:faderOverlay];
    [self addChild: pausedText];
    [self addChild: menu];
    [[GameManager sharedInstance] handlePause];
}

-(void) handleUnpase {
    paused = false;
    [self removeChild:faderOverlay cleanup:YES];
    [self removeChild:pausedText cleanup:YES];
    [self removeChild:menu cleanup:NO
     ];
    [[GameManager sharedInstance] handleUnpause];
}

-(void) removeTouchResponse {
    [self setIsTouchEnabled: NO];
}

-(void) update:(ccTime)delta
{
 
    if([self isTouchEnabled]) {
        KKInput* input = [KKInput sharedInput];
        if (input.anyTouchEndedThisFrame)
        {
            if(paused) {
                [self handleUnpase];
                
            } else {
                paused = true;
                [self handlePause];
            }
        }
    }
    
}

@end
