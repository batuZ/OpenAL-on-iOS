//
//  baseObject.m
//  testPro01
//
//  Created by 张智 on 2019/1/21.
//  Copyright © 2019 aboutTabelView. All rights reserved.
//

#import "baseObject.h"

@implementation baseObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        _uuid = [NSUUID UUID];
        _createTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:   _uuid       forKey:@"uuid"];
    [aCoder encodeInteger:  _createTime forKey:@"createTime"];
    [aCoder encodeObject:   _owner      forKey:@"owner"];
    [aCoder encodeInteger:  _like       forKey:@"like"];
    [aCoder encodeObject:   _comments   forKey:@"comments"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if(self){
        _uuid       = [aDecoder decodeObjectForKey:     @"uuid"];
        _createTime = [aDecoder decodeIntegerForKey:    @"createTime"];
        _owner      = [aDecoder decodeObjectForKey:     @"owner"];
        _like       = [aDecoder decodeIntegerForKey:    @"like"];
        _comments   = [aDecoder decodeObjectForKey:     @"comments"];
    }
    return self;
}

@end
