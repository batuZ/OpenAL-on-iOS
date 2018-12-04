//
//  LameSupport.m
//  MSSupport
//
//  Created by 张智 on 2018/12/2.
//  Copyright © 2018 MS_Module. All rights reserved.
//

#import "LameSupport.h"
#import "MSLocationObject.h"
@interface LameSupport()

@end

@implementation LameSupport
+ (instancetype)sharedInstance {
    static LameSupport *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LameSupport alloc] init];
    });
    return instance;
}
/**
 ConvertMp3
 
 @param cafFilePath caf FilePath
 @param mp3FilePath mp3 FilePath
 @param sampleRate sampleRate (same record sampleRate set)
 @param callback callback result
 */
- (void)conventToMp3SameTimeWithCafFilePath:(NSString *)cafFilePath
                        mp3FilePath:(NSString *)mp3FilePath
                         sampleRate:(int)sampleRate
                           callback:(void(^)(BOOL result))callback
{
    
    ALog("convert begin!!");
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        weakself.stopRecord = NO;
        
        @try {
            
            int read, write;
            
            FILE *pcm = fopen([cafFilePath cStringUsingEncoding:NSASCIIStringEncoding], "rb");
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb+");
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE * 2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_in_samplerate(lame, sampleRate);
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            long curpos;
            BOOL isSkipPCMHeader = NO;
            
            do {
                curpos = ftell(pcm);
                long startPos = ftell(pcm);
                fseek(pcm, 0, SEEK_END);
                long endPos = ftell(pcm);
                long length = endPos - startPos;
                fseek(pcm, curpos, SEEK_SET);
                
                if (length > PCM_SIZE * 2 * sizeof(short int)) {
                    
                    if (!isSkipPCMHeader) {
                        //Uump audio file header, If you do not skip file header
                        //you will heard some noise at the beginning!!!
                        fseek(pcm, 4 * 1024, SEEK_CUR);
                        isSkipPCMHeader = YES;
                        ALog("skip pcm file header !!!!!!!!!!");
                    }
                    
                    read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                    fwrite(mp3_buffer, write, 1, mp3);
                    ALog("read %d bytes",write);
                } else {
                    [NSThread sleepForTimeInterval:0.05];
                    ALog("sleep");
                }
                
            } while (! weakself.stopRecord);
            
            read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            ALog("read %d bytes and flush to mp3 file", write);
            lame_mp3_tags_fid(lame, mp3);
            
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            ALog("%s", [[exception description] UTF8String]);
            if (callback) {
                callback(NO);
            }
        }
        @finally {
            if (callback) {
                callback(YES);
            }
            ALog("convert mp3 finish!!! %s", [mp3FilePath UTF8String]);
        }
    });
}

/**
 send end record signal
 */
- (void)sendEndRecord2 {
    self.stopRecord = YES;
}



#pragma mark - ----------------------------------

// 这是录完再转码的方法, 如果录音时间比较长的话,会要等待几秒...
// Use this FUNC convent to mp3 after record

+ (void)conventToMp3AfterWithCafFilePath:(NSString *)cafFilePath
                        mp3FilePath:(NSString *)mp3FilePath
                         sampleRate:(int)sampleRate
                           callback:(void(^)(BOOL result))callback
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @try {
            int read, write;
            
            FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb+");  //output 输出生成的Mp3文件位置
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_num_channels(lame,1);//设置1为单通道，默认为2双通道
            lame_set_in_samplerate(lame, sampleRate);
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            do {
                
                read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0) {
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                    
                } else {
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                }
                
                fwrite(mp3_buffer, write, 1, mp3);
                
            } while (read != 0);
            
            lame_mp3_tags_fid(lame, mp3);
            
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            ALog("%s" ,[[exception description] UTF8String]);
            if (callback) {
                callback(NO);
            }
        }
        @finally {
            ALog("-----\n  MP3生成成功: %@   -----  \n", [mp3FilePath UTF8String]);
            if (callback) {
                callback(YES);
            }
        }
    });
}

@end
