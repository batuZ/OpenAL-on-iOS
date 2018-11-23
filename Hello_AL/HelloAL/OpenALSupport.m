#import "OpenALSupport.h"

@implementation OpenALSupport

+(void)initAL{
    ALCcontext *newContext = NULL;
    ALCdevice *newDevice = NULL;
    newDevice = alcOpenDevice(NULL);
    if (newDevice != NULL){
        newContext = alcCreateContext(newDevice, 0);
        if (newContext != NULL){
            alcMakeContextCurrent(newContext);
        }
    }
}
+(void)closeAL{
    ALCcontext *context = alcGetCurrentContext();
    ALCdevice *device = alcGetContextsDevice(context);
    alcMakeContextCurrent(NULL);
    alcDestroyContext(context);
    alcCloseDevice(device);
}


+(OSStatus)openAudioFile:(NSURL*)filePath AudioFileID:(AudioFileID*)fileID{
    OSStatus  err = AudioFileOpenURL(
                                     (__bridge CFURLRef)filePath,
                                     kAudioFileReadPermission,
                                     0,
                                     fileID);
    return err;
}
+(OSStatus)audioFileSize:(AudioFileID)fileID Size:(UInt32*)size{
    UInt64 outDataSize = 0;
    UInt32 thePropSize = sizeof(UInt64);
    OSStatus err = AudioFileGetProperty(fileID, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
    if(err) return err;
    *size = (UInt32)outDataSize;
    return err;
}
+(OSStatus)audioFileFormat:(AudioFileID)fileID format:(ALenum*)format SampleRate:(ALsizei*)freq{
    OSStatus err = noErr;
    AudioStreamBasicDescription info;
    UInt32 pSize = sizeof(info);
    err = AudioFileGetProperty(fileID, kAudioFilePropertyDataFormat, &pSize, &info);
    if(err) return err;
    
    *freq = info.mSampleRate;
    
    if(info.mBitsPerChannel == 8 && info.mChannelsPerFrame == 1){
        *format = AL_FORMAT_MONO8;//8位单通道
    }else if(info.mBitsPerChannel == 8 && info.mChannelsPerFrame == 2){
        *format = AL_FORMAT_STEREO8;//8位双通道
    }else if(info.mBitsPerChannel == 16 && info.mChannelsPerFrame == 1){
        *format = AL_FORMAT_MONO16;//16位单通道
    }else if(info.mBitsPerChannel == 16 && info.mChannelsPerFrame == 2){
        *format = AL_FORMAT_STEREO16;//16位双通道
    }else{
        return -1;//不能识别
    }
    return err;
}

+(ALvoid)Rendering_Quality:(ALint)value{
    static alcMacOSXRenderingQualityProcPtr Rendering_Quality = NULL;
    if(Rendering_Quality == NULL)
        Rendering_Quality = (alcMacOSXRenderingQualityProcPtr)alcGetProcAddress(NULL, "alcMacOSXRenderingQuality");
    return Rendering_Quality(value);
}
@end

