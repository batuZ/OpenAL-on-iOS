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
    alSourcef(sid,AL_REFERENCE_DISTANCE, 100.0f);
    [self setSource];
}
-(void)setSource{
    ALfloat sourcePos[]={_sound.frame.origin.x,_sound.frame.origin.y,0};
    alSourcefv(sid,AL_POSITION,sourcePos);
}
-(void)setListener{
    ALfloat listenerPos[]={_listener.frame.origin.x,_listener.frame.origin.y,-1};
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
@end
