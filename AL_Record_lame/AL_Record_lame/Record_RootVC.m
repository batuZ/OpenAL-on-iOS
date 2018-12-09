/**
 参考 https://github.com/CivelXu/iOS-Lame-Audio-transcoding
 */
#import "Record_RootVC.h"
#import "MS_Recorder.h"
#import "OpenALSupport.h"

@interface Record_RootVC ()
{
    NSString* mp3File;
}
@end

@implementation Record_RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [OpenALSupport initAL];
}
- (IBAction)RecordPress:(id)sender {
    if([[MS_Recorder getInstance] isRecording]){
        [_RecordBtn setTitle:@"Record" forState:UIControlStateNormal];
        [[MS_Recorder getInstance] stopRecordWithCallBack:^(NSString *res) {
            self->mp3File = res;
            if(res)
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.PlayBtn.enabled = YES;
                });
            else
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.PlayBtn.enabled = NO;
                });
        }];
    }else{
        [_RecordBtn setTitle:@"Stop" forState:UIControlStateNormal];
        [[MS_Recorder getInstance] startRecord:@"test"];
    }
}
- (IBAction)playPress:(UIButton *)sender {
    if(mp3File)
        [OpenALSupport PlayAudioWithFilepath:mp3File finish:^{}];
}

-(void)test{
    NSMutableArray* pointArr = [[NSMutableArray alloc] init];
    AVAudioRecorder *player = [[AVAudioRecorder alloc]init];
    
    player.meteringEnabled = YES;
    [player updateMeters];
    
    float peakPower = [player averagePowerForChannel:0];//分贝
    double peakPowerForChannel = pow(10, (0.05 * peakPower));//波形幅度
    [pointArr addObject:[NSNumber numberWithDouble:peakPowerForChannel]];
    
}
@end
