//
//  _SnailBadgeDragView.m
//  SnailBadge
//
//  Created by liu on 2018/10/18.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "_SnailBadgeDragView.h"

struct SnailBadgeCycle {
    CGFloat radius;
    CGPoint center;
};
typedef struct SnailBadgeCycle SnailBadgeCycle;

@interface _SnailBadgeBoom : UIView<CAAnimationDelegate>

@property (nonatomic ,copy) void(^endBlock)(void);
@property (nonatomic) NSInteger count;

@end

@implementation _SnailBadgeBoom

+ (void)boomInView:(UIView *)view Point:(CGPoint)point Block:(void(^)(void))block {
    _SnailBadgeBoom *boom = [_SnailBadgeBoom new];
    boom.frame = CGRectMake(0, 0, 60, 60);
    boom.center = point;
    boom.layer.contentsGravity = kCAGravityCenter;
    boom.layer.contentsScale = UIScreen.mainScreen.scale;
    boom.endBlock = block;
    [view addSubview:boom];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CAKeyframeAnimation *ani = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        ani.values = @[
                       (id)[[UIImage imageNamed:@"snailbadgeboom_1"] CGImage],
                       (id)[[UIImage imageNamed:@"snailbadgeboom_2"] CGImage],
                       (id)[[UIImage imageNamed:@"snailbadgeboom_3"] CGImage],
                       (id)[[UIImage imageNamed:@"snailbadgeboom_4"] CGImage],
                       (id)[[UIImage imageNamed:@"snailbadgeboom_5"] CGImage]
                       ];
        ani.duration = 0.5;
        ani.delegate = boom;
        [boom.layer addAnimation:ani forKey:@"boom"];;
    });
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.endBlock) self.endBlock();
    self.layer.contents = nil;
    self.endBlock = nil;
    [self removeFromSuperview];
}

@end

@implementation _SnailBadgeDragView
{
    UIPanGestureRecognizer *_privatePanGes;
    
    NSMutableArray<CAShapeLayer *> *_shapes;
    
    CGFloat _radius;  //圆最大半径
    CGFloat _radiusExtend; //圆半径可变化长度
    CGFloat _maxDistance;   //断裂距离
    
    SnailBadgeCycle _firstCycle;
    
    UIView *_previewView;
    
    BOOL _isShowBridge; //用于记录鼻涕是否断过了，断过了以后就不能连上
    BOOL _isBreaken;
    
    CADisplayLink *_watchLink;
    
}

- (instancetype)init {
    self = [super init];
    if (self) {

        _maxDistance = 60;
        _shapes = [NSMutableArray new];
        
        for (int i = 0; i < 3; i++) {
            CAShapeLayer *shape = [CAShapeLayer layer];
            shape.strokeColor = UIColor.clearColor.CGColor;
            [_shapes addObject:shape];
        }
        self.snailEnableDrag = true;
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    //_privateShape0.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)boom {
    if (self.startBlock) self.startBlock();
    UIView *showView = UIApplication.sharedApplication.keyWindow;
    [_SnailBadgeBoom boomInView:showView Point:[showView convertPoint:self.center fromView:self.superview] Block:^{
        [self endActon];
    }];
}

- (void)snailFilleColor:(UIColor *)color {
    [_shapes enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.fillColor = color.CGColor;
    }];
}

- (void)privatePanAction:(UIPanGestureRecognizer *)ges {
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            _radius = MIN(self.bounds.size.width, self.bounds.size.height) * .5;
            if (_radius > 10) _radius = 10;
            _radiusExtend = _radius * .5;
            
            UIView *showView = UIApplication.sharedApplication.keyWindow;
            
            [_shapes enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull shape, NSUInteger idx, BOOL * _Nonnull stop) {
                [showView.layer addSublayer:shape];
            }];
            
            _firstCycle.center = [showView convertPoint:CGPointMake(self.bounds.size.width * .5, self.bounds.size.height * .5) fromView:self];
            _firstCycle.radius = _radius;
            
            _previewView = [UIView new];
            _previewView.layer.contentsScale = UIScreen.mainScreen.scale;
            _previewView.layer.contentsGravity = kCAGravityCenter;
            _previewView.frame = [showView convertRect:self.frame fromView:self.superview];
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, [UIScreen mainScreen].scale);
            [self.layer renderInContext:UIGraphicsGetCurrentContext()];
            _previewView.layer.contents = (__bridge id _Nullable)(UIGraphicsGetImageFromCurrentImageContext().CGImage);
            UIGraphicsEndImageContext();
            [showView addSubview:_previewView];
            
            CGMutablePathRef pathref = CGPathCreateMutable();
            CGPathAddArc(pathref, &CGAffineTransformIdentity, _firstCycle.center.x, _firstCycle.center.y, _firstCycle.radius, 0, M_PI * 2, false);
            [_shapes enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.path = pathref;
            }];
            CGPathRelease(pathref);
            
            _isBreaken = false;
            _isShowBridge = true;
            
            if (self.startBlock) self.startBlock();
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            UIView *showView = UIApplication.sharedApplication.keyWindow;
            SnailBadgeCycle touchCycle;
            touchCycle.center = [ges locationInView:showView];
            touchCycle.radius = _radius;
            [self _updatePathWithTouchCycle:touchCycle];
            _previewView.center = touchCycle.center;
        }
            break;
        default:
        {
            if (_isBreaken) {
                UIView *showView = UIApplication.sharedApplication.keyWindow;
                _shapes[1].path = nil;
                _previewView.hidden = true;
                [_SnailBadgeBoom boomInView:showView Point:_previewView.center Block:^{
                    [self endActon];
                }];
            }
            else {
                if (_isShowBridge) [self startWatch];
                else _shapes[1].path = nil;
                [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self->_previewView.center = self->_firstCycle.center;
                } completion:^(BOOL finished) {
                    if (self->_isShowBridge) [self stopWatch];
                    [self endActon];
                }];
                
            }
            
        }
            break;
    }
}

- (void)startWatch {
    [self stopWatch];
    _watchLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(watchAction)];
    [_watchLink addToRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
}

- (void)stopWatch {
    [_watchLink setPaused:true];
    [_watchLink invalidate];
    _watchLink = nil;
}

- (void)watchAction {
    SnailBadgeCycle touchCycle;
    touchCycle.center = _previewView.center;
    touchCycle.radius = _radius;
    [self _updatePathWithTouchCycle:touchCycle];
}

- (void)endActon {
    
    [self->_previewView removeFromSuperview];
    self->_previewView = nil;
    [self->_shapes enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.path = nil;
        [obj removeFromSuperlayer];
    }];
    if (self.stopBlock) self.stopBlock(self->_isBreaken);
    self->_isBreaken = false;
    
}

- (void)_updatePathWithTouchCycle:(SnailBadgeCycle)touchCycle {
    
    CGPoint a0 = _firstCycle.center;
    CGPoint a1 = touchCycle.center;
    
    CGFloat distance = sqrt(powf(a0.x - a1.x, 2) + powf(a0.y - a1.y, 2));
    if (distance > _maxDistance) {
        distance = _maxDistance;
        _isBreaken = true;
        if (_isShowBridge) _isShowBridge = false;
    }
    else _isBreaken = false;
    
    _firstCycle.radius = _radius - _radiusExtend * (distance / _maxDistance);
    
    CGFloat r0 = _firstCycle.radius;
    CGFloat r1 = touchCycle.radius;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (!_isBreaken && _isShowBridge) [path addArcWithCenter:a0 radius:r0 startAngle:0 endAngle:M_PI * 2 clockwise:false];
    _shapes[0].path = path.CGPath;
    [path removeAllPoints];
    
    [path addArcWithCenter:a1 radius:r1 startAngle:0 endAngle:M_PI * 2 clockwise:false];
    _shapes[1].path = path.CGPath;
    [path removeAllPoints];
    
    if (!_isBreaken && _isShowBridge) {
        CGFloat angle1 = atan((a1.y - a0.y) / (a0.x - a1.x));
        CGFloat angle2 = asin((r1 - r0) / distance);
        CGFloat angle3 = M_PI_2 - angle1 - angle2;
        CGFloat angle4 = M_PI_2 - angle1 + angle2;
        
        CGPoint p1;
        p1.x = a0.x - cos(angle3) * r0;
        p1.y = a0.y - sin(angle3) *r0;
        
        CGPoint p2;
        p2.x = a1.x - cos(angle3) * r1;
        p2.y = a1.y - sin(angle3) *r1;
        
        CGPoint p3;
        p3.x = a0.x + cos(angle4) * r0;
        p3.y = a0.y + sin(angle4) *r0;
        
        CGPoint p4;
        p4.x = a1.x + cos(angle4) * r1;
        p4.y = a1.y + sin(angle4) *r1;
        
        CGPoint p5;
        p5.x = (p1.x + p4.x) *.5;
        p5.y = (p1.y + p4.y) *.5;
        
        CGPoint p6;
        p6.x = (p3.x + p2.x) *.5;
        p6.y = (p3.y + p2.y) *.5;
        
        [path moveToPoint:p1];
        [path addLineToPoint:p3];
        [path addQuadCurveToPoint:p4 controlPoint:p6];
        [path addLineToPoint:p2];
        [path addQuadCurveToPoint:p1 controlPoint:p5];
        
    }
    
    _shapes[2].path = path.CGPath;
    
}

- (void)setSnailEnableDrag:(BOOL)snailEnableDrag {
    if (_snailEnableDrag != snailEnableDrag) {
        _snailEnableDrag = snailEnableDrag;
        if (snailEnableDrag) {
            _privatePanGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(privatePanAction:)];
            [self addGestureRecognizer:_privatePanGes];
        }
        else {
            [self removeGestureRecognizer:_privatePanGes];
            _privatePanGes = nil;
        }
    }
}

- (void)dealloc {
    [_shapes enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    _shapes = nil;
}

@end
