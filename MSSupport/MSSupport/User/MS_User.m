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

#pragma mark - getter
-(UIImage*)userImage{
    if(_userImage == nil){
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imagePath]];
        if(data)
            _userImage = [UIImage imageWithData:data];
    }
    return _userImage;
}


#pragma mark - setter

@end
