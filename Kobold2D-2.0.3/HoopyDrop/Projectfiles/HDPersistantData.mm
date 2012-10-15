//
//  HDPersistantData.m
//  HoopyDrop
//
//  Created by Jon DeJong on 10/9/12.
//
//

#import "HDPersistantData.h"

@implementation HDPersistantData {
@private bool _soundEffectsOn;
}

@synthesize highScores;

- (id)init
{
    self = [super init];
    if (self) {
        _soundEffectsOn = true;
        self.highScores = [NSMutableArray arrayWithCapacity:10];
        
        for(int i=10; i>0; i--) {
            [highScores addObject:[NSNumber numberWithInt:(i * 10)]];
        }
    }
    return self;
}


-(bool) isSoundEffectsOn {
    return _soundEffectsOn;
}

-(void) setSoundEffectsOff {
    _soundEffectsOn = NO;
}

-(void) setSoundEffectsOn {
    _soundEffectsOn = YES;
}

@end
