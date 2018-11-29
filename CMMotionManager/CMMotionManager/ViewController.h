//
//  ViewController.h
//  CMMotionManager
//
//  Created by 张智 on 2018/11/24.
//  Copyright © 2018 OPENAL_EXAMPLE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *userAcceleration;
@property (weak, nonatomic) IBOutlet UILabel *rotationRate;
@property (weak, nonatomic) IBOutlet UILabel *magneticField_;
@property (weak, nonatomic) IBOutlet UILabel *attitude;
@property (weak, nonatomic) IBOutlet UILabel *gravity;
@property (weak, nonatomic) IBOutlet UILabel *heading;

@property (weak, nonatomic) IBOutlet UILabel *coor;
@property (weak, nonatomic) IBOutlet UILabel *head;

@property (weak, nonatomic) IBOutlet UILabel *juli;
@property (weak, nonatomic) IBOutlet UILabel *sudu;
@property (weak, nonatomic) IBOutlet UILabel *bushu;

@end

