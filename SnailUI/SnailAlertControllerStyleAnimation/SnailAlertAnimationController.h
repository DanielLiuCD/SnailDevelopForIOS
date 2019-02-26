//
//  SnailAlertAnimationController.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SnailAlertAnimationType) {
    SnailAlertAnimation_Fade,
    SnailAlertAnimation_FromeBottom,
};

@interface SnailAlertAnimationController : UIViewController

@property (nonatomic ,copy) CGFloat(^offsetBlock)(void);//获取动画移动的距离
@property (nonatomic) SnailAlertAnimationType type;

@end
