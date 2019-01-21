//
//  MS_GlobalObject.h
//  MSSupport
//
//  Created by 张智 on 2019/1/20.
//  Copyright © 2019 MS_Module. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//全局宏

#ifdef DEBUG
#define ALog(...) printf("-->%s at %d : ",__FUNCTION__,__LINE__); printf(__VA_ARGS__);printf("\n")
#else
#define ALog(...)
#endif
#define GDKEY @"5e055d702d7c2e49e72632e1d7e36cb6"

//全局变量（对象）

// 时间格式化对象
extern NSDateFormatter *g_TimeStrFormatter;

//paths
extern NSString* g_DocumentDir;
extern NSString* g_TempDir;
extern NSString* g_CachesDir;

//全局函数
@interface MS_GlobalObject:NSObject

@end







