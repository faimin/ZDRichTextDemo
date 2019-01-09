//
//  ZDCoreTextController.m
//  ZDRichTextDemo
//
//  Created by Zero.D.Saber on 2016/10/28.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDCoreTextController.h"
@import CoreText;

static CGFloat ascentCallbacks(void *ref) {
    return [((__bridge NSDictionary *)ref)[@"height"] floatValue];
}

static CGFloat descentCallbacks(void *ref) {
    return 0;
}

static CGFloat widthCallbacks(void *ref) {
    return [((__bridge NSDictionary *)ref)[@"width"] floatValue];
}

//----------------------------------------------------

@interface ZDCoreTextController ()

@end

@implementation ZDCoreTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.redColor;
    // Do any additional setup after loading the view.
    if (@available(iOS 11, *)) {
        self.additionalSafeAreaInsets = UIEdgeInsetsMake(86, 0, 83, 0);
    }
    [self setupCoreText];
    
}

#pragma mark - CoreText
// CoreText实现图文混排: http://www.jianshu.com/p/6db3289fb05d
/**
 首先通过CFAttributeString来创建CTFramaeSetter，然后再通过CTFrameSetter来创建CTFrame。
 在CTFrame内部，是由多个CTLine来组成的，每个CTLine代表一行，每个CTLine是由多个CTRun来组成，每个CTRun代表一组显示风格一致的文本。
 */
- (void)setupCoreText {
    CGRect frame = self.view.bounds;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        // 获取上下文
        UIGraphicsBeginImageContextWithOptions(frame.size, YES, 1.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(context, 1, 0, 0.5, 1);
        CGContextFillRect(context, frame);
        
        // 转换坐标系
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, frame.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"Coretext学习，处理富文本~~~"];
        
        /// 创建CTRunDelegate需要两个参数：
        /// 一个是callBack结构体，另一个是callBack里的函数调用时需要传入的参数
        
        /// callBack结构体主要包含了返回当前CTRun的ascent、descent和width函数
        CTRunDelegateCallbacks callbacks;
        memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
        callbacks.version = kCTRunDelegateVersion1;
        callbacks.getAscent = ascentCallbacks;
        callbacks.getDescent = descentCallbacks;
        callbacks.getWidth = widthCallbacks;
        
        NSDictionary *dicPic = @{@"width" : @20, @"height" : @20};
        CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void * _Nullable)(dicPic));
        
        // 如果用unichar类型，则创建回调结构体时需要用`memset`方法开辟内存，空字符串则不需要
        unichar placeholder = 0xFFFC;//空白字符,或者直接用空字符串（@“ ”）代替
        NSString *placeHolderString = [NSString stringWithCharacters:&placeholder length:1];
        NSMutableAttributedString *placeholderAttrStr = [[NSMutableAttributedString alloc] initWithString:placeHolderString];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)placeholderAttrStr, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);// 给字符串中的字符设置代理
        CFRelease(delegate);
        [attributeString insertAttributedString:placeholderAttrStr atIndex:11];
        
        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, frame);
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributeString.length), path, NULL);
        CTFrameDraw(frame, context);
        
        UIImage *image = [UIImage imageNamed:@"hami"];
        CGRect imageFrame = [self calculateImageRectWithFrmae:frame];
        CGContextDrawImage(context, imageFrame, image.CGImage);
        CFRelease(frame);
        CFRelease(path);
        CFRelease(frameSetter);
        
        UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view addSubview:[[UIImageView alloc] initWithImage:renderedImage]];
        });
    });
}

- (CGRect)calculateImageRectWithFrmae:(CTFrameRef)frame {
    CFArrayRef arrLines = CTFrameGetLines(frame);
    NSUInteger count = CFArrayGetCount(arrLines);
    CGPoint points[count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);
    
    for (int i = 0; i < count; i++) {
        CTLineRef line = (__bridge CTLineRef)((__bridge NSArray *)arrLines)[i];
        NSArray *arrGlyphRun = (NSArray *)CTLineGetGlyphRuns(line);
        
        for (int j = 0; j < arrGlyphRun.count; j++) {
            CTRunRef run = (__bridge CTRunRef)(arrGlyphRun[j]);
            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)(attributes[(NSString *)kCTRunDelegateAttributeName]);
            if (delegate == NULL) {
                continue;
            }
            NSDictionary *dic = CTRunDelegateGetRefCon(delegate);
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            CGPoint point = points[i];
            CGFloat ascent, descent;
            CGRect boundsRun;
            boundsRun.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            boundsRun.size.height = ascent + descent;
            CGFloat offsetX = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            //point是行起点位置，加上每个字的偏移量得到每个字的x
            boundsRun.origin.x = point.x + offsetX;
            boundsRun.origin.y = point.y - descent;
            
            //获取绘制区域
            CGPathRef path = CTFrameGetPath(frame);
            //获取剪裁区域边框
            CGRect colRect = CGPathGetBoundingBox(path);
            CGRect imageBounds = CGRectOffset(boundsRun, colRect.origin.x, colRect.origin.y);
            return imageBounds;
        }
    }
    return CGRectZero;
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


