//
//  SnailPopupController.h
//  QianXun
//
//  Created by JobNewMac1 on 2018/12/3.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSString * SNAIL_POPUPCONTROLLER_KEY NS_STRING_ENUM;

FOUNDATION_EXPORT SNAIL_POPUPCONTROLLER_KEY const SnailPopupControllerImage;
FOUNDATION_EXPORT SNAIL_POPUPCONTROLLER_KEY const SnailPopupControllerText;
FOUNDATION_EXPORT SNAIL_POPUPCONTROLLER_KEY const SnailPopupControllerDetail;
FOUNDATION_EXPORT SNAIL_POPUPCONTROLLER_KEY const SnailPopupControllerTextAttribute;
FOUNDATION_EXPORT SNAIL_POPUPCONTROLLER_KEY const SnailPopupControllerDetailAttribute;

NS_CLASS_AVAILABLE_IOS(8_0) @interface SnailPopupController : UIViewController

@property (nonatomic) BOOL blur;
@property (nonatomic ,strong) UIColor *backgroundColor;
@property (nonatomic) BOOL backgroundClose;

+ (instancetype)Point:(CGPoint)origin Size:(CGSize)size List:(NSArray<NSDictionary<SNAIL_POPUPCONTROLLER_KEY,id> *> *)datas Block:(void(^)(NSDictionary<SNAIL_POPUPCONTROLLER_KEY,id> *item))block;

+ (instancetype)Point:(CGPoint)origin Size:(CGSize)size Controller:(UIViewController *)controller;

@end
