//
//  ZDCoreTextView.m
//  ZDRichTextDemo
//
//  Created by Zero.D.Saber on 2016/10/28.
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

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.clipsToBounds = YES;
    [self setupCoreText];
}

#pragma mark - 图文混排

// http://www.jianshu.com/p/6345a9af78a5
- (void)setupCoreText {
    CGRect contextFrame = (CGRect){CGPointZero, CGRectInset(self.bounds, 20, 20).size};
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        // 获取当前画布
        UIGraphicsBeginImageContextWithOptions(contextFrame.size, YES, 1.f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // 旋转坐标系
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, contextFrame.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // 设置填充色
        CGContextSetRGBFillColor(context, 0.961, 0.961, 0.961, 1);
        // 设置填充大小
        CGContextFillRect(context, contextFrame);
        
        // 设置富文本属性
        NSMutableAttributedString *mutAttString = [[NSMutableAttributedString alloc] initWithString:@"中国空军新闻发言人申进科大校10月28日在北京发布消息说：空军试飞员将驾歼-20飞机在第11届中国航展上进行飞行展示，这是中国自主研制的新一代隐身战斗机首次公开亮相。28日召开的“中国空军参加中国航展新闻发布会”上，申进科介绍，歼-20飞机是适应未来战场需要，由中国自主研制的新一代隐身战斗机。目前，歼-20飞机研制正在按计划推进，该机将进一步提升我空军综合作战能力，有助于空军更好的肩负起维护国家主权、安全和领土完整的神圣使命。"];
        [mutAttString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16], NSForegroundColorAttributeName : [UIColor greenColor]} range:NSMakeRange(0, 10)];
        [mutAttString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:32] range:NSMakeRange(10, 20)];
        [mutAttString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:22], NSForegroundColorAttributeName : [UIColor redColor]} range:NSMakeRange(20, mutAttString.length - 20)];
        [mutAttString addAttributes:@{NSParagraphStyleAttributeName : ({
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
            paragraphStyle;
        })} range:NSMakeRange(0, mutAttString.length)];
        
        NSString *imageName = @"hami";
        // 初始化回调结构体
        CTRunDelegateCallbacks callback;
        callback.version = kCTRunDelegateVersion1;
        callback.dealloc = deallockCallback;
        callback.getAscent = ascentCallback;
        callback.getDescent = descentCallbakc;
        callback.getWidth = widthCallback;
        
        // 第一个参数是回调结构体，第二个是回调结构体中函数（它可以接受任意类型的参数）的参数（void* 类型）
        // 可以简单理解为绑定或者关联，把一个任意对象绑定到代理上
        CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callback, (__bridge void *)imageName);
        NSMutableAttributedString *imagePlaceholderString = [[NSMutableAttributedString alloc] initWithString:@" "];
        CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)imagePlaceholderString, CFRangeMake(0, 1), kCTRunDelegateAttributeName, runDelegate);
        CFRelease(runDelegate);
        [imagePlaceholderString addAttribute:@"imageNameKey" value:imageName range:NSMakeRange(0, 1)];
        [mutAttString insertAttributedString:imagePlaceholderString atIndex:20];
        
        /// 设置framesetter、frame，然后绘制到context上
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)mutAttString);
        // 创建绘制区域，将整个视图作为绘制区域
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, contextFrame);
        CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, mutAttString.length), path, NULL);
        // 绘制
        CTFrameDraw(frameRef, context);
        
        
        NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frameRef);
        NSUInteger lineCount = lines.count;
        CGPoint lineOrigins[lineCount];
        CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
        
        for (int i = 0; i < lineCount; i++) {
            // 获取line
            CTLineRef line = (__bridge CTLineRef)(lines[i]);
            // 获取每个CTLine中的所有CTRun
            NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
            
            for (int j = 0; j < runs.count; j++) {
                // 获取run及其属性
                CTRunRef run = (__bridge CTRunRef)runs[j];
                NSDictionary *dic = (NSDictionary *)CTRunGetAttributes(run);
                
                // 通过key获取到delegate
                CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)(dic[(NSString *)kCTRunDelegateAttributeName]);
                if (delegate == NULL) {
                    continue;
                }
                
                // 获取与代理绑定的对象
                NSString *imageName = dic[@"imageNameKey"];// 或者 CTRunDelegateGetRefCon(runDelegate);
                UIImage *image = [UIImage imageNamed:imageName];
                CGRect runBounds;
                CGFloat ascent, dscent;
                runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &dscent, NULL);
                runBounds.size.height = ascent + dscent;
                
                CFIndex index = CTRunGetStringRange(run).location;
                // 获取CTRun的x偏移量
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, index, NULL);
                // lineOrigins是行起点位置，加上每个字的偏移量得到每个字的x
                runBounds.origin.x = lineOrigins[i].x + xOffset;
                runBounds.origin.y = lineOrigins[i].y - dscent;
                runBounds.size = image.size;
                CGContextDrawImage(context, runBounds, image.CGImage);
            }
        }
        
        CFRelease(frameRef);
        CFRelease(path);
        
        UIImage *renderImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:renderImage];
            imageView.frame = (CGRect){20, 20, contextFrame.size};
            [self addSubview:imageView];
        });
    });
}

#pragma mark - Functions


@end







