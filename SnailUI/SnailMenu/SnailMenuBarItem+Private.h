//
//  SnailMenuBarItem+_SnailMenuBarItem.h
//  SnailMenu
//
//  Created by JobNewMac1 on 2018/10/30.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailMenuBarItem.h"

#ifdef SNAILMENUBARITEM_PROTECTED_ACCESS

@interface SnailMenuBarItem()

@property (nonatomic ,weak ,readonly) UIView *view;
@property (nonatomic ,weak ,readonly) UIView *bar;

- (void)setState:(SnailMenuBarItemState)state;
- (void)setViewController:(UIViewController *)viewController;

- (UIImage *)showImage;
- (NSAttributedString *)showTitle;

- (CGSize)size;
- (CGSize)size:(SnailMenuBarItemState)state;
- (BOOL)isEqualSize;

- (CGSize)badgeSize;
- (NSAttributedString *)showBadge;

@end

@protocol SnailMenuBarItemProtocol<NSObject>

@required
- (void)SnailMenuBarItemUpdateContent:(SnailMenuBarItem *)item;
- (void)SnailMenuBarItemUpdateBadge:(SnailMenuBarItem *)item;

@end

#else
#error Only be included by SnailMenu!
#endif
