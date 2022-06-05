#import "RootViewController.h"

@interface RootViewController ()
@end

@implementation RootViewController

- (void)loadView {
  [super loadView];

  self.view.backgroundColor = UIColor.blackColor;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = UIColor.whiteColor;

  _titleLabel = [[UILabel alloc]
      initWithFrame:CGRectMake(0, 50, UIScreen.mainScreen.bounds.size.width,
                               100)];
  _titleLabel.text = @"vnodebypass";
  _titleLabel.textAlignment = NSTextAlignmentCenter;
  _titleLabel.textColor = UIColor.blackColor;
  _titleLabel.font = [UIFont systemFontOfSize:40];
  [self.view addSubview:_titleLabel];

  _subtitleLabel = [[UILabel alloc]
      initWithFrame:CGRectMake(0, 100, UIScreen.mainScreen.bounds.size.width,
                               100)];
  _subtitleLabel.text = @"USE IT AT YOUR OWN RISK!";
  _subtitleLabel.textAlignment = NSTextAlignmentCenter;
  _subtitleLabel.textColor = UIColor.blackColor;
  _subtitleLabel.font = [UIFont systemFontOfSize:20];
  [self.view addSubview:_subtitleLabel];

  _button = [UIButton buttonWithType:UIButtonTypeSystem];
  _button.frame =
      CGRectMake(UIScreen.mainScreen.bounds.size.width / 2 - 30,
                 UIScreen.mainScreen.bounds.size.height / 2 - 25, 60, 50);
  [_button setTitle:self.enabled ? @"Disable" : @"Enable"
           forState:UIControlStateNormal];
  [_button addTarget:self
                action:@selector(buttonPressed:)
      forControlEvents:UIControlEventTouchUpInside];

  if (@available(iOS 13, *)) {
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    _titleLabel.textColor = UIColor.labelColor;
    _subtitleLabel.textColor = UIColor.labelColor;
  }

  [self.view addSubview:_button];
}

- (void)buttonPressed:(UIButton *)sender {
  BOOL disabled = !self.enabled;
  NSArray *opts;
  if (disabled) {
    opts = @[ @"-s", @"-h" ];
  } else {
    opts = @[ @"-r", @"-R" ];
  }

  NSString *launchPath = [NSString
      stringWithFormat:@"/usr/bin/%@", NSProcessInfo.processInfo.processName];
  NSTask *task =
      [NSTask launchedTaskWithLaunchPath:launchPath arguments:@[ opts[0] ]];
  [task waitUntilExit];
  task = [NSTask launchedTaskWithLaunchPath:launchPath arguments:@[ opts[1] ]];
  [task waitUntilExit];
  NSString *title = self.enabled ? @"Disable" : @"Enable";
  NSString *successTitle = self.enabled != disabled ? @"Failed" : @"Success";
  [_button setTitle:successTitle forState:UIControlStateNormal];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^{
                   sleep(1);
                   dispatch_async(dispatch_get_main_queue(), ^{
                     [_button setTitle:title forState:UIControlStateNormal];
                   });
                 });
}

- (BOOL)isEnabled {
  return access("/bin/sh", F_OK) != 0;
}

@end
