/**
        所有带位置信息对象的基类
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MS_LocationObject_Protocol.h"
#import "MS_User.h"
#import "MS_Comment.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSLocationObject : NSObject <MS_LocationObject_Protocol,NSCoding>
{
@protected
    OBJ_TYPE _type;
}
//加载进内存的对象集合
@property (class, nonatomic, readonly)  NSMutableDictionary* locObjects;
//子类共用的目录属性
@property (class, nonatomic, readonly)  NSString* documentDir;
@property (class, nonatomic, readonly)  NSString* tempDir;
@property (class, nonatomic, readonly)  NSString* cachesDir;
//基础属性
@property (nonatomic, readonly)  NSString*               uuid;
@property (nonatomic, readonly)  OBJ_TYPE                type;
@property (nonatomic, readonly)  NSString*               createDateStr;

@property (nonatomic, assign)    CLLocationCoordinate2D  coordinate;
@property (nonatomic, strong)    NSString*               address;
//公开属性
@property (nonatomic, strong)    MS_User*                owner;
@property (nonatomic, assign)    NSInteger               likeCount;
@property (nonatomic, strong)    NSArray<MS_Comment*>*   comments;
//读取已有对象到内存
-(instancetype)initWithUUID:(NSString*)uuid Location:(CLLocationCoordinate2D)coordinate TYPE:(OBJ_TYPE)type date:(NSInteger)date;

+(BOOL)saveALL;
//getter
+(NSMutableDictionary*)locObjects;
@end

NS_ASSUME_NONNULL_END


