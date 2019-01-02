//
//  HT_PlayerVC.m
//  HappyTime
//
//  Created by 张智 on 2018/12/30.
//  Copyright © 2018 CustemVedioPlayer. All rights reserved.
//

#import "HT_PlayerVC.h"
#import <AVFoundation/AVFoundation.h>

@interface HT_PlayerVC ()
@property (strong, nonatomic)AVPlayer *myPlayer;//播放器
@property (strong, nonatomic)AVPlayerItem *item;//播放单元
@property (strong, nonatomic)AVPlayerLayer *playerLayer;//播放界面（layer）
@property (strong, nonatomic)NSString* file;
@property (strong, nonatomic)UISlider *avSlider;//用来现实视频的播放进度，并且通过它来控制视频的快进快退。
@property (assign, nonatomic)BOOL isReadToPlay;//用来判断当前视频是否准备好播放。
@property (strong, nonatomic)UIButton* PlayBtn;
@property (strong, nonatomic)UILabel* timeLabel;
@property (strong, nonatomic)NSTimer* updateUITimer;
@end

@implementation HT_PlayerVC
{
    CGRect FastForward,Rewind;
}
-(instancetype)initWithFile:(NSString*)filePath{
    self = [super init];
    if (self) {
        self.file = filePath;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:self.file]];
    self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
    self.playerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.playerLayer];
    
    //通过KVO来观察status属性的变化，来获得播放之前的错误信息
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    //slider
    [self.avSlider addTarget:self action:@selector(avSliderAction) forControlEvents:
     UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside];
    [self.PlayBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.timeLabel];
    
    [self.navigationController.navigationBar setHidden:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                NSLog(@"item 有误");
                self.isReadToPlay = NO;
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"准好播放了");
                self.isReadToPlay = YES;
                self.avSlider.maximumValue = self.item.duration.value / self.item.duration.timescale;
                [self playAction:self.PlayBtn];
                 self.updateUITimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateUITimerAction) userInfo:nil repeats:YES];
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"视频资源出现未知错误");
                self.isReadToPlay = NO;
                break;
            default:
                break;
        }
    }
    //移除监听（观察者）
    [object removeObserver:self forKeyPath:@"status"];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* tc = [touches anyObject];
    CGPoint pt = [tc locationInView:self.view]; // 点击位置
    CGSize sz = self.view.frame.size;
    
    UIInterfaceOrientation fx =  [UIApplication sharedApplication].statusBarOrientation;    //屏幕方向
    switch (fx) {
        case UIInterfaceOrientationPortrait: //1.下
            FastForward = CGRectMake(0, 150, sz.width, 100);
            Rewind = CGRectMake(0, 0, sz.width, 100);
            break;
        case UIInterfaceOrientationLandscapeLeft://3.左
            FastForward = CGRectMake(0, 150, 100, 100);
            Rewind = CGRectMake(0, 0, 100, 100);
            break;
        case UIInterfaceOrientationLandscapeRight://4.右
            
            FastForward = CGRectMake(sz.width - 100, 150, 100, 100);
            Rewind = CGRectMake(sz.width-100, 0, 100, 100);
            break;
        default:
            break;
    }
    
    if(tc.tapCount == 1){
        int step = 0;
        if(CGRectContainsPoint(FastForward, pt)){
            step = 10;
            NSLog(@"FastForward");
        }
        if(CGRectContainsPoint(Rewind, pt)){
            step = -10;
            NSLog(@"Rewind");
        }
        if(step){
            CMTime tm = self.myPlayer.currentTime;
            tm.value =  (tm.value / tm.timescale + step ) * tm.timescale;
            //让视频从指定处播放
            [self.myPlayer seekToTime:tm completionHandler:^(BOOL finished) {
                if (finished) {
                    [self.myPlayer play];
                }
            }];
        }
    }
    else if(tc.tapCount == 2)
    {
    }
}

BOOL isPlaying = 0;
- (void)playAction:(UIButton*)sender{
    if (self.isReadToPlay){
        if(isPlaying){
            [self.myPlayer pause];
            [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        }else{
             [self.myPlayer play];
            [sender setImage:[UIImage imageNamed:@"puase"] forState:UIControlStateNormal];
        }
         isPlaying = !isPlaying;
    }else{
        NSLog(@"视频正在加载中");
    }
}

- (UISlider *)avSlider{
    if (!_avSlider) {
        _avSlider = [[UISlider alloc]initWithFrame:CGRectMake(60, self.view.bounds.size.height - 55, self.view.bounds.size.width - 60, 30)];
        _avSlider.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_avSlider];
    }return _avSlider;
}
-(UIButton*)PlayBtn{
    if(_PlayBtn == nil){
        _PlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGSize fa = self.view.frame.size;
        _PlayBtn.frame = CGRectMake(20, fa.height-55, 32, 32);
        [_PlayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        _PlayBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:_PlayBtn];
    }
    return _PlayBtn;
}
-(UILabel*)timeLabel{
    if(_timeLabel == nil){
        CGSize fa = self.view.frame.size;
        _timeLabel = [[UILabel alloc] initWithFrame: CGRectMake(fa.width - 190, fa.height - 40, 200, 40)];
        _timeLabel.textColor = [UIColor darkGrayColor];
        _timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return _timeLabel;
}

-(void)updateUITimerAction{
    CMTime tm = self.myPlayer.currentTime;
    self.avSlider.value = tm.value / tm.timescale;
    NSString* allTime = [self convertTimeToString: self.item.duration.value / self.item.duration.timescale];
    NSString* plyTime = [self convertTimeToString: tm.value / tm.timescale];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@",plyTime,allTime];
}

- (void)avSliderAction{
    //slider的value值为视频的时间
    float seconds = self.avSlider.value;
    //让视频从指定的CMTime对象处播放。
    CMTime startTime = CMTimeMakeWithSeconds(seconds, self.item.currentTime.timescale);
    //让视频从指定处播放
    [self.myPlayer seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
             [self.myPlayer play];
        }
    }];
}

// 翻转时更新画面尺寸、方向
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.playerLayer.frame = CGRectMake(0, 0, size.width, size.height);
   
}

// 时间格式化成字符串
- (NSString *)convertTimeToString:(NSInteger)second {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss"];
    NSDate *date = [formatter dateFromString:@"00:00:00"];
    date = [date dateByAddingTimeInterval:second];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.myPlayer pause];
}
@end
