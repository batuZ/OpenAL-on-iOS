//
//  MS_User.h
//  MSSupport
//
//  Created by 张智 on 2018/12/1.
//  Copyright © 2018 MS_Module. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class MS_Comment;
@interface MS_User : NSObject<NSCoding>
@property(nonatomic,strong,class) MS_User*          CurrentUser;            //当前用户，默认为游客
@property(nonatomic,assign,class) BOOL              isCurrenUserLogin;      //当前用户是否登录
// 实例属性
@property(nonatomic,readonly)NSUUID *               userID;                //用户ID，唯一

//公开信息
@property(nonatomic,strong)NSString*                userName;               //用户昵称
@property(nonatomic,strong)UIImage*                 userImage;               //用户头像

//基础信息
@property(nonatomic,assign)NSInteger                telephong;              //手机号
@property(nonatomic,strong)NSString*                eMail;                  //邮箱
@property(nonatomic,assign)BOOL                     isBoy;                  //性别    1-boy 0-girl
@property(nonatomic,assign)NSInteger                birthday;               //生日    YYYYMMDD
@property(nonatomic,readonly)NSInteger              userCreateDate;         //用户注册时间

//基础属性
@property(nonatomic,readonly)CGFloat                rangeHearing;          //听力范围
@property(nonatomic,readonly)CGFloat                rangeExploration;      //探索范围

//社交信息
@property(nonatomic,readonly)NSArray<MS_User*>*     friendList;             //好友列表
@property(nonatomic,readonly)NSArray*               sendoutObjects;         //发布过的内容
@property(nonatomic,readonly)NSArray<MS_Comment*>*  commentList;            //发布过的评论


@end

NS_ASSUME_NONNULL_END
