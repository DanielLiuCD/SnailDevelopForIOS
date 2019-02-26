//
//  SnailSimpleFiledController.h
//  QianXun
//
//  Created by JobNewMac1 on 2018/12/4.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailSimpleFiledController : UIViewController

@property (nonatomic ,strong) UIFont *font;
@property (nonatomic ,strong) UIColor *textColor;
@property (nonatomic ,strong) NSString *placeHolder;
@property (nonatomic ,strong) UIColor *placeHolderColor;
@property (nonatomic ,strong) NSString *text;

@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) UIReturnKeyType returnKeyType;

@property (nonatomic ,copy) void(^block)(NSString *text);

@end
