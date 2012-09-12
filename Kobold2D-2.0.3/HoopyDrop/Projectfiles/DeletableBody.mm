//
//  DeletableBody.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/11/12.
//
//

#import "HoopyDrop.h"
#import "Box2d.h"

@implementation DeletableBody {
    @private
    b2Body* _body;
    bool deleted;
}

- (id)init
{
    self = [super init];
    if (self) {
        deleted = false;
    }
    return self;
}

-(b2Body*) body {
    return _body;
}

-(void) setBody: (b2Body*) body {
    _body = body;
}

-(void) markDeleted {
    deleted = true;
}

-(bool) isAlreadyDeleted {
    return deleted;
}



@end
