#import "HelloAL_RootVC.h"
#import "OpenALSupport.h"
@implementation HelloAL_RootVC
NSMutableDictionary *di=nil;
- (void)viewDidLoad {
    [super viewDidLoad];
    [OpenALSupport initAL];
    di = [[NSMutableDictionary alloc] init];
    di[@"Footsteps"] = @"/Users/Batu/Music/media/Footsteps.wav";    // 3s 1-16 44.1kHz
    di[@"fiveptone"] = @"/Users/Batu/Music/media/fiveptone.wav";    // 12S 6-16 48kHz
    di[@"stereo"] = @"/Users/Batu/Music/media/stereo.wav";          // 3s 2-16 22kHz
    di[@"wave1"] = @"/Users/Batu/Music/media/wave1.wav";            // 1s 1-16 44.1kHz
    di[@"wave2"] = @"/Users/Batu/Music/media/wave2.wav";            // 1s 1-16 44.1kHz
    di[@"wave3"] = @"/Users/Batu/Music/media/wave3.wav";            // 1s 1-16 44.1kHz
    
    di[@"sound_bubbles"] = @"/Users/Batu/Music/media/SoundFiles/sound_bubbles.wav"; //10s 1-16 22kHz
    di[@"sound_electric"] = @"/Users/Batu/Music/media/SoundFiles/sound_electric.wav"; //29s 1-16 22kHz
    di[@"sound_engine"] = @"/Users/Batu/Music/media/SoundFiles/sound_engine.wav"; //13s 1-16 22kHz
    di[@"sound_monkey"] = @"/Users/Batu/Music/media/SoundFiles/sound_monkey.wav"; //82s 1-16 48kHz
    di[@"sound_voices"] = @"/Users/Batu/Music/media/SoundFiles/sound_voices.wav"; //31s 1-16 44.1kHz
    di[@"wow"] = @"/Users/Batu/Music/QQ_music/wow.mp3"; //4m35s 2-16 44.1kHz
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [OpenALSupport closeAL];
}

- (IBAction)onPlay:(id)sender {
    //[self playOneFile];
    [self palyManyFiles];
}

#pragma mark -  play a static file
-(void)playOneFile{
    OSStatus err = noErr;
    AudioFileID fileID;
    UInt32 audioSize;
    ALvoid* audioData;
    ALenum format;
    ALsizei freq;
    ALuint bid, sid;
    NSURL* filePath;
    
    // get data info
    filePath = [NSURL URLWithString:di[@"wow"]];
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
    
    //把数据复制到Buffer,复制后要手动释放audioData
    //    alBufferData(bid, format, audioData, audioSize, freq);
    //    free(audioData);
    //    audioData = NULL;
    
    //数据不会在缓冲区中复制，因此在删除缓冲区之前无法释放数据，用来在外部管理data
    [OpenALSupport alBufferDataStatic_BufferID:bid format:format data:audioData size:audioSize freq:freq];
    
    // create&setting source
    alGenSources(1, &sid);
    alSourcei(sid, AL_BUFFER, bid);
    
    // play
    alSourcePlay(sid);
}

#pragma mark - play many files(buffer) with a source
//用于支持下载的数据流
-(void)palyManyFiles{
    UInt32 audioSize;
    ALvoid* audioData;
    ALenum format;
    ALsizei freq;
    ALuint bids[3],sid;
    
    NSArray* fileArr = @[di[@"wave1"], di[@"wave2"] ,di[@"wave3"]];
    alGenBuffers(3, bids);
    alGenSources(1, &sid);
    for (int i = 0 ; i < fileArr.count; i++) {
        audioData = [OpenALSupport GetAudioDataWithPath:fileArr[i] outDataSize:&audioSize outDataFormat:&format outSampleRate:&freq];
        [OpenALSupport alBufferDataStatic_BufferID:bids[i] format:format data:audioData size:audioSize freq:freq];
    }
    //附加一个或一组buffer到一个source上
    alSourceQueueBuffers(sid, 3, bids);
    alSourcePlay(sid);
    
}
-(void)updateSourceQueue:(ALuint)sid{
    ALint processed, queued, state;
    
    //获取处理队列，得出已经播放过的缓冲器的数量
    alGetSourcei(sid, AL_BUFFERS_PROCESSED, &processed);
    
    //获取缓存队列，缓存的队列数量
    alGetSourcei(sid, AL_BUFFERS_QUEUED, &queued);
    
    //获取播放状态，是不是正在播放
    alGetSourcei(sid, AL_SOURCE_STATE, &state);
    
    //停止状态
    if (state == AL_STOPPED ||state == AL_PAUSED ||state == AL_INITIAL){
        //如果没有数据,或数据播放完了
        if (queued < processed || queued == 0 ||(queued == 1 && processed ==1))
        {
            //停止播放
            alSourceStop(sid);
            alDeleteSources(1, &sid);
            return ;
        }
        
        if (state != AL_PLAYING)
        {
            alSourcePlay(sid);
        }
    }
    
    //将已经播放过的的数据删除掉
    while(processed--)
    {
        ALuint buff;
        //更新缓存buffer中的数据到source中
        alSourceUnqueueBuffers(sid, 1, &buff);
        //删除缓存buff中的数据
        alDeleteBuffers(1, &buff);
    }
}
@end
