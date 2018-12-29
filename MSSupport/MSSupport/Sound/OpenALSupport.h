#import <Foundation/Foundation.h>
/** 使用OS集成的AL库，与OpenAL官方文档略有不同，但也可以查到很多资料 **/
#import <OpenAL/OpenAL.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenALSupport : NSObject
#pragma mark - 环境
+(BOOL)initAL;
//+(void)closeAL;

+(void)PlayAudioWithFilepath:(NSString*)filePath finish:(void(^)(void))callBack;

+(ALvoid)alBufferDataStatic_BufferID:(ALint)bid format:(ALenum)format data:(ALvoid*)data size:(ALsizei) size freq:(ALsizei)freq;

#pragma mark - 获取数据源信息工具
+(ALvoid*)GetAudioDataWithPath:(NSString*)path outDataSize:(ALsizei*)size outDataFormat:(ALenum*)format outSampleRate:(ALsizei*)freq;
+(OSStatus)openAudioFile:(NSURL*)filePath AudioFileID:(AudioFileID*)fileID;
+(OSStatus)audioFileSize:(AudioFileID)fileID Size:(UInt32*)size;
+(OSStatus)audioFileFormat:(AudioFileID)fileID format:(ALenum*)format SampleRate:(ALsizei*)freq;
@end
NS_ASSUME_NONNULL_END


/*!     源的状态及对函数响应方式
 *  alSourcePlay：
 *      AL_INITIAL  ->   将源提升为AL_PLAYING，因此缓冲区中找到的数据将从开始处进入处理。
 *      AL_PLAYING  ->   将从头开始重新启动源。 它不会影响配置，并且会使源处于AL_PLAYING状态，但会将采样偏移重置为开头。
 *      AL_PAUSED   ->   将使用alSourcePause操作中保留的源状态恢复处理。
 *      AL_STOPPED  ->   将其传播到AL_INITIAL，然后立即传播到AL_PLAYING。
 *
 *  alSourcePause：
 *      AL_INITIAL  ->   合法的NOP。
 *      AL_PLAYING  ->   将其状态更改为AL_PAUSED。 源免于处理，其当前状态被保留。
 *      AL_PAUSED   ->   合法的NOP。
 *      AL_STOPPED  ->   合法的NOP。
 *
 *  alSourceStop：
 *      AL_INITIAL  ->   合法的NOP。
 *      AL_PLAYING  ->   将其状态更改为AL_STOPPED。 源免于处理，其当前状态被保留。
 *      AL_PAUSED   ->   将其状态更改为AL_STOPPED。 源免于处理，其当前状态被保留。
 *      AL_STOPPED  ->   合法的NOP。
 *
 *  alSourceRewind：
 *      AL_INITIAL  ->   合法的NOP。
 *      AL_PLAYING  ->   将其状态更改为AL_STOPPED，然后更改为AL_INITIAL。 源免于处理：保留当前状态，但采样偏移除外，它被重置为开头。
 *      AL_PAUSED   ->   将其状态更改为AL_INITIAL。 源免于处理：保留当前状态，但采样偏移除外，它被重置为开头。
 *      AL_STOPPED  ->   将源提升为AL_INITIAL，将采样偏移重置为开头。
 */
