//
//  SnailSimpleSearchBox.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/25.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailSimpleSearchBox : UIView

@property (nonatomic ,strong ,readonly) UITextField *filed;

@property (nonatomic) UIEdgeInsets insert;

+ (instancetype)PlaceHolder:(NSString *)placeHolder LeftImage:(UIImage *)leftIcon RightImage:(UIImage *)rightIcon;

@end
