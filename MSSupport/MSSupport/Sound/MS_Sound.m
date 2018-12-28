#import "MS_Sound.h"
#import "OpenALSupport.h"
#import "LameSupport.h"
#import <AVFoundation/AVFoundation.h>
@interface MS_Sound()
@property(class,nonatomic,readonly) ALuint sid;
@end
@implementation MS_Sound
{
    ALuint sid, bid;
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
        NSString* dir = [MS_Sound.cachesDir stringByAppendingString:@"DIR_SOUNDS/"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:dir])
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        NSString* name = [NSString stringWithFormat:@"%@.mp3",self.uuid];
        return [dir stringByAppendingString:name];
    }
}
-(NSString*)wavPath{
    NSString* dir = [MS_Sound.tempDir stringByAppendingString:@"DIR_SOUNDS/"];
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
    if(_msinfo.audioData == nil && [[NSFileManager defaultManager] fileExistsAtPath:self.mp3Path]){
        _msinfo.audioData = [OpenALSupport GetAudioDataWithPath:self.mp3Path outDataSize:&_msinfo.audioSize outDataFormat:&_msinfo.format outSampleRate:&_msinfo.freq];
        if(_msinfo.audioData){
            _msinfo.channels = _msinfo.format == AL_FORMAT_STEREO8 || _msinfo.format == AL_FORMAT_STEREO16 ? 2 : 1;
            _msinfo.bits =  _msinfo.format == AL_FORMAT_MONO8 || _msinfo.format == AL_FORMAT_STEREO8 ? 8 : 16;
            _msinfo.timeLength = _msinfo.audioSize / _msinfo.freq / _msinfo.channels /(_msinfo.bits / 8);
        }
    }
    return _msinfo;
}
+(ALuint)sid{
    if(_sid == AL_NONE){
        
    }
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
    NSError* err;
    if(self.msinfo.audioData && self.msinfo.audioSize > 0){                 //判断数据是否可用
        if([[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&err]){   //设置 AVAudioSession
            if([OpenALSupport initAL]){                                       //初始化OpenAL环境
                ALenum sourceState = [self getSourceState];                 //判断当前source状态
    
                switch (sourceState) {
                    case (AL_NONE):                     //未创建
                        if([self setupDataToOpenAL]){
                            ALog("AL_NONE加载数据成功。");
                        }else{
                            ALog("AL_NONE加载数据失败。");
                            return NO;
                        }
                        break;
                        
                    case AL_STOPPED:                    //播放完成或被用户手动停止，数据被清除
                        if([self setupDataToOpenAL]){
                             ALog("AL_STOPPED加载数据成功。");
                        }else{
                            ALog("AL_STOPPED加载数据失败。");
                            return NO;
                        }
                        break;
                        
                    case AL_INITIAL:                    //数据已加载，还没被播放
                        //ready for play, do nothing...
                        ALog("准备播放被未play的source");
                        break;
                        
                    case AL_PAUSED:                     //被用户手动暂停
                        //ready for play, do nothing...
                        ALog("准备播放被暂停的source");
                        break;
                        
                    case AL_PLAYING:                    //正在播放
                        ALog("正在播放中，不能重复执行play");
                        return YES;
                        break;
                        
                    default:
                        ALog("一个未知的 sourceState：%d",sourceState);
                        return NO;
                        break;
                }
                
                if(![[AVAudioSession sharedInstance] setActive:YES error:&err]){
                    ALog("AVAudioSession 会话启动错误：%s",[[err localizedDescription] UTF8String]);
                }
                
                alSourcePlay(sid);
                
                // callback delegates
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                    ALenum state;
                    ALfloat time;
                    do{
                        [NSThread sleepForTimeInterval:0.1f];
                        // 监控状态
                        alGetSourcei(self->sid, AL_SOURCE_STATE, &state);
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
                        alGetSourcef(self->sid, AL_BYTE_OFFSET, &time);
                         if([self.delegate respondsToSelector:@selector(PlayProgress:)]){
                             dispatch_async(dispatch_get_main_queue(), ^{[self.delegate PlayProgress:time/self.msinfo.audioSize];});
                         }
                    }while(state == AL_PLAYING);
                    
                    //播放完毕代理
                    ALog("AL_PLAYING finished or puased");
                    if([self.delegate respondsToSelector:@selector(PlayFinished)]){
                        dispatch_async(dispatch_get_main_queue(), ^{[self.delegate PlayFinished];});
                    }
                    //清理内存
                    [OpenALSupport closeAL];
                    
                    //关闭会话
                    NSError* err;
                    if(![[AVAudioSession sharedInstance] setActive:NO error:&err]){
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
                    }else{
                        ALog("AVAudioSession 会话关闭错误：%s",[[err localizedDescription] UTF8String]);
                    }
                });
                return YES;
            }else{
                ALog("初始化OpenAL环境失败。");
                return NO;
            }
        }else{
            ALog("AVAudioSession 会话设置错误：%s",[[err localizedDescription] UTF8String]);
            return NO;
        }
    }else{
        ALog("文件不存在。");
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
        alSourceStop(sid);                      //停止播放
        [NSThread sleepForTimeInterval:0.5];
        alSourcei(sid, AL_BUFFER, 0);           //断开与数据的关联，否则不能释放数据内存
        alDeleteSources(1, &sid);
        sid = AL_NONE;
        alDeleteBuffers(1, &bid);
        bid = AL_NONE;
        
        free(_msinfo.audioData);                //释放数据
        _msinfo.audioData = nil;
        
        [[AVAudioSession sharedInstance] setActive:NO error:nil];   //停止会话
        [[NSNotificationCenter defaultCenter] removeObserver:self]; //移除所有通知
         ALog("已经停止播放。");
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
        NSURL* url = [NSURL fileURLWithPath:self.wavPath];
        NSError* error;
        _msRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.recorderSetting error:&error];
        [_msRecorder prepareToRecord];
        [_msRecorder setMeteringEnabled:YES];
        
        if(error){
            ALog("录音机初始化失败。");
            return NO;
        }
        
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [session setActive:YES error:nil];
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
#pragma mark - AVAudioSession
-(void)audioSessionInterruption:(NSNotification *)notification{
    [self StopPlay_Clear];
    ALog("audioSessionInterruption");
}
-(void)audioSessionRouteChange:(NSNotification *)notification{
    [self StopPlay_Clear];
     ALog("audioSessionRouteChange");
}
#pragma mark - helpers
//获取sid状态
-(ALenum)getSourceState{
    ALenum s = AL_NONE;
    if(sid)
        alGetSourcei(sid, AL_SOURCE_STATE, &s);
    return s;
}
-(BOOL)setupDataToOpenAL{

    alGenSources(1, &sid);
    if(alGetError()){
        ALog("AL_ERROR");
        return NO;
    }
    
    //sourceSetting
    alSource3f(sid, AL_POSITION, self.coordinate.longitude,self.coordinate.longitude,10);
    //距离和衰减
    alSourcef(sid,AL_MAX_DISTANCE, 20.0f);
    alSourcef(sid,AL_REFERENCE_DISTANCE, 20.0f);
    if(alGetError()){
        ALog("AL_ERROR");
        return NO;
    }
    
    alGenBuffers(1, &bid);
    //数据不会在缓冲区中复制，因此在删除缓冲区之前无法释放数据，用来在外部管理data
    [OpenALSupport alBufferDataStatic_BufferID:bid format:self.msinfo.format data:self.msinfo.audioData size:self.msinfo.audioSize freq:self.msinfo.freq];
    if(alGetError()){
        ALog("AL_ERROR");
        return NO;
    }
    
    alSourcei(sid, AL_BUFFER, bid);
    if(alGetError()){
        ALog("AL_ERROR");
        return NO;
    }
    return YES;
}
@end
