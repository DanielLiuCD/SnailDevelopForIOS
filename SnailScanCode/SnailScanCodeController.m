//
//  SnailScanCodeController.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/11/28.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailScanCodeController.h"
@import AVFoundation;

#define SNAIL_SCAN_ERROR_DOMAIN  @"SnailScanCodeErrorDomain"
#define SNAIL_SCAN_ERROR_CODE  -101

#define SNAIL_SCAL_ERROR_MAKER(info) [NSError errorWithDomain:SNAIL_SCAN_ERROR_DOMAIN code:SNAIL_SCAN_ERROR_CODE userInfo:@{NSLocalizedDescriptionKey:info}]

#define SNAIL_SCAN_FOCUS_LENGTH_SCALE .7f

#define SNAIL_IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)

@interface SnailScanCodeController (SNAILUI)

- (void)refeshUI;
- (void)refeshDisplay;
- (void)refeshIndicatorAnimation;
- (void)clearIndicatorAnimation;

- (void)showActivityIndicator;
- (void)hiddenActivityIndicator;

@end

@interface SnailScanCodeController (ALERT)

- (void)haveNoAuthAlert;
- (void)canNotScanQRAlert;
- (void)haveNoDeviceAlert;
- (void)otherErrorAlert:(NSError *)error;

@end

@interface SnailScanCodeController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic) SnailScanCodeType type;
@property (nonatomic) SnailScanCodeType currentType;

@property (nonatomic ,strong) UIView *preView;
@property (nonatomic ,strong) UIView *focusView;
@property (nonatomic ,strong) CAShapeLayer *cornerLayer;
@property (nonatomic ,strong) CAShapeLayer *borderLayer;
@property (nonatomic ,strong) CAShapeLayer *gridLayer;
@property (nonatomic ,strong) UIView *indicatorView;
@property (nonatomic ,strong) NSArray<CALayer *> *maskLayers;
@property (nonatomic ,strong) UIView *containerView;

@property (nonatomic ,strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic ,strong) AVCaptureSession *session;
@property (nonatomic ,strong) AVCaptureDevice *device;
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *capturePreviewLayer;

@property BOOL canReceive;

@property (nonatomic ,copy) void (^configureContainerViewBlock)(UIView *view);

@end

@implementation SnailScanCodeController

- (instancetype)init {
    return [self initWithType:SnailScanCodeTypeDefault];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self sna_init_with_type:SnailScanCodeTypeDefault];
}

- (void)configureContainerView:(void (^)(UIView *))block {
    if (self.containerView) block(self.containerView);
    else self.configureContainerViewBlock = block;
}

- (instancetype)initWithType:(SnailScanCodeType)type {
    self = [super init];
    if (self) {
        [self sna_init_with_type:type];
    }
    return self;
}

- (void)sna_init_with_type:(SnailScanCodeType)type {
    self.type = type;
    self.currentType = type;
    [self _setupInit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self _setupViews];
    [self refeshUI];
    [self refeshDisplay];
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) [self haveNoAuthAlert];
    else {
        [self showActivityIndicator];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _setupAV];
            [self refeshIndicatorAnimation];
            [self hiddenActivityIndicator];
        });
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
- (void)_setupInit {
    self.canReceive = true;
    self.timeInterval = .25;
    _cornerWidth = 3;
    _cornerLength = .15;
    _borderWidth = 1;
    _gridWidth = 1;
    _gridNum = 10;
    _indicatorWidth = 3;
    _indicatorColor = [[UIColor blueColor] colorWithAlphaComponent:.5];
    _indicatorImg = [UIImage imageNamed:@"scanLine"];
    _maskColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    _cornerColor = [UIColor blueColor];
    _borderColor = [[UIColor blueColor] colorWithAlphaComponent:.5];
    _gridColor = [[UIColor blueColor] colorWithAlphaComponent:.3];
}

- (void)_setupViews {
    
    self.preView = [UIView new];
    self.preView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.focusView = [UIView new];
    
    self.cornerLayer = [CAShapeLayer layer];
    self.cornerLayer.fillColor = UIColor.clearColor.CGColor;
    
    self.borderLayer = [CAShapeLayer layer];
    self.borderLayer.fillColor = UIColor.clearColor.CGColor;
    
    self.gridLayer = [CAShapeLayer layer];
    self.gridLayer.fillColor = UIColor.clearColor.CGColor;
    
    self.indicatorView = [UIView new];
    self.indicatorView.layer.contentsScale = UIScreen.mainScreen.nativeScale;
    self.indicatorView.layer.contentsGravity = kCAGravityCenter;
    
    NSMutableArray *tmps = [NSMutableArray new];
    for (int i = 0; i < 4; i++) {
        CALayer *layer = [CALayer layer];
        [tmps addObject:layer];
    }
    self.maskLayers = tmps.copy;
    
    self.containerView = [UIView new];

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.hidesWhenStopped = true;
    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.activityIndicator.center = self.view.center;
    
    [self.view addSubview:self.preView];
    [self.view addSubview:self.activityIndicator];
    [self.preView addSubview:self.focusView];
    [self.focusView.layer addSublayer:self.cornerLayer];
    [self.focusView.layer addSublayer:self.borderLayer];
    [self.focusView.layer addSublayer:self.gridLayer];
    [self.focusView addSubview:self.indicatorView];
    [self.maskLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.preView.layer addSublayer:obj];
    }];
    [self.preView addSubview:self.containerView];
    
}

- (void)_setupAV {
    
    self.session = [AVCaptureSession new];
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    if (error) {
        [self haveNoDeviceAlert];
        return;
    }
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    else {
        [self otherErrorAlert:SNAIL_SCAL_ERROR_MAKER(NSLocalizedString(@"添加输入设备失败", nil))];
        return;
    }
    
    if ([self.device supportsAVCaptureSessionPreset:AVCaptureSessionPreset3840x2160] || [self.device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
        if ([self.session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
        }
    }
    else if ([self.device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1280x720]) {
        if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
        }
    }
    else if ([self.session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    else {
        [self otherErrorAlert:SNAIL_SCAL_ERROR_MAKER(NSLocalizedString(@"相机分辨率设置失败", nil))];
        return;
    }
    
    CGFloat spaceScale = (1 - SNAIL_SCAN_FOCUS_LENGTH_SCALE) * .5;
    
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
    [output setRectOfInterest:CGRectMake(spaceScale,spaceScale,SNAIL_SCAN_FOCUS_LENGTH_SCALE,SNAIL_SCAN_FOCUS_LENGTH_SCALE)];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if ([self.session canAddOutput:output]) [self.session addOutput:output];
    else {
        [self otherErrorAlert:SNAIL_SCAL_ERROR_MAKER(NSLocalizedString(@"添加输出捕获失败", nil))];
        return;
    }
    
    {
        BOOL availableQRCode = false;
        for (id type in output.availableMetadataObjectTypes) {
            NSLog(@"type:%@",type);
            if (type && [type isKindOfClass:[AVMetadataObjectTypeQRCode class]]) {
                if ([[type lowercaseString] rangeOfString:@"qrcode"].location != NSNotFound) {
                    availableQRCode = true;
                    break;
                }
            }
        }
        
        NSArray *qrtypes = @[AVMetadataObjectTypeQRCode];
        NSArray *bctypes = @[
                             AVMetadataObjectTypeEAN13Code,
                             AVMetadataObjectTypeEAN8Code,
                             AVMetadataObjectTypeUPCECode,
                             AVMetadataObjectTypeCode39Code,
                             AVMetadataObjectTypeCode39Mod43Code,
                             AVMetadataObjectTypeCode93Code,
                             AVMetadataObjectTypeCode128Code,
                             AVMetadataObjectTypePDF417Code
                             ];
        
        NSArray *types = nil;
        if (self.currentType == SnailScanCodeTypeQR) {
            if (availableQRCode) types = qrtypes;
            else {
                [self canNotScanQRAlert];
                return;
            }
        }
        else if (self.currentType == SnailScanCodeTypeBC) {
            types = bctypes;
        }
        else if (self.currentType == SnailScanCodeTypeDefault) {
            NSMutableArray *tmps = [NSMutableArray new];
            if (availableQRCode) [tmps addObjectsFromArray:qrtypes];
            [tmps addObjectsFromArray:bctypes];
            types = tmps.copy;
        }
        [output setMetadataObjectTypes:types];
    }
    {
        self.capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        [self.capturePreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        self.capturePreviewLayer.frame = self.view.bounds;
        [self.preView.layer insertSublayer:self.capturePreviewLayer atIndex:0];
    }
    
    [self startRuning];
    
}

- (void)startRuning {
    [self.session startRunning];
}

- (void)stopRuning {
    [self.session stopRunning];
}

#pragma mark -

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *responseObj = metadataObjects[0];
        if (responseObj) {
            if (self.canReceive) {
                self.canReceive = false;
                NSString *strResponse = responseObj.stringValue;
                if (self.successCallback) {
                    BOOL tmp = !self.successCallback(strResponse);
                    if (tmp && self.timeInterval > 0) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.canReceive = tmp;
                        });
                    }
                    else self.canReceive = tmp;
                }
            }
        }
    }
    
}


#pragma mark -

- (void)dealloc {
    [self clearIndicatorAnimation];
    [self stopRuning];
    self.successCallback = nil;
    self.errorCallback = nil;
}

@end

@implementation SnailScanCodeController(SNAILUI)

- (void)refeshUI {
    
    CGFloat width = MIN(self.view.bounds.size.width, self.view.bounds.size.height) * SNAIL_SCAN_FOCUS_LENGTH_SCALE;
    self.focusView.frame = CGRectMake(0, 0, width, width);
    self.focusView.center = self.view.center;
    
    [self.maskLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = CGRectZero;
        if (idx == 0) frame = CGRectMake(0, 0, self.view.bounds.size.width, CGRectGetMinY(self.focusView.frame));
        else if (idx == 1) frame = CGRectMake(0, CGRectGetMinY(self.focusView.frame), CGRectGetMinX(self.focusView.frame), CGRectGetHeight(self.focusView.frame));
        else if (idx == 2) frame = CGRectMake(0, CGRectGetMaxY(self.focusView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.focusView.frame));
        else if (idx == 3) frame = CGRectMake(CGRectGetMaxX(self.focusView.frame), CGRectGetMinY(self.focusView.frame), self.view.bounds.size.width - CGRectGetMaxX(self.focusView.frame), CGRectGetHeight(self.focusView.frame));
#ifdef DEBUG
        NSLog(@"snail scan code idx:%lu frame:%@",(unsigned long)idx,NSStringFromCGRect(frame));
#endif
        obj.frame = frame;
    }];
    
    self.containerView.frame = CGRectMake(0, CGRectGetMaxY(self.focusView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.focusView.frame));
    
    {
        CGFloat fix = self.cornerWidth * .5;
        CGFloat length = width * self.cornerLength;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        [path moveToPoint:CGPointMake(fix, length)];
        [path addLineToPoint:CGPointMake(fix, fix)];
        [path addLineToPoint:CGPointMake(length, fix)];
        
        [path moveToPoint:CGPointMake(width - fix, length)];
        [path addLineToPoint:CGPointMake(width - fix, fix)];
        [path addLineToPoint:CGPointMake(width - length, fix)];
        
        [path moveToPoint:CGPointMake(fix, width - length)];
        [path addLineToPoint:CGPointMake(fix, width - fix)];
        [path addLineToPoint:CGPointMake(length, width - fix)];
        
        [path moveToPoint:CGPointMake(width - fix, width - length)];
        [path addLineToPoint:CGPointMake(width - fix, width - fix)];
        [path addLineToPoint:CGPointMake(width - length, width - fix)];
        
        self.cornerLayer.path = path.CGPath;
    }
    {
        CGFloat fix = self.borderWidth * .5;
        
        CGFloat cornerLength = width * self.cornerLength;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        [path moveToPoint:CGPointMake(cornerLength, fix)];
        [path addLineToPoint:CGPointMake(width - cornerLength, fix)];
        
        [path moveToPoint:CGPointMake(fix, cornerLength)];
        [path addLineToPoint:CGPointMake(fix, width - cornerLength)];
        
        [path moveToPoint:CGPointMake(cornerLength, width - fix)];
        [path addLineToPoint:CGPointMake(width - cornerLength, width - fix)];
        
        [path moveToPoint:CGPointMake(width - fix, cornerLength)];
        [path addLineToPoint:CGPointMake(width - fix, width - cornerLength)];
        
        self.borderLayer.path = path.CGPath;
    }
    {
        CGFloat fix0 = self.cornerWidth;
        CGFloat fix1 = self.borderWidth;
        CGFloat fix = fix0 + fix1;
        
        CGFloat cornerLength = width * self.cornerLength;
        
        CGFloat spaceing = (width - fix * 2) / (self.gridNum + 1);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        for (int i = 0; i < self.gridNum; i++) {
            CGFloat x = spaceing * (i+1) + fix;
            CGFloat y = (x < cornerLength || x > width - cornerLength)?fix0:fix1;
            [path moveToPoint:CGPointMake(x, y)];
            [path addLineToPoint:CGPointMake(x, width - y)];
        }
        for (int i = 0; i < self.gridNum; i++) {
            CGFloat y = spaceing * (i+1) + fix;
            CGFloat x = (y < cornerLength || y > width - cornerLength)?fix0:fix1;
            [path moveToPoint:CGPointMake(x, y)];
            [path addLineToPoint:CGPointMake(width - x, y)];
        }
        
        self.gridLayer.path = path.CGPath;
    }
    
    self.indicatorView.frame = CGRectMake(self.cornerWidth, self.cornerWidth, width - self.cornerWidth * 2, self.indicatorWidth);
    
    if (self.configureContainerViewBlock) {
        self.configureContainerViewBlock(self.containerView);
        self.configureContainerViewBlock = nil;
    }
    
}

- (void)refeshDisplay {
    
    self.borderLayer.strokeColor = self.borderColor.CGColor;
    self.cornerLayer.strokeColor = self.cornerColor.CGColor;
    self.gridLayer.strokeColor = self.gridColor.CGColor;
    
    self.borderLayer.lineWidth = self.borderWidth;
    self.cornerLayer.lineWidth = self.cornerWidth;
    self.gridLayer.lineWidth = self.gridWidth;
    
    [self.maskLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.backgroundColor = self.maskColor.CGColor;
    }];
    
    self.indicatorView.layer.contents = (__bridge id _Nullable)(self.indicatorImg.CGImage);
    if (self.indicatorImg) self.indicatorView.backgroundColor = nil;
    else self.indicatorView.backgroundColor = self.indicatorColor;
    
}

- (void)refeshIndicatorAnimation {
    
    CGFloat width = CGRectGetWidth(self.focusView.frame);
    
    [self.indicatorView.layer removeAllAnimations];
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.translation.y";
    animation.toValue = @(width - self.cornerWidth);
    animation.repeatDuration = INFINITY;
    animation.duration = 1.6;
    animation.autoreverses = YES;
    [self.indicatorView.layer addAnimation:animation forKey:@"snailanimation"];
    
}

- (void)clearIndicatorAnimation {
    [self.indicatorView.layer removeAnimationForKey:@"snailanimation"];
}

- (void)showActivityIndicator {
    self.preView.hidden = true;
    [self.activityIndicator startAnimating];
}

- (void)hiddenActivityIndicator {
    self.preView.hidden = false;
    [self.activityIndicator stopAnimating];
}

@end

@implementation SnailScanCodeController (ALERT)

- (void)haveNoAuthAlert {
    
    NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
    if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
    
    NSString *message = NSLocalizedString(@"请在[设备]的\"设置-[应用]-相机\"选项中，\r允许[应用]访问你的相机。", nil);
    [message stringByReplacingOccurrencesOfString:@"[应用]" withString:appName];
    [message stringByReplacingOccurrencesOfString:@"[设备]" withString:[UIDevice currentDevice].model];
    
    UIAlertController *con = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action0 = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.errorCallback) self.errorCallback(SNAIL_SCAL_ERROR_MAKER(NSLocalizedString(@"缺少相机权限", nil)));
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"去设置", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SNAIL_IOS8_OR_LATER ? UIApplicationOpenSettingsURLString : @"prefs:root"]];
    }];
    [con addAction:action0];
    [con addAction:action1];
    [self presentViewController:con animated:YES completion:nil];
    
}

- (void)haveNoDeviceAlert {
    [self otherErrorAlert:SNAIL_SCAL_ERROR_MAKER(NSLocalizedString(@"该设备缺少摄像头", nil))];
}

- (void)canNotScanQRAlert {
    [self otherErrorAlert:SNAIL_SCAL_ERROR_MAKER(NSLocalizedString(@"该设备不能扫描二维码", nil))];
}

- (void)otherErrorAlert:(NSError *)error {
    
    UIAlertController *con = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.errorCallback) self.errorCallback(error);
    }];
    [con addAction:action];
    [self presentViewController:con animated:true completion:^{
        
    }];
    
}

@end
