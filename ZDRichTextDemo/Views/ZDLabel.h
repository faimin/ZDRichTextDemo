//
//  ZDLabel.h
//  ZDRichTextDemo
//
//  Created by Zero.D.Saber on 2017/3/30.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZDLabel : UILabel

- (void)setTarget:(id)target action:(SEL)selector forRange:(NSRange)range;

@end
