#import <UIKit/UIKit.h>
#import "OpenALSupport.h"
NS_ASSUME_NONNULL_BEGIN

@interface AL_Pos_RootVC : UIViewController
{
    ALuint sid;
    CGPoint tagLoc;
}
@property (weak, nonatomic) IBOutlet UILabel *sound;
@property (weak, nonatomic) IBOutlet UILabel *listener;

@end

NS_ASSUME_NONNULL_END
