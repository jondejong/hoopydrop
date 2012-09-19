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
    float lastUpdateTime;
    uint _targetCount;
    float lastYellowPoint;
    float lastPurplePoint;
    float lastGreenPoint;
    float _timeTargetsEmpited;
    double _now;

}

@synthesize existingGreens;
@synthesize existingPurples;
@synthesize existingYellows;

- (id)init
{
    self = [super init];
    if (self) {
        lastYellowPoint = SECONDS_PER_GAME + YELLOW_EXPIRE_SECONDS + 1;
        lastGreenPoint = SECONDS_PER_GAME + GREEN_EXPIRE_SECONDS + 1;
        lastPurplePoint = SECONDS_PER_GAME + PURPLE_EXPIRE_SECONDS + 1;
        
        lastUpdateTime = CACurrentMediaTime();
        _now = lastUpdateTime;
        
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
    lastUpdateTime = CACurrentMediaTime();
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
    [self expireGreens];
    [self expirePurples];
    [self expireYellows];
    
    _now = CACurrentMediaTime();
    
    int forced = -1;
    
    if(_targetCount <=0 &&  (_now - _timeTargetsEmpited) > MAX_TARGET_EMPTY_SECONDS) {
        forced = arc4random() % 10;
    }
    
    if(forced >= 0 || _now - lastUpdateTime >= REDRAW_LOOP_SECONDS) {
        
        
        uint score = [[GameManager sharedInstance] getScore];
        
        uint multiplier = score/BASE_SCORE_MULTIPLIER_SCORE;
        
        [[GameManager sharedInstance] setYellowTargetPoints: YELLOW_POINTS + (multiplier * YELLOW_SCORE_INCREMENTS)];
        [[GameManager sharedInstance] setGreenTargetPoints:GREEN_POINTS + (multiplier * GREEN_SCORE_INCREMENTS)];
        [[GameManager sharedInstance] setPurpleTargetPoints:PURPLE_POINTS + (multiplier * PURPLE_SCORE_INCREMENTS)];
        
        [self addYellowThing: (forced >= 0 && forced < 6)];
        [self addGreenThing: (forced < 9 && forced >= 6)];
        [self addPurpleThing: (9==forced)];
        
        lastUpdateTime = _now;
    }
}

-(void) handleTargetAdded {
    _targetCount++;
}

-(void) decrementTargets {
    if(--_targetCount == 0) {
        _timeTargetsEmpited = CACurrentMediaTime();
    }
//    CCLOG(@"_targetCount: %i", _targetCount);
}

-(uint) adjustFrequency:(int)frequency withIncrement: (uint) increment andMinimum: (int) min {
    uint score = [[GameManager sharedInstance] getScore];
    uint multiplier = score/BASE_FREQUENCY_MULTIPLIER;
    frequency -= (increment * multiplier);
    return frequency < min ? min : frequency;
}

-(uint) adjustExpireTime:(int)expireTime withIncrement:(uint)increment {
    uint score = [[GameManager sharedInstance] getScore];
    uint multiplier = score/BASE_SCORE_MULTIPLIER_SCORE;
    expireTime -= (increment * multiplier);
    return expireTime < MINIMUM_EXPIRE_TIME ? MINIMUM_EXPIRE_TIME : expireTime;
}

-(void) addYellowThing:(bool) force {
    
    if(!force) {
        bool time = lastYellowPoint > SECONDS_PER_GAME || (_now - lastYellowPoint) >= YELLOW_MINIMUM_SECONDS_BUFFER;
        int at = [self adjustFrequency:YELLOW_FREQ withIncrement:YELLOW_FREQUENCY_INCREMENTS andMinimum:MINIMUM_YELLOW_FREQ];
        int rand = (arc4random() % at);
//        CCLOG(@"Yellow FREQ: %i -- rand: %i with time %i (dif: %f)", at, rand, time, (_now - lastYellowPoint));
        if(!time || 1 != rand)  {
            return;
        }
    }
    
    lastYellowPoint = _now;
    
    CollisionHandler* handler = [[YellowThingHandler alloc]init];
    [[GameManager sharedInstance]  addTarget:handler andBaseSprite:@"yellow_thing" andParentNode:kYellowThingNode andTrackedBy:existingYellows at:_now];
}

-(void) addGreenThing:(bool) force  {
    if(!force) {
        bool time = lastGreenPoint > SECONDS_PER_GAME|| (_now - lastGreenPoint) >= GREEN_MINIMUM_SECONDS_BUFFER;
        if(!time || 1 != (arc4random() % [self adjustFrequency:GREEN_FREQ withIncrement:GREEN_FREQUENCY_INCREMENTS andMinimum:MINIMUM_GREEN_FREQ])) {
            return;
        }
        
    }
    lastGreenPoint = _now;
    [[GameManager sharedInstance] addTarget:[[GreenThingHandler alloc]init] andBaseSprite:@"green_thing" andParentNode:kGreenThingNode andTrackedBy:existingGreens at:_now];
}

-(void) addPurpleThing:(bool) force {
    if(!force) {
        bool time = lastGreenPoint > SECONDS_PER_GAME || (_now - lastPurplePoint) >= PURPLE_MINIMUM_SECONDS_BUFFER;
        int at = [self adjustFrequency:PURPLE_FREQ withIncrement:PURPLE_FREQUENCY_INCREMENTS andMinimum:MINIMUM_PURPLE_FREQ];
//        CCLOG(@"Purple FREQ: %i", at);
        if(!time || 1 != (arc4random() % at))  {
            return;
        }
    }
    lastPurplePoint = _now;
    
    [[GameManager sharedInstance] addTarget:[[PurpleThingHandler alloc]init] andBaseSprite:@"purple_thing" andParentNode:kPurpleThingNode andTrackedBy:existingPurples at:_now];
}

-(void) expireYellows {
    for(uint i=0; i<[existingYellows count]; i++) {
        YellowThingHandler* handler = (YellowThingHandler*)[existingYellows objectAtIndex:i];
        if(![handler isRemoved]) {
            double at = [self adjustExpireTime:YELLOW_EXPIRE_SECONDS withIncrement:YELLOW_SPEED_INCREMENTS];
//            CCLOG(@"Expiring Yellow in: %f", at);
            if(_now - [handler createTime] >= at) {
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
