//
//  SnailSimpleInputItem.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/22.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SnailSimpleInputItem;

@interface SnailSimpleInputItemConfigure : NSObject

@property (nonatomic ,strong) UIFont *titleFont;
@property (nonatomic ,strong) UIFont *filedFont;
@property (nonatomic ,strong) UIColor *titleColor;
@property (nonatomic ,strong) UIColor *filedColor;

@property (nonatomic) NSTextAlignment filedTextAlignment;

@property (nonatomic ,strong) UIColor *backgroundColor;
@property (nonatomic ,strong) UIColor *bottomLineColor;

@property (nonatomic ,copy) NSString *title;
@property (nonatomic ,copy) NSString *text;
@property (nonatomic ,copy) NSString *placeHolder;
@property (nonatomic ,copy) UIImage *rightImage;

@property (nonatomic) CGFloat titleWidth;
@property (nonatomic) CGFloat titleLeading;
@property (nonatomic) CGFloat rightTrailing;

@property (nonatomic) BOOL showTitle;
@property (nonatomic) BOOL showInputFiled;
@property (nonatomic) BOOL showRightImage;
@property (nonatomic) BOOL showBottomLine;

@property (nonatomic) BOOL canInput;

@property (nonatomic ,copy) void(^otherUIBlock)(SnailSimpleInputItem *objc,NSInteger tag);

@property (nonatomic ,copy) void(^clickBlock)(SnailSimpleInputItem *objc);
@property (nonatomic ,copy) void(^rightViewActionBlock)(SnailSimpleInputItem *objc);

@end


@interface SnailSimpleInputItem : UIView

@property (nonatomic ,strong ,readonly) UITextField *filed;
@property (nonatomic ,strong, readonly) UILabel *titleLbl;

@property (nonatomic ,strong) NSString *title;
@property (nonatomic ,strong) NSString *text;
@property (nonatomic ,strong) NSString *placeHolder;
@property (nonatomic ,strong) UIImage *rightImage;

@property (nonatomic) CGFloat titleWidth;
@property (nonatomic) CGFloat titleLeading;
@property (nonatomic) CGFloat rightTrailing;

@property (nonatomic) BOOL showTitle;
@property (nonatomic) BOOL showInputFiled;
@property (nonatomic) BOOL showRightImage;
@property (nonatomic) BOOL showBottomLine;

@property (nonatomic) BOOL canInput;

@property (nonatomic ,strong) void(^clickBlock)(SnailSimpleInputItem *objc);
@property (nonatomic ,strong) void(^rightViewActionBlock)(SnailSimpleInputItem *objc);

+ (instancetype)createWithConfigure:(SnailSimpleInputItemConfigure *)configure;

+ (instancetype)createWithConfigure:(SnailSimpleInputItemConfigure *)configure Tag:(NSInteger)tag;

@end
