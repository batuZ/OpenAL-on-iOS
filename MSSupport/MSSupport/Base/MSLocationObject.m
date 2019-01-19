#define TEST_PATH @"/Users/Batu/Projects/TEST_HOME/"

#import "MSLocationObject.h"
@interface MSLocationObject()
//本地文件保存路径
@property (class, nonatomic, readonly) NSString* locaDatalFile;
//格式化时间，用于显示
@property (nonatomic,strong) NSDateFormatter *formatter;
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

/** 无差别序列化
 //序列化
 -(void)encodeWithCoder:(NSCoder *)aCoder{
 unsigned int ivarCount = 0;
 Ivar *ivars = class_copyIvarList([self class], &ivarCount);
 for (unsigned int i = 0; i < ivarCount; i++) {
 const char *ivar_name = ivar_getName(ivars[i]);
 NSString *key = [NSString stringWithCString:ivar_name encoding:NSUTF8StringEncoding];
 [aCoder encodeObject:[self valueForKey:key] forKey:key];
 }
 }
 
 //反序列化
 - (instancetype)initWithCoder:(NSCoder *)coder
 {
 self = [super init];
 if (self) {
 unsigned int ivarCount = 0;
 Ivar *ivars = class_copyIvarList([self class], &ivarCount);
 for (unsigned int i = 0; i < ivarCount; i++) {
 const char *ivar_name = ivar_getName(ivars[i]);
 NSString *key = [NSString stringWithCString:ivar_name encoding:NSUTF8StringEncoding];
 [self setValue:[coder decodeObjectForKey:key] forKey:key];
 }
 }
 return self;
 }
 */

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

#pragma mark - getter
-(NSString*)createDateStr{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:_createDate];
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
