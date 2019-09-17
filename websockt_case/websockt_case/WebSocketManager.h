//
//  WebSocketManager.h
//  webSocket
//
//  Created by 张智 on 2019/6/30.
//  Copyright © 2019 localFile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebSocketManager : NSObject
@property (nonatomic, strong) SRWebSocket *webSocket;
+ (instancetype)sharedSocketManager;//单例
- (void)connectServer;//建立长连接
- (void)SRWebSocketClose;//关闭长连接
- (void)sendDataToServer:(id)data;//发送数据给服务器
@end

NS_ASSUME_NONNULL_END
