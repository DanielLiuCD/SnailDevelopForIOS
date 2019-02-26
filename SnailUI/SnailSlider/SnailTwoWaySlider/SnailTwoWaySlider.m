//
//  SnailTwoWaySlider.m
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2018/12/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailTwoWaySlider.h"

@interface SnailTwoWaySlider()

@property (nonatomic ,strong) UIImageView *little;
@property (nonatomic ,strong) UIImageView *large;
@property (nonatomic ,strong) NSLayoutConstraint *littleLeadeing;
@property (nonatomic ,strong) NSLayoutConstraint *largeTrailing;

@property (nonatomic ,strong) UIPanGestureRecognizer *longGes;

@property (nonatomic ,weak) UIView *dragView;

@end

@implementation SnailTwoWaySlider

- (void)testAction {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _little = [UIImageView new];
        _large = [UIImageView new];
        
        _littleValue = 0.0;
        _largeValue = 1.0;
        
        _foregroundColor = [UIColor blueColor];
        _sliderColor = [UIColor lightGrayColor];
        
        [self addSubview:_little];
        [self addSubview:_large];
    
        _little.translatesAutoresizingMaskIntoConstraints = false;
        _large.translatesAutoresizingMaskIntoConstraints = false;
        self.translatesAutoresizingMaskIntoConstraints = false;
        
        NSLayoutConstraint *littleLeadeing = [NSLayoutConstraint constraintWithItem:_little attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
        NSLayoutConstraint *littleCenterY = [NSLayoutConstraint constraintWithItem:_little attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *littleHeight = [NSLayoutConstraint constraintWithItem:_little attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        NSLayoutConstraint *littleWidth = [NSLayoutConstraint constraintWithItem:_little attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        
        NSLayoutConstraint *largeTrailing = [NSLayoutConstraint constraintWithItem:_large attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        NSLayoutConstraint *largeCenterY = [NSLayoutConstraint constraintWithItem:_large attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *largeHeight = [NSLayoutConstraint constraintWithItem:_large attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        NSLayoutConstraint *largeWidth = [NSLayoutConstraint constraintWithItem:_large attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        
        [_little addConstraints:@[littleHeight,littleWidth]];
        [_large addConstraints:@[largeWidth,largeHeight]];
        [self addConstraints:@[littleLeadeing,littleCenterY,largeTrailing,largeCenterY]];
        
        _littleLeadeing = littleLeadeing;
        _largeTrailing = largeTrailing;
        
        self.longGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
        [self addGestureRecognizer:self.longGes];
        
    }
    return self;
}

-(void)setImageOfLittleSlider:(UIImage *)image {
    _little.image = image;
    [self setNeedsDisplay];
}

-(void)setImageOfLargeSlider:(UIImage *)image {
    _large.image = image;
    [self setNeedsDisplay];
}

- (void)longAction:(UILongPressGestureRecognizer *)ges {
    CGPoint point = [ges locationInView:self];
    if (ges.state == UIGestureRecognizerStateBegan) {
        if (CGRectContainsPoint(self.little.frame, point)) self.dragView = self.little;
        else if (CGRectContainsPoint(self.large.frame, point)) self.dragView = self.large;
        else self.dragView = nil;
    }
    else if (ges.state == UIGestureRecognizerStateEnded) self.dragView = nil;
    else if (ges.state == UIGestureRecognizerStateChanged) {
        
        if (self.dragView == _little) {
            CGFloat leading = point.x - _little.frame.size.width / 2.0;
            if (point.x + _little.frame.size.width / 2.0 > _large.frame.origin.x) {
                leading = _large.frame.origin.x - _little.frame.size.width;
            }
            else if (point.x - _little.frame.size.width / 2.0 < 0) {
                leading = 0;
            }
            _littleLeadeing.constant = leading;
            _littleValue = (_little.center.x - _little.frame.size.width / 2.0) / (self.frame.size.width - _little.frame.size.width - _large.frame.size.width );
        }
        else if (self.dragView == _large) {
            CGFloat trailing = point.x + _large.frame.size.width / 2.0 - self.frame.size.width;
            if (point.x - _large.frame.size.width / 2.0 < CGRectGetMaxX(_little.frame)) {
                trailing =  CGRectGetMaxX(_little.frame) + _large.frame.size.width - self.frame.size.width;
            }
            else if (point.x + _large.frame.size.width / 2.0 > self.frame.size.width) {
                trailing = 0;
            }
            _largeTrailing.constant = trailing;
            _largeValue = (_large.center.x - _large.frame.size.width / 2.0 - _little.frame.size.width) / (self.frame.size.width - _little.frame.size.width - _large.frame.size.width);
        }
        [self setNeedsDisplay];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
    }
}


-(void)setLittleValue:(CGFloat)littleValue {
    if (_littleValue != littleValue) {
        _littleValue = littleValue;
        CGFloat leaading = _littleValue * (self.frame.size.width - _little.frame.size.width - _large.frame.size.width);
        _littleLeadeing.constant = leaading;
        [self setNeedsDisplay];
    }
}

-(void)setLargeValue:(CGFloat)largeValue {
    if (_largeValue != largeValue) {
        _largeValue = largeValue;
        CGFloat trailing = self.frame.size.width - (_largeValue * (self.frame.size.width - _little.frame.size.width - _large.frame.size.width) + _little.frame.size.width + _large.frame.size.width);
        _largeTrailing.constant = -trailing;
        [self setNeedsDisplay];
    }
}

-(void)drawRect:(CGRect)rect {
    CGFloat centerY = rect.size.height / 2.0;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetStrokeColorWithColor(ctx, _sliderColor.CGColor);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextMoveToPoint(ctx, 0, centerY);
    CGContextAddLineToPoint(ctx, _little.frame.origin.x, centerY);
    CGContextMoveToPoint(ctx, CGRectGetMaxX(_large.frame), centerY);
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), centerY);
    CGContextStrokePath(ctx);
    CGContextSetStrokeColorWithColor(ctx, _foregroundColor.CGColor);
    CGContextMoveToPoint(ctx, CGRectGetMaxX(_little.frame), centerY);
    CGContextAddLineToPoint(ctx, CGRectGetMinX(_large.frame), centerY);
    CGContextStrokePath(ctx);
}

@end
