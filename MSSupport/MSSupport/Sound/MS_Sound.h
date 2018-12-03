//
//  MS_Sound.h
//  MSSupport
//
//  Created by 张智 on 2018/12/1.
//  Copyright © 2018 MS_Module. All rights reserved.
//

#import "MSLocationObject.h"

NS_ASSUME_NONNULL_BEGIN
@interface MS_Sound : MSLocationObject

-(instancetype)init;

#pragma mark - Play
-(BOOL)PlayWhithBlock:(void(^)(void))finished;
-(BOOL)pausePlay;
-(BOOL)StopPlay_Clear;

#pragma mark - Record
-(BOOL)Record;
-(void)StopRecordWithBlock:(void(^)(NSString*))finished;
-(void)CancelRecord;

@end

NS_ASSUME_NONNULL_END
