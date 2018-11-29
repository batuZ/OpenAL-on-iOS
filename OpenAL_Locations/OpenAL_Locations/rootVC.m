//
//  rootVC.m
//  OpenAL_Locations
//
//  Created by 张智 on 2018/11/29.
//  Copyright © 2018 testProject. All rights reserved.
//

#import "rootVC.h"
#import "OpenALSupport.h"
#import <CoreMotion/CoreMotion.h>
@interface rootVC ()
{
    ALuint bid, sid;
    NSString* audioFile;
    
}
@property (strong, nonatomic) CMMotionManager* motionManager;
@property (weak, nonatomic) IBOutlet UILabel *audioName;
@property (weak, nonatomic) IBOutlet UILabel *audioInfo;
@property (weak, nonatomic) IBOutlet UILabel *listenerHeading;
@property (weak, nonatomic) IBOutlet UILabel *listenerPos;
@end

@implementation rootVC
NSMutableDictionary *di=nil;
- (void)viewDidLoad {
    [super viewDidLoad];
    [OpenALSupport initAL];
    self.motionManager = [[CMMotionManager alloc] init];
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
    

   audioFile = [[NSBundle mainBundle] pathForResource:@"Footsteps" ofType:@"wav"];

    
}
-(void) copyFile{
    
    NSString* temp = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}
- (IBAction)playStop:(UIButton *)sender {
    ALint soucreState;
    alGetSourcei(sid, AL_SOURCE_STATE, &soucreState);
    if(soucreState!= AL_PLAYING)
    {
        [self startMotion];
        [self setSource];
        alSourcePlay(sid);
    }else{
        alSourceStop(sid);
        [self.motionManager stopDeviceMotionUpdates];
        //清理内存
    }
}

-(void)setSource{
    ALsizei audioSize,freq;
    ALvoid* audioData;
    ALenum format;
    [self getAudioInfo];
    audioData = [OpenALSupport GetAudioDataWithPath:audioFile outDataSize:&audioSize outDataFormat:&format outSampleRate:&freq];
    alGenBuffers(1, &bid);
    [OpenALSupport alBufferDataStatic_BufferID:bid format:format data:audioData size:audioSize freq:freq];
    alGenSources(1, &sid);
    //    alSourcef(sid,AL_MAX_DISTANCE, 200.0f);
    //    alSourcef(sid,AL_REFERENCE_DISTANCE, 50.0f);
    alSourcei(sid, AL_BUFFER, bid);
    alSourcei(sid, AL_LOOPING, AL_TRUE);
    alSource3f(sid, AL_POSITION, 0, 0, 1);
}

-(void)setListenerWithDeraction:(double)angre{
    alListener3f(AL_POSITION, 0, -1, 0);
    
    //转头影响1、2
    float x = sin(angre);
    float y = cos(angre);
    ALfloat ori[] = {x,y,0,  0,0,1};
    self.listenerHeading.text = [NSString stringWithFormat:@"heading: %0.1f {%0.3f}, {%0.3f}, 0",angre,x,y];
    alListenerfv(AL_ORIENTATION, ori);
}

-(void)getAudioInfo{
    AudioFileID fid;
    AudioFileOpenURL((__bridge CFURLRef)[NSURL URLWithString:audioFile],kAudioFileReadPermission,0,&fid);
    
    AudioStreamBasicDescription info;
    UInt32 pSize = sizeof(info);
    AudioFileGetProperty(fid, kAudioFilePropertyDataFormat, &pSize, &info);
    NSString *res = [NSString stringWithFormat:@"频率：%.f  通道：%d  位宽：%d",info.mSampleRate,info.mChannelsPerFrame,info.mBitsPerChannel];
    NSLog(@"%@", res);
    self.audioName.text = [audioFile lastPathComponent];
    self.audioInfo.text = res;
}

-(void)startMotion{
    if([self.motionManager isDeviceMotionAvailable]){
         self.motionManager.deviceMotionUpdateInterval = 0.1;
        NSOperationQueue* _queue = [[NSOperationQueue alloc] init];
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical toQueue:_queue withHandler:^(CMDeviceMotion * motion, NSError * error){
            if(error){
                NSLog(@"error:%@",error);
                [self.motionManager stopDeviceMotionUpdates];
            }else{
                [self setListenerWithDeraction:motion.heading];
            }
        }];
    }
}
@end
