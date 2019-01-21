//
//  user.m
//  testPro01
//
//  Created by 张智 on 2019/1/21.
//  Copyright © 2019 aboutTabelView. All rights reserved.
//

#import "user.h"

@implementation user
- (instancetype)init
{
    self = [super init];
    if (self) {
        _uuid = [NSUUID UUID];
    }
    return self;
}
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_uuid forKey:@"uuid"];
    [aCoder encodeObject:_name forKey:@"name"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _uuid = [aDecoder decodeObjectForKey:@"uuid"];
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

@end
