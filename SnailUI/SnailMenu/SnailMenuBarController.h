//
//  SnailMenuBarController.h
//  SnailMenu
//
//  Created by JobNewMac1 on 2018/10/24.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnailMenuBarItem.h"
#import "SnailMenuBar.h"

@protocol SnailMenuBarControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SnailMenuBarController : UIViewController<SnailMenuBarDelegate>

@property (nullable, nonatomic ,copy) NSArray<__kindof UIViewController *> *viewControllers;
@property (nonnull ,nonatomic ,readonly) SnailMenuBar *menuBar;
@property (nonatomic) NSUInteger selectedIndex;
@property (nullable ,nonatomic ,readonly ,assign) __kindof UIViewController *selecterViewController;

@property (nullable ,nonatomic ,strong ,readonly) UIView *menuBarHeader;
@property (nullable ,nonatomic ,strong ,readonly) UIView *menuBarFooter;

@property (nullable ,nonatomic ,weak) id<SnailMenuBarControllerDelegate> delegate;

@property (nonatomic) BOOL hiddenMenuBar;

@end

@protocol SnailMenuBarControllerDelegate<NSObject>

@optional
- (void)snailMenuBarController:(SnailMenuBarController *)menuBarController didSelectedViewController:(__kindof UIViewController *)viewController;

@end

@interface UIViewController(SnailMenuBarControllerItem)

@property (null_resettable ,nonatomic ,strong) SnailMenuBarItem *menuBarItem;
@property (null_resettable ,nonatomic ,readonly ,weak) SnailMenuBarController *menuBarController;

@end

NS_ASSUME_NONNULL_END
