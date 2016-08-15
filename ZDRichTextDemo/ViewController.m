//
//  ViewController.m
//  ZDRichTextDemo
//
//  Created by 符现超 on 16/8/11.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"
@import CoreText;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *testLabel;

@end

@implementation ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self notification];
    [self coretext];
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

// http://www.jianshu.com/p/6db3289fb05d
- (void)coretext {
    CGContextRef content = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(content, CGAffineTransformIdentity);
    CGContextTranslateCTM(content, 0, self.view.bounds.size.height);
    CGContextScaleCTM(content, 1.0, -1.0);
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"Coretext学习，处理富文本~~~"];
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallbacks;
    callbacks.getDescent = descentCallbacks;
    callbacks.getWidth = widthCallbacks;
    
    NSDictionary *dicPic = @{@"width" : @200, @"height" : @100};
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void * _Nullable)(dicPic));
    
    unichar placeholder = 0xFFFC;//空白字符
    NSString *placeHolderString = [NSString stringWithCharacters:&placeholder length:1];
    NSMutableAttributedString *placeholderAttrStr = [[NSMutableAttributedString alloc] initWithString:placeHolderString];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)placeholderAttrStr, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);// 给字符串中的字符设置代理
    CFRelease(delegate);
    [attributeString insertAttributedString:placeholderAttrStr atIndex:12];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.view.bounds);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributeString.length), path, NULL);
    CTFrameDraw(frame, content);
    
    UIImage *image = [UIImage imageNamed:@"hami"];
    CGRect imageFrame = [self calculateImageRectWithFrmae:frame];
    CGContextDrawImage(content, imageFrame, image.CGImage);
    CFRelease(frameSetter);
    CFRelease(path);
    CFRelease(frame);
}

- (CGRect)calculateImageRectWithFrmae:(CTFrameRef)frame {
    NSArray *arrLines = (NSArray *)CTFrameGetLines(frame);
    NSUInteger count = arrLines.count;
    CGPoint points[count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);
    
    for (int i = 0; i < count; i++) {
        CTLineRef line = (__bridge CTLineRef)arrLines[i];
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


static CGFloat ascentCallbacks(void *ref) {
    return [((__bridge NSDictionary *)ref)[@"height"] floatValue];
}

static CGFloat descentCallbacks(void *ref) {
    return 0;
}

static CGFloat widthCallbacks(void *ref) {
    return [((__bridge NSDictionary *)ref)[@"width"] floatValue];
}

@end
