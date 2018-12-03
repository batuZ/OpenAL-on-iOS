//
//  LameSupport.h
//  MSSupport
//
//  Created by 张智 on 2018/12/2.
//  Copyright © 2018 MS_Module. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <lame/lame.h>

NS_ASSUME_NONNULL_BEGIN

@interface LameSupport : NSObject
@property (nonatomic, assign) BOOL stopRecord;

+ (instancetype)sharedInstance;
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
                           callback:(void(^)(BOOL result))callback;


// Use this FUNC convent to mp3 after record
+ (void)conventToMp3AfterWithCafFilePath:(NSString *)cafFilePath
                        mp3FilePath:(NSString *)mp3FilePath
                         sampleRate:(int)sampleRate
                           callback:(void(^)(BOOL result))callback;

@end

NS_ASSUME_NONNULL_END
