
/*
 *  blog对象基类
 */

#import <Foundation/Foundation.h>
#import "user.h"
#import "comment.h"
NS_ASSUME_NONNULL_BEGIN

@interface baseObject : NSObject<NSCoding>
@property (nonatomic,strong)NSUUID* uuid;
@property (nonatomic,assign)NSInteger createTime;
@property (nonatomic,strong)user* owner;
@property (nonatomic,assign)NSInteger like;
@property (nonatomic,strong)NSArray<comment*>* comments;
@end

NS_ASSUME_NONNULL_END
