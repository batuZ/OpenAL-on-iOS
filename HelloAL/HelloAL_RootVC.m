#import "HelloAL_RootVC.h"
#import "OpenALSupport.h"
@implementation HelloAL_RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [OpenALSupport initAL];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [OpenALSupport closeAL];
}

- (IBAction)onPlay:(id)sender {
    OSStatus err = noErr;
    AudioFileID fileID;
    UInt32 audioSize;
    ALvoid* audioData;
    ALenum format;
    ALsizei freq;
    ALuint bid, sid;
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
    
    // play
    alSourcePlay(sid);
}

@end
