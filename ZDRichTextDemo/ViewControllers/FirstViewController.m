//
//  ViewController.m
//  ZDRichTextDemo
//
//  Created by Zero.D.Saber on 16/8/11.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "FirstViewController.h"
@import CoreText;

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UILabel *testLabel;

@end

@implementation FirstViewController

- (void)dealloc {
    NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self notification];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseNotification:) name:@"testNotification" object:nil];
}

- (void)responseNotification:(NSNotification *)notifi {
    NSThread *thread = [NSThread currentThread];
    NSLog(@"%@", thread);
}

@end
