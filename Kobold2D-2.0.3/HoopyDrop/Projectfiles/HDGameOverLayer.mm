//
//  HDGameOverLayer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 10/3/12.
//
//

#import "HoopyDrop.h"
#import "HDUtil.h"

@implementation HDGameOverLayer {
    @private
    int _loopCount;
    float _lastLoopTime;
    bool _scorePlaced;
    bool _scoresInPlace;
    bool _freeTextPlaced;
    GLubyte _opacity;
}

@synthesize overlayTransitionSprite, scoreLabelText, scoreText;

- (id)init
{
    self = [super init];
    if (self) {
        _loopCount = 0;
        _scorePlaced = false;
        _scoresInPlace = false;
        
        _freeTextPlaced = YES;
        
#if !HD_PAID_VERSION
        [[KKAdBanner sharedAdBanner] updateBannerPosition:KKAdBannerOnBottom];
        [[KKAdBanner sharedAdBanner] loadBanner];
        _freeTextPlaced = NO;
#endif
        
        CCSpriteBatchNode* image = [CCSpriteBatchNode batchNodeWithFile:[ScreenImage convertImageName:@"game_over"] capacity:1];
        _opacity = OVERLAY_ALPHA_CHANNEL_INCREMENTS;
        [self addChild:image z:0 tag:kTagBatchNode];

    }
    return self;
}

-(void) startTransition
{
    _scoresInPlace = false;
    _lastLoopTime = CACurrentMediaTime();
    [self scheduleUpdate];
}

-(void) update: (ccTime) dt
{
    [self handleTouch];
    [self continueAnimation];
}

-(void) continueAnimation {
    float now = CACurrentMediaTime();
    if(now - _lastLoopTime >= .1){
        if(_loopCount == 0) {
            CCSpriteBatchNode* batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
            CCSprite * sprite = [CCSprite spriteWithTexture: [batch texture]];
            sprite.position = ccp(0,0);
            sprite.anchorPoint = ccp(0,0);
            [sprite setOpacity:_opacity];
            self.overlayTransitionSprite = sprite;
            [batch addChild:sprite z:OVERLAY_Z];
            
        } else if(_loopCount < OVERLAY_INTERVALS) {
            _opacity += OVERLAY_ALPHA_CHANNEL_INCREMENTS;
            [[self overlayTransitionSprite] setOpacity:_opacity];
            
        } else if(!_scorePlaced) {
            _scorePlaced = true;
            int score = [[GameManager sharedInstance] getScore];
            NSString* scoreString = [NSString stringWithFormat:@"%i", score];
            
            self.scoreLabelText = [CCLabelBMFont labelWithString:@"Score:" fntFile:@"hdfont-full-light.fnt" ];
            self.scoreText = [CCLabelBMFont labelWithString:scoreString fntFile:@"hdfont-full-light.fnt" ];
            
            CGSize screenSize = [CCDirector sharedDirector].winSize;
            scoreLabelText.position = ccp(screenSize.width/2, screenSize.height + 60);
            scoreText.position = ccp(screenSize.width/2, screenSize.height + 60 - SCORE_LINESPACING);
            [self addChild:scoreLabelText z:OVERLAY_TEXT_Z];
            [self addChild:scoreText z:OVERLAY_TEXT_Z];
            
            CGPoint labelEndPoint = ccp(screenSize.width/2, screenSize.height/2);
            CGPoint scoreEndPoint = ccp(screenSize.width/2, (screenSize.height/2) - SCORE_LINESPACING);
            
            CCFiniteTimeAction* moveLabelAction = [CCMoveTo actionWithDuration: SCORE_DROP_SECONDS position: labelEndPoint];
            CCFiniteTimeAction* moveScoreAction = [CCMoveTo actionWithDuration: SCORE_DROP_SECONDS position: scoreEndPoint];
            
            CCCallFunc* doneHandler = [CCCallFunc actionWithTarget:self selector:@selector(handleScoresDoneMoving)];
            
            [scoreLabelText runAction:[CCSequence actions:moveLabelAction, doneHandler, nil]];
            [scoreText runAction:[CCSequence actions:moveScoreAction, nil]];
            
            [self addScorePosition];
            
        } else if(!_freeTextPlaced) {
            _freeTextPlaced = YES;
            CCLabelTTF * buyMe1 = [CCLabelTTF labelWithString:@"Tap through this screen on the full version..." fontName:@"Optima" fontSize:14];
            CCLabelTTF * buyMe2 = [CCLabelTTF labelWithString:@"Buy Hoopy Drop on the App Store!." fontName:@"Optima" fontSize:14];
             CGSize screenSize = [CCDirector sharedDirector].winSize;
            buyMe1.position = ccp(screenSize.width/2, screenSize.height - 25);
            buyMe2.position = ccp(screenSize.width/2, screenSize.height - 40);
            
            [self addChild:buyMe1 z:OVERLAY_TEXT_Z];
            [self addChild:buyMe2 z:OVERLAY_TEXT_Z];
        }
        if(_loopCount >= TOTAL_LOOPCOUNT ) {
            [self pauseSchedulerAndActions];
            [[GameManager sharedInstance] returnToMenu];
        }
        _lastLoopTime = now;
        _loopCount++;
    }
    
}

-(void) addScorePosition {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    int scorePos = [[GameManager sharedInstance] scorePosition];
    if(scorePos > 0) {
        NSString* pos = [NSString stringWithFormat:@"#%i", scorePos];
        CCLabelBMFont* scorePositionText = [CCLabelBMFont labelWithString:pos fntFile:@"hdfont-full-light.fnt" ];
        scorePositionText.position = CGPointMake(screenSize.width/2, screenSize.height/2 - 2* SCORE_LINESPACING);
        
        CCLabelBMFont* scorePositionDescriptionText = [CCLabelBMFont labelWithString:@"All Time" fntFile:@"hdfont-full-small.fnt"];
        CCLabelBMFont* scorePositionDescriptionTextLine2 = [CCLabelBMFont labelWithString:@"High Score!" fntFile:@"hdfont-full-small.fnt"];
        scorePositionDescriptionText.position = CGPointMake(screenSize.width/2, screenSize.height/2 - 3* SCORE_LINESPACING);
        scorePositionDescriptionTextLine2.position = CGPointMake(screenSize.width/2, screenSize.height/2 - 4* SCORE_LINESPACING);
        
        [self addChild:scorePositionText z:OVERLAY_TEXT_Z];
        [self addChild:scorePositionDescriptionText z:OVERLAY_TEXT_Z];
        [self addChild:scorePositionDescriptionTextLine2 z:OVERLAY_TEXT_Z];
    }
}

-(void) handleScoresDoneMoving {
    _scoresInPlace = true;
}

-(void) handleTouch {
#if HD_PAID_VERSION
    if([TouchUtil wasIntentiallyTouched]) {
        if(_scoresInPlace) {
            CCLOG(@"Telling the game over screen to end");
            _loopCount = TOTAL_LOOPCOUNT;
        } else if(_scorePlaced) {
            CCLOG(@"Removing scores and re-adding them in the finished spot.");
            // Background is fine, place scores at the end.
            [self removeChild:scoreLabelText cleanup:YES];
            [self removeChild:scoreText cleanup:YES];
            [self placeScoresAtFinish];
            _loopCount = OVERLAY_INTERVALS;

        } else {
            CCLOG(@"Removing the background and putting everything on the screen.");
            // Finish the background and place the scores at the end
            [self removeChild:overlayTransitionSprite cleanup:YES];
            CCSpriteBatchNode* batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
            CCSprite * sprite = [CCSprite spriteWithTexture: [batch texture]];
            sprite.position = ccp(0,0);
            sprite.anchorPoint = ccp(0,0);
            
            _opacity = (OVERLAY_ALPHA_CHANNEL_INCREMENTS * OVERLAY_INTERVALS + 1);
            
            [sprite setOpacity:_opacity];
            self.overlayTransitionSprite = sprite;
            [batch addChild:sprite z:OVERLAY_Z];
            [self placeScoresAtFinish];
            [self addScorePosition];
            _scorePlaced = true;
            _loopCount = OVERLAY_INTERVALS;
        }
    }
#endif
}

-(void) placeScoresAtFinish{
    
    int score = [[GameManager sharedInstance] getScore];
    NSString* scoreString = [NSString stringWithFormat:@"%i", score];
    
    self.scoreLabelText = [CCLabelBMFont labelWithString:@"Score:" fntFile:@"hdfont-full-light.fnt" ];
    self.scoreText = [CCLabelBMFont labelWithString:scoreString fntFile:@"hdfont-full-light.fnt" ];
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    scoreLabelText.position = ccp(screenSize.width/2, screenSize.height/2);
    scoreText.position = ccp(screenSize.width/2, (screenSize.height/2) - SCORE_LINESPACING);
    
    [self addChild:scoreLabelText z:OVERLAY_TEXT_Z];
    [self addChild:scoreText z:OVERLAY_TEXT_Z];
    _scoresInPlace = true;
}

@end
