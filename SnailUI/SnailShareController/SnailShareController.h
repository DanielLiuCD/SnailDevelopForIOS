//
//  SnailShareController.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/12/5.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailAlertAnimationController.h"

typedef NS_ENUM(NSInteger,SnailShareControllerScrollerDircetion) { //滚动方向
    SnailShareControllerScrollerDircetionH,
    SnailShareControllerScrollerDircetionV,
};

typedef NS_ENUM(NSInteger,SnailShareControllerStyle) { //显示风格
    SnailShareControllerStyleSheet,
    SnailShareControllerStyleGrid,
};

@interface SnailShareControllerItem : NSObject

@property (nonatomic ,strong) NSString *title;
@property (nonatomic ,strong) UIImage *image;

+ (instancetype):(NSString *)title :(UIImage *)image;

@end

@interface SnailShareControllerSectionData : NSObject

@property (nonatomic) SnailShareControllerScrollerDircetion dircetion;
@property (nonatomic ,strong) NSArray<SnailShareControllerItem *> *items;

+ (instancetype):(SnailShareControllerScrollerDircetion)dircetion :(NSArray<SnailShareControllerItem *> *)items;

@end

@interface SnailShareControllerData : NSObject

@property (nonatomic) SnailShareControllerStyle style;
@property (nonatomic ,strong) NSArray<SnailShareControllerSectionData *> *datas;

+ (instancetype):(SnailShareControllerStyle)style :(NSArray<SnailShareControllerSectionData *> *)datas;

@end

NS_CLASS_AVAILABLE_IOS(9_0) @interface SnailShareController : SnailAlertAnimationController

@property (nonatomic ,strong) void(^didSelectedItemBlock)(SnailShareControllerItem *item);

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithData:(SnailShareControllerData *)data;

@end
