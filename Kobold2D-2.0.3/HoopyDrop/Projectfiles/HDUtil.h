//
//  HDUtil.h
//  HoopyDrop
//
//  Created by Jon DeJong on 9/24/12.
//
//

#import <Foundation/Foundation.h>
#import "KKInput.h"

@interface ScreenImage : NSObject

+(NSString*)convertImageName:(NSString*)baseName;

@end

@interface TouchUtil : CCLayer

+(bool) wasIntentiallyTouched;

@end