//
//  SnailVCConf.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/15.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailVCConf.h"
#import "Aspects.h"

typedef NS_ENUM(NSInteger ,SnailVCItemActionType) {
    SnailVCItemActionNone,
    SnailVCItemActionName,
    SnailVCItemActionImage,
    SnailVCItemActionView,
};

@interface SnailVCItemAction()

@property (nonatomic) SnailVCItemActionType type;
@property (nonatomic ,strong) NSString *na;
@property (nonatomic ,strong) UIImage *im;
@property (nonatomic ,strong) UIView *vi;

@property (nonatomic ,strong) id target;
@property (nonatomic) SEL selector;

@end

@implementation SnailVCItemAction

+ (instancetype)Name:(NSString *)name SEL:(SEL)selector {
    SnailVCItemAction *model = [SnailVCItemAction new];
    model.type = SnailVCItemActionName;
    model.na = name;
    model.selector = selector;
    return model;
}

+ (instancetype)Name:(NSString *)name SEL:(SEL)selector Target:(id)target{
    SnailVCItemAction *model = [SnailVCItemAction Name:name SEL:selector];
    model.target = target;
    return model;
}

+ (instancetype)Image:(UIImage *)image SEL:(SEL)selector {
    SnailVCItemAction *model = [SnailVCItemAction new];
    model.type = SnailVCItemActionImage;
    model.im = image;
    model.selector = selector;
    return model;
}

+ (instancetype)Image:(UIImage *)image SEL:(SEL)selector Target:(id)target{
    SnailVCItemAction *model = [SnailVCItemAction Image:image SEL:selector];
    model.target = target;
    return model;
}

+ (instancetype)View:(UIView *)view SEL:(SEL)selector {
    SnailVCItemAction *model = [SnailVCItemAction new];
    model.type = SnailVCItemActionView;
    model.vi = view;
    model.selector = selector;
    return model;
}

+ (instancetype)View:(UIView *)view SEL:(SEL)selector Target:(id)target{
    SnailVCItemAction *model = [SnailVCItemAction View:view SEL:selector];
    model.target = target;
    return model;
}

- (UIBarButtonItem *)giveMeBarItem:(UIViewController *)viewController {
    
    UIBarButtonItem *item;
    switch (self.type) {
        case SnailVCItemActionName:
            {
                item = [[UIBarButtonItem alloc] initWithTitle:self.na style:UIBarButtonItemStyleDone target:self.target?:viewController action:self.selector];
            }
            break;
        case SnailVCItemActionImage:
        {
            item = [[UIBarButtonItem alloc] initWithImage:self.im style:UIBarButtonItemStyleDone target:self.target?:viewController action:self.selector];
        }
            break;
        case SnailVCItemActionView:
        {
            item = [[UIBarButtonItem alloc] initWithCustomView:self.vi];
            if (self.selector) {
                UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self.target?:viewController action:self.selector];
                [self.vi addGestureRecognizer:ges];
            }
        }
            break;
        default:
            break;
    }
    return item;
    
}

@end

@implementation UIViewController(SnailVCConf)

- (NSDictionary *)snailVCBaseUI {
    return nil;
}

- (void)snailConfigureUI {
    
}

- (void)snailObjcInitalize {
    
}

- (void)snailBindModelAndView {
    
}

- (void)snailFirstAction {
    
}

- (NSString *)snailIdentifer {
    return [NSString stringWithUTF8String:object_getClassName(self)];
}

- (void)snailBackAction {
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count > 1) [self snailPopVc];
        else {
            [self.navigationController dismissViewControllerAnimated:true completion:^{
                
            }];
        };
    }
    else {
        [self dismissViewControllerAnimated:true completion:^{
            
        }];
    }
}

- (void)snailPushToVc:(UIViewController *)vc {
    vc.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:vc animated:true];
}

- (void)snailPushToVc:(UIViewController *)vc Complete:(void (^)(void))completeBlock {
    [CATransaction begin];
    [CATransaction setCompletionBlock:completeBlock];
    vc.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:vc animated:true];
    [CATransaction commit];
}

- (void)snailPopVc {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)snailPopToRootVc {
    [self.navigationController popToRootViewControllerAnimated:true];
}

- (void)snailPopToVc:(NSString *)identifer {
    
    if (identifer == nil) return;
    
    NSArray *tmp = self.navigationController.viewControllers;
    UIViewController *ta;
    for (UIViewController *vc in tmp) {
        if ([[vc snailIdentifer] isEqualToString:identifer]) {
            ta = vc;
            break;
        }
    }
    [self.navigationController popToViewController:ta animated:true];
    
}

- (void)snailPresentVc:(UIViewController *)vc {
    [self snailPresentVc:vc Complete:nil];
}

- (void)snailPresentVc:(UIViewController *)vc Complete:(void (^)(void))completeBlock {
    [self presentViewController:vc animated:true completion:completeBlock];
}

- (void)snailDissmiss {
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}

@end

@interface SnailVCConf()

@property (nonatomic ,weak) id<SnailVCConfDelegate> delegate;
@property (nonatomic ,strong) id<SnailVCConfProtocol> protocol;
@property (nonatomic ,strong) id<AspectToken> currentToken;

@property (nonatomic ,strong) NSMutableDictionary *cache;

@end

@implementation SnailVCConf

+ (instancetype)shared {
    
    static SnailVCConf *sha;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sha = [SnailVCConf new];
    });
    return sha;
    
}

+ (void)setDelegate:(id<SnailVCConfDelegate>)delegate {
    [SnailVCConf shared].delegate = delegate;
}

+ (void)switchConf:(NSString *)protocolIdentifer {
    id<SnailVCConfDelegate> delegate = [[SnailVCConf shared] delegate];
    [SnailVCConf shared].protocol = [delegate SnailVCConfTakeProtocol:protocolIdentifer];
}

+ (void)enableSnailController {
    
    id<AspectToken> token = [UIViewController aspect_hookSelector:@selector(viewDidLoad) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        [[SnailVCConf shared] snailConfigure_viewDidLoad:info.instance];
    } error:NULL];
    [SnailVCConf shared].currentToken = token;
    
}

+ (void)disableSanilController {
    [[SnailVCConf shared].currentToken remove];
    [SnailVCConf shared].currentToken = nil;
}

- (void)snailConfigure_viewDidLoad:(UIViewController *)viewController {
    
    if ([self canConfigure:viewController]) {
        
        NSLog(@"%@",NSStringFromClass(viewController.class));
        
        [self firstConfiguew:viewController];
        
        BOOL async = false;
        if ([viewController respondsToSelector:@selector(snailAsyncUI)]) {
            async = [viewController snailAsyncUI];
        }
        else if ([self.protocol respondsToSelector:@selector(snailAsyncUI)]) {
            async = [self.protocol snailAsyncUI];
        }
        
        if (async) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self secendConfiguew:viewController];
            });
        }
        else {
            [self secendConfiguew:viewController];
        }
    }
    
}

- (BOOL)canConfigure:(UIViewController *)viewController {
    
    BOOL result = true;
    NSString *className = [NSString stringWithUTF8String:object_getClassName(viewController)];
    @synchronized(self) {
        if (self.cache[className]) {
            result = [self.cache[className] boolValue];
        }
        else  {
            
            static NSSet *defaultBlacklist;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                defaultBlacklist = [NSSet setWithObjects:@"UITabBarController",@"UINavigationController",@"EducationTabBarController",@"CAPSPageMenu",@"UIInputWindowController",@"UIApplicationRotationFollowingControllerNoTouches",@"UIAlertController",@"AVPlayerViewController",@"AVFullScreenPlaybackControlsViewController",@"PUPhotoPickerHostViewController",@"_UIAlertControllerTextFieldViewController",@"UICompatibilityInputViewController",@"SnailCityPickerSelectedController",@"SnailAlertController", nil];
            });
            
            NSSet *targets = nil;
            if ([self.protocol respondsToSelector:@selector(blackLists)]) {
                NSArray *tmps = [self.protocol blackLists];
                if (tmps.count > 0) targets = [NSSet setWithArray:tmps];
            };
            
            result = ![defaultBlacklist containsObject:className];
            if (result && targets) result = ![targets containsObject:className];
            
//            for (NSString *str in targets) {
//                if ([className isEqualToString:str]) {
//                    result = false;
//                    break;
//                }
//            }
            
            self.cache[className] = @(result);
            
        }
    }
    return result;
    
}

- (void)firstConfiguew:(UIViewController *)viewController {
    
    if ([self.protocol respondsToSelector:@selector(SnailViewControLlerDefaultBackground)]) {
        id ta = [self.protocol SnailViewControLlerDefaultBackground];
        if ([ta isKindOfClass:[UIView class]]) viewController.view = (UIView *)ta;
        else if ([ta isKindOfClass:[UIColor class]]) viewController.view.backgroundColor = (UIColor *)ta;
    }
    
    if ([self.protocol respondsToSelector:@selector(SnailViewControllerNavagationBarBackImage)]) {
        UIImage *tmp = [self.protocol SnailViewControllerNavagationBarBackImage];
        if ([tmp isKindOfClass:[UIImage class]]) {
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:tmp style:UIBarButtonItemStyleDone target:viewController action:@selector(snailBackAction)];
            viewController.navigationItem.leftBarButtonItem = item;
            
            viewController.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)viewController;
            
        }
    }
    
    if ([self.protocol respondsToSelector:@selector(SnailViewControLlerNavgationBarBackground)]) {
        
        id tmp = [self.protocol SnailViewControLlerNavgationBarBackground];
        if ([tmp isKindOfClass:[UIImage class]]) {
            [viewController.navigationController.navigationBar setBackgroundImage:tmp forBarMetrics:UIBarMetricsDefault];
        }
        else if ([tmp isKindOfClass:[UIColor class]]) {
            [viewController.navigationController.navigationBar setBarTintColor:tmp];
        }
        
    }
    
    if ([self.protocol respondsToSelector:@selector(SnailViewControllerNavagationBarTranslucent)]) {
        viewController.navigationController.navigationBar.translucent = [self.protocol SnailViewControllerNavagationBarTranslucent];
    }
    
    if ([self.protocol respondsToSelector:@selector(SnailViewControLlerNavagationBarTintColor)]) {
        UIColor *color = [self.protocol SnailViewControLlerNavagationBarTintColor];
        if (color && [color isKindOfClass:[UIColor class]]) {
            [viewController.navigationController.navigationBar setTintColor:color];
        }
    }
    
    if ([self.protocol respondsToSelector:@selector(SnailViewControllerNavagationBarTitleAttribute)]) {
        NSDictionary *dic = [self.protocol SnailViewControllerNavagationBarTitleAttribute];
        if (dic) {
            [viewController.navigationController.navigationBar setTitleTextAttributes:dic];
        }
    }
    
}

- (void)secendConfiguew:(UIViewController *)viewController {
    
    [self baseUIConfigure:viewController];
    [viewController snailConfigureUI];
    [viewController snailObjcInitalize];
    [viewController snailBindModelAndView];
    [viewController snailFirstAction];
    
}

- (void)baseUIConfigure:(UIViewController *)viewController {
    
    NSDictionary *baseInfo = [viewController snailVCBaseUI];
    for (NSString *key in baseInfo) {
        
        if ([key isEqualToString:kSVCNavRight]) viewController.navigationItem.rightBarButtonItems = [self takeItemsFromeValue:baseInfo[key] Controller:viewController];
        else if ([key isEqualToString:kSVCNavLeft]) viewController.navigationItem.leftBarButtonItems = [self takeItemsFromeValue:baseInfo[key] Controller:viewController];
        else if ([key isEqualToString:kSVCBackgroundColor])viewController.view.backgroundColor = baseInfo[key];
        else if ([key isEqualToString:kSVCNavTitle]) viewController.navigationItem.title = baseInfo[key];
        else if ([key isEqualToString:kSVCTitle]) viewController.title = baseInfo[key];
        else if ([key isEqualToString:kSVCTabBarTitle]) viewController.tabBarItem.title = baseInfo[key];
        else if ([key isEqualToString:kSVCNavBackgroundColor]) [viewController.navigationController.navigationBar setBarTintColor:baseInfo[key]];
        else if ([key isEqualToString:kSVCNavTintColor]) [viewController.navigationController.navigationBar setTintColor:baseInfo[key]];
        else if ([key isEqualToString:kSVCNavTitleAttribute]) [viewController.navigationController.navigationBar setTitleTextAttributes:baseInfo[key]];
        else if ([key isEqualToString:kSVCTitleView]) viewController.navigationItem.titleView = baseInfo[key];
        
    }
    
}

- (NSArray<UIBarButtonItem *> *)takeItemsFromeValue:(id)value Controller:(UIViewController *)viewController{
    
    NSArray *tmp;
    if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *ar = [NSMutableArray new];
        for (id va in value) {
            if ([va isKindOfClass:[SnailVCItemAction class]]) {
                UIBarButtonItem *item = [(SnailVCItemAction *)va giveMeBarItem:viewController];
                if (item) [ar addObject:item];
            }
        }
        if (ar.count > 0) tmp = ar;
    }
    else if ([value isKindOfClass:[SnailVCItemAction class]]) {
        UIBarButtonItem *item = [(SnailVCItemAction *)value giveMeBarItem:viewController];
        if (item) tmp = @[item];
    }
    return tmp;
    
}

- (NSMutableDictionary *)cache {
    if (!_cache) {
        _cache = [NSMutableDictionary new];
    }
    return _cache;
}

@end
