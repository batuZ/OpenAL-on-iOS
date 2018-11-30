#import <Foundation/Foundation.h>
/** 使用OS集成的AL库，与OpenAL官方文档略有不同，但也可以查到很多资料 **/
#import <OpenAL/OpenAL.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenALSupport : NSObject
#pragma mark - 环境
+(void)initAL;
+(void)closeAL;

+(void)closeDataSources:(ALuint[])sources sourcesCount:(int) sCount buffers:(ALuint[])buffers buffersCount:(int) bCount;
+(void)PlayAudioWithFilepath:(NSString*)filePath finish:(void(^)(void))callBack;

+(ALvoid)alBufferDataStatic_BufferID:(ALint)bid format:(ALenum)format data:(ALvoid*)data size:(ALsizei) size freq:(ALsizei)freq;

#pragma mark - 获取数据源信息工具
+(ALvoid*)GetAudioDataWithPath:(NSString*)path outDataSize:(ALsizei*)size outDataFormat:(ALenum*)format outSampleRate:(ALsizei*)freq;
+(OSStatus)openAudioFile:(NSURL*)filePath AudioFileID:(AudioFileID*)fileID;
+(OSStatus)audioFileSize:(AudioFileID)fileID Size:(UInt32*)size;
+(OSStatus)audioFileFormat:(AudioFileID)fileID format:(ALenum*)format SampleRate:(ALsizei*)freq;
@end
NS_ASSUME_NONNULL_END
