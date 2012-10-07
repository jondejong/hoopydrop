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
    int countTime;
    float lastUpdateTime;
}

- (id)init
{
    self = [super init];
    if (self) {
        countTime = SECONDS_PER_GAME;
        lastUpdateTime = CACurrentMediaTime();        

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
    lastUpdateTime = CACurrentMediaTime();
    [self resumeSchedulerAndActions];
}

-(int)remainingTime {
    return countTime;
}

-(void) tick: (ccTime) dt
{	
	if (CACurrentMediaTime() - lastUpdateTime >= 1) {
		countTime--;
		[[GameManager sharedInstance] updateTimer:countTime];
	}
    
    if(countTime > 0 && countTime <= 10) {
        [[GameManager sharedInstance] fireSound:kHDSoundAlarm];
    }
	
	if (countTime == 0) {
        [[GameManager sharedInstance] fireSound:kHDSoundGameOver];
        [self unschedule: @selector(tick:)];
        [[GameManager sharedInstance] handleEnd];
    }
    
}

@end


