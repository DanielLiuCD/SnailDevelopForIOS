//
//  SnailCameraDefaultController.m
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/9/4.
//  Copyright © 2018年 com.snail. All rights reserved.
//

#import "SnailCameraDefaultController.h"
#import "_SnailCameraButton.h"
@import AVFoundation;

@interface SnailCameraDefaultActionButton : UIView

@property (nonatomic ,strong) _SnailCameraButton *button;
@property (nonatomic ,strong) CAShapeLayer *cycleBackLayer;
@property (nonatomic ,strong) CAShapeLayer *cycleLayer;
@property (nonatomic ,strong) NSLayoutConstraint *leadingConstraint;
@property (nonatomic ,strong) NSLayoutConstraint *topConstraint;

- (void)setImage:(UIImage *)image;
- (void)setMovieDownBlock:(void(^)(void))block;
- (void)setClickBlock:(void(^)(void))block;
- (void)setStartLongPressBlock:(void(^)(void))block;
- (void)setEndLongPressBlock:(void(^)(void))block;
- (void)manualStartLongPressBlock;
- (void)manualEndLongPressBlock;

///value 0 - 1
- (void)setProgressValue:(CGFloat)value;

- (void)setProgressColor:(UIColor *)color;
- (void)setProgressBackColor:(UIColor *)color;
- (void)showProgressCycle;
- (void)hiddenProgressCycle;

- (void)setCycleWidth:(CGFloat)width;

@end

@implementation SnailCameraDefaultActionButton

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.button = [_SnailCameraButton new];
        self.button.translatesAutoresizingMaskIntoConstraints = false;
        [self addSubview:self.button];
        
        NSLayoutConstraint *constraintX = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *constraintY = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *constraintLeading = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:12];
        NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:12];
        
        [self addConstraints:@[constraintX,constraintY,constraintTop,constraintLeading]];
        
        self.leadingConstraint = constraintLeading;
        self.topConstraint = constraintTop;
        
        self.cycleBackLayer = [CAShapeLayer layer];
        self.cycleBackLayer.lineWidth = 12.0;
        self.cycleBackLayer.lineCap = kCALineCapRound;
        self.cycleBackLayer.lineJoin = kCALineCapRound;
        self.cycleBackLayer.fillColor = UIColor.clearColor.CGColor;
        self.cycleBackLayer.strokeStart = 0;
        self.cycleBackLayer.strokeEnd = 1;
        [self.layer addSublayer:self.cycleBackLayer];
        
        self.cycleLayer = [CAShapeLayer layer];
        self.cycleLayer.lineWidth = 12.0;
        self.cycleLayer.lineCap = kCALineCapSquare;
        self.cycleLayer.lineJoin = kCALineCapSquare;
        self.cycleLayer.fillColor = UIColor.clearColor.CGColor;
        self.cycleLayer.strokeStart = 0;
        self.cycleLayer.strokeEnd = 0;
        [self.layer addSublayer:self.cycleLayer];
        
        [self hiddenProgressCycle];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.cycleLayer.frame = self.bounds;
    
    CGAffineTransform transfrom = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
    transfrom = CGAffineTransformTranslate(transfrom, -self.bounds.size.width, -self.bounds.size.height);
    
    CGMutablePathRef pathref = CGPathCreateMutable();
    CGPathAddArc(pathref, &transfrom, self.bounds.size.width * .5, self.bounds.size.height * .5, self.bounds.size.width * .5 - self.cycleLayer.lineWidth * .5, 0, M_PI * 2, false);
    self.cycleLayer.path = pathref;
    CGPathRelease(pathref);
    
    CGMutablePathRef backpathref = CGPathCreateMutable();
    CGPathAddArc(backpathref, &transfrom, self.bounds.size.width * .5, self.bounds.size.height * .5, self.bounds.size.width * .5 - self.cycleBackLayer.lineWidth * .5, 0, M_PI * 2, false);
    self.cycleBackLayer.path = backpathref;
    CGPathRelease(backpathref);
    
}

- (void)setImage:(UIImage *)image {
    self.button.image = image;
}

- (void)setMovieDownBlock:(void (^)(void))block {
    self.button.movieDoneActionBlock = block;
}

- (void)setClickBlock:(void (^)(void))block {
    self.button.clickActionBlock = block;
}

- (void)setStartLongPressBlock:(void (^)(void))block {
    self.button.startLongPressActionBlock = block;
}

- (void)setEndLongPressBlock:(void (^)(void))block {
    self.button.endLongPressActionBlock = block;
}

- (void)setProgressValue:(CGFloat)value {
    self.cycleLayer.strokeEnd = value;
}

- (void)setProgressColor:(UIColor *)color {
    self.cycleLayer.strokeColor = color.CGColor;
}

- (void)setProgressBackColor:(UIColor *)color {
    self.cycleBackLayer.strokeColor = color.CGColor;
}

- (void)manualStartLongPressBlock {
    self.button.startLongPressActionBlock();
}

- (void)manualEndLongPressBlock {
    self.button.endLongPressActionBlock();
}

- (void)showProgressCycle {
    self.cycleLayer.hidden = self.cycleBackLayer.hidden = false;
}

- (void)hiddenProgressCycle {
    self.cycleLayer.hidden = self.cycleBackLayer.hidden = true;
}

- (void)setCycleWidth:(CGFloat)width {
    self.cycleLayer.lineWidth = width;
    self.leadingConstraint.constant = self.topConstraint.constant = width;
}

@end

#define SnailCameraUILocalized(key,comment) NSLocalizedString(key, comment)
#define SnailCameraDegressTranToRadians(DEGRESS) DEGRESS * M_PI / 180

@interface SnailCameraDefaultController ()<AVCaptureMetadataOutputObjectsDelegate>

/*-----------------------------------UI----------------------------------------------*/

@property (nonatomic ,strong) UIActivityIndicatorView *activityView;

@property (nonatomic ,strong) NSLock *lock;
@property (nonatomic ,weak) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic ,strong) SnailCameraDefaultActionButton *acBtn;
@property (nonatomic ,strong) UIButton *swiCam;
@property (nonatomic ,strong) UIButton *lightBtn;
@property (nonatomic ,strong) UIButton *closeBtn;

@property (nonatomic ,weak) NSLayoutConstraint *acW;
@property (nonatomic ,weak) NSLayoutConstraint *acH;

@property (nonatomic ,strong) dispatch_queue_t snaCameraQueue;

/*-----------------------------------相机----------------------------------------------*/
@property (nonatomic ,strong) SnailCameraManager *camera;

/*-----------------------------------Movie----------------------------------------------*/
@property (nonatomic) NSInteger maxMovieTime;
@property (nonatomic) NSInteger minMovieTime;

/*-----------------------------------Face----------------------------------------------*/
@property (nonatomic) BOOL enableFace;
@property (nonatomic ,copy) SnailCameraDefaultControllerFaceBlock faceBlock;
@property (nonatomic ,strong) NSMutableDictionary *faces;
@property (nonatomic ,strong) NSMutableDictionary *lostFaces;
@property (nonatomic ,strong) AVCaptureMetadataOutput *faceMetaOutput;
@property (nonatomic ,copy) UIColor *faceBorderColor;
@property (nonatomic ,strong) NSArray *tmpFaceLayers;

@end

@interface SnailCameraDefaultController()

- (void)handleLostFaces;

@end

@implementation SnailCameraDefaultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    {
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityView.hidesWhenStopped = true;
        self.activityView.translatesAutoresizingMaskIntoConstraints = false;
        
        NSLayoutConstraint *activityX = [NSLayoutConstraint constraintWithItem:self.activityView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *activityY = [NSLayoutConstraint constraintWithItem:self.activityView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
        [self.view addSubview:self.activityView];
        
        [self.view addConstraints:@[activityX,activityY]];
        
        [self.activityView startAnimating];
    }

    if (self.maxMovieTime <= 0) self.maxMovieTime = 60.0;
    if (self.minMovieTime <= 0) self.minMovieTime = 5.0;
    if (self.minMovieTime > self.maxMovieTime) self.maxMovieTime = self.minMovieTime;
    
    __weak typeof(self) weakself = self;
    
    self.camera = [SnailCameraManager new];
    self.camera.movieClarity = 0.2;
    self.camera.cameraErrorBlock = self.cameraErrorBlock;
    self.camera.cameraImageBlock = ^(UIImage *image, NSString *imageName) {
        
        if (weakself.cameraImageBlock) {
            weakself.cameraImageBlock(image, imageName);
        }
        if (weakself.faceBlock) {
            
            UIImage *tmpImage = image;
            CGFloat imageScale = tmpImage.scale;
            CGSize imageSize = tmpImage.size;
            
            NSMutableArray *tmpFaces = [NSMutableArray new];
            NSMutableArray *tmpFaceNames = [NSMutableArray new];
            NSArray<CALayer *> *tmpLayers = weakself.tmpFaceLayers;
            
            [tmpLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               
                NSValue *originalValue= objc_getAssociatedObject(obj, "SNAIL_CAMERA_FACE_BOUNDS_KEY");
                CGRect originalFrame = originalValue.CGRectValue;
                
                { /*人脸范围补偿*/
                    
                    switch (image.imageOrientation) {
                        case UIImageOrientationRight:
                        case UIImageOrientationLeft:
                        {
                            if (weakself.faceFixInsets.left != 0) {
                                originalFrame.origin.y = originalFrame.origin.y - weakself.faceFixInsets.left;
                                originalFrame.size.height = originalFrame.size.height + weakself.faceFixInsets.left;
                            }
                            if (weakself.faceFixInsets.top != 0) {
                                originalFrame.origin.x = originalFrame.origin.x - weakself.faceFixInsets.top;
                                originalFrame.size.width = originalFrame.size.width + weakself.faceFixInsets.top;
                            }
                            if (weakself.faceFixInsets.right != 0) {
                                originalFrame.size.height = originalFrame.size.height + weakself.faceFixInsets.right;
                            }
                            if (weakself.faceFixInsets.bottom != 0) {
                                originalFrame.size.width = originalFrame.size.width + weakself.faceFixInsets.bottom;
                            }
                        }
                            break;
                        case UIImageOrientationUp:
                        case UIImageOrientationDown:
                        {
                            if (weakself.faceFixInsets.left != 0) {
                                originalFrame.origin.x -= weakself.faceFixInsets.left;
                                originalFrame.size.width += weakself.faceFixInsets.left;
                            }
                            if (weakself.faceFixInsets.top != 0) {
                                originalFrame.origin.y -= weakself.faceFixInsets.top;
                                originalFrame.size.height += weakself.faceFixInsets.top;
                            }
                            if (weakself.faceFixInsets.right != 0) {
                                originalFrame.size.width += weakself.faceFixInsets.right;
                            }
                            if (weakself.faceFixInsets.bottom != 0) {
                                originalFrame.size.height += weakself.faceFixInsets.bottom;
                            }
                        }
                            break;
                        default:
                            break;
                    }
                    
                }
                
                CGRect frame = CGRectZero;
                switch (image.imageOrientation) {
                    case UIImageOrientationRight:
                    case UIImageOrientationLeft:
                        frame = CGRectMake(imageSize.height * originalFrame.origin.x, imageSize.width * originalFrame.origin.y, imageSize.height * originalFrame.size.width, imageSize.width * originalFrame.size.height);
                        break;
                    case UIImageOrientationDown:
                    case UIImageOrientationUp:
                        frame = CGRectMake(imageSize.width * originalFrame.origin.x, imageSize.height * originalFrame.origin.y, imageSize.width * originalFrame.size.width, imageSize.height * originalFrame.size.height);
                        break;
                    default:break;
                }
                frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeScale(imageScale, imageScale));
                
                CGImageRef imgRef = CGImageCreateWithImageInRect(tmpImage.CGImage, frame);
                UIImage *faceImage = [UIImage imageWithCGImage:imgRef scale:imageScale orientation:tmpImage.imageOrientation];
                CGImageRelease(imgRef);
                
                if (faceImage) {
                    [tmpFaces addObject:faceImage];
                    [tmpFaceNames addObject:[NSString stringWithFormat:@"%f.png",[[NSDate date] timeIntervalSince1970]]];
                }
                
            }];
            weakself.tmpFaceLayers = nil;
            weakself.faceBlock(tmpFaces.copy, tmpFaceNames.copy);
            
        }
        
    };
    self.camera.cameraMovieBlock = ^(NSURL *moviewUrl, NSTimeInterval duration, UIImage *previewImage, NSUInteger fileSize) {
        
        if (duration < weakself.minMovieTime) {
            
            [[NSFileManager defaultManager] removeItemAtURL:moviewUrl error:nil];
            
            UIAlertController *con = [UIAlertController alertControllerWithTitle:SnailCameraUILocalized(@"提示",nil) message:SnailCameraUILocalized(@"录制时间太短", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ac0 = [UIAlertAction actionWithTitle:SnailCameraUILocalized(@"确定",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [con addAction:ac0];
            [weakself presentViewController:con animated:true completion:^{
                
            }];
            
        }
        else {
            weakself.cameraMovieBlock(moviewUrl,duration,previewImage,fileSize);
        }
        
    };
    
    
    self.camera.cameraMovieTimeProgressBlock = ^(NSTimeInterval duration) {
        NSLog(@"录制了%.0fs",duration);
        [weakself.acBtn setProgressValue:duration / weakself.maxMovieTime];
        if (duration > weakself.maxMovieTime) {
            [weakself.acBtn manualEndLongPressBlock];
        }
    };

    [self.camera runAsync:^(UIView *preview) {
        
        {
            if (self.enableFace) {
                
                AVCaptureMetadataOutput *metaOutput = [AVCaptureMetadataOutput new];
                if ([self.camera addOutput:metaOutput]) {
                    metaOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
                    metaOutput.rectOfInterest = self.view.bounds;
                    [metaOutput setMetadataObjectsDelegate:self queue:self.snaCameraQueue];
                    self.faceMetaOutput = metaOutput;
                }
                
            }
        }
        
        {
            [self.activityView stopAnimating];
            [self.activityView removeFromSuperview];
            self.activityView = nil;
        }
        
        self.previewLayer = (AVCaptureVideoPreviewLayer *)preview.layer;
        
        UIView *tmp = preview;
        tmp.translatesAutoresizingMaskIntoConstraints = false;
    //    tmp.frame = self.view.bounds;
        [self.view insertSubview:tmp atIndex:0];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(tmp);
        
        NSArray *tmps0 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tmp]-0-|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:views];
        NSArray *tmps1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tmp]-0-|" options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:nil views:views];

        [self.view addConstraints:tmps0];
        [self.view addConstraints:tmps1];
        
        [self createUI];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createUI {
    
    UIImage *acImage = nil;
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(55, 55), false, UIScreen.mainScreen.scale);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 55, 55) cornerRadius:55 * .5];
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextAddPath(ctx, path.CGPath);
        [[UIColor whiteColor] setFill];
        CGContextFillPath(ctx);
        
        acImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    UIColor *progressColor = [UIColor colorWithRed:217 / 255.0 green:212 / 255.0 blue:208 / 255.0 alpha:1];
    
    self.acBtn = [SnailCameraDefaultActionButton new];
    [self.acBtn setProgressColor:[UIColor whiteColor]];
    [self.acBtn setProgressBackColor:progressColor];
    [self.acBtn setImage:acImage];
    
    self.swiCam = [UIButton new];
    [self.swiCam setImage:[UIImage imageNamed:@"snail_camera_icon"] forState:UIControlStateNormal];
    
    self.lightBtn = [UIButton new];
    [self.lightBtn setImage:[[UIImage imageNamed:@"snail_lamp_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.lightBtn setImage:[[UIImage imageNamed:@"snail_lamp_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    self.lightBtn.tintColor = [UIColor whiteColor];
    
    UIImage *closeImage = nil;
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(22, 15), false, UIScreen.mainScreen.scale);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(3, 3)];
        [path addLineToPoint:CGPointMake(11, 12)];
        [path addLineToPoint:CGPointMake(19, 3)];
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ctx, 3);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextAddPath(ctx, path.CGPath);
        [[UIColor whiteColor] setStroke];
        CGContextStrokePath(ctx);
        
        closeImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    self.closeBtn = [UIButton new];
    [self.closeBtn setImage:closeImage forState:UIControlStateNormal];
    
    self.acBtn.translatesAutoresizingMaskIntoConstraints = false;
    self.swiCam.translatesAutoresizingMaskIntoConstraints = false;
    self.lightBtn.translatesAutoresizingMaskIntoConstraints = false;
    self.closeBtn.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.view addSubview:self.acBtn];
    [self.view addSubview:self.swiCam];
    [self.view addSubview:self.lightBtn];
    [self.view addSubview:self.closeBtn];
    
    NSLayoutConstraint *lightB = [NSLayoutConstraint constraintWithItem:self.lightBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-30];
    NSLayoutConstraint *lightX = [NSLayoutConstraint constraintWithItem:self.lightBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:0.5 constant:-30];
    NSLayoutConstraint *lightW = [NSLayoutConstraint constraintWithItem:self.lightBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    NSLayoutConstraint *lightH = [NSLayoutConstraint constraintWithItem:self.lightBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    
    [self.view addConstraints:@[lightX,lightB]];
    [self.lightBtn addConstraints:@[lightH,lightW]];
    
    NSLayoutConstraint *acY = [NSLayoutConstraint constraintWithItem:self.acBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.lightBtn attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *acW = [NSLayoutConstraint constraintWithItem:self.acBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:70];
    NSLayoutConstraint *acH = [NSLayoutConstraint constraintWithItem:self.acBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:70];
    NSLayoutConstraint *acX = [NSLayoutConstraint constraintWithItem:self.acBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    [self.view addConstraints:@[acY,acX]];
    [self.acBtn addConstraints:@[acH,acW]];
    
    self.acW = acW;
    self.acH = acH;
    
    NSLayoutConstraint *swiY = [NSLayoutConstraint constraintWithItem:self.swiCam attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.lightBtn attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *swiX = [NSLayoutConstraint constraintWithItem:self.swiCam attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.5 constant:30];
    NSLayoutConstraint *swiW = [NSLayoutConstraint constraintWithItem:self.swiCam attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    NSLayoutConstraint *swiH = [NSLayoutConstraint constraintWithItem:self.swiCam attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    
    [self.view addConstraints:@[swiX,swiY]];
    [self.swiCam addConstraints:@[swiH,swiW]];
    
    NSLayoutConstraint *closeTop = [NSLayoutConstraint constraintWithItem:self.closeBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:44];
    NSLayoutConstraint *closeTre = [NSLayoutConstraint constraintWithItem:self.closeBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:-30];
    NSLayoutConstraint *closeW = [NSLayoutConstraint constraintWithItem:self.closeBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    NSLayoutConstraint *closeH = [NSLayoutConstraint constraintWithItem:self.closeBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    
    [self.view addConstraints:@[closeTop,closeTre]];
    [self.closeBtn addConstraints:@[closeH,closeW]];
    
    __weak typeof(self) weakself = self;
    [self.acBtn setMovieDownBlock:^{
       
        [weakself zoomOutAnimale];
        
    }];
    
    [self createAction];
    
}

- (void)createAction {
    
    [self.swiCam addTarget:self action:@selector(switchCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.lightBtn addTarget:self action:@selector(switchLightAction) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    
    switch (self.mode) {
        case SnailCameraDefaultControllerDefault:
        {
            [self createMovieAction];[self createPhotoAction];
        }
            break;
        case SnailCameraDefaultControllerPhoto:[self createPhotoAction];
            break;
        case SnailCameraDefaultControllerMovie:[self createMovieAction];
            break;
        default:break;
    }
    
}

- (void)createPhotoAction {
    
    __weak typeof(self) weakself = self;
    [self.acBtn setClickBlock:^{
        [weakself zoomInAnimale];
        if (weakself.enableFace) {
            weakself.tmpFaceLayers = weakself.faces.allValues.copy;
        }
        [weakself.camera takePhoto];
    }];
    
}

- (void)createMovieAction {
    
    __weak typeof(self) weakself = self;
    [self.acBtn setStartLongPressBlock:^{
        [weakself.camera resumeMovie];
        [weakself.acBtn showProgressCycle];
    }];
    
    [self.acBtn setEndLongPressBlock:^{
        [weakself zoomInAnimale];
        [weakself.camera stopMovie];
    }];
    
}

- (void)zoomInAnimale {
    
    [UIView animateWithDuration:0.2 delay:0.001 usingSpringWithDamping:0.8 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.acBtn.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
        [self.acBtn setProgressValue:0];
        [self.acBtn hiddenProgressCycle];
        
    }];
    
}

- (void)zoomOutAnimale {
    
    [UIView animateWithDuration:0.2 delay:0.001 usingSpringWithDamping:0.8 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.acBtn.transform = CGAffineTransformMakeScale(1.3, 1.3);
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)switchCameraAction {
    
    [self.camera switchCamera];
    
    if (self.enableFace) {
        [self.lock lock];
        [self handleLostFaces];
        [self.lock unlock];
    }
    
    SnailCameraVideoPosition position = self.camera.currentCamera;
    self.lightBtn.hidden = position == SnailCameraVideoFront;
    
}

- (void)switchLightAction {
    self.lightBtn.selected = !self.lightBtn.selected;
    if (self.lightBtn.selected) {
        [self.camera changeLight:SnailCameraLightModeTorch];
    }
    else {
        [self.camera changeLight:SnailCameraLightModeOff];
    }
}

- (void)closeAction {
    
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
    
}

- (NSLock *)lock {
    if (!_lock) _lock = [NSLock new];
    return _lock;
}

- (dispatch_queue_t)snaCameraQueue {
    if (!_snaCameraQueue) {
        _snaCameraQueue = dispatch_get_main_queue(); //dispatch_queue_create("com.snail.camerderfaultui.queue", DISPATCH_QUEUE_SERIAL)
    }
    return _snaCameraQueue;
}

- (UIColor *)faceBorderColor {
    if (!_faceBorderColor) {
        _faceBorderColor = [UIColor blueColor];
    }
    return _faceBorderColor;
}

- (NSMutableDictionary *)faces {
    if (!_faces) _faces = [NSMutableDictionary new];
    return _faces;
}

- (NSMutableDictionary *)lostFaces {
    if (!_lostFaces) _lostFaces = [NSMutableDictionary new];
    return _lostFaces;
}

- (void)dealloc {
    if (self.faceMetaOutput) {
        [self.camera removeOutput:self.faceMetaOutput];
        self.faceMetaOutput = nil;
    }
    [self.camera clear];
}

@end

@implementation SnailCameraDefaultController(FACE)

- (void)handleFace:(AVMetadataFaceObject *)faceObj {
    
    CGRect origionalBounds = faceObj.bounds;
    
    faceObj = (AVMetadataFaceObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:faceObj];
    
    NSInteger faceId = faceObj.faceID;
    NSNumber *key = @(faceId);
    CALayer *layer = self.faces[key];
    if (layer) {
        [self.faces removeObjectForKey:key];
    }
    else {
        layer = [CALayer layer];
        layer.borderWidth = 1.2;
        layer.borderColor = self.faceBorderColor.CGColor;
        [self.previewLayer addSublayer:layer];
    }
    self.lostFaces[key] = layer;
    
    CGRect faceBounds = faceObj.bounds;
    { /*------修正人脸识别框---------*/
        
        if (self.faceFixInsets.left != 0) {
            
            CGFloat fix = self.previewLayer.frame.size.width * self.faceFixInsets.left;
            
            faceBounds.origin.x = faceBounds.origin.x - fix;
            faceBounds.size.width = faceBounds.size.width + fix;
            
        }
        if (self.faceFixInsets.top != 0) {
            
            CGFloat fix = self.previewLayer.frame.size.height * self.faceFixInsets.top;
            
            faceBounds.origin.y = faceBounds.origin.y - fix;
            faceBounds.size.height = faceBounds.size.height + fix;
            
        }
        if (self.faceFixInsets.right != 0) {
            
            CGFloat fix = self.previewLayer.frame.size.width * self.faceFixInsets.right;
            faceBounds.size.width = faceBounds.size.width + fix;
            
        }
        if (self.faceFixInsets.bottom != 0) {
            
            CGFloat fix = self.previewLayer.frame.size.width * self.faceFixInsets.bottom;
            faceBounds.size.height = faceBounds.size.height + fix;
            
        }
    }
    
    layer.frame = faceBounds;
    objc_setAssociatedObject(layer, "SNAIL_CAMERA_FACE_BOUNDS_KEY", [NSValue valueWithCGRect:origionalBounds], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CATransform3D transFrome = CATransform3DIdentity;
    transFrome.m34 = -1 / 100;
    if (faceObj.hasYawAngle) {
        transFrome = CATransform3DConcat(transFrome, CATransform3DMakeRotation(SnailCameraDegressTranToRadians(faceObj.yawAngle), 0, -1, 0));
    }
    if (faceObj.rollAngle) {
        transFrome = CATransform3DConcat(transFrome, CATransform3DMakeRotation(SnailCameraDegressTranToRadians(faceObj.rollAngle),0,0,1));
    }
    layer.transform = transFrome;
    
}

- (void)handleLostFaces {
    for (CALayer *layer in self.faces.allValues) {
        [layer removeFromSuperlayer];
    }
    [self.faces removeAllObjects];
    [self.faces setDictionary:self.lostFaces];
    [self.lostFaces removeAllObjects];
}

@end

@interface SnailCameraDefaultController(PRIVATEDELEGATE)

@end

@implementation SnailCameraDefaultController(PRIVATEDELEGATE)

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    [self.lock lock];
    [metadataObjects enumerateObjectsUsingBlock:^(__kindof AVMetadataObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:AVMetadataFaceObject.class]) {
            [self handleFace:obj];
        }
    }];
    [self handleLostFaces];
    [self.lock unlock];
    
}

@end
