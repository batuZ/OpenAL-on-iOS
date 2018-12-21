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
    sound = [[MS_Sound alloc] init];
  
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

- (IBAction)save:(id)sender {
    MS_Sound *a = [MS_Sound new];
    MS_Sound *b = [[MS_Sound alloc] init];
    MS_Sound *c = [[MS_Sound alloc]init];
    
    [MS_Sound.locObjects setObject:a forKey:a.uuid];
    [MS_Sound.locObjects setObject:b forKey:b.uuid];
    [MS_Sound.locObjects setObject:c forKey:c.uuid];
    
    [MS_Sound saveALL];
}
- (IBAction)load:(id)sender {
    NSLog(@"%@",MS_Sound.locObjects);
}


@end
