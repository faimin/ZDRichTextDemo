//
//  ZDCoreTextView.m
//  ZDRichTextDemo
//
//  Created by 符现超 on 2016/10/28.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDCoreTextView.h"
@import CoreText;


void deallockCallback(void *refCon) {

}

CGFloat ascentCallback(void *refCon) {
    NSString *imageName = (__bridge NSString *)refCon;
    CGFloat imageHeight = [UIImage imageNamed:imageName].size.height;
    return imageHeight;
}

CGFloat descentCallbakc(void *refCon) {
    return 0.f;
}

CGFloat widthCallback(void *refCon) {
    NSString *imageName = (__bridge NSString *)refCon;
    CGFloat imageWidth = [UIImage imageNamed:imageName].size.width;
    return imageWidth;
}

@implementation ZDCoreTextView

#pragma mark - Functions



#pragma mark -
// http://www.jianshu.com/p/6345a9af78a5
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    // 获取当前画布
    CGContextRef context = UIGraphicsGetCurrentContext();

    // 旋转坐标系
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // 创建绘制区域，将整个视图作为绘制区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.viewForLastBaselineLayout.bounds);

    //
    NSMutableAttributedString *mutAttString = [[NSMutableAttributedString alloc] initWithString:@"中国空军新闻发言人申进科大校10月28日在北京发布消息说：空军试飞员将驾歼-20飞机在第11届中国航展上进行飞行展示，这是中国自主研制的新一代隐身战斗机首次公开亮相。28日召开的“中国空军参加中国航展新闻发布会”上，申进科介绍，歼-20飞机是适应未来战场需要，由中国自主研制的新一代隐身战斗机。目前，歼-20飞机研制正在按计划推进，该机将进一步提升我空军综合作战能力，有助于空军更好的肩负起维护国家主权、安全和领土完整的神圣使命。"];
    [mutAttString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16], NSForegroundColorAttributeName : [UIColor greenColor]} range:NSMakeRange(0, 10)];
    [mutAttString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:32] range:NSMakeRange(11, 20)];


}


@end
