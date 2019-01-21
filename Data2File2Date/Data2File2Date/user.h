
/*
 *  被引用的类，用户
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface user : NSObject<NSCoding>
@property (nonatomic,strong)NSUUID* uuid;
@property (nonatomic,strong)NSString* name;
@end

NS_ASSUME_NONNULL_END
