#import "OpenALSupport.h"

@implementation OpenALSupport

+(BOOL)initAL{
    ALCcontext *newContext = alcGetCurrentContext();
    if(!newContext){
        ALCdevice *newDevice = alcOpenDevice(NULL);
        if (newDevice){
            newContext = alcCreateContext(newDevice, NULL);
            if (newContext){
                alcMakeContextCurrent(newContext);
            }else return NO;
        }else return NO;
    }
    return YES;
}
+(void)closeAL{
    ALCcontext *context = alcGetCurrentContext();
    if(!context){
        ALCdevice *device = alcGetContextsDevice(context);
        alcMakeContextCurrent(NULL);
        alcDestroyContext(context);
        alcCloseDevice(device);
    }
}

+(void)PlayAudioWithFilepath:(NSString*)filePath finish:(void(^)(void))callBack{
    ALsizei audioSize;
    ALvoid* audioData;
    ALenum format;
    ALsizei freq;
    ALuint bid, sid;
    audioData = [OpenALSupport GetAudioDataWithPath:filePath outDataSize:&audioSize outDataFormat:&format outSampleRate:&freq];
    alGenBuffers(1, &bid);
    [OpenALSupport alBufferDataStatic_BufferID:bid format:format data:audioData size:audioSize freq:freq];
    alGenSources(1, &sid);
    alSourcei(sid, AL_BUFFER, bid);
    alSourcePlay(sid);
    
    ALint state;
    do{
        alGetSourcei(sid, AL_SOURCE_STATE, &state);
        sleep(1);
    }while(state == AL_PLAYING);
    
    callBack();
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
    
    /**
     AudioStreamBasicDescription:
     mSampleRate;       采样率, eg. 44100
     mFormatID;         格式, eg. kAudioFormatLinearPCM
     mFormatFlags;      标签格式, eg. kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
     mBytesPerPacket;   每个Packet的Bytes数量, eg. 2
     mFramesPerPacket;  每个Packet的帧数量, eg. 1
     mBytesPerFrame;    (mBitsPerChannel / 8 * mChannelsPerFrame) 每帧的Byte数, eg. 2
     mChannelsPerFrame; 1:单声道；2:立体声, eg. 1
     mBitsPerChannel;   语音每采样点占用位数[8/16/24/32], eg. 16
     mReserved;         保留
     */
    
    
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

+(ALvoid*)GetAudioDataWithPath:(NSString*)path outDataSize:(ALsizei*)size outDataFormat:(ALenum*)format outSampleRate:(ALsizei*)freq{
    AudioStreamBasicDescription fileFormat;
    AudioStreamBasicDescription outputFormat;
    SInt64 fileLengthInFrames = 0;
    UInt32 propertySize = sizeof(fileFormat);
    ExtAudioFileRef audioFileRef = NULL;
    void* data = NULL;
    
    CFURLRef fileUrl = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef) path, NULL);
    OSStatus error = ExtAudioFileOpenURL(fileUrl, &audioFileRef);
    
    CFRelease(fileUrl);
    
    if (error != noErr)
    {
        NSLog(@"Audio GetAudioData ExtAudioFileOpenURL failed, error = %x, filePath = %@", (int) error, fileUrl);
        goto label_exit;
    }
    
    // get the audio data format
    error = ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileDataFormat, &propertySize, &fileFormat);
    
    if (error != noErr)
    {
        NSLog(@"Audio GetAudioData ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) failed, error = %x, filePath = %@", (int) error, fileUrl);
        goto label_exit;
    }
    
    if (fileFormat.mChannelsPerFrame > 2)
    {
        NSLog(@"Audio GetAudioData unsupported format, channel count = %u is greater than stereo, filePath = %@", fileFormat.mChannelsPerFrame, fileUrl);
        goto label_exit;
    }
    
    // set the client format to 16 bit signed integer (native-endian) data
    // maintain the channel count and sample rate of the original source format
    outputFormat.mSampleRate       = fileFormat.mSampleRate;
    outputFormat.mChannelsPerFrame = fileFormat.mChannelsPerFrame;
    outputFormat.mFormatID         = kAudioFormatLinearPCM;
    outputFormat.mBytesPerPacket   = outputFormat.mChannelsPerFrame * 2;
    outputFormat.mFramesPerPacket  = 1;
    outputFormat.mBytesPerFrame    = outputFormat.mChannelsPerFrame * 2;
    outputFormat.mBitsPerChannel   = 16;
    outputFormat.mFormatFlags      = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    
    // set the desired client (output) data format
    error = ExtAudioFileSetProperty(audioFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(outputFormat), &outputFormat);
    
    if(error != noErr)
    {
        NSLog(@"Audio GetAudioData ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat) failed, error = %x, filePath = %@", (int) error, fileUrl);
        goto label_exit;
    }
    
    // get the total frame count
    propertySize = sizeof(fileLengthInFrames);
    error        = ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileLengthFrames, &propertySize, &fileLengthInFrames);
    
    if(error != noErr)
    {
        NSLog(@"Audio GetAudioData ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) failed, error = %x, filePath = %@", (int) error, fileUrl);
        goto label_exit;
    }
    
    
    // read all the data into memory
    UInt32 framesToRead = (UInt32) fileLengthInFrames;
    UInt32 dataSize = framesToRead * outputFormat.mBytesPerFrame;
    
    *size = (ALsizei) dataSize;
    *format = outputFormat.mChannelsPerFrame > 1 ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
    *freq = (ALsizei) outputFormat.mSampleRate;
    
    
    data = malloc(dataSize);
    
    if (data != NULL)
    {
        AudioBufferList    dataBuffer;
        dataBuffer.mNumberBuffers              = 1;
        dataBuffer.mBuffers[0].mDataByteSize   = dataSize;
        dataBuffer.mBuffers[0].mNumberChannels = outputFormat.mChannelsPerFrame;
        dataBuffer.mBuffers[0].mData           = data;
        
        // read the data into an AudioBufferList
        error = ExtAudioFileRead(audioFileRef, &framesToRead, &dataBuffer);
        
        if(error != noErr)
        {
            free(data);
            data = NULL; // make sure to return NULL
            NSLog(@"Audio GetAudioData ExtAudioFileRead failed, error = %x, filePath = %@", (int) error, fileUrl);
            goto label_exit;
        }
    }
    
label_exit:
    
    // dispose the ExtAudioFileRef, it is no longer needed
    if (audioFileRef != 0)
    {
        ExtAudioFileDispose(audioFileRef);
    }
    return data;
}

+(ALvoid)alBufferDataStatic_BufferID:(ALint)bid format:(ALenum)format data:(ALvoid*)data size:(ALsizei) size freq:(ALsizei)freq{
    static alBufferDataStaticProcPtr proc = NULL;
    if(proc == NULL){
        proc = (alBufferDataStaticProcPtr)alcGetProcAddress(NULL, "alBufferDataStatic");
    }
    proc(bid,format,data,size,freq);
}
@end

