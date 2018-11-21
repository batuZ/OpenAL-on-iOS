#import "OpenALSupport.h"

@implementation OpenALSupport

-(void)initAL{
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
-(void)closeAL{
    ALCcontext *context = alcGetCurrentContext();
    ALCdevice *device = alcGetContextsDevice(context);
    alcMakeContextCurrent(NULL);
    alcDestroyContext(context);
    alcCloseDevice(device);
}

// By ExtndedAudioFile.h
-(ExtAudioFileRef)openExtAudioFile:(CFURLRef)FileURL{
    ExtAudioFileRef fileID;
    OSStatus err = noErr;
    err = ExtAudioFileOpenURL(FileURL, &fileID);
    if(err){
        NSLog(@"ExtAudioFileOpenURL FAILED, Error = %d",err);
        fileID = nil;
    }
    return fileID;
}
-(ALenum)getDataFormat:(ExtAudioFileRef)fileID{
    OSStatus err = noErr;
    AudioStreamBasicDescription audioDataInfo;
    UInt32 propertySize = sizeof(audioDataInfo);
    err = ExtAudioFileGetProperty(fileID, kExtAudioFileProperty_FileDataFormat, &propertySize, &audioDataInfo);
    if(err){
        NSLog(@"ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = %d",err);
        return -1;
    }
    if(audioDataInfo.mChannelsPerFrame>2){//每帧数据中的通道数。
        NSLog(@"Unsupported Format, channel count is greater than stereo");
        return -1;
    }
    return audioDataInfo.mChannelsPerFrame > 1 ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
}
-(ALsizei)getDataSize:(ExtAudioFileRef)fileID{
    OSStatus err = noErr;
    SInt64 theFileLengthInFrames = 0;
    UInt32 thePropSize = sizeof(theFileLengthInFrames);
    err = ExtAudioFileGetProperty(fileID, kExtAudioFileProperty_FileLengthFrames, &thePropSize, &theFileLengthInFrames);
    if(err){
        NSLog(@"ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) FAILED, Error = %d",err);
        return -1;
    }
    return (ALsizei)theFileLengthInFrames;
}
-(ALsizei)getDataSampleRate:(ExtAudioFileRef)fileID{
    OSStatus err = noErr;
    AudioStreamBasicDescription audioDataInfo;
    UInt32 propertySize = sizeof(audioDataInfo);
    err = ExtAudioFileGetProperty(fileID, kExtAudioFileProperty_FileDataFormat, &propertySize, &audioDataInfo);
    if(err){
        NSLog(@"ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = %d",err);
        return -1;
    }
    return audioDataInfo.mSampleRate;
}

// By AudioFile.h
-(AudioFileID)openAudioFile:(NSURL*)filePath{
    AudioFileID outAFID;
    OSStatus err = noErr;
    err = AudioFileOpenURL(
                           (__bridge CFURLRef)filePath,
                           kAudioFileReadPermission,
                           0,
                           &outAFID);
    if(err){
        NSLog(@"AudioFileOpenURL FAILED, Error = %d",err);
        return nil;
    }
    return outAFID;
}

-(UInt32)audioFileSize:(AudioFileID)fileID
{
    UInt64 outDataSize = 0;
    UInt32 thePropSize = sizeof(UInt64);
    OSStatus err = noErr;
    err = AudioFileGetProperty(fileID,
                               kAudioFilePropertyAudioDataByteCount,
                               &thePropSize,
                               &outDataSize);
    if(err){
        NSLog(@"AudioFileGetProperty(kAudioFilePropertyAudioDataByteCount) FAILED, Error = %d",err);
        return 0;
    }
    return (UInt32)outDataSize;
}


void* MyGetOpenALAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei*    outSampleRate)
{
    OSStatus                        err = noErr;
    SInt64                            theFileLengthInFrames = 0;
    AudioStreamBasicDescription        theFileFormat;
    UInt32                            thePropertySize = sizeof(theFileFormat);
    ExtAudioFileRef                    extRef = NULL;
    void*                            theData = NULL;
    AudioStreamBasicDescription        theOutputFormat;
    
    // Open a file with ExtAudioFileOpen()
    err = ExtAudioFileOpenURL(inFileURL, &extRef);
    if(err) { printf("MyGetOpenALAudioData: ExtAudioFileOpenURL FAILED, Error = %d\n", (int)err); goto Exit; }
    
    // Get the audio data format
    err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &theFileFormat);
    if(err) { printf("MyGetOpenALAudioData: ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = %d\n", (int)err); goto Exit; }
    if (theFileFormat.mChannelsPerFrame > 2)  { printf("MyGetOpenALAudioData - Unsupported Format, channel count is greater than stereo\n"); goto Exit;}
    
    // Set the client format to 16 bit signed integer (native-endian) data
    // Maintain the channel count and sample rate of the original source format
    theOutputFormat.mSampleRate = theFileFormat.mSampleRate;
    theOutputFormat.mChannelsPerFrame = theFileFormat.mChannelsPerFrame;
    
    theOutputFormat.mFormatID = kAudioFormatLinearPCM;
    theOutputFormat.mBytesPerPacket = 2 * theOutputFormat.mChannelsPerFrame;
    theOutputFormat.mFramesPerPacket = 1;
    theOutputFormat.mBytesPerFrame = 2 * theOutputFormat.mChannelsPerFrame;
    theOutputFormat.mBitsPerChannel = 16;
    theOutputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    
    // Set the desired client (output) data format
    err = ExtAudioFileSetProperty(extRef, kExtAudioFileProperty_ClientDataFormat, sizeof(theOutputFormat), &theOutputFormat);
    if(err) { printf("MyGetOpenALAudioData: ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat) FAILED, Error = %d\n", (int)err); goto Exit; }
    
    // Get the total frame count
    thePropertySize = sizeof(theFileLengthInFrames);
    err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileLengthFrames, &thePropertySize, &theFileLengthInFrames);
    if(err) { printf("MyGetOpenALAudioData: ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) FAILED, Error = %d\n", (int)err); goto Exit; }
    
    // Read all the data into memory
    UInt32 theFramesToRead = (UInt32)theFileLengthInFrames;
    UInt32 dataSize = theFramesToRead * theOutputFormat.mBytesPerFrame;;
    theData = malloc(dataSize);
    if (theData)
    {
        AudioBufferList        theDataBuffer;
        theDataBuffer.mNumberBuffers = 1;
        theDataBuffer.mBuffers[0].mDataByteSize = dataSize;
        theDataBuffer.mBuffers[0].mNumberChannels = theOutputFormat.mChannelsPerFrame;
        theDataBuffer.mBuffers[0].mData = theData;
        
        // Read the data into an AudioBufferList
        err = ExtAudioFileRead(extRef, &theFramesToRead, &theDataBuffer);
        if(err == noErr)
        {
            // success
            *outDataSize = (ALsizei)dataSize;
            *outDataFormat = (theOutputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
            *outSampleRate = (ALsizei)theOutputFormat.mSampleRate;
        }
        else
        {
            // failure
            free (theData);
            theData = NULL; // make sure to return NULL
            printf("MyGetOpenALAudioData: ExtAudioFileRead FAILED, Error = %d\n", (int)err); goto Exit;
        }
    }
    
Exit:
    // Dispose the ExtAudioFileRef, it is no longer needed
    if (extRef) ExtAudioFileDispose(extRef);
    return theData;
}

@end

