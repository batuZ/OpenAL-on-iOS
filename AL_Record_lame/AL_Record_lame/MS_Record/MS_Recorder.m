//
//  MS_Recorder.m
//  AudioManager
//
//  Created by 张智 on 2018/11/15.
//  Copyright © 2018 myapp. All rights reserved.
//

#import "MS_Recorder.h"
#import "ConvertAudioFile.h"

@interface MS_Recorder ()<AVAudioRecorderDelegate>
{
    AVAudioRecorder* _msRecorder;
    
    NSMutableDictionary* _ecorderSetting;
    NSString* _rootDir;
    NSString* _wavPath;
    NSString* _mp3Path;
    BOOL deleteWAV; //是否在转MP3后立即删除WAV
}

@end

@implementation MS_Recorder


+(instancetype)getInstance{
    static MS_Recorder* s = nil;
    @synchronized(self){
        if(s==nil){
            s = [[MS_Recorder alloc]init];
            [s onInit];
        }
    }
    return s;
}

-(void)onInit{
    NSString* documets =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _rootDir = [documets stringByAppendingPathComponent:@"AudioData/"];
    _rootDir = @"/Users/Batu/Projects/TEST_HOME/tmp/DIR_SOUNDS/";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:_rootDir isDirectory:&isDir];
    if(!(isDirExist && isDir)){
        [fileManager createDirectoryAtPath:_rootDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    _ecorderSetting = [self getRecorderSetting];
    deleteWAV = YES;
}

-(void)startRecordWithName:(NSString*) uuid{
    if(_msRecorder && _msRecorder.isRecording){
        [_msRecorder stop];
    }else{
        _wavPath = [_rootDir stringByAppendingFormat:@"%@.wav",uuid];
        _mp3Path = [_rootDir stringByAppendingFormat:@"%@.mp3",uuid];
        
        NSURL* url = [NSURL fileURLWithPath:_wavPath];
        NSError* error;
        _msRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:[self getRecorderSetting] error:&error];
        if(error){
            NSLog(@"init error!");
            return ;
        }
        _msRecorder.delegate = self;
        [_msRecorder record];
    }
}

-(void)stopRecordWithCallBack:(void(^)(NSString* res))callback{
    if(_msRecorder!=nil){
        [_msRecorder stop];
        
        [ConvertAudioFile conventToMp3WithCafFilePath:_wavPath mp3FilePath:_mp3Path sampleRate:44100 callback:^(BOOL result) {
            if(result)
                callback(self->_mp3Path);
            else
                callback(nil);
            
            if(self->deleteWAV && [[NSFileManager defaultManager] fileExistsAtPath:self->_wavPath])
                [[NSFileManager defaultManager] removeItemAtPath:self->_wavPath error:nil];
        }];
    }
}

-(void)cancel{
    if(_msRecorder!=nil)
        [_msRecorder deleteRecording];//delete wav
}

-(BOOL)isRecording{
    return _msRecorder!=nil && [_msRecorder isRecording];
}
-(void)pause{
    if(_msRecorder!=nil){
        [_msRecorder pause];
    }
}
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
