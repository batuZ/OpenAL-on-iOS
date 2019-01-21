#import "MS_Sound.h"
#import "OpenALSupport.h"
#import "LameSupport.h"
#import <AVFoundation/AVFoundation.h>
@interface MS_Sound()
@property(nonatomic,readonly,class) ALuint sid;
@end
@implementation MS_Sound
{
    ALuint bid;
    AVAudioRecorder* _msRecorder;
    NSMutableDictionary* _recorderSetting; // 设置录音机
    MS_SoundInfmation _msinfo;
    NSString* localPath;
}
static  ALuint _sid = AL_NONE;
#pragma mark - getters
// 返回沙盒中Temp/Sounds与wav文件的组合路径
-(NSString*)mp3Path{
    if(localPath&&[[NSFileManager defaultManager] fileExistsAtPath:localPath]){
        return localPath;
    }else{
        NSString* dir = [g_CachesDir stringByAppendingString:@"DIR_SOUNDS/"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:dir])
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        NSString* name = [NSString stringWithFormat:@"%@.mp3",self.uuid];
        return [dir stringByAppendingString:name];
    }
}
-(NSString*)wavPath{
    NSString* dir = [g_TempDir stringByAppendingString:@"DIR_SOUNDS/"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:dir])
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    NSString* name = [NSString stringWithFormat:@"%@.wav",self.uuid];
    return [dir stringByAppendingString:name];
}
-(NSMutableDictionary*)recorderSetting{
    if(_recorderSetting == nil){
        _recorderSetting = [[NSMutableDictionary alloc]init];
        //设置录制音频的格式
        [_recorderSetting setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
        
        //设置录制音频的采样率，8000是电话采样率，对于一般录音已经够了
        [_recorderSetting setObject:@(44100) forKey:AVSampleRateKey];
        
        //设置录制音频的通道数,1声道
        [_recorderSetting setObject:@(2) forKey:AVNumberOfChannelsKey];
        
        //每个采样点位数,分为8、16、24、32
        [_recorderSetting setObject:@(16) forKey:AVLinearPCMBitDepthKey];
        
        //设置录制音频采用高位优先的记录格式
        //[_recorderSetting setObject:[NSNumber numberWithBool:YES] forKey:AVLinearPCMIsBigEndianKey];
        
        //设置采样信号采用浮点数
        //[_recorderSetting setObject:[NSNumber numberWithBool:YES]forKey:AVLinearPCMIsFloatKey];
        
        [_recorderSetting setObject:@(AVAudioQualityMin) forKey:AVEncoderAudioQualityKey];
    }
    return _recorderSetting;
}
-(MS_SoundInfmation)msinfo{
    if(_msinfo.audioSize == 0 && [[NSFileManager defaultManager] fileExistsAtPath:self.mp3Path]){
        _msinfo.audioData = [OpenALSupport GetAudioDataWithPath:self.mp3Path outDataSize:&_msinfo.audioSize outDataFormat:&_msinfo.format outSampleRate:&_msinfo.freq];
        if(_msinfo.audioSize > 0){
            _msinfo.channels = _msinfo.format == AL_FORMAT_STEREO8 || _msinfo.format == AL_FORMAT_STEREO16 ? 2 : 1;
            _msinfo.bits =  _msinfo.format == AL_FORMAT_MONO8 || _msinfo.format == AL_FORMAT_STEREO8 ? 8 : 16;
            _msinfo.timeLength = _msinfo.audioSize / _msinfo.freq / _msinfo.channels /(_msinfo.bits / 8);
        }
    }
    return _msinfo;
}
+(ALuint)sid{
    if(_sid == AL_NONE){
        alGenSources(1, &_sid);
        //距离和衰减
        alSourcef(_sid,AL_MAX_DISTANCE, 20.0f);
        alSourcef(_sid,AL_REFERENCE_DISTANCE, 20.0f);    }
    return _sid;
}
#pragma mark - init
- (instancetype)init{
    self = [super init];
    if(self){
        _type = T_SOUND;
    }
    return self;
}

-(instancetype)initWithFile:(NSString*)filePath{
    self = [super init];
    if(self){
        _type = T_SOUND;
        localPath = filePath;
    }
    return self;
}

#pragma mark - Play
-(BOOL)play{
    if(self.msinfo.audioData && self.msinfo.audioSize > 0){                 //判断数据是否可用
        //在这之前必须指定一下 AVAudioSession 的 Category 类型
        if([OpenALSupport initAL]){                                       //初始化OpenAL环境
            ALenum sourceState = [self getSourceState];                 //判断当前source状态
            if(sourceState != AL_PAUSED){
                [self reSetSource]; // --> AL_INITIAL
                [self setupData];
            }
            
            alSourcePlay(MS_Sound.sid);
            
            //播放开始代理
            if(alGetError() == AL_NONE && [self.delegate respondsToSelector:@selector(PlayBegin)]){
                [self.delegate PlayBegin];
            }
            
            // callback delegates
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                ALenum state;
                ALfloat time;
                do{
                    [NSThread sleepForTimeInterval:0.1f];
                    // 监控状态
                    alGetSourcei(MS_Sound.sid, AL_SOURCE_STATE, &state);
                    //ALog("AL_PLAYING...");
                    
                    //lisener位置更新代理
                    if([self.delegate respondsToSelector:@selector(updateLisenerLocation)]){
                        CLLocation* loc = [self.delegate updateLisenerLocation];
                        alListener3f(AL_POSITION,loc.coordinate.longitude,loc.coordinate.longitude,0);
                        //ALog("%f, %f",loc.coordinate.longitude,loc.coordinate.latitude);
                    }
                    
                    //lisener方向更新代理
                    if([self.delegate respondsToSelector:@selector(updateLisenerHeading)]){
                        CLHeading* head = [self.delegate updateLisenerHeading];
                        float x = sinf(head.trueHeading*0.0174532925);
                        float y = cosf(head.trueHeading*0.0174532925);
                        ALfloat listenerOri[] = {x,y,0,  0,0,1};
                        //                          ALfloat listenerOri[]={0,1,0,0,0,1}; //面向北，头向上
                        alListenerfv(AL_ORIENTATION,listenerOri);
                        // ALog("%f",head.trueHeading);
                    }
                    
                    //播放进度代理
                    alGetSourcef(MS_Sound.sid, AL_BYTE_OFFSET, &time);
                    if([self.delegate respondsToSelector:@selector(PlayProgress:)]){
                        dispatch_async(dispatch_get_main_queue(), ^{[self.delegate PlayProgress:time/self->_msinfo.audioSize];});
                    }
                }while(state == AL_PLAYING);
                
                if(state == AL_PAUSED){
                    ALog("AL_PAUSED!");
                }else{
                    
                    //播放完毕代理
                    if([self.delegate respondsToSelector:@selector(PlayFinished)]){
                        dispatch_async(dispatch_get_main_queue(), ^{ [self.delegate PlayFinished]; });
                    }
                    
                    // 释放数据
                    [self freeData];
                    ALog("AL_STOPED!");
                }
            });
            return YES;
        }else{
            ALog("初始化OpenAL环境失败。");
            return NO;
        }
        
    }else{
        ALog("文件不存在。");
        return NO;
    }
}
-(BOOL)pausePlay{
    alSourcePause(MS_Sound.sid);
    ALog("已经暂停播放。");
    return YES;
}
-(BOOL)StopPlay{
    alSourceStop(MS_Sound.sid);
    [self freeData];
    ALog("已经停止播放。");
    return YES;
}


#pragma mark - Record
-(BOOL)Record{
    if(_msRecorder && _msRecorder.isRecording){
        ALog("正在录音");
        return NO;
    }else{
        NSURL* url = [NSURL fileURLWithPath:self.wavPath];
        NSError* error;
        _msRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.recorderSetting error:&error];
        [_msRecorder prepareToRecord];
        [_msRecorder setMeteringEnabled:YES];
        
        if(error){
            ALog("录音机初始化失败。");
            return NO;
        }
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
        //在这之前必须指定一下 AVAudioSession 的 Category 类型
        return [_msRecorder record];
    }
}
-(BOOL)PuaseRecord{
    if(_msRecorder!=nil){
        [_msRecorder pause];
    }
    return YES;
}
-(BOOL)StopRecordWithBlock:(void(^)(NSString* res))finished{
    if(_msRecorder!=nil){
        [_msRecorder stop];
        [LameSupport conventToMp3AfterWithCafFilePath:self.wavPath mp3FilePath:self.mp3Path sampleRate:44100 callback:^(BOOL result) {
            if(result){
                finished(self.mp3Path);
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
//获取录间时的电平值
-(float)normalizedValue{
    [_msRecorder updateMeters];
    //dB = 20*log(normalizedValue),分贝计算公式
    return pow (10, [_msRecorder averagePowerForChannel:0] / 20);
}

#pragma mark - helpers
//获取sid状态
-(ALenum)getSourceState{
    ALenum s = AL_NONE;
    if(MS_Sound.sid)
        alGetSourcei(MS_Sound.sid, AL_SOURCE_STATE, &s);
    return s;
}
-(void)reSetSource{
    alSourceRewind(MS_Sound.sid); // stop & move to begin
    [NSThread sleepForTimeInterval:0.5];
    alSourcei(MS_Sound.sid, AL_BUFFER, 0); // remove buffer
}
-(BOOL)setupData{
    //sourceLocation
    alSource3f(MS_Sound.sid, AL_POSITION, self.coordinate.longitude,self.coordinate.longitude,10);
    alGenBuffers(1, &bid);
    //数据不会在缓冲区中复制，因此在删除缓冲区之前无法释放数据，用来在self.msinfo管理data
    [OpenALSupport alBufferDataStatic_BufferID:bid format:self.msinfo.format data:self.msinfo.audioData size:self.msinfo.audioSize freq:self.msinfo.freq];
    alSourcei(MS_Sound.sid, AL_BUFFER, bid);
    if(alGetError()){
        ALog("AL_ERROR");
        return NO;
    }
    return YES;
}
-(void)freeData{
    [self reSetSource];
    alDeleteBuffers(1, &bid);
    bid = 0;
    //释放数据
    _msinfo = (MS_SoundInfmation){0,0,0,0,0,0,nil};
}
@end
