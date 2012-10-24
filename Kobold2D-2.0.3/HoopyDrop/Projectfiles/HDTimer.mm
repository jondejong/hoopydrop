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
    bool _bombTargetRemoved;
    
    bool _extraSecondsTargetAdded;
    bool _extraSecondsTargetRemoved;
    
    int _bombAddTime;
    int _bombExpireTime;
    
    int _extraSecondsAddTime;
    int _extraSecondsExpireTime;
}

- (id)init
{
    self = [super init];
    if (self) {
        _countTime = SECONDS_PER_GAME;
        _lastUpdateTime = CACurrentMediaTime();
        
        _bombTargetAdded = NO;
        _bombTargetRemoved = NO;
        _extraSecondsTargetAdded = NO;
        _extraSecondsTargetRemoved = NO;
        
        _bombAddTime = (arc4random() % (GOODIE_BEGIN_TIME - GOODIE_END_TIME)) + GOODIE_END_TIME;
        _bombExpireTime = _bombAddTime - GOODIE_EXPIRE_SECONDS;
        CCLOG(@"BOMB ADD TIME: %i", _bombAddTime);
        
        _extraSecondsAddTime = (arc4random() % (GOODIE_BEGIN_TIME - GOODIE_END_TIME)) + GOODIE_END_TIME;
        _extraSecondsExpireTime = _extraSecondsAddTime - GOODIE_EXPIRE_SECONDS;

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

-(void) addTime: (int) time {
    _countTime += 5;
    [[GameManager sharedInstance] updateTimer:_countTime];
}

-(void) tick: (ccTime) dt
{	
	if (CACurrentMediaTime() - _lastUpdateTime >= 1) {
		_countTime--;
		[[GameManager sharedInstance] updateTimer:_countTime];
	}
    
    if(_countTime <= _bombAddTime && !_bombTargetAdded) {
        _bombTargetAdded = YES;
        [[GameManager sharedInstance] addBombTargetWithTime:_countTime];
    } else if(_countTime <= _bombExpireTime &&!_bombTargetRemoved) {
        _bombTargetRemoved = YES;
        [[GameManager sharedInstance] removeBombTarget];
    }
    
    if(_countTime <= _extraSecondsAddTime && !_extraSecondsTargetAdded) {
        _extraSecondsTargetAdded = YES;
        [[GameManager sharedInstance] addExtraTimeTargetWithTime:_countTime];
    } else if(_countTime <= _extraSecondsExpireTime &&!_extraSecondsTargetRemoved) {
        _extraSecondsTargetRemoved = YES;
        [[GameManager sharedInstance] removeExtraTimeTarget];
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


