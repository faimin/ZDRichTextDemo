//
//  NotificationViewController.m
//  ZDRichTextDemo
//
//  Created by 符现超 on 16/8/15.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "NotificationViewController.h"
#import "ZDCoreTextController.h"
#import "ZDCoreTextView.h"

#define kScreen_Width   ([UIScreen mainScreen].bounds.size.width)
#define kScreen_Height  ([UIScreen mainScreen].bounds.size.height)

@interface NotificationViewController ()

@end

@implementation NotificationViewController

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postNotification:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification" object:[NSThread currentThread] userInfo:nil];
    });
}

- (void)setup {
    ZDCoreTextView *ctView = [[ZDCoreTextView alloc] initWithFrame:CGRectMake(20, 170, kScreen_Width - 40, kScreen_Height - 200)];
    ctView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    ctView.backgroundColor = UIColor.yellowColor;
    [self.view addSubview:ctView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
