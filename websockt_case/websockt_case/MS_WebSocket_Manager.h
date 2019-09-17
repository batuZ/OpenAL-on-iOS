//
//  MS_WebSocket_Manager.h
//  websockt_case
//
//  Created by 张智 on 2019/7/1.
//  Copyright © 2019 localFile. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MS_WebSocket_Manager : NSObject

+ (instancetype)sharedSocketManager;//单例
- (void)connectServer;//建立长连接
- (void)SRWebSocketClose;//关闭长连接
- (void)sendDataToServer:(id)data;//发送数据给服务器

@property (nonatomic, copy) void(^outBlock)(NSString* str);

@end

NS_ASSUME_NONNULL_END
