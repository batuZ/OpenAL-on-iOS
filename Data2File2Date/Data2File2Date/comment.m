//
//  comment.m
//  testPro01
//
//  Created by 张智 on 2019/1/21.
//  Copyright © 2019 aboutTabelView. All rights reserved.
//

#import "comment.h"

@implementation comment

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_owner forKey:@"owner"];
    [aCoder encodeObject:_commentStr forKey:@"commentStr"];
    [aCoder  encodeInteger:_applaund forKey:@"applaund"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self=[super init];
    if(self){
        _owner = [aDecoder decodeObjectForKey:@"owner"];
        _commentStr = [aDecoder decodeObjectForKey:@"commentStr"];
        _applaund = [aDecoder decodeIntegerForKey:@"applaund"];
    }
    return self;
}

@end
