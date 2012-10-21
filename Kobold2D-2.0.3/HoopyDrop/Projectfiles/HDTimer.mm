//
//  HDTimer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/15/12.
//
//

#import "HoopyDrop.h"
#import "SimpleAudioEngine.h"

@implementation HDTimer {
    @private
    int _countTime;
    float _lastUpdateTime;
    bool _bombTargetAdded;
}

- (id)init
{
    self = [super init];
    if (self) {
        _countTime = SECONDS_PER_GAME;
        _lastUpdateTime = CACurrentMediaTime();
        _bombTargetAdded = NO;

    }
    return self;
}

-(void)start {
    [self schedule: @selector(tick:) interval:1.0];
}

-(void)pause {
    [self pauseSchedulerAndActions];
}

-(void)unpause {
    _lastUpdateTime = CACurrentMediaTime();
    [self resumeSchedulerAndActions];
}

-(int)remainingTime {
    return _countTime;
}

-(void) tick: (ccTime) dt
{	
	if (CACurrentMediaTime() - _lastUpdateTime >= 1) {
		_countTime--;
		[[GameManager sharedInstance] updateTimer:_countTime];
	}
    
    if(_countTime <= 58 && !_bombTargetAdded) {
        _bombTargetAdded = YES;
        [[GameManager sharedInstance] addBombTargetWithTime:_countTime];
    }
    
    if(_countTime > 0 && _countTime <= 10) {
        [[GameManager sharedInstance] fireSound:kHDSoundAlarm];
    }
	
	if (_countTime == 0) {
        [[GameManager sharedInstance] fireSound:kHDSoundGameOver];
        [self unschedule: @selector(tick:)];
        [[GameManager sharedInstance] handleEnd];
    }
    
}

@end


