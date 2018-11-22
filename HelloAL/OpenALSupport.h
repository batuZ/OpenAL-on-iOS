#import <Foundation/Foundation.h>
/** 使用OS集成的AL库，与OpenAL官方文档略有不同，但也可以查到很多资料 **/
#import <OpenAL/OpenAL.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenALSupport : NSObject

#pragma mark - 环境
+(void)initAL;
+(void)closeAL;

#pragma mark - 获取数据源信息工具
+(ExtAudioFileRef)openExtAudioFile:(CFURLRef)FileURL;
+(ALenum)getDataFormat:(ExtAudioFileRef)fileID;
+(ALsizei)getDataSize:(ExtAudioFileRef)fileID;
+(ALsizei)getDataSampleRate:(ExtAudioFileRef)fileID;

+(AudioFileID)openAudioFile:(NSURL*)filePath;
+(UInt32)audioFileSize:(AudioFileID)fileID;
+(UInt32)audioFileFormat:(AudioFileID)fileID;

+(OSStatus)AudioFileToBuffer:(const NSString*)filePath
               //  AudioFileID:(AudioFileID*)fileID
                      format:(ALenum*)format
                   audioData:(ALvoid**)data
                    dataSize:(UInt32*)size
                  SampleRate:(ALsizei*)freq;


static void* MyGetOpenALAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei*    outSampleRate);


@end

NS_ASSUME_NONNULL_END
