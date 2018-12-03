//
//  ViewController.m
//  forTest
//
//  Created by 张智 on 2018/12/3.
//  Copyright © 2018 MS_Module. All rights reserved.
//

#import "ViewController.h"
#import <MSSupport/MSSupport.h>
@interface ViewController ()
{
    MS_Sound* sound;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    sound = [[MS_Sound alloc]init];
}
- (IBAction)playTest:(id)sender {
    [sound PlayWhithBlock:^{
        ALog("Play Finishied,and call back!");
    }];
}
- (IBAction)playPuaseTest:(id)sender {
    [sound pausePlay];
}
- (IBAction)playStopTest:(id)sender {
    [sound StopPlay_Clear];
}

- (IBAction)recordTest:(id)sender {
    [sound Record];
}
- (IBAction)recordStopTest:(id)sender {
    [sound StopRecordWithBlock:^(NSString * res) {
        NSLog(@"%@",res);
    }];
}
- (IBAction)recordCancelTest:(id)sender {
    [sound CancelRecord];
}

@end
