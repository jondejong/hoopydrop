//
//  HDOrbTimer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/18/12.
//
//

#import "HoopyDrop.h"

@implementation HDOrbTimer{
@private
    float _lastLoopTime;
    uint _targetCount;
    float _lastYellowPoint;
    float _lastPurplePoint;
    float _lastGreenPoint;
    
    // Current game time in 10ths of seconds
    uint _now;
    uint _timeTargetsEmpited;
    uint _lastUpdateTime;

}

@synthesize existingGreens;
@synthesize existingPurples;
@synthesize existingYellows;

- (id)init
{
    self = [super init];
    if (self) {
        _lastYellowPoint = SECONDS_PER_GAME + YELLOW_EXPIRE_SECONDS + 1;
        _lastGreenPoint = SECONDS_PER_GAME + GREEN_EXPIRE_SECONDS + 1;
        _lastPurplePoint = SECONDS_PER_GAME + PURPLE_EXPIRE_SECONDS + 1;
        _lastLoopTime = 0.0;
        _now = 0.0;
        _lastUpdateTime = _now;
        
        _targetCount = 0;
        _timeTargetsEmpited = SECONDS_PER_GAME + 1;
        
        self.existingPurples = [NSMutableArray arrayWithCapacity:10];
        self.existingGreens = [NSMutableArray arrayWithCapacity:10];
        self.existingYellows = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

-(void) start {
    [self schedule: @selector(tick:)];
}

-(void) pauseAction: (CollisionHandler*) handler {
    [[handler sprite] pauseSchedulerAndActions];
}

-(void) resumeAction: (CollisionHandler*) handler {
    [[handler sprite] resumeSchedulerAndActions];
}

-(void) handlePause {
    [self pauseSchedulerAndActions];
    for(uint i=0; i<[existingYellows count]; i++) {
        [self pauseAction: (CollisionHandler*)[existingYellows objectAtIndex:i]];
    }
    for(uint i=0; i<[existingGreens count]; i++) {
        [self pauseAction: (CollisionHandler*)[existingGreens objectAtIndex:i]];
    }
    for(uint i=0; i<[existingPurples count]; i++) {
        [self pauseAction: (CollisionHandler*)[existingPurples objectAtIndex:i]];
    }
}

-(void) handleUnpause {
    for(uint i=0; i<[existingYellows count]; i++) {
        [self resumeAction: (CollisionHandler*)[existingYellows objectAtIndex:i]];
    }
    for(uint i=0; i<[existingGreens count]; i++) {
        [self resumeAction: (CollisionHandler*)[existingGreens objectAtIndex:i]];
    }
    for(uint i=0; i<[existingPurples count]; i++) {
        [self resumeAction: (CollisionHandler*)[existingPurples objectAtIndex:i]];
    }
    [self resumeSchedulerAndActions];
}

-(void) tick: (ccTime) dt
{
    
//     We want to process every 10th of second
    float currentTime = CACurrentMediaTime();
    if(currentTime - _lastLoopTime  >= UPDATE_TIMER_LOOP_SECONDS) {
        
        _lastLoopTime = currentTime;
        
        [self expireGreens];
        [self expirePurples];
        [self expireYellows];
        
        _now++;
        
        int forced = -1;
        
        if(_targetCount <=0) {
//            CCLOG(@"Looking to force. _now: %i, _timeTargetsEmpited: %i, emptySecondsConst: %f", _now, _timeTargetsEmpited,(10.0 * (float)MAX_TARGET_EMPTY_SECONDS) );
        }
        
        if(_targetCount <=0 &&  (_now - _timeTargetsEmpited) > 10.0 * (float)MAX_TARGET_EMPTY_SECONDS) {
            forced = arc4random() % 10;
        }
        
        if(forced >= 0 || _now - _lastUpdateTime >= 10.0 * (float)REDRAW_LOOP_SECONDS) {
            
            uint score = [[GameManager sharedInstance] getScore];
            
            uint multiplier = score/BASE_SCORE_MULTIPLIER_SCORE;
            
            [[GameManager sharedInstance] setYellowTargetPoints: YELLOW_POINTS + (multiplier * YELLOW_SCORE_INCREMENTS)];
            [[GameManager sharedInstance] setGreenTargetPoints:GREEN_POINTS + (multiplier * GREEN_SCORE_INCREMENTS)];
            [[GameManager sharedInstance] setPurpleTargetPoints:PURPLE_POINTS + (multiplier * PURPLE_SCORE_INCREMENTS)];
            
            [self addYellowThing: (forced >= 0 && forced < 6)];
            [self addGreenThing: (forced < 9 && forced >= 6)];
            [self addPurpleThing: (9==forced)];
            
            _lastUpdateTime = _now;
        }
    }
}

-(void) handleTargetAdded {
    _targetCount++;
}

-(void) decrementTargets {
    if(--_targetCount == 0) {
        _timeTargetsEmpited = _now;
    }
//    CCLOG(@"_targetCount: %i", _targetCount);
}

-(uint) adjustFrequency:(int)frequency withIncrement: (uint) increment andMinimum: (int) min {
    uint score = [[GameManager sharedInstance] getScore];
    uint multiplier = score/BASE_FREQUENCY_MULTIPLIER;
    frequency -= (increment * multiplier);
    return frequency < min ? min : frequency;
}

-(uint) adjustExpireTime:(float)expireTime withIncrement:(uint)increment {
    // Expire times are in seconds, game time counters are in 1/10 seconds.
    // adjust accordingly.
    
    expireTime *= 10;
    float minimumExpireTime = 10 * MINIMUM_EXPIRE_TIME;
    
    uint score = [[GameManager sharedInstance] getScore];
    uint multiplier = score/BASE_SCORE_MULTIPLIER_SCORE;
    expireTime -= (increment * multiplier);
    return expireTime < minimumExpireTime ? minimumExpireTime : expireTime;
}

-(void) addYellowThing:(bool) force {
    
    if(!force) {
        bool time = _lastYellowPoint > SECONDS_PER_GAME || (_now - _lastYellowPoint) >= YELLOW_MINIMUM_SECONDS_BUFFER;
        int at = [self adjustFrequency:YELLOW_FREQ withIncrement:YELLOW_FREQUENCY_INCREMENTS andMinimum:MINIMUM_YELLOW_FREQ];
        int rand = (arc4random() % at);
//        CCLOG(@"Yellow FREQ: %i -- rand: %i with time %i (dif: %f)", at, rand, time, (_now - lastYellowPoint));
        if(!time || 1 != rand)  {
            return;
        }
    }
    
    _lastYellowPoint = _now;
    
    CollisionHandler* handler = [[YellowThingHandler alloc]init];
    [[GameManager sharedInstance]  addTarget:handler andBaseSprite:@"yellow_thing" andParentNode:kYellowThingNode andTrackedBy:existingYellows at:_now];
}

-(void) addGreenThing:(bool) force  {
    if(!force) {
        bool time = _lastGreenPoint > SECONDS_PER_GAME|| (_now - _lastGreenPoint) >= GREEN_MINIMUM_SECONDS_BUFFER;
        if(!time || 1 != (arc4random() % [self adjustFrequency:GREEN_FREQ withIncrement:GREEN_FREQUENCY_INCREMENTS andMinimum:MINIMUM_GREEN_FREQ])) {
            return;
        }
        
    }
    _lastGreenPoint = _now;
    [[GameManager sharedInstance] addTarget:[[GreenThingHandler alloc]init] andBaseSprite:@"green_thing" andParentNode:kGreenThingNode andTrackedBy:existingGreens at:_now];
}

-(void) addPurpleThing:(bool) force {
    if(!force) {
        bool time = _lastGreenPoint > SECONDS_PER_GAME || (_now - _lastPurplePoint) >= PURPLE_MINIMUM_SECONDS_BUFFER;
        int at = [self adjustFrequency:PURPLE_FREQ withIncrement:PURPLE_FREQUENCY_INCREMENTS andMinimum:MINIMUM_PURPLE_FREQ];
//        CCLOG(@"Purple FREQ: %i", at);
        if(!time || 1 != (arc4random() % at))  {
            return;
        }
    }
    _lastPurplePoint = _now;
    
    [[GameManager sharedInstance] addTarget:[[PurpleThingHandler alloc]init] andBaseSprite:@"purple_thing" andParentNode:kPurpleThingNode andTrackedBy:existingPurples at:_now];
}

-(void) expireYellows {
    for(uint i=0; i<[existingYellows count]; i++) {
        YellowThingHandler* handler = (YellowThingHandler*)[existingYellows objectAtIndex:i];
        if(![handler isRemoved]) {
            double at = [self adjustExpireTime:YELLOW_EXPIRE_SECONDS withIncrement:YELLOW_SPEED_INCREMENTS];
//            CCLOG(@"Expiring Yellow in: %f", at);
            if(_now - [handler createTime] >= at) {
//                CCLOG(@"It is now %i.  --  Expiring Yellow with create time: %i", _now, [handler createTime]);
                [handler removeThisTarget];
            }
        }
    }
}

-(void) expireGreens {
    for(uint i=0; i<[existingGreens count]; i++) {
        GreenThingHandler* handler = (GreenThingHandler*)[existingGreens objectAtIndex:i];
        if(![handler isRemoved]) {
            uint at = [self adjustExpireTime:GREEN_EXPIRE_SECONDS withIncrement:GREEN_SPEED_INCREMENTS];
            //            CCLOG(@"Expiring Green in: %d", at);
            if(_now - [handler createTime] > at) {
                //                CCLOG(@"Expiring green target. Was created at %d, it is now %d.", [handler createTime], [[GameManager sharedInstance] getRemainingTime]);
                [handler removeThisTarget];
            }
        }
    }
}

-(void) expirePurples {
    for(uint i=0; i<[existingPurples count]; i++) {
        PurpleThingHandler* handler = (PurpleThingHandler*)[existingPurples objectAtIndex:i];
        if(![handler isRemoved]) {
            double at = [self adjustExpireTime:PURPLE_EXPIRE_SECONDS withIncrement:PURPLE_SPEED_INCREMENTS];
            //            CCLOG(@"Expiring Purple in: %f", at);
            if(_now - [handler createTime] >= at) {
                [handler removeThisTarget];
            }
        }
    }
}

@end
