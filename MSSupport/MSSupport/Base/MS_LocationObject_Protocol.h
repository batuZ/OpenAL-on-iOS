//
//  MS_LocationObject_Protocol.h
//  MSSupport
//
//  Created by 张智 on 2018/12/7.
//  Copyright © 2018 MS_Module. All rights reserved.
//
#ifdef DEBUG
#define ALog(...) printf("-->%s at %d : ",__FUNCTION__,__LINE__); printf(__VA_ARGS__);printf("\n")
#else
#define ALog(...)
#endif

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,OBJ_TYPE)
{
    NONE = 0,
    SOUND = 1,
    USER = 2,
    OTHER
};
@protocol MS_LocationObject_Protocol <NSObject>

@property(nonatomic, readonly)  NSString*               uuid;
@property(nonatomic, assign)    CLLocationCoordinate2D  coordinate;
@property(nonatomic, readonly)  OBJ_TYPE                type;
@end

NS_ASSUME_NONNULL_END
