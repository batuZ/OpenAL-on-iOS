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

NS_ASSUME_NONNULL_BEGIN

@interface MS_Recorder : NSObject<AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioRecorder* msRecorder;

+(instancetype)getInstance;

-(BOOL)startRecord:(NSString*) uuid;
-(void)stopRecord;
-(void)cancel;
@end

NS_ASSUME_NONNULL_END
