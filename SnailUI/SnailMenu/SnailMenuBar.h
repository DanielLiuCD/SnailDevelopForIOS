//
//  SnailMenuBar.h
//  SnailMenu
//
//  Created by JobNewMac1 on 2018/10/24.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SnailMenuBarItem;
@class SnailMenuBar;

typedef NS_ENUM(char ,SnailMenuBarItemStrategy) {
    ///均分
    SnailMenuBarItemStrategyDefault,
    ///适应内容大小
    SnailMenuBarItemStrategyFit,
    //所有宽度一样,以能包裹最大内容为准
    SnailMenuBarItemStrategyMax NS_ENUM_DEPRECATED_IOS(2_0, 2_0, "性能较差,不推荐使用"),
};

typedef NS_ENUM(char ,SnailMenuBarIndicatorStrategy) {
    ///跟随item宽度
    SnailMenuBarIndicatorStrategyDefault,
    ///固定宽度
    SnailMenuBarIndicatorStrategyStatic,
};

typedef struct {
    CGFloat leading;
    CGFloat trailing;
} SnailMenuBarPadding;

CG_INLINE SnailMenuBarPadding
SnailMenuBarPaddingMake(CGFloat leading,CGFloat trailing) {
    SnailMenuBarPadding padding;
    padding.leading = leading;padding.trailing = trailing;
    return padding;
}

@protocol SnailMenuBarDelegate<NSObject>

@optional
- (void)menuBar:(SnailMenuBar *)tabBar didSelectItem:(SnailMenuBarItem *)item;
- (void)menuBarShouldUpdateHeight;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SnailMenuBar : UIView

@property (nullable ,nonatomic ,weak) id<SnailMenuBarDelegate> delegate;
@property (nullable ,nonatomic ,copy) NSArray<SnailMenuBarItem *> *items;
@property (nonatomic) SnailMenuBarItemStrategy itemStrategy; // default is SnailMenuBarItemStrategyDefault
@property (nonatomic) NSInteger itemOnePageCount; //default is 5, only for SnailMenuBarItemStrategyDefault

- (void)setItems:(NSArray<__kindof SnailMenuBarItem *> * _Nullable)items animated:(BOOL)animated NS_REQUIRES_SUPER;

@property (nonatomic ,getter=isTranslucent) BOOL translucent UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIBarStyle barStyle UI_APPEARANCE_SELECTOR;

@property (nonatomic) BOOL bounces;
@property (nonatomic) SnailMenuBarPadding padding UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGFloat spaceing UI_APPEARANCE_SELECTOR; //default is 0.0

@property (nullable, nonatomic, copy) UIImage *backgroundImage;

@property (nullable ,nonatomic ,copy) UIColor *indicatorColor UI_APPEARANCE_SELECTOR; //defalut is blue
@property (nonatomic) CGFloat indicatorHeight UI_APPEARANCE_SELECTOR;  //defalut is 2.5
@property (nonatomic) CGFloat indicatorStaticWidth UI_APPEARANCE_SELECTOR;  //defalut is 30, only for SnailMenuBarIndicatorStrategyStatic
@property (nonatomic) BOOL showIndicator;       //defalut is true
@property (nonatomic) BOOL indicatorAnimation UI_APPEARANCE_SELECTOR;  //defalut is true
@property (nonatomic) SnailMenuBarIndicatorStrategy indictorStrategy;

@property (nullable ,nonatomic ,strong) UIColor *bottomLineColor UI_APPEARANCE_SELECTOR; //defalut is black
@property (nonatomic) CGFloat bottomLineHeight UI_APPEARANCE_SELECTOR; //defalut is .8f

- (void)selectedAtIndex:(NSInteger)index animated:(BOOL)animated NS_REQUIRES_SUPER;
- (void)selectedAtIndex:(NSInteger)index animated:(BOOL)animated CallBack:(BOOL)callBack NS_REQUIRES_SUPER;

- (NSInteger)selectedIndex;

@end

NS_ASSUME_NONNULL_END
