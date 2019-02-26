//
//  SnailVerCodeView.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/27.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailVerCodeView.h"
#import "SnailSimpleCIMManager.h"

@interface SnailVerCodeView()

@property (nonatomic ,strong) NSMutableArray<NSString *> *sources;

@property (nonatomic ,strong) NSString *right;

@end

@implementation SnailVerCodeView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.vCount = 4;
        self.lineCount = 8;
        self.codeSize = (CGSize){.width=70,.height=30};
        self.codeColor = [UIColor groupTableViewBackgroundColor];
        [self setSourcesCharacts:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"]];
        [self switchCode];
    }
    return self;
}

- (void)setSourcesCharacts:(NSArray<NSString *> *)sources {
    self.sources = [NSMutableArray arrayWithArray:sources];
}

- (void)switchCode {
    
    NSMutableString *rightCode = [NSMutableString new];
    UIImage *img = [SnailSimpleCIMManager takeCIM:nil Cache:false Size:^CGSize{
        return self.codeSize;
    } Block:^(CGContextRef ctx, CGRect rect, CGFloat scale) {
        
        CGContextAddRect(ctx, rect);
        [self.codeColor setFill];
        CGContextFillPath(ctx);
        
        CGFloat avgWidth = floor(rect.size.width / self.vCount);
        
        for (int i = 0; i < self.vCount;) {
            
            NSInteger index = arc4random() % (self.sources.count-1);
            NSString *tempStr = [self.sources objectAtIndex:index];
            
            UIFont *font = SNAS_SYS_FONT(arc4random() % 5 + 15);
            
            int tmp = (int)(avgWidth - font.pointSize);
            
            if (tmp <= 0) continue;
            
            CGFloat x = avgWidth * i + arc4random() % tmp;
            CGFloat y = arc4random() % ((int)(rect.size.height - font.lineHeight));
            
            [tempStr drawAtPoint:(CGPoint){.x=x,.y=y} withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor blackColor]}];
            
            [rightCode appendString:tempStr];
            
            i++;
            
        }
        
        CGContextSetLineWidth(ctx, 1);
        CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        for (int i = 0; i < self.lineCount; i++) {
            
            CGFloat x = arc4random() % ((int)rect.size.width);
            CGFloat y = arc4random() % ((int)rect.size.height);
            CGContextMoveToPoint(ctx, x, y);
            
            x = arc4random() % ((int)rect.size.width);
            y = arc4random() % ((int)rect.size.height);
            CGContextAddLineToPoint(ctx, x, y);
            
        }
        CGContextStrokePath(ctx);

    }];
    self.layer.contents = (__bridge id _Nullable)(img.CGImage);
    self.right = rightCode.copy;
    
}

- (NSString *)rightCodeString {
    return self.right.copy;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.clickBlock)self.clickBlock();
}

@end
