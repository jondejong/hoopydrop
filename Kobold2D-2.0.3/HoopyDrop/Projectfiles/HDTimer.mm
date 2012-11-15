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
    float _pauseTime;
    
    bool _bombTargetAdded;
    bool _bombTargetRemoved;
    
    bool _extraSecondsTargetAdded;
    bool _extraSecondsTargetRemoved;
    
    bool _cherryTargetAdded;
    bool _cherryTargetRemoved;
    
    bool _boltTargetAdded;
    bool _boltTargetRemoved;
    
    int _bombAddTime;
    int _bombExpireTime;
    
    int _extraSecondsAddTime;
    int _extraSecondsExpireTime;
    
    int _cherryAddTime;
    int _cherryExpireTime;
    
    int _boltAddTime;
    int _boltExpireTime;
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
        _cherryTargetAdded = NO;
        _cherryTargetRemoved = NO;
        _boltTargetAdded = NO;
        _boltTargetRemoved = NO;
        
        _bombAddTime = (arc4random() % (GOODIE_BEGIN_TIME - GOODIE_END_TIME)) + GOODIE_END_TIME;
        _bombExpireTime = _bombAddTime - GOODIE_EXPIRE_SECONDS;
        
        _extraSecondsAddTime = (arc4random() % (GOODIE_BEGIN_TIME - GOODIE_END_TIME)) + GOODIE_END_TIME;
        _extraSecondsExpireTime = _extraSecondsAddTime - GOODIE_EXPIRE_SECONDS;
        
        _cherryAddTime = (arc4random() % (CHERRY_BEGIN_TIME - CHERRY_END_TIME)) + CHERRY_END_TIME;
        _cherryExpireTime = _cherryAddTime - GOODIE_EXPIRE_SECONDS;
        
        _boltAddTime = (arc4random() % (GOODIE_BEGIN_TIME - GOODIE_END_TIME)) + GOODIE_END_TIME;
        _boltExpireTime = _boltAddTime - GOODIE_EXPIRE_SECONDS;

    }
    return self;
}

-(void)start {
    [self schedule: @selector(tick:) interval:1.0];
}

-(void)pause {
    _pauseTime = CACurrentMediaTime();
    [self pauseSchedulerAndActions];
}

-(void)unpause {
    _lastUpdateTime += CACurrentMediaTime() - _pauseTime;
    [self resumeSchedulerAndActions];
}

-(int)remainingTime {
    return _countTime;
}

-(void) addTime: (int) time {
    _countTime += time;
    if(_boltTargetAdded && !_boltTargetRemoved) {
        _boltExpireTime += time;
    }
    if(_bombTargetAdded && !_bombTargetRemoved) {
        _bombExpireTime += time;
    }
    if(_extraSecondsTargetAdded && !_extraSecondsTargetRemoved) {
        _extraSecondsExpireTime += time;
    }
    [[GameManager sharedInstance] updateTimer:_countTime];
}

-(void) tick: (ccTime) dt
{	
	if (CACurrentMediaTime() - _lastUpdateTime >= 1) {
		_countTime--;
		[[GameManager sharedInstance] updateTimer:_countTime];
	}
    
#if DRAW_TNT
    if(_countTime <= _bombAddTime && !_bombTargetAdded) {
        _bombTargetAdded = YES;
        [[GameManager sharedInstance] addBombTargetWithTime:_countTime];
    } else if(_countTime <= _bombExpireTime &&!_bombTargetRemoved) {
        _bombTargetRemoved = YES;
        [[GameManager sharedInstance] removeBombTarget];
    }
#endif
#if DRAW_EXTRA_TIME
    if(_countTime <= _extraSecondsAddTime && !_extraSecondsTargetAdded) {
        _extraSecondsTargetAdded = YES;
        [[GameManager sharedInstance] addExtraTimeTargetWithTime:_countTime];
    } else if(_countTime <= _extraSecondsExpireTime &&!_extraSecondsTargetRemoved) {
        _extraSecondsTargetRemoved = YES;
        [[GameManager sharedInstance] removeExtraTimeTarget];
    }
#endif
#if DRAW_CHERRY
    if(_countTime <= _cherryAddTime && !_cherryTargetAdded) {
        _cherryTargetAdded = YES;
        [[GameManager sharedInstance] addCherryTargetWithTime:_countTime];
    } else if(_countTime <= _cherryExpireTime &&!_cherryTargetRemoved) {
        _cherryTargetRemoved = YES;
        [[GameManager sharedInstance] removeCherryTarget];
    }
#endif
#if DRAW_BOLT
    if(_countTime <= _boltAddTime && !_boltTargetAdded) {
        _boltTargetAdded = YES;
        [[GameManager sharedInstance] addBoltTargetWithTime:_countTime];
    } else if(_countTime <= _boltExpireTime &&!_boltTargetRemoved) {
        _boltTargetRemoved = YES;
        [[GameManager sharedInstance] removeBoltTarget];
    }
#endif
    
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


