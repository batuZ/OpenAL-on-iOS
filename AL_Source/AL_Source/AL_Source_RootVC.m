#import "AL_Source_RootVC.h"

@interface AL_Source_RootVC ()

@end

@implementation AL_Source_RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [OpenALSupport initAL];
    OSStatus err = noErr;
    AudioFileID fileID;
    UInt32 audioSize;
    ALvoid* audioData;
    ALenum format;
    ALsizei freq;
    ALuint bid;
    NSURL* filePath;
    
    // get data info
    filePath = [NSURL URLWithString:@"/Users/Batu/Music/media/Footsteps.wav"];
    err = [OpenALSupport openAudioFile:filePath AudioFileID:&fileID];
    if(err) return;
    
    err = [OpenALSupport audioFileSize:fileID Size:&audioSize];
    if(err) return;
    
    err = [OpenALSupport audioFileFormat:fileID format:&format SampleRate:&freq];
    if(err) return;
    
    // read data
    audioData = malloc(audioSize);
    err = AudioFileReadBytes(fileID, false, 0, &audioSize, audioData);
    if(err) return;
    
    // create&setting buffer
    alGenBuffers(1, &bid);
    alBufferData(bid, format, audioData, audioSize, freq);
    
    // create&setting source
    alGenSources(1, &sid);
    alSourcei(sid, AL_BUFFER, bid);
    
    // 设置源属性
    [self setSource];
    [self setListener];
}
-(void)setSource{
    //设置声音的播放速度,默认为1.0
    //alSpeedOfSound(1.0);
    
    //多普勒效应，这属于高级范畴，不是做游戏开发，对音质没有苛刻要求的话，一般无需设置,默认为1.0
    //alDopplerVelocity(1.0);
    //alDopplerFactor(1.0);
    
    //在听众处指定要应用的音高。无论是在源头，还是在混音器上,默认为1.0
    //alSourcef(sid,AL_PITCH, 1.0f);
    
    //设置音量大小，1.0f表示最大音量。openAL动态调节音量大小就用这个方法,默认为1.0
    //alSourcef(sid,AL_GAIN, 1.0f);
    
    // 设置音频播放是否为循环播放，默认为AL_FALSE
    alSourcei(sid,AL_LOOPING, AL_TRUE);
    
    // 设置声音数据为流试，（openAL 针对PCM格式数据流）
    //alSourcef(sid,AL_SOURCE_TYPE, AL_STATIC);
    //alSourceQueueBuffers(sid,1, &bufferID);
    
    //这个属性告诉实现程序以渲染上下文环境的听从作为它原点来定位。
    //alSourcei(_sourceID,AL_SOURCE_RELATIVE,AL_TRUE);
    
    //距离和衰减
    //alSourcef(sid,AL_MAX_DISTANCE, 200.0f);
    //alSourcef(sid,AL_REFERENCE_DISTANCE, 200.0f);
    
    // 设置源的位置和速度，pos和方向有关，速度只影响alDoppler
    //ALfloat sourcePos[]={-1,0,0};
    //ALfloat sourceVel[]={0,0,0};
    //alSourcefv(sid,AL_POSITION,sourcePos);
    //alSourcefv(sid,AL_VELOCITY,sourceVel);
}
-(void)setListener{
    //ALfloat listenerPos[]={0,0,0};
    //ALfloat listenerVel[]={0,0,0};
    //ALfloat listenerOri[]={0,0,-1,0,1,0};
    //alListenerfv(AL_POSITION,listenerPos);
    //alListenerfv(AL_VELOCITY,listenerVel);
    //alListenerfv(AL_ORIENTATION,listenerOri);
}
- (IBAction)onPlayPress:(id)sender {
    alSourcePlay(sid);
}
@end
