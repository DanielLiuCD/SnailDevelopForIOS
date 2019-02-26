//
//  SnailAlertContainerView.h
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2019/1/4.
//  Copyright © 2019年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SnailAlertAction;

@interface SnailAlertContainerView : UIView

@property (nonatomic ,copy) void(^afterRefeshBlock)(void);
@property (nonatomic ,copy) void(^actionBlock)(SnailAlertAction *action);
@property (nonatomic ,strong) UIColor *sepertorColor;

- (void)refeshTitle:(NSString *)title Attribute:(NSDictionary *)titleAttribute
            Message:(NSString *)message MessageAttribue:(NSDictionary *)messageAttribute;

- (void)appendCustomeViews:(UIView *)customeView;
- (void)refeshWithActions:(NSArray<SnailAlertAction *> *)actions;

@end
