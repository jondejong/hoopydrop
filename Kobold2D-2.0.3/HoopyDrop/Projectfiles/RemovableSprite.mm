//
//  RemovableSprite.m
//  HoopyDrop
//
//  Created by Jon DeJong on 10/20/12.
//
//

#import "HoopyDrop.h"

@implementation RemovableSprite

@synthesize parentNode;
@synthesize sprite;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void) remove {
    [parentNode removeChild:sprite cleanup:YES];
}

@end
