//
//  SnailMenuBarItem.h
//  SnailMenu
//
//  Created by JobNewMac1 on 2018/10/24.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(char,SnailMenuBarItemState) {
    SnailMenuBarItemStateNormal,
    SnailMenuBarItemStateSelected,
};

NS_ASSUME_NONNULL_BEGIN

@interface SnailMenuBarItem : NSObject

@property (null_resettable ,nonatomic ,copy) NSString *title;
@property (null_resettable ,nonatomic ,copy) NSString *selectedTitle;

@property (nullable ,nonatomic ,copy) UIImage *image;
@property (nullable ,nonatomic ,copy) UIImage *selectedImage;

@property CGAffineTransform affineTransform; //default is CGAffineTransformIdentity
@property CGAffineTransform selectedAffineTransform; //default is CGAffineTransformIdentity

@property (nonatomic ,readonly) CGFloat spaceing; //default 8.0

@property (nullable, nonatomic, copy) NSString *badgeValue;

@property (nonatomic, copy) UIColor *tintColor; //default is blue

@property (nonatomic ,readonly) SnailMenuBarItemState state;
@property (nonatomic ,weak ,readonly) UIViewController *viewController;

- (instancetype)initWithTitle:(nullable NSString *)title Image:(nullable UIImage *)image;

- (instancetype)initWithTitle:(nullable NSString *)title Image:(nullable UIImage *)image SelectedTitle:(nullable NSString *)selectedTitle SelectedImage:(nullable UIImage *)selectedImage NS_DESIGNATED_INITIALIZER;

- (void)setTitleTextAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)attributes forState:(SnailMenuBarItemState)state;

- (nonnull NSDictionary<NSString *,id> *)titleTextAttributesForState:(SnailMenuBarItemState)state;

- (void)setBadgeTextAttributes:(nullable NSDictionary<NSString *,id> *)badgeAttributes forState:(SnailMenuBarItemState)state;

/// Returns attributes previously set via -setBadgeTextAttributes:forState:.
- (nullable NSDictionary<NSString *,id> *)badgeTextAttributesForState:(SnailMenuBarItemState)state;

@end

NS_ASSUME_NONNULL_END


