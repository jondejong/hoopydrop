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
    if(now - _lastLoopTime >= .1)
    {
        if(_loopCount == 0) {
            CCSpriteBatchNode* batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
            CCSprite * sprite = [CCSprite spriteWithTexture: [batch texture]];
            sprite.position = ccp(0,0);
            sprite.anchorPoint = ccp(0,0);
            [sprite setOpacity:_opacity];
            self.overlayTransitionSprite = sprite;
            [batch addChild:sprite z:OVERLAY_Z];
            
        } else if(_loopCount < OVERLAY_INTERVALS)
        {
            _opacity += OVERLAY_ALPHA_CHANNEL_INCREMENTS;
            [[self overlayTransitionSprite] setOpacity:_opacity];
            
        } else if(!_scorePlaced)
        {
            _scorePlaced = true;
            int score = [[GameManager sharedInstance] getScore];
            NSString* scoreString = [NSString stringWithFormat:@"%i", score];
            
            self.scoreLabelText = [CCLabelBMFont labelWithString:@"Score:" fntFile:@"hdfont-full.fnt" ];
            self.scoreText = [CCLabelBMFont labelWithString:scoreString fntFile:@"hdfont-full.fnt" ];
            
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
            
        }
        if(_loopCount >= TOTAL_LOOPCOUNT )
        {
            [self pauseSchedulerAndActions];
            [[GameManager sharedInstance] returnToMenu];
        }
        _lastLoopTime = now;
        _loopCount++;
    }
    
}

-(void) handleScoresDoneMoving {
    _scoresInPlace = true;
}

-(void) handleTouch {
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
            _scorePlaced = true;
            _loopCount = OVERLAY_INTERVALS;
        }
    }
}

-(void) placeScoresAtFinish{
    
    int score = [[GameManager sharedInstance] getScore];
    NSString* scoreString = [NSString stringWithFormat:@"%i", score];
    
    self.scoreLabelText = [CCLabelBMFont labelWithString:@"Score:" fntFile:@"hdfont-full.fnt" ];
    self.scoreText = [CCLabelBMFont labelWithString:scoreString fntFile:@"hdfont-full.fnt" ];
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    scoreLabelText.position = ccp(screenSize.width/2, screenSize.height/2);
    scoreText.position = ccp(screenSize.width/2, (screenSize.height/2) - SCORE_LINESPACING);
    
    [self addChild:scoreLabelText z:OVERLAY_TEXT_Z];
    [self addChild:scoreText z:OVERLAY_TEXT_Z];
    _scoresInPlace = true;
}

@end
