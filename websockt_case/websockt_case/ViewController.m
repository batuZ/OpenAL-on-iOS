//
//  ViewController.m
//  websockt_case
//
//  Created by 张智 on 2019/7/1.
//  Copyright © 2019 localFile. All rights reserved.
//

#import "ViewController.h"
#import "MS_WebSocket_Manager.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *show_content;

@end

@implementation ViewController
{
    MS_WebSocket_Manager* webSocket_manager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    webSocket_manager = [MS_WebSocket_Manager sharedSocketManager];
 
    webSocket_manager.outBlock = ^(NSString * _Nonnull str) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_show_content setText:str];
        });
    };
}
- (IBAction)connect_action:(id)sender {
 
    [webSocket_manager connectServer];
   
}
- (IBAction)send:(id)sender {
    /*
     case data["command"]
     when "subscribe"   then add data
     when "unsubscribe" then remove data
     when "message"     then perform_action data
     */
    // data = {"command"=>"subscribe", "identifier"=>"{\"channel\":\"RoomChannel\"}"}
    NSDictionary* dic = @{@"command": @"subscribe",
                          @"identifier": @"{\"channel\":\"RoomChannel\"}"};
    
    // data = {"command"=>"message", "identifier"=>"{\"channel\":\"RoomChannel\"}", "data"=>"{\"msg\":\"客户端向服务器发送的消息。。。\",\"action\":\"print_log\"}"}
    dic = @{@"command": @"message",
            @"identifier": @"{\"channel\":\"RoomChannel\"}",
            @"data":@"{\"msg\":\"发送的消息。。。\", \"action\":\"print_log\"}"
            };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    [webSocket_manager sendDataToServer:jsonString];
}

- (IBAction)cancel:(id)sender {
    [webSocket_manager SRWebSocketClose];
}

@end
