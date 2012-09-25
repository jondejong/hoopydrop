//
//  BackgroundLayer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/15/12.
//
//

#import "HoopyDrop.h"
#import "HDUtil.h"

@implementation BackgroundLayer

+(BackgroundLayer *) layer {
    return [BackgroundLayer node];
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString* imageName = [ScreenImage convertImageName:@"start_screen_bg"];
        CCSprite* background = [CCSprite spriteWithFile:imageName];
        background.position = ccp(0,0);
        background.anchorPoint = ccp(0,0);
        [self addChild:background];
    }
    return self;
}

@end
