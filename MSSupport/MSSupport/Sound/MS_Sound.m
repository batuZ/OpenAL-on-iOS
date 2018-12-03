//
//  MS_Sound.m
//  MSSupport
//
//  Created by 张智 on 2018/12/1.
//  Copyright © 2018 MS_Module. All rights reserved.
//

#import "MS_Sound.h"
#import "OpenALSupport.h"
#import "LameSupport.h"
#import <AVFoundation/AVFoundation.h>

@interface MS_Sound()
{
    ALuint sid,bid;
    ALvoid* audioData;
    
    AVAudioRecorder* _msRecorder;
    
}
@end
@implementation MS_Sound

#pragma - mark Play
-(BOOL)PlayWhithBlock:(void(^)(void))finished{
    ALsizei audioSize,freq;
    ALenum format;
    ALenum sourceState = AL_NONE;
    NSString* mp3Path = get_mp3_path(self.uuid);                    //获取MP3的本地路径
    if([[NSFileManager defaultManager] fileExistsAtPath:mp3Path]    //文件存在
       && [OpenALSupport initAL]){                                  //确认环境已初始化
        if(sid)                                                     //判断源状态
            alGetSourcei(sid, AL_SOURCE_STATE, &sourceState);       // 0 未创建
        // AL_INITIAL 未播放
        // AL_STOPPED 完成播放
        // AL_PAUSED 暂停
        // AL_PLAYING 正在播放
        
        if(sourceState == AL_NONE || sourceState == AL_INITIAL || sourceState == AL_STOPPED){
            
            audioData = [OpenALSupport GetAudioDataWithPath:mp3Path outDataSize:&audioSize outDataFormat:&format outSampleRate:&freq];
            if(audioData == NULL){
                ALog("打开文件失败。");
                return NO;
            }
            alGenBuffers(1, &bid);
            alGenSources(1, &sid);
            
            [OpenALSupport alBufferDataStatic_BufferID:bid format:format data:audioData size:audioSize freq:freq];
            
            alSourcei(sid, AL_BUFFER, bid);
            
            if(alGetError() != AL_NO_ERROR) {
                ALog("AL_ERROR = %d",alGetError());
                return NO;
            }
        }else if (sourceState == AL_PLAYING){
            return YES;
        }
        alSourcePlay(sid);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            ALenum state;
            do{
                [NSThread sleepForTimeInterval:0.5f];
                alGetSourcei(self->sid, AL_SOURCE_STATE, &state);
                ALog("AL_PLAYING...");
            }while(state == AL_PLAYING);
            ALog("AL_PLAYING finished");
            finished();
        });
        return YES;
    }
    else{
        ALog("文件不存在或初始化环境失败。");
        return NO;
    }
}
-(void)pausePlay{
    alSourcePause(sid);
}
-(void)StopPlay_Clear{
    alSourceStop(sid);
    alSourcei(sid, AL_BUFFER, 0);
    alDeleteSources(1, &sid);
    alDeleteBuffers(1, &bid);
    sid = AL_NONE;
    bid = AL_NONE;
}

#pragma - mark Record
-(BOOL)Record{
    if(_msRecorder && _msRecorder.isRecording){
        ALog("正在录音");
        return NO;
    }else{
        NSURL* url = [NSURL fileURLWithPath:get_wav_path(self.uuid)];
        NSError* error;
        _msRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:[self getRecorderSetting] error:&error];
        if(error){
            ALog("录音机初始化失败。");
            return NO;
        }
        [_msRecorder record];
        return YES;
    }
}
-(void)StopRecordWithBlock:(void(^)(NSString*))finished{
    if(_msRecorder!=nil){
        [_msRecorder stop];
        NSString* wav = get_wav_path(self.uuid);
        NSString* mp3 = get_mp3_path(self.uuid);
        [LameSupport conventToMp3AfterWithCafFilePath:wav mp3FilePath:mp3 sampleRate:44100 callback:^(BOOL result) {
            if(result)
                finished(mp3);
            else
                finished(nil);
            //删掉wav
            //[self->_msRecorder deleteRecording];
        }];
    }
}
-(void)CancelRecord{
    if(_msRecorder!=nil)
        [_msRecorder deleteRecording];//delete wav
}


#pragma mark - helpers
// 返回沙盒中Temp/Sounds与wav文件的组合路径
NSString* get_wav_path(NSString* _Nonnull uuid){
    NSString* soundD = [NSTemporaryDirectory() stringByAppendingString:@"/Sounds/"];
    NSString* name = [NSString stringWithFormat:@"%@.wav",uuid];
    return [soundD stringByAppendingString:name];
}
// 返回沙盒中Caches/Sounds与mp3文件的组合路径
NSString* get_mp3_path(NSString* _Nonnull uuid){
    NSString* cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString* soundD = [cachesDir stringByAppendingString:@"/Sounds/"];
    NSString* name = [NSString stringWithFormat:@"%@.mp3",uuid];
    return [soundD stringByAppendingString:name];
}
// 设置录音机
-(NSMutableDictionary *)getRecorderSetting{
    //创建一个Dictionary，用于保存录制属性
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc]init];
    
    //设置录制音频的格式
    [recordSettings setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    
    //设置录制音频的采样率，8000是电话采样率，对于一般录音已经够了
    [recordSettings setObject:@(44100) forKey:AVSampleRateKey];
    
    //设置录制音频的通道数,1声道
    [recordSettings setObject:@(2) forKey:AVNumberOfChannelsKey];
    
    //每个采样点位数,分为8、16、24、32
    [recordSettings setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    
    //设置录制音频采用高位优先的记录格式
    //[recordSettings setObject:[NSNumber numberWithBool:YES] forKey:AVLinearPCMIsBigEndianKey];
    
    //设置采样信号采用浮点数
    //[recordSettings setObject:[NSNumber numberWithBool:YES]forKey:AVLinearPCMIsFloatKey];
    
    [recordSettings setObject:@(AVAudioQualityMin) forKey:AVEncoderAudioQualityKey];
    return recordSettings;
}
@end
