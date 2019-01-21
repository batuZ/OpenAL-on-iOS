
/*
 *  自定义继承、引用对象本地化示例
 */

#import "ViewController.h"
#import "locationObject.h"
#import "user.h"
#import "comment.h"

@interface ViewController ()
@property(nonatomic,strong) NSArray<locationObject*>* objects;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* savePath = @"/Users/Batu/Projects/test.data";
    // 写文件
    //    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.objects];
    //    [data writeToFile: savePath atomically:YES];
    
    // 读文件
    NSData* data = [[NSData alloc] initWithContentsOfFile:savePath];
    if(data){
        _objects = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"");
    }
}

-(NSArray<locationObject*>*)objects{
    if(_objects == nil){
        user* user_a = [user new];
        user_a.name = @"AAAA";
        
        locationObject* obj_1 = [locationObject new];
        obj_1.owner = user_a;
        obj_1.like = 88;
        {
            user* user_11 = [user new];
            user_11.name = @"1111";
            
            comment* com_1 = [comment new];
            com_1.owner = user_11;
            com_1.commentStr = @"user_11 say nice!";
            com_1.applaund = 18;
            
            user* user_22 = [user new];
            user_22.name = @"2222";
            
            comment* com_2 = [comment new];
            com_2.owner = user_22;
            com_2.commentStr = @"user_22 say nice!";
            com_2.applaund = 19;
            
            obj_1.comments = @[com_1,com_2];
        }
        obj_1.X = 109;
        obj_1.Y = 110;
        
        
        user* user_k = [user new];
        user_k.name = @"KKKK";
        
        locationObject* obj_2 = [locationObject new];
        obj_2.owner = user_k;
        obj_2.like = 99;
        {
            user* user_33 = [user new];
            user_33.name = @"3333";
            
            comment* com_3 = [comment new];
            com_3.owner = user_33;
            com_3.commentStr = @"user_33 say nice!";
            com_3.applaund = 28;
            
            user* user_44 = [user new];
            user_44.name = @"4444";
            
            comment* com_4 = [comment new];
            com_4.owner = user_44;
            com_4.commentStr = @"user_44 say nice!";
            com_4.applaund = 29;
            
            obj_2.comments = @[com_3,com_4];
        }
        obj_2.X = 208;
        obj_2.Y = 210;
        
        _objects = @[obj_1,obj_2];
    }
    return _objects;
}
@end
