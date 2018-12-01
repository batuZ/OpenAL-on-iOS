//
//  MS_Sound.m
//  MSSupport
//
//  Created by 张智 on 2018/12/1.
//  Copyright © 2018 MS_Module. All rights reserved.
//

#import "MS_Sound.h"
#import "OpenALSupport.h"
static ALuint bid,sid;
static ALenum sourceState;
@implementation MS_Sound
-(BOOL) funcTest{
    
    NSString* mp3Path = @"/Users/Batu/Music/QQ_music/wow.mp3";
    if([[NSFileManager defaultManager] fileExistsAtPath:mp3Path] && [OpenALSupport initAL]){
        alGetSourcei(sid, AL_SOURCE_STATE, &sourceState);
        if(sourceState == AL_INITIAL || sourceState == AL_STOPPED){
            ALsizei audioSize;
            ALvoid* audioData;
            ALenum format;
            ALsizei freq;
            audioData = [OpenALSupport GetAudioDataWithPath:mp3Path outDataSize:&audioSize outDataFormat:&format outSampleRate:&freq];
            if(!audioData)return NO;
            alGenBuffers(1, &bid);
            [OpenALSupport alBufferDataStatic_BufferID:bid format:format data:audioData size:audioSize freq:freq];
            alGenSources(1, &sid);
            alSourcei(sid, AL_BUFFER, bid);
            if(alGetError() != AL_NO_ERROR)return NO;
            alSourcePlay(sid);
            return YES;
        }else if (sourceState == AL_PAUSED){
            alSourcePlay(sid);
            return YES;
        }else{
            return NO;
        }
    }
    else{
        return NO;
    }
}
@end
