//
//  SnailImageCropController.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/9/26.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailImageCropController.h"

static CGFloat snailImageCropFrameControlPointWidth = 15;
static CGFloat snailImageCropFrameBarHeight = 45;
static CGFloat snailImageCropFrameMinWidth = 100;

typedef NS_ENUM(char,SnailImageCropFrameControlDirection) {
    SnailImageCropFrameControlDirectionLT, //左上
    SnailImageCropFrameControlDirectionRT, //右上
    SnailImageCropFrameControlDirectionMT, //中上
    SnailImageCropFrameControlDirectionLB, //左下
    SnailImageCropFrameControlDirectionRB, //右下
    SnailImageCropFrameControlDirectionMB, //中下
    SnailImageCropFrameControlDirectionLM, //左中
    SnailImageCropFrameControlDirectionRM, //右中
    SnailImageCropFrameControlDirectionMC, //正中
};

@protocol SnailImageCropFrameControlProtocol<NSObject>

- (void)SnailImageCropFrameControlChange:(CGPoint)offset Direction:(SnailImageCropFrameControlDirection)direction;

@end

@interface SnailImageCropFrameControlView : UIView

@property (nonatomic ,strong) UIButton *ltBtn; //左上
@property (nonatomic ,strong) UIButton *rtBtn; //右上
@property (nonatomic ,strong) UIButton *mtBtn; //中上

@property (nonatomic ,strong) UIButton *lbBtn; //左下
@property (nonatomic ,strong) UIButton *rbBtn; //右下
@property (nonatomic ,strong) UIButton *mbBtn; //中下

@property (nonatomic ,strong) UIButton *lmBtn; //左中
@property (nonatomic ,strong) UIButton *rmBtn; //右中
@property (nonatomic ,strong) UIButton *mcBtn; //正中

@property (nonatomic ,assign) id<SnailImageCropFrameControlProtocol> protocol;

@property (nonatomic) BOOL isMoveing;

@end

@implementation SnailImageCropFrameControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        CGSize tmp = CGSizeMake(snailImageCropFrameControlPointWidth, snailImageCropFrameControlPointWidth);
        
        self.ltBtn = [UIButton new];
        self.ltBtn.frame = (CGRect){.origin=CGPointZero,.size=tmp};
        self.ltBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
        
        self.rtBtn = [UIButton new];
        self.rtBtn.frame = (CGRect){.origin=CGPointMake(frame.size.width - snailImageCropFrameControlPointWidth, 0),.size=tmp};
        self.rtBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
        
        self.mtBtn = [UIButton new];
        self.mtBtn.frame = (CGRect){.origin=CGPointMake((frame.size.width - snailImageCropFrameControlPointWidth) * .5, 0),.size=tmp};
        self.mtBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        
        CGFloat y = frame.size.height - snailImageCropFrameControlPointWidth;
        
        self.lbBtn = [UIButton new];
        self.lbBtn.frame = (CGRect){.origin=CGPointMake(0, y),.size=tmp};
        self.lbBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
        
        self.rbBtn = [UIButton new];
        self.rbBtn.frame = (CGRect){.origin=CGPointMake(frame.size.width - snailImageCropFrameControlPointWidth, y),.size=tmp};
        self.rbBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        
        self.mbBtn = [UIButton new];
        self.mbBtn.frame = (CGRect){.origin=CGPointMake((frame.size.width - snailImageCropFrameControlPointWidth) * .5, y),.size=tmp};
        self.mbBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        
        self.lmBtn = [UIButton new];
        self.lmBtn.frame = (CGRect){.origin=CGPointMake(0, (frame.size.height - snailImageCropFrameControlPointWidth) * .5),.size=tmp};
        self.lmBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        self.rmBtn = [UIButton new];
        self.rmBtn.frame = (CGRect){.origin=CGPointMake(frame.size.width - snailImageCropFrameControlPointWidth, (frame.size.height - snailImageCropFrameControlPointWidth) * .5),.size=tmp};
        self.rmBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        self.mcBtn = [UIButton new];
        self.mcBtn.frame = (CGRect){.origin=CGPointMake(snailImageCropFrameControlPointWidth * 2, snailImageCropFrameControlPointWidth * 2),.size=CGSizeMake(frame.size.width - snailImageCropFrameControlPointWidth * 4, frame.size.height - snailImageCropFrameControlPointWidth * 4)};
        self.mcBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.mcBtn addTarget:self action:@selector(moveEndAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.ltBtn];
        [self addSubview:self.rtBtn];
        [self addSubview:self.mtBtn];
        
        [self addSubview:self.lbBtn];
        [self addSubview:self.rbBtn];
        [self addSubview:self.mbBtn];
        
        [self addSubview:self.lmBtn];
        [self addSubview:self.rmBtn];
        [self addSubview:self.mcBtn];
        
        for (UIButton *btn in @[self.ltBtn,self.rtBtn,self.mtBtn,self.lbBtn,self.mbBtn,self.rbBtn,self.lmBtn,self.rmBtn,self.mcBtn]) {
            [self addSubview:btn];
            [btn addTarget:self action:@selector(dragAction:Event:) forControlEvents:UIControlEventTouchDragInside];
            if (btn != self.mcBtn) {
                btn.snail_corner(snailImageCropFrameControlPointWidth * .5);
                btn.backgroundColor = SNA_RED_COLOR;
            }
        }
        
    }
    return self;
}

- (void)dragAction:(UIButton *)btn Event:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:btn];
    CGPoint prePoint = [touch previousLocationInView:btn];
    CGPoint offset = CGPointMake(point.x - prePoint.x, point.y - prePoint.y);
    
    SnailImageCropFrameControlDirection direction;
    if (btn == self.ltBtn) direction = SnailImageCropFrameControlDirectionLT;
    else if (btn == self.rtBtn) direction = SnailImageCropFrameControlDirectionRT;
    else if (btn == self.mtBtn) direction = SnailImageCropFrameControlDirectionMT;
    else if (btn == self.lbBtn) direction = SnailImageCropFrameControlDirectionLB;
    else if (btn == self.rbBtn) direction = SnailImageCropFrameControlDirectionRB;
    else if (btn == self.mbBtn) direction = SnailImageCropFrameControlDirectionMB;
    else if (btn == self.lmBtn) direction = SnailImageCropFrameControlDirectionLM;
    else if (btn == self.rmBtn) direction = SnailImageCropFrameControlDirectionRM;
    else {
        if (!self.isMoveing) {
            [self hiddenControlPoint];
            self.isMoveing = true;
        }
        direction = SnailImageCropFrameControlDirectionMC;
    }
    
    [self.protocol SnailImageCropFrameControlChange:offset Direction:direction];
    
}

- (void)moveEndAction {
    
    self.isMoveing = false;
    [self showControlPoint];
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIButton *btn in @[self.ltBtn,self.rtBtn,self.mtBtn,self.lbBtn,self.mbBtn,self.rbBtn,self.lmBtn,self.rmBtn]) {
        if (CGRectContainsPoint(CGRectInset(btn.frame, -15, -15), point)) {
            return btn;
        }
    }
    return [super hitTest:point withEvent:event];
}

- (void)hiddenControlPoint {
    [UIView animateWithDuration:0.15 animations:^{
        for (UIButton *btn in @[self.ltBtn,self.rtBtn,self.mtBtn,self.lbBtn,self.mbBtn,self.rbBtn,self.lmBtn,self.rmBtn]) {
            btn.alpha = 0;
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showControlPoint {
    [UIView animateWithDuration:0.15 animations:^{
        for (UIButton *btn in @[self.ltBtn,self.rtBtn,self.mtBtn,self.lbBtn,self.mbBtn,self.rbBtn,self.lmBtn,self.rmBtn]) {
            btn.alpha = 1;
        }
    } completion:^(BOOL finished) {
        
    }];
}

@end

@interface SnailImageCropFrameView : UIView

@property (nonatomic) SnailImageCropType type;
@property (nonatomic ,copy) UIColor *maskColor;

@end

@implementation SnailImageCropFrameView

- (instancetype)init {
    self = [super init];
    if (self) {
      //  self.layer.contentsCenter = CGRectMake(0.25, 0.25, .5, .5);
        self.type = -1;
    }
    return self;
}

- (void)update {
    
    UIImage *tmp = [SnailSimpleCIMManager takeCIM:nil Cache:false Size:^CGSize{
        return CGSizeMake(SNA_MIN_WH, SNA_MIN_WH);
    } Block:^(CGContextRef ctx, CGRect rect, CGFloat scale) {
        
        switch (self.type) {
            case SnailImageCropSquare:
            {
                
            }
                break;
            case SnailImageCropCycle:
            {
                [self.maskColor setFill];
                UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
                CGContextAddPath(ctx, path.CGPath);
                path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.width * .5];
                CGContextAddPath(ctx, path.CGPath);
                CGContextEOFillPath(ctx);
            }
                break;
        }
        
    }];
    self.layer.contents = (__bridge id _Nullable)(tmp.CGImage);
    
}

- (void)setType:(SnailImageCropType)type {
    if (_type != type) {
        _type = type;
        [self update];
    }
}

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    [self update];
}

@end

#pragma mark -

@interface SnailImageCropImageShowView : UIScrollView<UIScrollViewDelegate>


@end

@interface SnailImageCropImageShowView()

@property (nonatomic ,strong) UIImageView *imageview;

@end

@implementation SnailImageCropImageShowView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageview.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageview];
        self.delegate = self;
        self.maximumZoomScale = 3;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = self.imageview;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end

#pragma mark -

@interface SnailImageCropController(Protocol)<SnailImageCropFrameControlProtocol>

@end

#pragma mark -

@interface SnailImageCropController ()

@property (nonatomic ,strong) UIColor *maskColor;

/*----------------------------------Nav-----------------------------------------------------------*/
@property (nonatomic) BOOL navIsHidden;

/*----------------------------------container-----------------------------------------------------------*/

@property (nonatomic ,strong) UIView *topContainer;

@property (nonatomic ,strong) UIView *topMask;
@property (nonatomic ,strong) UIView *leftMask;
@property (nonatomic ,strong) UIView *bottomMask;
@property (nonatomic ,strong) UIView *rightMask;

@property (nonatomic ,strong) UIView *frameContainer;
@property (nonatomic ,strong) SnailImageCropFrameControlView *frameControl;
@property (nonatomic ,strong) SnailImageCropFrameView *frameView;

@property (nonatomic ,strong) SnailImageCropImageShowView *imageShowView;

/*----------------------------------bar-----------------------------------------------------------*/

@property (nonatomic ,strong) UIView *barView;
@property (nonatomic ,strong) UIToolbar *barBackView;
@property (nonatomic ,strong) UIButton *cancleBtn;
@property (nonatomic ,strong) UIButton *doneBtn;

@end

@implementation SnailImageCropController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maskColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.canScaleFrame = true;
        self.scale = MAX(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height) / MIN(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
        self.type = SnailImageCropSquare;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    if (self.type == SnailImageCropCycle) {
        self.scale = 1.0;
    }
    
    self.topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - snailImageCropFrameBarHeight)];
    self.topContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.imageShowView = [[SnailImageCropImageShowView alloc] initWithFrame:self.topContainer.bounds];
    
    {
        CGFloat frameWidth = self.view.frame.size.width;
        CGFloat frameHeight = frameWidth / self.scale;
        
        self.frameContainer = [UIView new];
        self.frameContainer.frame = CGRectMake(0, (self.topContainer.bounds.size.height - frameHeight) * .5, frameWidth, frameHeight);
        
        self.frameView = [SnailImageCropFrameView new];
        self.frameView.frame = CGRectMake(0, 0, self.frameContainer.frame.size.width, self.frameContainer.frame.size.height);
        self.frameView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.frameView.maskColor = self.maskColor;
        self.frameView.type = self.type;
        
        self.frameControl = [[SnailImageCropFrameControlView alloc] initWithFrame:CGRectMake(-snailImageCropFrameControlPointWidth * .5, -snailImageCropFrameControlPointWidth * .5, self.frameContainer.frame.size.width + snailImageCropFrameControlPointWidth, self.frameContainer.frame.size.height + snailImageCropFrameControlPointWidth)];
        self.frameControl.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.frameControl.protocol = self;
        
    }
    
    self.topMask = [UIView new];
    self.topMask.backgroundColor = self.maskColor;
    self.topMask.userInteractionEnabled = false;
    
    self.leftMask = [UIView new];
    self.leftMask.backgroundColor = self.maskColor;
    self.leftMask.userInteractionEnabled = false;
    
    self.bottomMask = [UIView new];
    self.bottomMask.backgroundColor = self.maskColor;
    self.bottomMask.userInteractionEnabled = false;
    
    self.rightMask = [UIView new];
    self.rightMask.backgroundColor = self.maskColor;
    self.rightMask.userInteractionEnabled = false;
    
    self.barView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - snailImageCropFrameBarHeight, self.view.bounds.size.width, snailImageCropFrameBarHeight)];
    self.barView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    
    self.barBackView = [[UIToolbar alloc] initWithFrame:self.barView.bounds];
    self.barBackView.barStyle = UIBarStyleBlack;
    self.barBackView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, snailImageCropFrameBarHeight)];
    [self.cancleBtn setTitle:SNASLS(取消) forState:UIControlStateNormal];
    [self.cancleBtn setTitleColor:SNA_WHITE_COLOR forState:UIControlStateNormal];
    [self.cancleBtn addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
    self.cancleBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 0, 80, snailImageCropFrameBarHeight)];
    [self.doneBtn setTitle:SNASLS(确定) forState:UIControlStateNormal];
    [self.doneBtn setTitleColor:SNA_WHITE_COLOR forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    self.doneBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.topContainer];
    [self.view addSubview:self.barView];
    
    [self.topContainer addSubview:self.imageShowView];
    [self.topContainer addSubview:self.topMask];
    [self.topContainer addSubview:self.leftMask];
    [self.topContainer addSubview:self.bottomMask];
    [self.topContainer addSubview:self.rightMask];
    [self.topContainer addSubview:self.frameContainer];
    [self.frameContainer addSubview:self.frameView];
    [self.frameContainer addSubview:self.frameControl];
    
    [self.barView addSubview:self.barBackView];
    [self.barView addSubview:self.cancleBtn];
    [self.barView addSubview:self.doneBtn];
    
    [self updateFrame];
    
    self.imageShowView.imageview.image = self.image;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navIsHidden = self.navigationController.navigationBar.hidden;
    self.navigationController.navigationBar.hidden = true;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = self.navIsHidden;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateFrame {
    
    self.topMask.frame = CGRectMake(0, 0, self.topContainer.frame.size.width, CGRectGetMinY(self.frameContainer.frame));
    self.bottomMask.frame = CGRectMake(0, CGRectGetMaxY(self.frameContainer.frame), self.topContainer.frame.size.width, self.topContainer.frame.size.height - CGRectGetMaxY(self.frameContainer.frame));
    self.leftMask.frame = CGRectMake(0, CGRectGetMinY(self.frameContainer.frame), CGRectGetMinX(self.frameContainer.frame), self.frameContainer.frame.size.height);
    self.rightMask.frame = CGRectMake(CGRectGetMaxX(self.frameContainer.frame), CGRectGetMinY(self.frameContainer.frame), self.topContainer.frame.size.width - CGRectGetMaxX(self.frameContainer.frame), self.frameContainer.frame.size.height);
    
}

- (void)cancleAction {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:true];
    }
    else {
        [self dismissViewControllerAnimated:true completion:^{
            
        }];
    }
}

- (void)doneAction {
    if (self.cropImageDoneBlock) {
        
        CGFloat screenScale = UIScreen.mainScreen.scale * 1.0;
        CGFloat zoomScale = self.imageShowView.zoomScale * 1.0;
        
        CGSize originSize = self.frameContainer.frame.size;
        CGPoint originPoint = CGPointMake(self.frameContainer.frame.origin.x + self.imageShowView.contentOffset.x, self.frameContainer.frame.origin.y + self.imageShowView.contentOffset.y);
    
        CGSize cropSize = CGSizeMake(originSize.width / zoomScale, originSize.height  / zoomScale);
        CGPoint cropPoint = CGPointMake(originPoint.x / zoomScale, originPoint.y / zoomScale);
        
        UIGraphicsBeginImageContextWithOptions(cropSize, false, screenScale);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(ctx, -cropPoint.x, -cropPoint.y);
        if (self.type == SnailImageCropCycle) {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:(CGRect){.origin=cropPoint,.size=cropSize} cornerRadius:cropSize.width * .5];
            CGContextAddPath(ctx, path.CGPath);
            CGContextClip(ctx);
        }
        [self.imageShowView.imageview.layer renderInContext:ctx];
        
        UIImage *crop = UIGraphicsGetImageFromCurrentImageContext();
        self.cropImageDoneBlock(crop);
        UIGraphicsEndImageContext();
    }
    [self cancleAction];
}

@end

@implementation SnailImageCropController(Protocol)

- (void)SnailImageCropFrameControlChange:(CGPoint)offset Direction:(SnailImageCropFrameControlDirection)direction {
    
    NSLog(@"offset: %@",NSStringFromCGPoint(offset));
    
    CGRect frame = self.frameContainer.frame;
    
    switch (direction) {
        case SnailImageCropFrameControlDirectionLM:
        {
            frame.origin.x += offset.x;
            if (frame.origin.x < 0) frame.origin.x = 0;
            frame.size.width -= offset.x;
            if (CGRectGetMaxX(frame) > self.topContainer.bounds.size.width) {
                frame.size.width = self.topContainer.bounds.size.width - frame.origin.x;
            }
            frame.size.height =  frame.size.width / self.scale;
        }
            break;
        case SnailImageCropFrameControlDirectionRM:
        {
            frame.size.width += offset.x;
            if (CGRectGetMaxX(frame) > self.topContainer.bounds.size.width) {
                frame.size.width = self.topContainer.bounds.size.width - frame.origin.x;
            }
            frame.size.height =  frame.size.width / self.scale;
        }
            break;
        case SnailImageCropFrameControlDirectionMT:
        {
            frame.origin.y += offset.y;
            if (frame.origin.y < 0) frame.origin.y = 0;
            frame.size.height -= offset.y;
            if (CGRectGetMaxY(frame) > self.topContainer.bounds.size.height) {
                frame.size.height = self.topContainer.bounds.size.height - frame.origin.y;
            }
            frame.size.width =  frame.size.height * self.scale;
        }
            break;
        case SnailImageCropFrameControlDirectionMB:
        {
            frame.size.height += offset.y;
            if (CGRectGetMaxY(frame) > self.topContainer.bounds.size.height) {
                frame.size.height = self.topContainer.bounds.size.height - frame.origin.y;
            }
            frame.size.width =  frame.size.height * self.scale;
        }
            break;
        case SnailImageCropFrameControlDirectionLT:
        {
            CGFloat offsetScale = sqrt(offset.x * offset.x + offset.y * offset.y) / self.topContainer.frame.size.width;
            if (offsetScale > 0) {
                
                CGFloat shouldScale = 0;
                
                if (offset.x < 0 && offset.y < 0) {
                    shouldScale = (1+offsetScale);
                }
                else if (offset.x > 0 && offset.y > 0) {
                    shouldScale = (1-offsetScale);
                }
                if (shouldScale > 0) {
                    CGPoint tmp = CGPointMake(CGRectGetMaxX(self.frameContainer.frame), CGRectGetMaxY(self.frameContainer.frame));
                    frame.size.width *= shouldScale;
                    frame.size.height = frame.size.width / self.scale;
                    frame.origin.x = tmp.x - frame.size.width;
                    frame.origin.y = tmp.y - frame.size.height;
                }
            }
            
        }
            break;
        case SnailImageCropFrameControlDirectionRT:
        {
            
            CGFloat offsetScale = sqrt(offset.x * offset.x + offset.y * offset.y) / self.topContainer.frame.size.width;
            if (offsetScale > 0) {
                
                CGFloat shouldScale = 0;
                
                if (offset.x > 0 && offset.y < 0) {
                    shouldScale = (1+offsetScale);
                }
                else if (offset.x < 0 && offset.y > 0) {
                    shouldScale = (1-offsetScale);
                }
                
                if (shouldScale > 0) {
                    CGPoint tmp = CGPointMake(CGRectGetMinX(self.frameContainer.frame), CGRectGetMaxY(self.frameContainer.frame));
                    frame.size.width *= shouldScale;
                    frame.size.height = frame.size.width / self.scale;
                    frame.origin.x = tmp.x;
                    frame.origin.y = tmp.y - frame.size.height;
                }
            }
            
        }
            break;
        case SnailImageCropFrameControlDirectionLB:
        {
            
            CGFloat offsetScale = sqrt(offset.x * offset.x + offset.y * offset.y) / self.topContainer.frame.size.width;
            
            if (offsetScale > 0) {
                
                CGFloat shouldScale = 0;
                
                if (offset.x < 0 && offset.y > 0) {
                    shouldScale = (1+offsetScale);
                }
                else if (offset.x > 0 && offset.y < 0) {
                    shouldScale = (1-offsetScale);
                }
                
                if (shouldScale > 0) {
                    CGPoint tmp = CGPointMake(CGRectGetMaxX(self.frameContainer.frame), CGRectGetMinY(self.frameContainer.frame));
                    frame.size.width *= shouldScale;
                    frame.size.height = frame.size.width / self.scale;
                    frame.origin.x = tmp.x - frame.size.width;
                    frame.origin.y = tmp.y;
                }
                
            }
            
        }
            break;
        case SnailImageCropFrameControlDirectionRB:
        {
            
            CGFloat offsetScale = sqrt(offset.x * offset.x + offset.y * offset.y) / self.topContainer.frame.size.width;
            if (offsetScale > 0) {
                
                CGFloat shouldScale = 0;
                
                if (offset.x > 0 && offset.y > 0) {
                    shouldScale = (1+offsetScale);
                }
                else if (offset.x < 0 && offset.y < 0) {
                    shouldScale = (1-offsetScale);
                }
                
                if (shouldScale > 0) {
                    CGPoint tmp = CGPointMake(CGRectGetMinX(self.frameContainer.frame), CGRectGetMinY(self.frameContainer.frame));
                    frame.size.width *= shouldScale;
                    frame.size.height = frame.size.width / self.scale;
                    frame.origin.x = tmp.x;
                    frame.origin.y = tmp.y;
                }
                
            }
            
        }
            break;
        case SnailImageCropFrameControlDirectionMC:
        {
            frame.origin.x += offset.x;
            frame.origin.y += offset.y;
            if (CGRectGetMaxX(frame) > self.topContainer.bounds.size.width) {
                frame.origin.x = self.topContainer.bounds.size.width - frame.size.width;
            }
            if (CGRectGetMaxY(frame) > self.topContainer.bounds.size.height) {
                frame.origin.y = self.topContainer.bounds.size.height - frame.size.height;
            }
            if (frame.origin.x < 0) {
                frame.origin.x = 0;
            }
            if (frame.origin.y < 0) {
                frame.origin.y = 0;
            }
        }
        break;
    }
    
    if (frame.size.width < snailImageCropFrameMinWidth) {
        frame.size.width = snailImageCropFrameMinWidth;
        frame.size.height = frame.size.width / self.scale;
    }
    if (CGRectGetMaxX(frame) > self.topContainer.frame.size.width) {
        frame.size.width = self.topContainer.frame.size.width - frame.origin.x;
        frame.size.height = frame.size.width / self.scale;
    }
    if (CGRectGetMaxY(frame) > self.topContainer.frame.size.height) {
        frame.size.height = self.topContainer.frame.size.height - frame.origin.y;
        frame.size.width = frame.size.height * self.scale;
    }
    
    self.frameContainer.frame = frame;
    [self updateFrame];
    
}

@end
