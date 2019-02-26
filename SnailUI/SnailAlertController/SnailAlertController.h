//
//  SnailAlertController.h
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2019/1/4.
//  Copyright © 2019年 com.jonnew. All rights reserved.
//

#import "SnailAlertAnimationController.h"
#import "SnailAlertAction.h"

@interface SnailAlertController : SnailAlertAnimationController

@property (nonatomic ,copy) NSDictionary *titleAttributes;
@property (nonatomic ,copy) NSDictionary *messageAttributes;
@property (nonatomic ,strong) UIColor *sepertorColor;

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle;

- (void)addCustomeViews:(UIView *)customeView;
- (void)addAction:(SnailAlertAction *)action;
- (void)addActions:(NSArray<SnailAlertAction *> *)actions;

@end
