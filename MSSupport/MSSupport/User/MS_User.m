//
//  MS_User.m
//  MSSupport
//
//  Created by 张智 on 2018/12/1.
//  Copyright © 2018 MS_Module. All rights reserved.
//

#import "MS_User.h"
@interface MS_User()
@property (nonatomic,strong) NSString* imagePath;
@end
@implementation MS_User
//当前用户
static MS_User* _CurrentUser = nil;
//当前用户是否登录
static BOOL _isCurrenUserLogin = NO;

#pragma mark - getters setters
+(MS_User*)CurrentUser{
    return _CurrentUser;
}
+(void)setCurrentUser:(MS_User *)CurrentUser{
    _CurrentUser = CurrentUser;
}
+(BOOL)isCurrenUserLogin{
    return _isCurrenUserLogin;
}
+(void)setIsCurrenUserLogin:(BOOL)isCurrenUserLogin{
    _isCurrenUserLogin = isCurrenUserLogin;
}
-(UIImage*)userImage{
    if(_userImage == nil){
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imagePath]];
        if(data)
            _userImage = [UIImage imageWithData:data];
    }
    return _userImage;
}

#pragma mark - 序列化

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_userID forKey:@"userID"];
    [aCoder encodeObject:_userName forKey:@"userName"];
    [aCoder encodeObject:_userImage forKey:@"userImage"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _userID = [aDecoder decodeObjectForKey:@"userID"];
        _userName = [aDecoder decodeObjectForKey:@"userName"];
        _userImage = [aDecoder decodeObjectForKey:@"userImage"];
    }
    return self;
}

@end
