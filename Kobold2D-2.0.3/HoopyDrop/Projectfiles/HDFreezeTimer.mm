//
//  HDFreezeTimer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 11/14/12.
//
//

#import "HoopyDrop.h"

@implementation HDFreezeTimer {
    @private
    float _lastUpdateTime;
    float _pauseTime;
    int _count;

}

- (id)init
{
    self = [super init];
    if (self) {
        _lastUpdateTime = CACurrentMediaTime();
        _count = 3;
        [[GameManager sharedInstance] updateFreezeImage:_count];
        [self schedule: @selector(tick)];
    }
    return self;
}

-(void) tick {
    float currentTime = CACurrentMediaTime();
    CCLOG(@"ticking away thre freeze with an update delta: %f", currentTime-_lastUpdateTime);
    if(currentTime-_lastUpdateTime >= 1) {
        _count--;
        if(_count <=0) {
            [[GameManager sharedInstance] handleUnfreeze];
            [self pauseSchedulerAndActions];
        } else {
            [[GameManager sharedInstance] updateFreezeImage:_count];
        }
        _lastUpdateTime = currentTime;
    }
    
}

-(void) pause {
    _pauseTime = CACurrentMediaTime();
    [self pauseSchedulerAndActions];
}

-(void) unpause {
    _lastUpdateTime += CACurrentMediaTime() - _pauseTime;
    [self resumeSchedulerAndActions];
}

@end
