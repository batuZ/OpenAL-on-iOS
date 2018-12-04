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
    AVAudioRecorder* _msRecorder;
}
@end
@implementation MS_Sound
- (instancetype)init{
    self = [super initWithType:SOUND];
    if (self) {
    }
    return self;
}

#pragma mark - Play
-(BOOL)PlayWhithBlock:(void(^)(void))finished{
    ALsizei audioSize,freq;
    ALenum format;
    ALenum err;
    NSString* mp3Path = get_mp3_path(self.uuid);                    //获取MP3的本地路径
#ifdef DEBUG
    mp3Path = @"/Users/Batu/Music/QQ_music/wow.mp3";
#endif
    if([[NSFileManager defaultManager] fileExistsAtPath:mp3Path]    //文件存在
       && [OpenALSupport initAL]){                                  //确认环境已初始化
        
        //判断源状态
        // 0 未创建
        // AL_INITIAL 未播放
        // AL_STOPPED 完成播放
        // AL_PAUSED 暂停
        // AL_PLAYING 正在播放
        ALenum sourceState = [self getSourceState];
        if(sourceState == AL_NONE || sourceState == AL_STOPPED){//未载入，或播放完被清理
            ALvoid* audioData = [OpenALSupport GetAudioDataWithPath:mp3Path outDataSize:&audioSize outDataFormat:&format outSampleRate:&freq];
            if(audioData == NULL){
                ALog("打开文件失败。");
                return NO;
            }
            alGenBuffers(1, &bid);
            alGenSources(1, &sid);
            //[OpenALSupport alBufferDataStatic_BufferID:bid format:format data:audioData size:audioSize freq:freq];
            alBufferData(bid, format, audioData, audioSize, freq);
            free(audioData);
            alSourcei(sid, AL_BUFFER, bid);
            
            err = alGetError();
            if(err != AL_NO_ERROR) {
                err =alGetError();
                ALog("AL_ERROR = %d",err);
                return NO;
            }
        }else if (sourceState == AL_PLAYING){
            return YES;//正在播放
        }
        alSourcePlay(sid);// AL_INITIAL|AL_PAUSED 时直接播放
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            ALenum state;
            do{
                [NSThread sleepForTimeInterval:0.5f];
                alGetSourcei(self->sid, AL_SOURCE_STATE, &state);
                ALog("AL_PLAYING...");
            }while(state == AL_PLAYING);
            ALog("AL_PLAYING finished or puased");
            finished();
        });
        return YES;
    }
    else{
        ALog("文件不存在或初始化环境失败。");
        return NO;
    }
}
-(BOOL)pausePlay{
    if([self getSourceState] == AL_PLAYING){
        alSourcePause(sid);
        return YES;
    }else{
        ALog("并没有在播放,不能暂停。");
        return NO;
    }
}
-(BOOL)StopPlay_Clear{
    ALenum state = [self getSourceState];
    if(state == AL_PLAYING || state == AL_PAUSED || state == AL_INITIAL){
        alSourceStop(sid);
        [NSThread sleepForTimeInterval:0.5];
        alSourcei(sid, AL_BUFFER, 0);
        alDeleteSources(1, &sid);
        alDeleteBuffers(1, &bid);
        sid = AL_NONE;
        bid = AL_NONE;
        return YES;
    }else{
        ALog("并没有加载音频,不能停止。");
        return NO;
    }
}


#pragma mark - Record
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
       return [_msRecorder record];
    }
}
-(BOOL)StopRecordWithBlock:(void(^)(NSString* res))finished{
    if(_msRecorder!=nil){
        [_msRecorder stop];
        NSString* mp3 = get_mp3_path(self.uuid);
        NSString* wav = get_wav_path(self.uuid);
        [LameSupport conventToMp3AfterWithCafFilePath:wav mp3FilePath:mp3 sampleRate:44100 callback:^(BOOL result) {
            if(result){
                finished(mp3);
            }
            else{
                finished(nil);
                ALog("wav转mp3失败。");
            }
        }];
        return YES;
    }else{
        ALog("录音机还没有创建，不能停止录音。");
        return NO;
    }
}
-(BOOL)CancelRecord{
    if(_msRecorder||_msRecorder.recording){
        ALog("录音机还没有创建，或正在录音，不能清除wav。");
        return NO;
    }
    else
       return [_msRecorder deleteRecording];//delete wav
}

#pragma mark - helpers
// 返回沙盒中Temp/Sounds与wav文件的组合路径
NSString* get_wav_path(NSString* _Nonnull uuid){
    NSString* soundD = [NSTemporaryDirectory() stringByAppendingString:@"/Sounds/"];
#ifdef DEBUG
    soundD = @"/Users/Batu/Music/testSound/";
#endif
    NSString* name = [NSString stringWithFormat:@"%@.wav",uuid];
    return [soundD stringByAppendingString:name];
}
// 返回沙盒中Caches/Sounds与mp3文件的组合路径
NSString* get_mp3_path(NSString* _Nonnull uuid){
    NSString* cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString* soundD = [cachesDir stringByAppendingString:@"/Sounds/"];
#ifdef DEBUG
    soundD = @"/Users/Batu/Music/testSound/";
#endif
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
//获取sid状态
-(ALenum)getSourceState{
    ALenum s = AL_NONE;
    if(sid)
        alGetSourcei(sid, AL_SOURCE_STATE, &s);
    return s;
}

@end
