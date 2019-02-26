//
//  SnailStarBar.m
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2018/12/29.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailStarBar.h"

@interface SnailStarBar()

@property (nonatomic ,strong) UITapGestureRecognizer *tapGes;
@property (nonatomic ,strong) UIPanGestureRecognizer *panGes;
@property (nonatomic) CGFloat currentPresent;
@property (nonatomic ,strong) NSNumber *currentValue;

@end

@implementation SnailStarBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        self.panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:self.tapGes];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIImage *temp = [self takeImage:self.currentPresent Update:false];
    self.layer.contents = (__bridge id _Nullable)temp.CGImage;
}

- (void)tapAction:(UITapGestureRecognizer *)ges {
    
    CGPoint point = [ges locationInView:self];
    CGSize starSize = self.starSize;
    CGFloat starLength = self.starCount * starSize.width + ( self.starCount >0?(self.starCount - 1) * self.starHSpaceing:0);
    if (point.x <= starLength) {
        UIImage *temp = [self takeImage:point.x Update:true];
        self.layer.contents = (__bridge id _Nullable)temp.CGImage;
    }
    
}

- (void)panAction:(UIPanGestureRecognizer *)ges {
    
    CGPoint point = [ges locationInView:self];
    CGSize starSize = self.starSize;
    CGFloat starLength = self.starCount * starSize.width + ( self.starCount >0?(self.starCount - 1) * self.starHSpaceing:0);
    if (point.x <= starLength) {
        UIImage *temp = [self takeImage:point.x Update:true];
        self.layer.contents = (__bridge id _Nullable)temp.CGImage;
    }
    
}

- (UIImage *)takeImage:(CGFloat)present Update:(BOOL)update {
    
    UIImage *img = nil;
    CGSize starSize = self.starSize;
    CGRect rect = self.bounds;
    CGFloat starLength = self.starCount * starSize.width + ( self.starCount >0?(self.starCount - 1) * self.starHSpaceing:0);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen.nativeScale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.backgroundColor setFill];
    CGContextFillRect(ctx, rect);
    
    {
        CGFloat x = 0;
        CGFloat y = (rect.size.height - starSize.height) * .5;
        for (NSInteger i = 0; i < self.starCount; i++) {
            [self.starImage drawInRect:CGRectMake(x, y, starSize.width, starSize.height)];
            x += (starSize.width + self.starHSpaceing);
        }
    }
    {
        CGRect rect0 = CGRectZero;
        if (self.present) {
            rect0 = CGRectMake(0, 0, present, rect.size.height);
            if (update) self.currentValue = [NSNumber numberWithFloat:present / starLength * self.starCount];
        }
        else {
            NSInteger count = ceil(present / starLength * self.starCount);
            CGFloat width = starSize.width * count + (count > 0?((count - 1) * self.starHSpaceing):0);
            rect0 = CGRectMake(0, 0, width, rect.size.height);
            if (update) self.currentValue = [NSNumber numberWithInteger:count];
        }
        CGContextClipToRect(ctx, rect0);
        
        CGFloat x = 0;
        CGFloat y = (rect.size.height - starSize.height) * .5;
        for (NSInteger i = 0; i < self.starCount; i++) {
            [self.starForceImage drawInRect:CGRectMake(x, y, starSize.width, starSize.height)];
            x += (starSize.width + self.starHSpaceing);
        }
        self.currentPresent = present;
        
    }
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
    
}

- (NSNumber *)takeSelectedCount {
    return self.currentValue;
}

- (void)setSelectedCount:(NSNumber *)count {
    
    self.currentValue = count;
    
    CGSize starSize = self.starSize;
    CGFloat starLength = self.starCount * starSize.width + ( self.starCount >0?(self.starCount - 1) * self.starHSpaceing:0);
    CGFloat present = floor(([count floatValue] / self.starCount) * starLength);
    
    UIImage *temp = [self takeImage:present Update:false];
    self.layer.contents = (__bridge id _Nullable)temp.CGImage;
    
}

- (void)setDrag:(BOOL)drag {
    if (_drag != drag) {
        _drag = drag;
        if (drag) [self addGestureRecognizer:self.panGes];
        else [self removeGestureRecognizer:self.panGes];
    }
}

- (void)setStarImage:(UIImage *)starImage {
    _starImage = starImage;
    UIImage *temp = [self takeImage:self.currentPresent Update:false];
    self.layer.contents = (__bridge id _Nullable)temp.CGImage;
}

- (void)setStarForceImage:(UIImage *)starForceImage {
    _starForceImage = starForceImage;
    UIImage *temp = [self takeImage:self.currentPresent Update:false];
    self.layer.contents = (__bridge id _Nullable)temp.CGImage;
}

- (void)setStarSize:(CGSize)starSize {
    _starSize = starSize;
    UIImage *temp = [self takeImage:self.currentPresent Update:false];
    self.layer.contents = (__bridge id _Nullable)temp.CGImage;
}

- (void)setStarCount:(NSInteger)starCount {
    _starCount = starCount;
    UIImage *temp = [self takeImage:self.currentPresent Update:false];
    self.layer.contents = (__bridge id _Nullable)temp.CGImage;
}

- (void)setStarHSpaceing:(CGFloat)starHSpaceing {
    _starHSpaceing = starHSpaceing;
    UIImage *temp = [self takeImage:self.currentPresent Update:false];
    self.layer.contents = (__bridge id _Nullable)temp.CGImage;
}

@end
