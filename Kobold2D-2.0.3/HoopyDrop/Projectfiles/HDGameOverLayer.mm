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
}

- (id)init
{
    self = [super init];
    if (self) {
        _loopCount = 0;
        CCSpriteBatchNode* image = [CCSpriteBatchNode batchNodeWithFile:[ScreenImage convertImageName:@"game_over"] capacity:12];
       
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
    if(now - _lastLoopTime >= .2)
    {
        if(_loopCount < 12)
        {
            CCSpriteBatchNode* batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
            CCSprite * sprite = [CCSprite spriteWithTexture: [batch texture]];
            sprite.position = ccp(0,0);
            sprite.anchorPoint = ccp(0,0);
            [batch addChild:sprite z:OVERLAY_Z];
        }
        if(_loopCount == 40)
        {
            [self pauseSchedulerAndActions];
            [[GameManager sharedInstance] handleEndGameTransitionEnd];
        }
        _lastLoopTime = now;
        _loopCount++;
    }
    
}

@end
