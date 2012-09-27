//
//  HDGamePlayBackground.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/25/12.
//
//

#import "HoopyDrop.h"

@implementation HDGamePlayBackground

- (id)init
{
    self = [super init];
    if (self) {
        
        [self addChild:[CCTMXTiledMap tiledMapWithTMXFile:[GameManager is16x9] ? @"hexabump-568@2x.tmx" : @"hexabump.tmx"] z:0];
    }
    return self;
}

@end
