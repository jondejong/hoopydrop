//
//  ScreenImage.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/24/12.
//
//

#import "HDUtil.h"
#import "HoopyDrop.h"

@implementation ScreenImage

+(NSString*)convertImageName:(NSString*)baseName {
    return [NSString stringWithFormat:@"%@%@.png", baseName, [GameManager is16x9] ? @"-568h" : @"" ];
}

@end
