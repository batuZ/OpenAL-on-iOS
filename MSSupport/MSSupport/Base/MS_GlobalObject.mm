//
//  MS_GlobalObject.m
//  MSSupport
//
//  Created by 张智 on 2019/1/20.
//  Copyright © 2019 MS_Module. All rights reserved.
//
#define TEST_PATH @"/Users/Batu/Projects/TEST_HOME/"
#import "MS_GlobalObject.h"

//TimeStrFormatter
NSDateFormatter * get_G_TimeStrFormatter(){
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return fmt;
}
NSDateFormatter *g_TimeStrFormatter = get_G_TimeStrFormatter();

//TempDir
NSString* get_G_TempDir(){
    NSString* path;
#if TARGET_IPHONE_SIMULATOR
    path = [TEST_PATH stringByAppendingString: @"tmp/"];
#else
    path = NSTemporaryDirectory();
#endif
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* g_TempDir = get_G_TempDir();

//DocumentDir
NSString* get_G_DocumentDir(){
    NSString* path;
#if TARGET_IPHONE_SIMULATOR
    path = [TEST_PATH stringByAppendingString: @"Documents/"];
#else
    path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask , YES) firstObject];
    path = [path stringByAppendingString:@"/"];
#endif
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* g_DocumentDir = get_G_DocumentDir();

//CachesDir
NSString* get_G_CachesDir(){
    NSString* path;
#if TARGET_IPHONE_SIMULATOR
    path = [TEST_PATH stringByAppendingString: @"Caches/"];
#else
    path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingString:@"/"];
#endif
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* g_CachesDir = get_G_CachesDir();

@implementation MS_GlobalObject
//string to date
+ (NSDate*)string2date:(NSString*)str{
    NSDate *date = [g_TimeStrFormatter dateFromString:str];
    NSLog(@"%s__%d__|%@",__FUNCTION__,__LINE__,date);
    return date;
}

//date to string
+ (NSString*)date2string:(NSDate*)date{
    NSString *currentDateStr = [g_TimeStrFormatter stringFromDate:date];
    NSLog(@"%s__%d__|%@",__FUNCTION__,__LINE__,currentDateStr);
    return currentDateStr;
}

@end
