//
//  PauseLayer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/12/12.
//
//

#import "HoopyDrop.h"

@implementation PauseLayer {
    @private
    bool paused;
}

- (id)init
{
    self = [super init];
    if (self) {
        paused = false;
        [self scheduleUpdate];
    }
    return self;
}

-(void) update:(ccTime)delta
{
 
    KKInput* input = [KKInput sharedInput];
    if (input.anyTouchEndedThisFrame)
    {
        if(paused) {
            paused = false;
            [[GameManager sharedInstance] handlePause];
        } else {
            paused = true;
            [[GameManager sharedInstance] handleUnpause];
        }
    }
    
}

@end
