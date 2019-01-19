//
//  MS_Comment.m
//  MSSupport
//
//  Created by 张智 on 2019/1/14.
//  Copyright © 2019 MS_Module. All rights reserved.
//

#import "MS_Comment.h"
@interface MS_Comment()
//格式化时间，用于显示
@property (nonatomic,strong) NSDateFormatter *formatter;
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
    return [self.formatter stringFromDate:date];
}

-(NSDateFormatter*)formatter{
    if(!_formatter){
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _formatter;
}
@end
