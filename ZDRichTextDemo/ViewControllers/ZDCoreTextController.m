//
//  ZDCoreTextController.m
//  ZDRichTextDemo
//
//  Created by 符现超 on 2016/10/28.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDCoreTextController.h"
@import CoreText;

@interface ZDCoreTextController ()

@end

@implementation ZDCoreTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self zd_coreText1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CoreText

- (void)zd_coreText1 {
    
}


@end


#pragma mark - 介绍
/**
 首先通过CFAttributeString来创建CTFramaeSetter，然后再通过CTFrameSetter来创建CTFrame。
 在CTFrame内部，是由多个CTLine来组成的，每个CTLine代表一行，每个CTLine是由多个CTRun来组成，每个CTRun代表一组显示风格一致的文本。
 */






