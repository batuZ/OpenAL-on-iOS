#import "MSLocationObject.h"

@interface MSLocationObject()
//本地文件保存路径
@property (class, nonatomic, readonly) NSString* locaDatalFile;
//创建时间的实体属性
@property (nonatomic,assign) NSInteger createDate;
@end

@implementation MSLocationObject

static NSMutableDictionary* _locObjects = nil;
#pragma mark - init
- (instancetype)init{
    self = [super init];
    if(self){
        _type = T_NONE;
        _uuid = [[NSUUID UUID] UUIDString];
        _createDate = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (instancetype)initWithUUID:(NSString*)uuid Location:(CLLocationCoordinate2D)coordinate TYPE:(OBJ_TYPE)type date:(NSInteger)date{
    self = [super init];
    if (self) {
        _uuid       = uuid;
        _coordinate = coordinate;
        _type       = type;
        _createDate = date;
    }
    return self;
}

#pragma mark - 序列化
// 序列化
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeInteger:self.createDate forKey:@"createDate"];
    [aCoder encodeObject:self.address forKey:@"address"];
}

// 反序列化
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _uuid = [aDecoder decodeObjectForKey:@"uuid"];
        CLLocationCoordinate2D coor;
        coor.latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        coor.longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        self.coordinate = coor;
        _createDate = [aDecoder decodeIntegerForKey:@"createDate"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
    }
    return self;
}


#pragma mark - functions
+(BOOL)saveALL{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_locObjects];
    return [data writeToFile: MSLocationObject.locaDatalFile atomically:YES];
}

+(BOOL)loadALL{
    NSData* data = [[NSData alloc] initWithContentsOfFile:MSLocationObject.locaDatalFile];
    if(data==nil){
        ALog("本地文件不存在或读取本地文件错误！");
        return NO;
    }
    _locObjects = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return YES;
}


#pragma mark - getter
-(NSString*)createDateStr{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:_createDate];
    return [g_TimeStrFormatter stringFromDate:date];
}

+(NSString*)locaDatalFile{
    return [g_CachesDir stringByAppendingString:@"localfiles.data"];
}

+(NSMutableDictionary*)locObjects{
    if(_locObjects == nil)
        [self loadALL];
    
    if(_locObjects == nil)
        _locObjects = [[NSMutableDictionary alloc]init];
    
    return _locObjects;
}
@end
