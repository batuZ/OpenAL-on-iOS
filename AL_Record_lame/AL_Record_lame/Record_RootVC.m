/**
 参考 https://github.com/CivelXu/iOS-Lame-Audio-transcoding
        https://www.jianshu.com/p/3ba345028941
 */
#import "Record_RootVC.h"
#import "MS_Recorder.h"
#import "OpenALSupport.h"

@interface Record_RootVC ()
{
    NSString* mp3File;
    NSTimer* tim;
}
@property (nonatomic) NSTimeInterval second;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
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
        [tim invalidate];
    }else{
        [_RecordBtn setTitle:@"Stop" forState:UIControlStateNormal];
        [[MS_Recorder getInstance] startRecordWithName:@"test"];
        tim = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSecond:) userInfo:nil repeats:YES];
 
        
    }
}
- (IBAction)playPress:(UIButton *)sender {
    if(mp3File)
        [OpenALSupport PlayAudioWithFilepath:mp3File finish:^{}];
}
- (IBAction)pause:(id)sender {
    [[MS_Recorder getInstance] pause];
    
}

//执行更新UI的操作，每秒执行
- (void)updateSecond:(NSTimer *)timer {
    
    _second ++;
    if (_second == 1) {
       // [self enbleBtn];
    }
    //这个方法是把时间显示成时分秒的形式显示在label上
    NSString *timerStr = [self convertTimeToString:_second];
    _timerLabel.text = timerStr;
}
//规范时间格式
- (NSString *)convertTimeToString:(NSInteger)second {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    NSDate *date = [formatter dateFromString:@"00:00"];
    date = [date dateByAddingTimeInterval:second];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
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
/**
-(void)cut:(NSString*)filePath res:(NSString*)resultPath{
    //AVURLAsset是AVAsset的子类,AVAsset类专门用于获取多媒体的相关信息,包括获取多媒体的画面、声音等信息.而AVURLAsset子类的作用则是根据NSURL来初始化AVAsset对象.
    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    //音频输出会话
    //AVAssetExportPresetAppleM4A: This export option will produce an audio-only .m4a file with appropriate iTunes gapless playback data(输出音频,并且是.m4a格式)
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:videoAsset presetName:AVAssetExportPresetAppleM4A];
    //设置输出路径 / 文件类型 / 截取时间段
    exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
    exportSession.outputFileType = AVFileTypeWAVE;
    exportSession.timeRange = CMTimeRangeFromTimeToTime(CMTimeMake(time1, 1), CMTimeMake(time2, 1));
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        //exporeSession.status
    }];
}
-(void)coment:(NSString*)filePath1 p2:(NSString*)filePath2 res:(NSString*)resultPath{
    //AVURLAsset子类的作用则是根据NSURL来初始化AVAsset对象.
    AVURLAsset *videoAsset1 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:filePath1] options:nil];
    AVURLAsset *videoAsset2 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:filePath2] options:nil];
    //音频轨迹(一般视频至少有2个轨道,一个播放声音,一个播放画面.音频有一个)
    AVAssetTrack *assetTrack1 = [[videoAsset1 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    AVAssetTrack *assetTrack2 = [[videoAsset2 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    //AVMutableComposition用来合成视频或音频
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // 把第二段录音添加到第一段后面
    [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset1.duration) ofTrack:assetTrack1 atTime:kCMTimeZero error:nil];
    [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset2.duration) ofTrack:assetTrack2 atTime:videoAsset1.duration error:nil];
    //输出
    AVAssetExportSession *exporeSession = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    exporeSession.outputFileType = AVFileTypeAppleM4A;
    exporeSession.outputURL = [NSURL fileURLWithPath:resultPath];
    [exporeSession exportAsynchronouslyWithCompletionHandler:^{
        //exporeSession.status
    }];
}
 */
@end
