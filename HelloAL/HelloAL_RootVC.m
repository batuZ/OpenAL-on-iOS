#import "HelloAL_RootVC.h"
#import "OpenALSupport.h"
@implementation HelloAL_RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // [OpenALSupport closeAL];
}

- (IBAction)onPlay:(id)sender {
    [OpenALSupport initAL];
    AudioFileID fileID;
    UInt32 audioSize;
    ALvoid* audioData;
    ALenum format;
    ALsizei freq;
    ALuint bid;
    ALuint sid;
    
    [OpenALSupport AudioFileToBuffer:@"/Users/Batu/Music/media/Footsteps.wav" format:&format audioData:&audioData dataSize:&audioSize SampleRate:&freq];

    alGenBuffers(1, &bid);
    alBufferData(bid, format, audioData, audioSize, freq);
    alGenSources(1, &sid);
    alSourcei(sid, AL_BUFFER, bid);
    alSourcePlay(sid);
}

@end
