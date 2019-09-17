//
//  AL_Recode_ViewController.m
//  AL_Record_lame
//
//  Created by 张智 on 2019/9/2.
//  Copyright © 2019 OPENAL_EXAMPLE. All rights reserved.
//

#import "AL_Recode_ViewController.h"
#import "OpenALSupport.h"
#import <AVFoundation/AVFoundation.h>



@interface AL_Recode_ViewController ()

@end

@implementation AL_Recode_ViewController
{
    ALCdevice *cap_device;
    BOOL is_recode;
    NSMutableData* all;
    ALCcontext  *ply_Context;   //内容，相当于给音频播放器提供一个环境描述
    ALCdevice   *ply_Device;    //硬件，获取电脑或者ios设备上的硬件，提供支持
    ALuint      sid;   //音源，相当于一个ID,用来标识音源
//
//    NSCondition *ply_DecodeLock;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //在这之前必须指定一下 AVAudioSession 的 Category 类型
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    is_recode = NO;
    all = [NSMutableData data];
    
    ply_Device = alcOpenDevice(NULL);
    ply_Context = alcCreateContext(ply_Device, NULL);
    alcMakeContextCurrent(ply_Context);
}

- (IBAction)recode_start:(id)sender {
    if(!is_recode){
        is_recode = YES;
        
        cap_device = alcCaptureOpenDevice("cap", 44100, AL_FORMAT_MONO16, 512);
        alcCaptureStart(cap_device);
        if(alGetError()) return;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            ALint  sample ;
            while (self->is_recode) {
                alcGetIntegerv(self->cap_device, ALC_CAPTURE_SAMPLES, 1 ,&sample);
                if(alGetError()) return;
                char * buffer[2*sample];
                if (sample >= 512){
                    alcCaptureSamples(self->cap_device, buffer, sample);
                    [self->all appendBytes:buffer length:sample*2];
                }
            }
        });
        
    }
}

- (IBAction)recode_stop:(id)sender {
    is_recode = NO;
    alcCaptureStop(cap_device);
    alcCaptureCloseDevice(cap_device);
}

- (IBAction)play:(id)sender {
    ALuint bid;
    alGenBuffers(1, &bid);
     alBufferData(bid, AL_FORMAT_MONO16, [all bytes] , (ALsizei)[all length], 44100 );
    NSLog(@"all.lenght %lu", all.length);    NSLog(@">>>> 1 %d",alGetError());
    alGenSources(1, &sid);
    alSourcei(sid, AL_BUFFER, bid);
    NSLog(@">>>> 2 %d",alGetError());
    ALint  state;
    alGetSourcei(sid, AL_SOURCE_STATE, &state);
    NSLog(@">>>> 3 %d",alGetError());
     alSourcePlay(sid);
    do{
        alGetSourcei(sid, AL_SOURCE_STATE, &state);
        sleep(1);
         NSLog(@">>>> 4 %d",alGetError());
    }while(state == AL_PLAYING);
     NSLog(@">>>> 5 %d",alGetError());
    
    alSourcei(sid, AL_BUFFER, AL_NONE);
    alDeleteBuffers(1, &bid);
    alDeleteSources(1, &sid);
    NSLog(@">>>> 6 %d",alGetError());
}

- (IBAction)stop_play:(id)sender {
    ALint  state;
    alGetSourcei(sid, AL_SOURCE_STATE, &state);
    if (state != AL_STOPPED)
    {
        alSourceStop(sid);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
