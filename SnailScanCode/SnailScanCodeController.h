//
//  SnailScanCodeController.h
//  QianXun
//
//  Created by JobNewMac1 on 2018/11/28.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,SnailScanCodeType) {
    SnailScanCodeTypeDefault,
    SnailScanCodeTypeQR, //二维码
    SnailScanCodeTypeBC, //条形码
};

@interface SnailScanCodeController : UIViewController

@property (nonatomic) CGFloat cornerWidth;
@property (nonatomic) CGFloat cornerLength; // 0 - 1

@property (nonatomic) CGFloat borderWidth;

@property (nonatomic) CGFloat gridWidth;
@property (nonatomic) unsigned int gridNum;

@property (nonatomic) CGFloat indicatorWidth;

@property (nonatomic ,strong) UIColor *indicatorColor;
@property (nonatomic ,strong) UIImage *indicatorImg;

@property (nonatomic ,strong) UIColor *maskColor;

@property (nonatomic ,strong) UIColor *cornerColor;
@property (nonatomic ,strong) UIColor *borderColor;
@property (nonatomic ,strong) UIColor *gridColor;

@property NSTimeInterval timeInterval; //扫描时间间隔

@property (nonatomic ,copy) BOOL (^successCallback)(NSString *result);
@property (nonatomic ,copy) void (^errorCallback)(NSError *error);

- (instancetype)initWithType:(SnailScanCodeType)type;

- (void)configureContainerView:(void(^)(UIView *containerView))block;

@end
