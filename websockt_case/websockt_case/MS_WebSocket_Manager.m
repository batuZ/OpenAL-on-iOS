//
//  MS_WebSocket_Manager.m
//  websockt_case
//
//  Created by 张智 on 2019/7/1.
//  Copyright © 2019 localFile. All rights reserved.
//
//主线程异步队列
#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define WS(weakSelf) __weak typeof(self)weakSelf = self;

#import "MS_WebSocket_Manager.h"
#import "AFNetworking.h"
#import "SRWebSocket.h"

@interface MS_WebSocket_Manager()<SRWebSocketDelegate>
@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, strong) NSTimer *heartBeatTimer; //心跳定时器
@property (nonatomic, strong) NSTimer *netWorkTestingTimer; //没有网络的时候检测网络定时器
@property (nonatomic, strong) dispatch_queue_t queue; //数据请求队列（串行队列）
@property (nonatomic, assign) NSTimeInterval reConnectTime; //重连时间
@property (nonatomic, strong) NSMutableArray *sendDataArray; //存储要发送给服务端的数据
@property (nonatomic, assign) BOOL isActivelyClose;    //用于判断是否主动关闭长连接，如果是主动断开连接，连接失败的代理中，就不用执行 重新连接方法

@end

@implementation MS_WebSocket_Manager

#pragma mark - --------------- init ------------
+ (instancetype)sharedSocketManager {
    static MS_WebSocket_Manager *_instace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _instace = [[self alloc] init];
    });
    return _instace;
}
- (instancetype)init {
    self = [super init];
    if(self)
    {
        self.reConnectTime = 0;
        self.isActivelyClose = NO;
        self.queue = dispatch_queue_create("BF",NULL);
        self.sendDataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - --------------- 连接(断开)服务器 ------------
//建立长连接
- (void)connectServer
{
    self.isActivelyClose = NO;
    
    if(self.webSocket)
    {
        self.webSocket = nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"ws://localhost:3000/cable"]];
    [request addValue:@"hahahahahah" forHTTPHeaderField:@"mstoken"];
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    self.webSocket.delegate = self;
    [self.webSocket open];
}

//重新连接服务器
- (void)reConnectServer
{
    if(self.webSocket.readyState == SR_OPEN)
    {
        return;
    }
    
    if(self.reConnectTime > 1024)  //重连10次 2^10 = 1024
    {
        self.reConnectTime = 0;
        return;
    }
    
    WS(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reConnectTime *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(weakSelf.webSocket.readyState == SR_OPEN && weakSelf.webSocket.readyState == SR_CONNECTING)
        {
            return;
        }
        
        [weakSelf connectServer];
        NSLog(@"正在重连......");
        if(weakSelf.reConnectTime == 0)  //重连时间2的指数级增长
        {
            weakSelf.reConnectTime = 2;
        }
        else
        {
            weakSelf.reConnectTime *= 2;
        }
    });
}

//关闭连接
- (void)SRWebSocketClose;
{
    self.isActivelyClose = YES;
    
    if(self.webSocket)
    {
        [self.webSocket close];
        self.webSocket = nil;
    }
    
    //关闭心跳定时器
    [self destoryHeartBeat];
    
    //关闭网络检测定时器
    [self destoryNetWorkStartTesting];
}

#pragma mark - --------------- 发送数据 ------------
//发送数据给服务器
- (void)sendDataToServer:(id)data {
    [self.sendDataArray addObject:data];
    [self sendeDataToServer];
}

- (void)sendeDataToServer{
    WS(weakSelf);
    
    //把数据放到一个请求队列中
    dispatch_async(self.queue, ^{
        
        //没有网络
        if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
        {
            //开启网络检测定时器
            [weakSelf noNetWorkStartTestingTimer];
        }
        else //有网络
        {
            if(weakSelf.webSocket != nil)
            {
                // 只有长连接OPEN开启状态才能调 send 方法，不然会Crash
                if(weakSelf.webSocket.readyState == SR_OPEN)
                {
                    if (weakSelf.sendDataArray.count > 0)
                    {
                        NSString *data = weakSelf.sendDataArray[0];
                        [weakSelf.webSocket send:data]; //发送数据
                        [weakSelf.sendDataArray removeObjectAtIndex:0];
                        
                        if([weakSelf.sendDataArray count] > 0)
                        {
                            [weakSelf sendeDataToServer];
                        }
                    }
                }
                else if (weakSelf.webSocket.readyState == SR_CONNECTING) //正在连接
                {
                    NSLog(@"正在连接中，重连后会去自动同步数据");
                }
                else if (weakSelf.webSocket.readyState == SR_CLOSING || weakSelf.webSocket.readyState == SR_CLOSED) //断开连接
                {
                    //调用 reConnectServer 方法重连,连接成功后 继续发送数据
                    [weakSelf reConnectServer];
                }
            }
            else
            {
                [weakSelf connectServer]; //连接服务器
            }
        }
    });
}
#pragma mark - --------------- 代理 ------------
//连接成功回调
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    
    NSLog(@"webSocket ===  连接成功,status: %ld",(long)webSocket.readyState);
    [self initHeartBeat]; //开启心跳
    
    // 默认订阅
    [self subscriptions:@"RoomChannel"];
    
    
    //如果有尚未发送的数据，继续向服务端发送数据
    if ([self.sendDataArray count] > 0){
        [self sendeDataToServer];
    }
}
//连接失败回调
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    //用户主动断开连接，就不去进行重连
    if(self.isActivelyClose)
    {
        return;
    }
    
    [self destoryHeartBeat]; //断开连接时销毁心跳
    
    NSLog(@"连接失败，这里可以实现掉线自动重连，要注意以下几点");
    NSLog(@"1.判断当前网络环境，如果断网了就不要连了，等待网络到来，在发起重连");
    NSLog(@"3.连接次数限制，如果连接失败了，重试10次左右就可以了");
    
    //判断网络环境
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) //没有网络
    {
        [self noNetWorkStartTestingTimer];//开启网络检测定时器
    }
    else //有网络
    {
        [self reConnectServer];//连接失败就重连
    }
}

//连接关闭，是 [socket close] 客户端主动关闭，注意连接关闭不是连接断开，断开可能是断网了，被动断开的。
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    /* 在这里判断 webSocket 的状态 是否为 open， 大家估计会有些奇怪， 因为我们的服务器都在海外，
     会有些时间差，经过测试我们在进行某次连接的时候，上次重连的回调刚好回来，而本次重连又成功了，
     就会误以为本次没有重连成功，而再次进行重连，就会出现问题，所以在这里做了一下判断 */
    if(self.webSocket.readyState == SR_OPEN || self.isActivelyClose){
        return;
    }
    
    NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",code,reason,wasClean);
    
    [self destoryHeartBeat]; //断开连接时销毁心跳
    
    //判断网络环境
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) //没有网络
    {
        [self noNetWorkStartTestingTimer];//开启网络检测
    }
    else //有网络
    {
        [self reConnectServer];//连接失败就重连
    }
}



//收到服务器发来的数据
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSDictionary *dataDic = [self dictionaryWithJsonString:message];
    if([[dataDic allKeys] containsObject:@"type"]) return;
    NSLog(@">>>>>>>>>> %@, class: %@", message, [message class]);
    if([[dataDic allKeys] containsObject:@"message"]){
        NSLog(@">>>>>>>>>> %@", dataDic[@"message"][@"title"]);
        if(_outBlock)
            _outBlock(dataDic[@"message"][@"title"]);
    }
  
    /*根据具体的业务做具体的处理*/
}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - --------------- 心跳 ------------
//初始化心跳
- (void)initHeartBeat
{
    //心跳没有被关闭
    if(self.heartBeatTimer)
    {
        return;
    }
    
    [self destoryHeartBeat];
    
    WS(weakSelf);
    dispatch_main_async_safe(^{
        weakSelf.heartBeatTimer  = [NSTimer timerWithTimeInterval:10 target:weakSelf selector:@selector(senderheartBeat) userInfo:nil repeats:true];
        [[NSRunLoop currentRunLoop]addTimer:weakSelf.heartBeatTimer forMode:NSRunLoopCommonModes];
    });
}
//发送心跳
- (void)senderheartBeat
{
    //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
    WS(weakSelf);
    dispatch_main_async_safe(^{
        if(weakSelf.webSocket.readyState == SR_OPEN)
        {
            [weakSelf.webSocket sendPing:nil];
        }
    });
}

//该函数是接收服务器发送的pong消息，其中最后一个参数是接受pong消息的, 代理
-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData*)pongPayload
{
//    NSString* reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
//    NSLog(@"reply === 收到后台心跳回复 Data:%@",reply);
}

//取消心跳
- (void)destoryHeartBeat
{
    WS(weakSelf);
    dispatch_main_async_safe(^{
        if(weakSelf.heartBeatTimer)
        {
            [weakSelf.heartBeatTimer invalidate];
            weakSelf.heartBeatTimer = nil;
        }
    });
}
#pragma mark - --------------- 网络检测 ------------
//没有网络的时候开始定时 -- 用于网络检测
- (void)noNetWorkStartTestingTimer
{
    WS(weakSelf);
    dispatch_main_async_safe(^{
        weakSelf.netWorkTestingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:weakSelf selector:@selector(noNetWorkStartTesting) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:weakSelf.netWorkTestingTimer forMode:NSDefaultRunLoopMode];
    });
}
//定时检测网络
- (void)noNetWorkStartTesting
{
    //有网络
    if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable)
    {
        //关闭网络检测定时器
        [self destoryNetWorkStartTesting];
        //开始重连
        [self reConnectServer];
    }
}
//取消网络检测
- (void)destoryNetWorkStartTesting
{
    WS(weakSelf);
    dispatch_main_async_safe(^{
        if(weakSelf.netWorkTestingTimer)
        {
            [weakSelf.netWorkTestingTimer invalidate];
            weakSelf.netWorkTestingTimer = nil;
        }
    });
}

#pragma mark - --------------- MS 交互逻辑 ------------
// 订阅频道
-(void)subscriptions:(NSString*)channelName{
    NSDictionary* dic = @{@"command": @"subscribe",@"identifier": [NSString stringWithFormat:@"{\"channel\":\"%@\"}",channelName]};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self sendDataToServer:jsonString];
}

@end
