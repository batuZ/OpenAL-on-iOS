#define TEST_PATH @"/Users/Batu/Projects/TEST_HOME/"

#import "MSLocationObject.h"
@interface MSLocationObject()
@property (nonatomic,strong) NSDateFormatter *formatter;
@property (class, nonatomic, readonly) NSString* locaDatalFile;
@end

@implementation MSLocationObject

static NSMutableDictionary* _locObjects = nil;

- (instancetype)init{return nil;}

- (instancetype)initWithType:(OBJ_TYPE)type{
    self = [super init];
    if(self){
        _type = type;
        _uuid = [[NSUUID UUID] UUIDString];
        _createDate = [NSDate date].timeIntervalSinceReferenceDate;
    }
    return self;
}
- (instancetype)initWithUUID:(NSString*)uuid Location:(CLLocationCoordinate2D)coordinate TYPE:(OBJ_TYPE)type date:(NSTimeInterval)date{
    self = [super init];
    if (self) {
        _uuid       = uuid;
        _coordinate = coordinate;
        _type       = type;
        _createDate = date;
    }
    return self;
}

//string to date
- (NSDate*)string2date:(NSString*)str{
    NSDate *date = [self.formatter dateFromString:str];
    NSLog(@"%s__%d__|%@",__FUNCTION__,__LINE__,date);
    
    return date;
}

//date to string
- (NSString*)date2string:(NSDate*)date{
    NSString *currentDateStr = [self.formatter stringFromDate:date];
    NSLog(@"%s__%d__|%@",__FUNCTION__,__LINE__,currentDateStr);
    return currentDateStr;
}

// 序列化
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.createDate forKey:@"createDate"];
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
        _createDate = [aDecoder decodeDoubleForKey:@"createDate"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
    }
    return self;
}


+(BOOL)saveALL{
    NSError* err;
    NSData* data = [NSJSONSerialization dataWithJSONObject:_locObjects options:NSJSONWritingPrettyPrinted error:&err];
    if(err)
        ALog("读取本地文件错误： %s",[err.description UTF8String]);
    
    if(data)
        return [data writeToFile: MSLocationObject.locaDatalFile atomically:YES];
    else
        return NO;
}

+(BOOL)loadALL{
    NSData* data = [NSData dataWithContentsOfFile:MSLocationObject.locaDatalFile];
    if(data==nil){
        ALog("读取本地文件错误！");
        return NO;
    }
    
    NSError* err;
    _locObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
    if(err){
        ALog("本地文件转对象集合错误： %s",[err.description UTF8String]);
        return NO;
    }
    return YES;
}


//getters
-(NSString*)createDateStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceReferenceDate:_createDate];
    return [self.formatter stringFromDate:date];
}

-(NSDateFormatter*)formatter{
    if(!_formatter){
        _formatter = [[NSDateFormatter alloc] init];
        //[_formatter setDateFormat:@"yyyyMMddHHmmss"];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _formatter;
}

+(NSString*)locaDatalFile{
    return [MSLocationObject.cachesDir stringByAppendingString:@"localfiles.data"];
}

+(NSString*)tempDir{
    NSString* path;
#if TARGET_IPHONE_SIMULATOR
    path = [TEST_PATH stringByAppendingString: @"tmp/"];
#else
    path = NSTemporaryDirectory();
#endif
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

+(NSString*)documentDir{
    NSString* path;
#if TARGET_IPHONE_SIMULATOR
    path = [TEST_PATH stringByAppendingString: @"Documents/"];
#else
    path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask , YES) firstObject];
    path = [path stringByAppendingString:@"/"];
#endif
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

+(NSString*)cachesDir{
    NSString* path;
#if TARGET_IPHONE_SIMULATOR
    path = [TEST_PATH stringByAppendingString: @"Caches/"];
#else
    path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingString:@"/"];
#endif
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

+(NSMutableDictionary*)locObjects{
    if(_locObjects == nil)
        [self loadALL];
    
    if(_locObjects == nil)
        _locObjects = [[NSMutableDictionary alloc]init];
    
    return _locObjects;
}
@end
