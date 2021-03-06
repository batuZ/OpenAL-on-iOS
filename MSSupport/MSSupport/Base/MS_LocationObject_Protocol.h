//全局宏

//#ifdef DEBUG
//#define ALog(...) printf("-->%s at %d : ",__FUNCTION__,__LINE__); printf(__VA_ARGS__);printf("\n")
//#else
//#define ALog(...)
//#endif
//#define GDKEY @"5e055d702d7c2e49e72632e1d7e36cb6"

//全局对象





#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,OBJ_TYPE)
{
    T_NONE            = 0,    //默认
    T_SOUND           = 1,    //声音
    T_SHOP            = 2,    //商店
    T_HELP_MESSAGE    = 3,    //求助
    T_TREASURE_CHEST  = 4,    //宝箱
    T_OTHER_USER      = 5     //其他用户
};

@protocol MS_LocationObject_Protocol <NSObject>

@property(nonatomic, readonly)  NSString*               uuid;
@property(nonatomic, assign)    CLLocationCoordinate2D  coordinate;
@property(nonatomic, readonly)  OBJ_TYPE                type;
@property(nonatomic, readonly)  NSInteger               createDate;

@end

NS_ASSUME_NONNULL_END
