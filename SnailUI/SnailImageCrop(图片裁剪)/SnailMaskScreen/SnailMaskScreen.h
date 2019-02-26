//
//  SnailMaskScreen.h
//  QianXun
//
//  Created by JobNewMac1 on 2018/11/7.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_CLASS_AVAILABLE_IOS(8_0) @interface SnailMaskScreen : UIView

@property (nonatomic) BOOL translucent; //default is false
@property (nonatomic) UIEdgeInsets marignInsets;
@property (nonatomic) BOOL dragInnerView;
@property (nullable ,nonatomic ,strong ,readonly) UIView *innerView;

- (void)replaceInnerView:(nullable UIView *)innerView;
- (void)updateInnerViewFrame:(CGRect)frame;
- (void)updateInnerViewCenter:(CGPoint)center;
- (void)refesh;

@end
