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
    float _jl;
}
@property (strong, nonatomic) CMMotionManager* motionManager;
@property (weak, nonatomic) IBOutlet UILabel *audioName;
@property (weak, nonatomic) IBOutlet UILabel *audioInfo;
@property (weak, nonatomic) IBOutlet UILabel *listenerHeading;
@property (weak, nonatomic) IBOutlet UILabel *listenerPos;

@property (weak, nonatomic) IBOutlet UILabel *listenerLab;
@property (weak, nonatomic) IBOutlet UILabel *soundLab;

@end

@implementation rootVC
NSMutableDictionary *di=nil;
- (void)viewDidLoad {
    [super viewDidLoad];
    [OpenALSupport initAL];
    self.motionManager = [[CMMotionManager alloc] init];
    audioFile = [[NSBundle mainBundle] pathForResource:@"Footsteps" ofType:@"wav"];
    _jl = sqrtf(pow((_soundLab.frame.origin.x - _listenerLab.frame.origin.x),2)+ pow((_soundLab.frame.origin.y - _listenerLab.frame.origin.y),2));
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

-(void)setListenerWithDeraction:(float)angre{
    //转头影响1、2
    float x = sinf(angre*0.0174532925);
    float y = cosf(angre*0.0174532925);
    ALfloat ori[] = {x,y,0,  0,0,1};
    self.listenerHeading.text = [NSString stringWithFormat:@"heading: %f {%0.2f, %0.2f, 0}",angre,x,y];
    self.soundLab.frame = CGRectMake(
                                     _listenerLab.frame.origin.x-x*_jl,
                                     _listenerLab.frame.origin.y-y*_jl,
                                     _soundLab.frame.size.width,
                                     _soundLab.frame.size.height);
    alListenerfv(AL_ORIENTATION, ori);
    alListener3f(AL_POSITION, 0, -1, 0);
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setListenerWithDeraction:(float)motion.heading];
                });
            }
        }];
    }
}
@end
