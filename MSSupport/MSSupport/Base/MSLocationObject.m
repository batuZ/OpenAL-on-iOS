//
//  MSLocationObject.m
//  MSSupport
//
//  Created by 张智 on 2018/12/2.
//  Copyright © 2018 MS_Module. All rights reserved.
//

#import "MSLocationObject.h"

@implementation MSLocationObject
-(instancetype)init{return nil;}
-(instancetype)initWithType:(OBJ_TYPE)type{
    self = [super init];
    if (self) {
        _uuid = [[NSUUID UUID] UUIDString];
        _type = type;
    }
    return self;
}

@end
