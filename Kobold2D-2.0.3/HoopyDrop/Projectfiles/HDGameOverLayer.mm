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
    GLubyte _opacity;
}

@synthesize overlayTransitionSprite;

- (id)init
{
    self = [super init];
    if (self) {
        _loopCount = 0;
        _scorePlaced = false;
        CCSpriteBatchNode* image = [CCSpriteBatchNode batchNodeWithFile:[ScreenImage convertImageName:@"game_over"] capacity:1];
        _opacity = 5;
        [self addChild:image z:0 tag:kTagBatchNode];
    }
    return self;
}

-(void) startTransition
{
    _lastLoopTime = CACurrentMediaTime();
    [self scheduleUpdate];
}

-(void) update: (ccTime) dt
{
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
        
        } else if(_loopCount < 40)
        {
            _opacity += 5;
            [[self overlayTransitionSprite] setOpacity:_opacity];
            
        } else if(!_scorePlaced)
        {
            _scorePlaced = true;
            int score = [[GameManager sharedInstance] getScore];
            NSString* scoreString = [NSString stringWithFormat:@"%i", score];
            
            CCLabelBMFont *scoreLabelText = [CCLabelBMFont labelWithString:@"Score:" fntFile:@"hdfont-full.fnt" ];
            CCLabelBMFont *scoreText = [CCLabelBMFont labelWithString:scoreString fntFile:@"hdfont-full.fnt" ];
            
            float lineSpacing = 45;
            
            CGSize screenSize = [CCDirector sharedDirector].winSize;
            scoreLabelText.position = ccp(screenSize.width/2, screenSize.height + 60);
            scoreText.position = ccp(screenSize.width/2, screenSize.height + 60 - lineSpacing);
            [self addChild:scoreLabelText z:OVERLAY_TEXT_Z];
            [self addChild:scoreText z:OVERLAY_TEXT_Z];
            
            CGPoint labelEndPoint = ccp(screenSize.width/2, screenSize.height/2);
            CGPoint scoreEndPoint = ccp(screenSize.width/2, (screenSize.height/2) - lineSpacing);
            
//            CCLOG(@"Moving label to (%f, %f) and score to (%f, %f)", labelEndPoint.x, labelEndPoint.y, scoreEndPoint.x, scoreEndPoint.y);
            
            CCFiniteTimeAction* moveLabelAction = [CCMoveTo actionWithDuration: 2 position: labelEndPoint];
            CCFiniteTimeAction* moveScoreAction = [CCMoveTo actionWithDuration: 2 position: scoreEndPoint];
            [scoreLabelText runAction:[CCSequence actions:moveLabelAction, nil]];
            [scoreText runAction:[CCSequence actions:moveScoreAction, nil]];
            
        }
        if(_loopCount == 120 )
        {
            [self pauseSchedulerAndActions];
            [[GameManager sharedInstance] returnToMenu];
        }
        _lastLoopTime = now;
        _loopCount++;
    }
    
}

@end
