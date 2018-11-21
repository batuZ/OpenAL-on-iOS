#import "HelloAL_RootVC.h"
#import "OpenALSupport.h"
@implementation HelloAL_RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

//获取数据信息
-(void) getDataInfo{
    NSString* filePath=@"/Users/Batu/MyData/OpenAL/media/Footsteps.wav";
    CFURLRef fileURL = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)filePath, NULL);
    OpenALSupport* als = [[OpenALSupport alloc]init];
    [als initAL];
    ExtAudioFileRef fileID = [als openExtAudioFile:fileURL];
    ALenum dataFormat = [als getDataFormat:fileID];
    ALsizei dataSize = [als getDataSize:fileID];
    ALsizei dataSampleRate = [als getDataSampleRate:fileID];

    NSLog(@"fileID: %d, dataFormat: %d, dataSize: %d, dataSampleRate: %d ",(uint)fileID,dataFormat,dataSize,dataSampleRate);
    [als closeAL];
}

@end
