//
//  locationObject.m
//  testPro01
//
//  Created by 张智 on 2019/1/21.
//  Copyright © 2019 aboutTabelView. All rights reserved.
//

#import "locationObject.h"

@implementation locationObject
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:_X forKey:@"x"];
    [aCoder encodeFloat:_Y forKey:@"y"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _X = [aDecoder decodeFloatForKey:@"x"];
        _Y = [aDecoder decodeFloatForKey:@"y"];
    }
    return self;
}

@end
