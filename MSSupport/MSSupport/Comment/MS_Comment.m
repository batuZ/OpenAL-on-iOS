//
//  MS_Comment.m
//  MSSupport
//
//  Created by 张智 on 2019/1/14.
//  Copyright © 2019 MS_Module. All rights reserved.
//

#import "MS_Comment.h"
#import "MS_GlobalObject.h"
@interface MS_Comment()
//创建时间的实体属性
@property (nonatomic,assign) NSInteger createTime;
@end
@implementation MS_Comment
-(instancetype)initWithUser:(MS_User*)user commentStr:(NSString*)str applaudCount:(NSInteger*) applaudCount createTime:(NSTimeInterval) createTime{
    self = [super init];
    if(self){
        _commentOwner = user;
        _commentStr = str;
        _applaudCount = applaudCount;
        if(createTime == 0){
             _createTime = [[NSDate date] timeIntervalSince1970];
        }else{
             _createTime = createTime;
        }
    }
    return self;
}

#pragma mark - getter
-(NSString*)createDateStr{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:_createTime];
    return [g_TimeStrFormatter stringFromDate:date];
}

@end
