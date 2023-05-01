#import <NSTask.h>
#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController
@property(readonly, getter=isEnabled) BOOL enabled;
@property UILabel *titleLabel;
@property UILabel *subtitleLabel;
@property UIButton *button;
@end
