//
//  SnailTableviewIndexView.m
//  QianXun
//
//  Created by liu on 2018/10/15.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailTableviewIndexView.h"

@interface SnailTableviewIndexIndicator : UIView

@property (nonatomic ,strong) UILabel *lbl;

@end

@implementation SnailTableviewIndexIndicator

- (instancetype)init {
    self = [super init];
    if (self) {
    
        self.lbl = [UILabel new];
        self.lbl.font = [UIFont systemFontOfSize:50];
        self.lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.lbl.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.lbl];
    
    }
    return self;
}

@end

@interface SnailTableviewIndexView()<UIGestureRecognizerDelegate>

@property (nonatomic ,strong) SnailTableviewIndexIndicator *indicator;
@property (nonatomic ,strong) NSArray *sizes;
@property (nonatomic ,strong) NSArray *frames;
@property (nonatomic) CGFloat totalCharacterHeight;
@property (nonatomic ,strong) UITapGestureRecognizer *snailTap;
@property (nonatomic ,strong) UIPanGestureRecognizer *snailPan;
@property (nonatomic ,strong) NSTimer *timer;

@end

@implementation SnailTableviewIndexView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = true;
        
        self.snailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesAction:)];
        self.snailPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesAction:)];

        [self addGestureRecognizer:self.snailTap];
        [self addGestureRecognizer:self.snailPan];
        
        self.font = [UIFont systemFontOfSize:13];
        self.color = [UIColor blueColor];
        self.indicatorColor = [UIColor whiteColor];
        self.indicatorBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    }
    return self;
}

- (void)tapGesAction:(UITapGestureRecognizer *)tapges {
    
    [self clearTimer];
    
    CGPoint point = [self.snailTap locationInView:self];
    [self indicatorPoint:point];
    
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}

- (void)clearTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerAction {
    [self clearTimer];
    [UIView animateWithDuration:0.3 animations:^{
        self.indicator.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeIndicator];
    }];
}

- (void)panGesAction:(UIPanGestureRecognizer *)ges {
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
             [self clearTimer];
            CGPoint point = [self.snailPan locationInView:self];
            [self indicatorPoint:point];
        }
            break;
        default:
            [self removeIndicator];
            break;
    }
}

- (void)removeIndicator {
    self.indicator.hidden = true;
    [self.indicator removeFromSuperview];
    self.indicator = nil;
}

- (void)indicatorPoint:(CGPoint)point {
    
    for (NSInteger i = 0; i < self.frames.count; i++) {
        CGRect frame = [self.frames[i] CGRectValue];
        if (CGRectContainsPoint(frame, point)) {
            
            NSString *character = self.characters[i];
            if (!self.indicator) {
                self.indicator = [SnailTableviewIndexIndicator new];
                self.indicator.layer.cornerRadius = 5;
                self.indicator.layer.masksToBounds = true;
                self.indicator.lbl.textColor = self.indicatorColor;
                self.indicator.backgroundColor = self.indicatorBackgroundColor;
                [self.superview addSubview:self.indicator];
                self.indicator.frame = CGRectMake(0, 0, 80, 80);
                self.indicator.center = self.superview.center;
            }
            self.indicator.lbl.text = character;
            
            if (self.selectedBlock) {
                self.selectedBlock(i, character.copy);
            }
            
            break;
        }
    }
    
}

- (void)drawRect:(CGRect)rect {
    
    CGFloat y = (rect.size.height - self.totalCharacterHeight) * .5;
    if (y < 0) y = 0;
    
    NSMutableArray *frames = [NSMutableArray new];
    for (NSUInteger i = 0; i < self.characters.count; i++) {
        
        CGSize size = [self.sizes[i] CGSizeValue];
        CGFloat x = self.left?0:(rect.size.width - size.width);
        CGRect drawRect = CGRectMake(x, y, size.width, size.height);
        
        [self.characters[i] drawInRect:drawRect withAttributes:@{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.color}];
        [frames addObject:[NSValue valueWithCGRect:CGRectMake(0, y, rect.size.width, size.height)]];
        
        y += (size.height + 5);
        
    }
    self.frames = frames.copy;
    
}

- (void)update {
    
    CGFloat totalHeight = 0.0;
    NSMutableArray *tmpSizes = [NSMutableArray new];
    for (NSString *character in self.characters) {
        CGSize size = [character boundingRectWithSize:CGSizeMake(100, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
        totalHeight += size.height;
        [tmpSizes addObject:[NSValue valueWithCGSize:size]];
    }
    totalHeight += (self.characters.count - 1) * 5;
    self.totalCharacterHeight = totalHeight;
    self.sizes = tmpSizes.copy;
    [self setNeedsDisplay];
}

- (void)setCharacters:(NSArray<NSString *> *)characters {
    _characters = characters;
    [self update];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    [self update];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorColor = indicatorColor;
    self.indicator.lbl.textColor = indicatorColor;
}

- (void)setIndicatorBackgroundColor:(UIColor *)indicatorBackgroundColor {
    _indicatorBackgroundColor = indicatorBackgroundColor;
    self.indicator.backgroundColor = indicatorBackgroundColor;
}

@end
