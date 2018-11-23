#import "AL_Pos_RootVC.h"

@interface AL_Pos_RootVC ()

@end

@implementation AL_Pos_RootVC

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
    
    // 定义listener位置和方向
    [self setListener];
    
    // 设置源属性
    alSourcei(sid,AL_LOOPING, AL_TRUE); //循环播放
    alSourcef(sid,AL_MAX_DISTANCE, 200.0f);
    alSourcef(sid,AL_REFERENCE_DISTANCE, 50.0f);
    [self setSource];
}
-(void)setSource{
    ALfloat sourcePos[]={_sound.frame.origin.x,_sound.frame.origin.y,0};
    alSourcefv(sid,AL_POSITION,sourcePos);
}
-(void)setListener{
    ALfloat listenerPos[]={_listener.frame.origin.x,_listener.frame.origin.y,20};
    ALfloat listenerOri[]={0,0,-1,0,1,0};
    alListenerfv(AL_POSITION,listenerPos);
    alListenerfv(AL_ORIENTATION,listenerOri);
}

- (IBAction)onPlayPress:(id)sender {
    alSourcePlay(sid);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    tagLoc = CGPointMake(_sound.frame.origin.x-pt.x, _sound.frame.origin.y-pt.y);
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    _sound.frame = CGRectMake(pt.x+tagLoc.x, pt.y+tagLoc.y, _sound.frame.size.width, _sound.frame.size.height);
    [self setSource];
    
    float sx = _sound.frame.origin.x;
    float sy = _sound.frame.origin.y;
    float lx = _listener.frame.origin.x;
    float ly = _listener.frame.origin.y;
    float x = sx - lx;
    float y = ly - sy;
    NSLog(@"Sound: x=%f,y=%f",x,y);
}

//测试混响
-(void)test{
    
    alcASASetSourceProcPtr sourceSetProc = (alcASASetSourceProcPtr)alcGetProcAddress(NULL, "alcASASetSource");
    
    // Source_Rendering_Quality(sid,ALC_IPHONE_SPATIAL_RENDERING_QUALITY_HEADPHONES);
    //type ALfloat    0.0 (dry) - 1.0 (wet) (0-100% dry/wet mix, 0.0 default)
    ALfloat val_4 = 0.5;
    sourceSetProc(ALC_ASA_REVERB_SEND_LEVEL,sid,&val_4,sizeof(val_4));
    
    // type ALfloat    -100.0 db (most occlusion) - 0.0 db (no occlusion, 0.0 default)
    ALfloat val_5 = -55;
    sourceSetProc(ALC_ASA_OCCLUSION,sid,&val_5,sizeof(val_5));
    
    // type ALfloat    -100.0 db (most obstruction) - 0.0 db (no obstruction, 0.0 default)
    ALfloat val_6 = -55;
    sourceSetProc(ALC_ASA_OBSTRUCTION,sid,&val_6,sizeof(val_6));
    
    
    
    
    alcASASetListenerProcPtr setProc = (alcASASetListenerProcPtr)alcGetProcAddress(NULL, "alcASASetListener");
    alcASAGetListenerProcPtr getProc = (alcASAGetListenerProcPtr) alcGetProcAddress(NULL, "alcASAGetListener");
    
    ALboolean value = AL_TRUE;
    ALfloat _value = 20;
    ALenum value_ = ALC_ASA_REVERB_ROOM_TYPE_LargeHall2;
    setProc(ALC_ASA_REVERB_ON,&value,sizeof(value));
    setProc(ALC_ASA_REVERB_GLOBAL_LEVEL,&_value,sizeof(_value));
    setProc(ALC_ASA_REVERB_ROOM_TYPE,&value_,sizeof(value_));
    
    ALfloat val_1 = 2.2;
    setProc(ALC_ASA_REVERB_EQ_GAIN,&val_1,sizeof(val_1));
    ALfloat val_2 = 2.2;
    setProc(ALC_ASA_REVERB_EQ_BANDWITH,&val_2,sizeof(val_2));
    ALfloat val_3 = 3.2;
    setProc(ALC_ASA_REVERB_EQ_FREQ,&val_3,sizeof(val_3));
    
    ALfloat res;
    ALuint resSz;
    getProc(ALC_ASA_REVERB_EQ_GAIN,&res,&resSz);
    getProc(ALC_ASA_REVERB_EQ_BANDWITH,&res,&resSz);
    getProc(ALC_ASA_REVERB_EQ_FREQ,&res,&resSz);
}
@end
