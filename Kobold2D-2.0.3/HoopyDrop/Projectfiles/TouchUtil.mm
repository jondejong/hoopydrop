//
//  TouchUtil.m
//  HoopyDrop
//
//  Created by Jon DeJong on 10/6/12.
//
//

#import "HDUtil.h"
#import "HoopyDrop.h"

@implementation TouchUtil

+(bool) wasIntentiallyTouched {
    KKInput* input = [KKInput sharedInput];
    if (input.anyTouchEndedThisFrame)
    {
        bool inArea = NO;
        CCArray* touches = [KKInput sharedInput].touches;
        KKTouch* touch;
        CCARRAY_FOREACH(touches, touch)
        {
            if(touch && touch->isInvalid == NO) \
            {
                CGSize size = [[CCDirector sharedDirector] winSize];
                CGPoint loc = [touch location];
                float maxX = (size.width - SCREEN_BUFFER_PERCENTAGE * size.width);
                float minX = SCREEN_BUFFER_PERCENTAGE * size.width;
                float maxY = (size.height - SCREEN_BUFFER_PERCENTAGE * size.height);
                float minY = SCREEN_BUFFER_PERCENTAGE * size.height;
                
                CCLOG(@"Looking for touches from (%f, %f) to (%f, %f)", minX, minY, maxX, maxY);
                
                if(loc.x >= minX && loc.x <= maxX && loc.y >= minY && loc.y <= maxY)
                {
                    inArea = YES;
                }
            }
            
        }
        if(inArea) {
            return YES;
        }
    }
    return NO;
}

@end
