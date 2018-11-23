//
//  MS_Recorder.m
//  AudioManager
//
//  Created by 张智 on 2018/11/15.
//  Copyright © 2018 myapp. All rights reserved.
//

#import "MS_Recorder.h"

@implementation MS_Recorder
+(instancetype)getInstance{
    static MS_Recorder* s = nil;
        @synchronized(self){
            if(s==nil){
                s = [[MS_Recorder alloc]init];
            }
        }
    return s;
}

-(BOOL)startRecord:(NSString*) uuid{
    if(_msRecorder && _msRecorder.isRecording)
    {
        [_msRecorder stop];
        return NO;
    }
    else{
#pragma mark 设置录音文件的保存路径信息
        //获取Documents目录路径
        NSString* dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
        //当前声音文件路径
        NSString* filePath = [dir stringByAppendingFormat:@"/%@.wav",uuid];
        
        //forTest
        filePath = @"/Users/Batu/Music/testSound/testSound.wav";
        
        //转为URL
        NSURL* url = [NSURL fileURLWithPath:filePath];
        
        NSError* error;
        _msRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:[self getRecorderSetting] error:&error];
        if(error)
        {
            NSLog(@"init error!");
            return NO;
        }
        _msRecorder.delegate = self;
        [_msRecorder record];
        
        return YES;
    }
}

-(void)stopRecord{
    if(self.msRecorder!=nil)
       [self.msRecorder stop];
}

-(void)cancel{
    [self.msRecorder deleteRecording];
}

-(NSMutableDictionary *)getRecorderSetting{
#pragma mark 下面设置录音的参数和录音文件的保存路径等信息
    //创建一个Dictionary，用于保存录制属性
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc]init];
    
    //设置录制音频的格式
    [recordSettings setObject:[NSNumber numberWithInt:kAudioFormatLinearPCM]forKey:AVFormatIDKey];
    
    //设置录制音频的采样率，8000是电话采样率，对于一般录音已经够了
    [recordSettings setObject:[NSNumber numberWithFloat:22050] forKey:AVSampleRateKey];
    
    //设置录制音频的通道数,1声道
    [recordSettings setObject:[NSNumber numberWithInt:2]forKey:AVNumberOfChannelsKey];
    
    //每个采样点位数,分为8、16、24、32
    [recordSettings setObject:@(16)forKey:AVLinearPCMBitDepthKey];
    
    //设置录制音频采用高位优先的记录格式
    [recordSettings setObject:[NSNumber numberWithBool:YES]forKey:AVLinearPCMIsBigEndianKey];
    
    //设置采样信号采用浮点数
    [recordSettings setObject:[NSNumber numberWithBool:YES]forKey:AVLinearPCMIsFloatKey];
    
    return recordSettings;
}
@end
