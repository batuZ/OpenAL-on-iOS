
/*
 *  被引用的类，评论
 */

#import <Foundation/Foundation.h>
#import "user.h"
NS_ASSUME_NONNULL_BEGIN

@interface comment : NSObject<NSCoding>
@property (nonatomic,strong)user* owner;
@property (nonatomic,strong)NSString* commentStr;
@property (nonatomic,assign)NSInteger applaund;
@end

NS_ASSUME_NONNULL_END
