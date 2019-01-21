//
//  MS_Comment.h
//  MSSupport
//
//  Created by 张智 on 2019/1/14.
//  Copyright © 2019 MS_Module. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class MS_User;
@interface MS_Comment : NSObject
@property(nonatomic,strong)     MS_User*    commentOwner;
@property(nonatomic,assign)     NSInteger*  applaudCount;
@property(nonatomic,readonly)   NSString*   createDateStr;
@property(nonatomic,strong)     NSString*   commentStr;

/*
 *  获取的comment,需要传入全部有效参数
 *  新建的comment，applaudCount,createTime都传入0
 */
-(instancetype)initWithUser:(MS_User*)user commentStr:(NSString*)str applaudCount:(NSInteger*) applaudCount createTime:(NSTimeInterval) createTime;

@end

NS_ASSUME_NONNULL_END
