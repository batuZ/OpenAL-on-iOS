//
//  MS_Sound.h
//  MSSupport
//
//  Created by 张智 on 2018/12/1.
//  Copyright © 2018 MS_Module. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "MSLocationObject.h"

NS_ASSUME_NONNULL_BEGIN

struct MS_SoundInfmation {
    NSTimeInterval timeLength;
    int audioSize;
    int freq;
    int format;
    int channels;
    int bits;
    void* audioData;
};
typedef struct MS_SoundInfmation MS_SoundInfmation;

@protocol MS_Sound_Delegate <NSObject>
@optional
-(void)PlayProgress:(float) progress;
-(void)PlayFinished;
-(CLLocation*)updateLisenerLocation;
-(CLHeading*)updateLisenerHeading;
@end


@interface MS_Sound : MSLocationObject
@property (nonatomic,weak) id<MS_Sound_Delegate> delegate;
@property (nonatomic,readonly) MS_SoundInfmation msinfo;
-(instancetype)initWithFile:(NSString*)filePath;

#pragma mark - Play
//-(BOOL)PlayWhithBlock:(void(^)(void))finished;
-(BOOL)play;
-(BOOL)pausePlay;
-(BOOL)StopPlay;



#pragma mark - Record
-(BOOL)Record;
-(BOOL)PuaseRecord;
-(BOOL)StopRecordWithBlock:(void(^)(NSString*))finished;
-(BOOL)CancelRecord;
//获取波形
-(float)normalizedValue;

@end

NS_ASSUME_NONNULL_END
