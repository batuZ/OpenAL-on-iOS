//
//  MS_Recorder.h
//  AudioManager
//
//  Created by 张智 on 2018/11/15.
//  Copyright © 2018 myapp. All rights reserved.
//

#import <Foundation/Foundation.h>
//音频框架
#import <AVFoundation/AVFoundation.h>
#import <lame/lame.h>

NS_ASSUME_NONNULL_BEGIN

@interface MS_Recorder : NSObject

+(instancetype)getInstance;

-(void)startRecordWithName:(NSString*) uuid;
-(void)stopRecordWithCallBack:(void(^)(NSString* res))callback;
-(BOOL)isRecording;
-(void)cancel;
-(void)pause;
@end

NS_ASSUME_NONNULL_END
