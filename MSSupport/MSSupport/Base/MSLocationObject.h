//
//  MSLocationObject.h
//  MSSupport
//
//  Created by 张智 on 2018/12/2.
//  Copyright © 2018 MS_Module. All rights reserved.
/**
        所有带位置信息对象的基类
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,OBJ_TYPE)
{
    NONE = 0,
    SOUND = 1,
    USER = 2,
    OTHER
};

@interface MSLocationObject : NSObject
// 名称（唯一），初始化时自动生成。
@property(readonly,nonatomic)NSString* uuid;
// 对象类型
@property(readonly,nonatomic)OBJ_TYPE type;
//位置信息
@property(strong,nonatomic,nullable)CLLocation* location;
//图标
@property(strong, nonatomic) NSString* iconName;

-(instancetype)initWithType:(OBJ_TYPE)type;

//禁用初始化方法
-(instancetype)init __attribute__((deprecated));
@end

NS_ASSUME_NONNULL_END


#ifdef DEBUG
#define ALog(...) printf("-->%s at %d : ",__FUNCTION__,__LINE__); printf(__VA_ARGS__);printf("\n")
#else
#define ALog(...)
#endif
