//
//  BackgroundLayer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/15/12.
//
//

#import "HoopyDrop.h"

@implementation BackgroundLayer

+(BackgroundLayer *) layer {
    return [BackgroundLayer node];
}

- (id)init
{
    self = [super init];
    if (self) {
        CCSprite* background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(0,0);
        background.anchorPoint = ccp(0,0);
        [self addChild:background];
    }
    return self;
}

@end
