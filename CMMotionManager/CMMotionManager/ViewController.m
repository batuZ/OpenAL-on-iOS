//
//  ViewController.m
//  CMMotionManager
//
//  Created by 张智 on 2018/11/24.
//  Copyright © 2018 OPENAL_EXAMPLE. All rights reserved.


#import "ViewController.h"

@interface ViewController ()<CLLocationManagerDelegate>
@property (strong , nonatomic) CMMotionManager* motionManager;
@property (strong , nonatomic) NSOperationQueue *queue;
@property (strong , nonatomic) CLLocationManager* locationManager;
@property (strong , nonatomic) CMPedometer *pedometer;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self DeviceMotion];
    [self location];
    [self mypedometer];
}
-(void)DeviceMotion{
    //创建CMMotionManager对象
    self.motionManager = [[CMMotionManager alloc] init];
    self.queue = [[NSOperationQueue alloc] init];
    
    if([self.motionManager isDeviceMotionAvailable]){
        self.motionManager.deviceMotionUpdateInterval = 0.1;
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical toQueue:_queue withHandler:
         ^(CMDeviceMotion * motion, NSError * error) {
             NSString *labelText_1,*labelText_2,*labelText_3,*labelText_4,*labelText_5,*labelText_6;
             if(error){
                 [self.motionManager stopDeviceMotionUpdates];
                 
             }else{
                 // motion.attitude          返回设备的方位信息。旋转 YRP 四元数 旋转矩阵
                 // motion.rotationRate      返回原始的陀螺仪信息。
                 // motion.gravity           返回地球重力向量
                 // motion.userAcceleration  回用户外力的加速度
                 // motion.magneticField     返回校准后的磁场信息。
                 // motion.heading 返回相对于CMAttitude参考系在[0,360]度范围内的标题角度。 返回负值
                 labelText_1 = [NSString stringWithFormat:@"方位 X:%+.2f Y:%+.2f Z:%+.2f",
                                motion.attitude.pitch,
                                motion.attitude.roll,
                                motion.attitude.yaw];
                 labelText_2 = [NSString stringWithFormat:@"陀螺仪 X:%+.2f Y:%+.2f Z:%+.2f",
                                motion.rotationRate.x,
                                motion.rotationRate.y,
                                motion.rotationRate.z];
                 labelText_3 = [NSString stringWithFormat:@"地球重力 X:%+.2f Y:%+.2f Z:%+.2f",
                                motion.gravity.x,
                                motion.gravity.y,
                                motion.gravity.z ];
                 labelText_4 = [NSString stringWithFormat:@"用户外力 X:%+.2f Y:%+.2f Z:%+.2f",
                                motion.userAcceleration.x,
                                motion.userAcceleration.y,
                                motion.userAcceleration.z];
                 labelText_5 = [NSString stringWithFormat:@"校准后的磁场 X:%+.2f Y:%+.2f Z:%+.2f",
                                motion.magneticField.field.x,
                                motion.magneticField.field.y,
                                motion.magneticField.field.z];
                 labelText_6 = [NSString stringWithFormat:@"heading %+.2f",motion.heading];
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     self.attitude.text = labelText_1;
                     self.rotationRate.text =labelText_2;
                     self.gravity.text = labelText_3;
                     self.userAcceleration.text = labelText_4;
                     self.magneticField_.text = labelText_5;
                     self.heading.text = labelText_6;
                 });
             }
         }];
    }
}

-(void)location{
    if([CLLocationManager locationServicesEnabled]&&[CLLocationManager headingAvailable]){
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 0;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        [self.locationManager requestWhenInUseAuthorization];
        
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
    }else{
        NSLog(@"不可用");
    }
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations{
    CLLocation* loc = [locations firstObject];
    NSString* coor = [NSString stringWithFormat:@"经：%0.6f 纬：%0.6f 高：%0.2f",loc.coordinate.longitude,loc.coordinate.latitude,loc.altitude];
    self.coor.text = coor;
}
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(nonnull CLHeading *)newHeading{
    NSString* h = [NSString stringWithFormat:@"方向：%0.2f",newHeading.trueHeading];
    self.head.text = h;
}

-(void)mypedometer{
    if([CMPedometer isStepCountingAvailable]
       &&[CMPedometer isDistanceAvailable]
       &&[CMPedometer isPaceAvailable])
    {
        self.pedometer = [[CMPedometer alloc]init];
        [self.pedometer stopPedometerEventUpdates];
        [self.pedometer stopPedometerUpdates];
        [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            if(error)
                NSLog(@"error :  %@",error);
            else
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.juli.text = [NSString stringWithFormat: @"距离:%@", pedometerData.distance];
                    self.bushu.text = [NSString stringWithFormat:@"步数: %@",pedometerData.numberOfSteps];
                    self.sudu.text = [NSString stringWithFormat:@"速度:%@",pedometerData.currentPace];
                });
        }];
    }
}
@end
