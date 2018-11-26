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
+(OSStatus)openAudioFile:(NSURL*)filePath AudioFileID:(AudioFileID*)fileID;
+(OSStatus)audioFileSize:(AudioFileID)fileID Size:(UInt32*)size;
+(OSStatus)audioFileFormat:(AudioFileID)fileID format:(ALenum*)format SampleRate:(ALsizei*)freq;

//
+(ALvoid)alBufferDataStatic_BufferID:(ALint)bid format:(ALenum)format data:(ALvoid*)data size:(ALsizei) size freq:(ALsizei)freq;


+(ALvoid)Rendering_Quality:(ALint)value;
@end

static alcMacOSXRenderingQualityProcPtr Rendering_Quality;
static alMacOSXRenderChannelCountProcPtr Render_Channel_Count;
static alcMacOSXMixerMaxiumumBussesProcPtr Mixer_Maxiumum_Busses;
static alcMacOSXMixerOutputRateProcPtr Mixer_Output_Rate;
static alcMacOSXGetRenderingQualityProcPtr Get_Rendering_Quality;
static alMacOSXGetRenderChannelCountProcPtr Get_Render_Channel_Count;
static alcMacOSXGetMixerMaxiumumBussesProcPtr Get_Mixer_Maxiumum_Busses;

static alSourceRenderingQualityProcPtr Source_Rendering_Quality;
static alSourceGetRenderingQualityProcPtr Source_Get_Rendering_Quality;

static alSourceNotificationProc Source_Notification;
static alSourceAddNotificationProcPtr Source_AddNotification;
static alSourceRemoveNotificationProcPtr Source_RemoveNotification;

static alcASAGetSourceProcPtr alc_ASA_Get_Source;
static alcASASetSourceProcPtr alc_ASA_Set_Source;
static alcASAGetListenerProcPtr alc_ASA_Get_Listener;
static alcASASetListenerProcPtr alc_ASA_SetListener;

static alcOutputCapturerPrepareProcPtr alc_OutputCapturer_Prepare;
static alcOutputCapturerStartProcPtr alc_OutputCapturer_Start;
static alcOutputCapturerAvailableSamplesProcPtr alc_OutputCapturer_AvailableSamples;
static alcOutputCapturerSamplesProcPtr alc_OutputCapturer_Samples;

NS_ASSUME_NONNULL_END
