//
//  SnailVCConf.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/15.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SnailVCConfProtocol<NSObject>

///可以返回view或color
- (id)SnailViewControLlerDefaultBackground;

///可以返回uiimage或color
- (id)SnailViewControLlerNavgationBarBackground;

- (BOOL)SnailViewControllerNavagationBarTranslucent;

- (UIColor *)SnailViewControLlerNavagationBarTintColor;

- (NSDictionary *)SnailViewControllerNavagationBarTitleAttribute;

- (UIImage *)SnailViewControllerNavagationBarBackImage;

@optional
///黑名单
- (NSArray<NSString *> *)blackLists;

- (BOOL)snailAsyncUI;

@end

#define  kSVCNavTitle               @"kSVCNavTitle"
#define  kSVCTitle                  @"kSVCTitle"
#define  kSVCTitleView              @"kSVCTitleView"
#define  kSVCTabBarTitle            @"kSVCTabBarTitle"
#define  kSVCBackgroundColor        @"kSVCBackgroundColor"
#define  kSVCNavLeft                @"kSVCNavLeft"
#define  kSVCNavRight               @"kSVCNavRight"
#define  kSVCNavBackgroundColor     @"kSVCNavBackgroundColor"
#define  kSVCNavTintColor           @"kSVCNavTintColor"
#define  kSVCNavTitleAttribute      @"kSVCNavTitleAttribute"

@interface SnailVCItemAction : NSObject

+ (instancetype)Name:(NSString *)name SEL:(SEL)selector;
+ (instancetype)Name:(NSString *)name SEL:(SEL)selector Target:(id)target;

+ (instancetype)Image:(UIImage *)image SEL:(SEL)selector;
+ (instancetype)Image:(UIImage *)image SEL:(SEL)selector Target:(id)target;

+ (instancetype)View:(UIView *)view SEL:(SEL)selector;
+ (instancetype)View:(UIView *)view SEL:(SEL)selector Target:(id)target;

@end

@interface UIViewController(SnailVCConf)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"

- (BOOL)snailAsyncUI; //default false

#pragma clang diagnostic pop

- (NSDictionary *)snailVCBaseUI;

- (void)snailConfigureUI;

- (void)snailObjcInitalize;

- (void)snailBindModelAndView; //for mvvm bind model-view

- (void)snailFirstAction;

- (NSString *)snailIdentifer;

- (void)snailBackAction;

- (void)snailPushToVc:(UIViewController *)vc;

- (void)snailPushToVc:(UIViewController *)vc Complete:(void(^)(void))completeBlock;

- (void)snailPopVc;

- (void)snailPopToRootVc;

- (void)snailPopToVc:(NSString *)identifer;

- (void)snailPresentVc:(UIViewController *)vc;

- (void)snailPresentVc:(UIViewController *)vc Complete:(void(^)(void))completeBlock;

- (void)snailDissmiss;

@end

@protocol SnailVCConfDelegate<NSObject>

- (id<SnailVCConfProtocol>)SnailVCConfTakeProtocol:(NSString *)identifer;

@end

@interface SnailVCConf : NSObject

+ (void)setDelegate:(id<SnailVCConfDelegate>)delegate;

+ (void)switchConf:(NSString *)protocolIdentifer;

+ (void)enableSnailController;

+ (void)disableSanilController;

@end
