//
//  Table_RootVC.m
//  HappyTime
//
//  Created by 张智 on 2018/12/30.
//  Copyright © 2018 CustemVedioPlayer. All rights reserved.
/*
        iOS横竖屏旋转及其基本适配方法 https://blog.csdn.net/DreamcoffeeZS/article/details/79037207
        iOS开发-自动布局      https://www.cnblogs.com/CodingMann/p/5511869.html
 */

#import "Table_RootVC.h"
#import "HT_PlayerVC.h"
@interface Table_RootVC ()
@property (nonatomic,strong) NSString* thisDir;
@property (nonatomic,strong) NSArray* files;
@end

@implementation Table_RootVC
-(instancetype)initWithDIR:(NSString*) DirPath{
    self = [super init];
    if(self){
        _thisDir = DirPath;
    }
    return self;
}
-(NSString*)thisDir{
    if(_thisDir == nil){
#if TARGET_IPHONE_SIMULATOR
        _thisDir = @"/Users/Batu/Movies/";
#else
        _thisDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask , YES) firstObject];
        _thisDir = [path stringByAppendingString:@"/"];
#endif
    }
    return _thisDir;
}
-(NSArray*)files{
    if(_files == nil){
        _files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.thisDir error:nil];
        NSMutableArray *mArr = [NSMutableArray new];
        for (NSString* itm in _files) {
            NSString* path = [self.thisDir stringByAppendingString:itm];
            BOOL isDIR;
            BOOL isMOVIEW = [[[path pathExtension] uppercaseString] isEqualToString:@"MP4"];
            [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDIR];
            
            if(isDIR || isMOVIEW){
                [mArr addObject:itm];
            }
        }
        _files = [NSArray arrayWithArray:mArr];
        NSLog(@"%@",_files);
    }
    return _files;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"_myMovies";
    UITableViewCell *myCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    myCell.textLabel.text = self.files[indexPath.row];
    return myCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* path = [self.thisDir stringByAppendingString:self.files[indexPath.row]];
    NSLog(@"%@", path);
    BOOL isDIR;
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDIR]){
        if(isDIR){
            Table_RootVC *tvc = [[Table_RootVC alloc] initWithDIR:path];
            [self.navigationController pushViewController:tvc animated:YES];
        }else{
            HT_PlayerVC* ply = [[HT_PlayerVC alloc]initWithFile:path];
            [self.navigationController pushViewController:ply animated:YES];
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
