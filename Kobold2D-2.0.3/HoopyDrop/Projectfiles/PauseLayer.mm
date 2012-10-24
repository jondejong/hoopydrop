//
//  PauseLayer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/12/12.
//
//

#import "HoopyDrop.h"
#import "HDUtil.h"
#import "KKInput.h"
#import "KKInputTouch.h"

@implementation PauseLayer {
@private
    bool _paused;
    CCSprite* _faderOverlay;
    CCMenu* _menu;
    CCLabelTTF* _pausedText;
    bool _bombButtonAdded;
}

- (id)init
{
    self = [super init];
    if (self) {
        _paused = false;
        _faderOverlay = [CCSprite spriteWithFile:[ScreenImage convertImageName:@"faderOverlay"]];
        _faderOverlay.position = ccp(0,0);
        _faderOverlay.anchorPoint = ccp(0,0);
        
        _pausedText = [CCLabelTTF labelWithString:@"Paused" fontName:@"Marker Felt" fontSize:48];
        CGSize size = [[CCDirector sharedDirector] winSize];
        _pausedText.position = ccp(size.width/2.0, size.height/1.2);
        
        CCSprite* abandonSprite = [CCSprite spriteWithFile:@"abandon.png"];
        CCSprite* abandonSpriteSelected = [CCSprite spriteWithFile:@"abandon.png"];
        
        CCMenuItemSprite * startButton = [CCMenuItemSprite itemWithNormalSprite:abandonSprite selectedSprite:abandonSpriteSelected target:self selector:@selector(handleEnd)];
        
        _menu = [CCMenu menuWithItems:startButton, nil];
        _menu.position = ccp(size.width/2.0, size.height/2.0);
        
        _bombButtonAdded = NO;
        
        [self setIsTouchEnabled:YES];
        
        [self scheduleUpdate];
    }
    return self;
}

-(void) handleEnd {
    [[GameManager sharedInstance] handleAbandon];
}

-(void) handlePause {
    _paused = YES;
    [self addChild: _faderOverlay];
    [self addChild: _pausedText];
    [self addChild: _menu];
    [[GameManager sharedInstance] handlePause];
}

-(void) handleUnpase {
    _paused = NO;
    [self removeChild:_faderOverlay cleanup:YES];
    [self removeChild:_pausedText cleanup:YES];
    [self removeChild:_menu cleanup:YES];
    [[GameManager sharedInstance] handleUnpause];
}

-(void) removeTouchResponse {
    [self setIsTouchEnabled: NO];
}

-(void) addBombButton;
{
    _bombButtonAdded = YES;
}

-(void) removeBombButton
{
    _bombButtonAdded = NO;
}

-(void) update:(ccTime)delta
{
    if([self isTouchEnabled]) {
        
        bool bombButtonPressed = NO;
        if(!_paused){
            if(_bombButtonAdded) {
                // Check to see if the button was pressed
                KKInput* input = [KKInput sharedInput];
                if ([input isAnyTouchOnNode:[[GameManager sharedInstance]bombButtonNode] touchPhase:KKTouchPhaseEnded])
                {
                    [[GameManager sharedInstance] explodeBomb];
                    bombButtonPressed = YES;
                }
            }
        }
        
        if(!bombButtonPressed && [TouchUtil wasIntentiallyTouched]) {
            if(_paused) {
                [self handleUnpase];
                
            } else {
                [self handlePause];
            }
        }
    }
}



@end
