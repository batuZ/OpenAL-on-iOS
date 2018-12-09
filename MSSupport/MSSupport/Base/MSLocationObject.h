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
#import "MS_LocationObject_Protocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface MSLocationObject : NSObject <MS_LocationObject_Protocol,NSCoding>
@property(nonatomic, readonly)  NSString*               uuid;
@property(nonatomic, assign)    CLLocationCoordinate2D  coordinate;
@property(nonatomic, readonly)  OBJ_TYPE                type;
//创建新对象
-(instancetype)initWithType:(OBJ_TYPE)type;
//读取已有对象到内存
-(instancetype)initWithUUID:(NSString*)uuid Location:(CLLocationCoordinate2D)coordinate TYPE:(OBJ_TYPE)type;
//禁用原构造函数
-(instancetype)init __attribute__((deprecated));
@end

NS_ASSUME_NONNULL_END


