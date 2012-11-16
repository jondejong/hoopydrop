//
//  HDOrbTimer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/18/12.
//
//

#import "HoopyDrop.h"
#import "SimpleAudioEngine.h"

@implementation HDOrbTimer{
@private
    float _lastLoopTime;
    uint _targetCount;
    
//    int _freezeTime;
//    bool _frozen;
    
    // Current game time in 10ths of seconds
    int _now;
    
    // How frequently is the player collecting orbs?
    int _frequency;
    int _lastDecrementTime;
    
    int _timeTargetsEmpited;
    int _lastTimeOrbPlaced;
    uint _collectedOrbCount;
    
    int _thresholdBottom;
    int _thresholdTop;
    double _thresholdChangeLevel;
    double _thresholdIncrementLevel;
    int _expireTime;
    
    double _pauseTime;
    
    // All scores will be uints when added
    // But store them as floating points since
    // we are doing percentage math on them.
    // i.e. 1.5 might be an acceptable value but
    // the game will only add 1 in that case.
    double _yellowScore;
    double _greenScore;
    double _purpleScore;
    
}

@synthesize existingOrbs;

- (id)init
{
    self = [super init];
    if (self) {
        
        self.existingOrbs = [NSMutableArray arrayWithCapacity:100];
        
//        _frozen = NO;
        
        _lastLoopTime = 0.0;
        _targetCount = 0;
        _frequency = 0;
        _lastDecrementTime = 0;
        
        // Current game time in 10ths of seconds
        _now = 0;
        _timeTargetsEmpited = 0;
        _lastTimeOrbPlaced = 0;
        _collectedOrbCount = 0;
        _pauseTime = 0.0;
        
#if PLACE_LINEAR_ALGORITHM
        _thresholdBottom = BASE_THRESHOLD_BOTTOM_LINEAR;
        _thresholdTop = BASE_THRESHOLD_TOP_LINEAR;
        _thresholdChangeLevel = THRESHOLD_CHANGE_LEVEL_LINEAR;
        _thresholdIncrementLevel = THRESHOLD_CHANGE_INCREMENT_LINEAR;
        _expireTime = BASE_EXPIRE_TIME_LINEAR;
        
        _yellowScore = BASE_YELLOW_SCORE_LINEAR;
        _greenScore = BASE_GREEN_SCORE_LINEAR;
        _purpleScore = BASE_PURPLE_SOCRE_LINEAR;
        
#else
        
        _thresholdBottom = BASE_THRESHOLD_BOTTOM;
        _thresholdTop = BASE_THRESHOLD_TOP;
        _thresholdChangeLevel = THRESHOLD_CHANGE_LEVEL;
        _thresholdIncrementLevel = THRESHOLD_CHANGE_LEVEL;
        _expireTime = BASE_EXPIRE_TIME;
        
        _yellowScore = BASE_YELLOW_SCORE;
        _greenScore = BASE_GREEN_SCORE;
        _purpleScore = BASE_PURPLE_SOCRE;
#endif
        
        [self updateGameWithNewOrbPointValues];

    }
    return self;
}

-(void) tick: (ccTime) dt
{
    
    /**
     
     New placement algorithm to try:
     
     (All increments in 1/10 of a second)
     
     Set a threshold for new orbs. For now, we can just set one threshold for all orbs,
     but we may need to change that to 1 per color. Each threshold has a lower time and
     an upper time (i.e. 5 and 10 seconds). Each orb gets a percentage chance of appearing
     during that threshold. We guarantee that a new orb will appear in that threshold.
     Once and orb is placed, we will restart the countdown. If the screen becomes empty, a
     new orb will immediately be placed.
     
     Once a certain number Orbs are collected we trigger a change. We will call this the
     THRESHOLD_CHANGE_LEVEL. At that point the threshold will shirnk and come quicker.
     For example, 5-10 seconds may become 4-8. In addition, the points awarded for each
     orb will go up, but the time the orb stays on the playing surface will decrease. At
     this point, the THRESHOLD_CHANGE_LEVEL will also go up.
     
     The values for the threshold change level, the base lower/upper points, and the rate
     and which every thing changes will be stored in constants so they can be tweaked
     until the appropriate difficutly of play is reached.
     
     **/
    
    //     We want to process every 10th of second
    float currentTime = CACurrentMediaTime();
    if(currentTime - _lastLoopTime  >= UPDATE_TIMER_LOOP_SECONDS) {
        // Adjust the counter
        if(_lastLoopTime > 0) {
//            if(_frozen ) {
//                _freezeTime += (10 * (currentTime - _lastLoopTime))/1;
//            } else {
                _now += (10 * (currentTime - _lastLoopTime))/1;
//            }
        } else {
            _now = 1;
        }
        
        // Adjust the frequency
        if(_now - _lastDecrementTime >= FREQUENCY_DECREMENT) {
            _frequency--;
            _lastDecrementTime = _now;
        }
        
//        CCLOG(@"Looping %i", _now);
        _lastLoopTime = currentTime;
        
        // Expire what needs to be expired
        [self expireOrbs];
        
        // Decide if we should add a new orb
        bool addTarget = NO;
        int timeSinceLastTarget = _now - _lastTimeOrbPlaced;
        
        if(_targetCount <= 0 || timeSinceLastTarget >= _thresholdTop) {
            // We are eiter out of targets or we've waited to long, force one.
            addTarget = true;
        } else if (timeSinceLastTarget > _thresholdBottom ) {
            // Give each loop in the threshold an equal change to have a new orb
            addTarget = (1 == arc4random() % (_thresholdTop - _thresholdBottom) );
        }
    
        if(addTarget) {
            [self addAnOrb];
        }
    
        // Update all values (if needed)
        [self updateValues];
//        if(_frozen && _freezeTime >= FREEZE_TIME_AMOUNT) {
//            [[GameManager sharedInstance] handleUnfreeze];
//            _frozen = NO;
//        }
    }
}

-(void) updateValues {
    if(_collectedOrbCount >= _thresholdChangeLevel) {
#if PLACE_LINEAR_ALGORITHM
        [self updateValuesLinear];
#else
        [self updateValueslExponential];
#endif
        [self updateGameWithNewOrbPointValues];
          CCLOG(@"Change level reset to: %f. New Increment: %f. New threshold to %i - %i. Expires at: %i", _thresholdChangeLevel, _thresholdIncrementLevel, _thresholdBottom, _thresholdTop, _expireTime);
    }
}

-(void) updateValuesLinear {
    _thresholdChangeLevel += _thresholdIncrementLevel;
    _yellowScore += YELLOW_SCORE_INCREMENT;
    _greenScore += GREEN_SCORE_INCREMENT;
    _purpleScore += PURPLE_SCORE_INCREMENT;
    
    _thresholdBottom -= THRESHOLD_BOTTOM_INCREMENT_LINEAR;
    _thresholdTop -= THRESHOLD_TOP_INCREMENT_LINEAR;
    _expireTime -= EXPIRE_TIME_INCREMENT_LINEAR;
    
    _thresholdBottom = (_thresholdBottom < MIN_THRESHOLD_BOTTOM_LINEAR) ? MIN_THRESHOLD_BOTTOM_LINEAR : _thresholdBottom;
    _thresholdTop = (_thresholdTop < MIN_THRESHOLD_TOP_LINEAR) ? MIN_THRESHOLD_TOP_LINEAR : _thresholdTop;
    _expireTime = (_expireTime < MIN_EXPIRE_TIME_LINEAR) ? MIN_EXPIRE_TIME_LINEAR : _expireTime;
}

-(void) updateValuesExponential {
    
    _thresholdIncrementLevel = _thresholdIncrementLevel * (1.0 + THESHOLD_LEVEL_CHANGE_PERCENTAGE);
    _thresholdChangeLevel += _thresholdIncrementLevel;
    _yellowScore *=  (1 + SCORE_CHANGE_PERCENTAGE_EXPONENTIAL);
    _greenScore *=  (1 + SCORE_CHANGE_PERCENTAGE_EXPONENTIAL);
    _purpleScore *=  (1 + SCORE_CHANGE_PERCENTAGE_EXPONENTIAL);
    _thresholdBottom = (uint)((float)_thresholdBottom * (1.0 - THESHOLD_CHANGE_PERCENTAGE));
    _thresholdTop = (uint)((float)_thresholdTop * (1.0 - THESHOLD_CHANGE_PERCENTAGE));
    float tempExpireTime = ((float)_expireTime * (1.0 - EXPIRE_TIME_CHANGE_PERCENTAGE));
    _expireTime = (tempExpireTime < MIN_EXPIRE_TIME_EXPONENTIAL) ? MIN_EXPIRE_TIME_EXPONENTIAL : (uint)tempExpireTime;
    
    _thresholdBottom = _thresholdBottom < MIN_THRESHOLD_BOTTOM_EXPONENTIAL ? MIN_THRESHOLD_BOTTOM_EXPONENTIAL : _thresholdBottom;
    _thresholdTop = _thresholdTop < MIN_THRESHOLD_TOP_EXPONENTIAL ? MIN_THRESHOLD_TOP_EXPONENTIAL : _thresholdTop;
    
}

-(void) updateGameWithNewOrbPointValues {
    [[GameManager sharedInstance] setYellowTargetPoints:_yellowScore];
    [[GameManager sharedInstance] setGreenTargetPoints:_greenScore];
    [[GameManager sharedInstance] setPurpleTargetPoints:_purpleScore];

}

-(void) addAnOrb {

    _lastTimeOrbPlaced = _now;
    
    uint val = arc4random() % 100;
    
    if(val < YELLOW_ODDS) {
        [self addYellowOrb];
    } else if (val >= YELLOW_ODDS && val < (YELLOW_ODDS + GREEN_ODDS)) {
        [self addGreenOrb];
    } else {
        [self addPurpleOrb];
    }
}

-(void) expireOrbs {
    for(CollisionHandler* handler in existingOrbs) {
        if( ![handler isRemoved] && (_now -  [handler createTime]) > _expireTime) {
            [handler removeThisTarget];
        }
    }
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
    _pauseTime = CACurrentMediaTime();
    [self pauseSchedulerAndActions];
    for(CollisionHandler* handler in existingOrbs) {
        [self pauseAction: handler];
    }
}

-(void) handleUnpause {
    for(CollisionHandler* handler in existingOrbs) {
        [self resumeAction: handler];
    }
    
    _lastLoopTime += CACurrentMediaTime() - _pauseTime;
    [self resumeSchedulerAndActions];
}


-(void) handleTargetAdded {
    _targetCount++;
    _collectedOrbCount++;
}

-(void) decrementTargets {
    if(--_targetCount == 0) {
        _timeTargetsEmpited = _now;
    }
}

-(void) addYellowOrb{
    
    CollisionHandler* handler = [[YellowThingHandler alloc]init];
    [[GameManager sharedInstance]  addTarget:handler andBaseSprite:@"yellow" andTrackedBy:existingOrbs at:_now];
}

-(void) addGreenOrb {
    [[GameManager sharedInstance] addTarget:[[GreenThingHandler alloc]init] andBaseSprite:@"green" andTrackedBy:existingOrbs at:_now];
}

-(void) addPurpleOrb {
    [[GameManager sharedInstance] addTarget:[[PurpleThingHandler alloc]init] andBaseSprite:@"purple" andTrackedBy:existingOrbs at:_now];
}

-(int) currentGameTime {
    return _now;
}

-(void) handleOrbCollected {
    if(_frequency < 0) {
        _frequency = 0;
    } else {
        _frequency++;
    }
}

-(int) frequency {
    return _frequency;
}

-(void) resetFrequency
{
    _frequency = 0;
}


@end
