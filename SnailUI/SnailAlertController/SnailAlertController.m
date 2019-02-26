//
//  SnailAlertController.m
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2019/1/4.
//  Copyright © 2019年 com.jonnew. All rights reserved.
//

#import "SnailAlertController.h"
#import "_SnailAlertContainerView.h"

@interface SnailAlertController ()

@property (nonatomic ,strong) SnailAlertContainerView *container;
@property (nonatomic) UIAlertControllerStyle style;
@property (nonatomic ,copy) NSString *alertTitle;
@property (nonatomic ,copy) NSString *alertMessage;

@property (nonatomic ,strong) NSMutableArray<SnailAlertAction *> *actions;
@property (nonatomic ,strong) NSMutableArray<UIView *> *customeViews;

@end

@implementation SnailAlertController

@dynamic sepertorColor;

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle {
    
    SnailAlertAnimationType type = SnailAlertAnimation_Fade;
    switch (preferredStyle) {
        case UIAlertControllerStyleActionSheet:
            type = SnailAlertAnimation_FromeBottom;
            break;
        case UIAlertControllerStyleAlert:
            type = SnailAlertAnimation_Fade;
            break;
    }
    
    SnailAlertController *vc = [SnailAlertController new];
    vc.type = type;
    vc.style = preferredStyle;
    vc.alertTitle = title;
    vc.alertMessage = message;
    [vc.container refeshTitle:vc.alertTitle Attribute:vc.titleAttributes Message:vc.alertMessage MessageAttribue:vc.messageAttributes];
    return vc;
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.titleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont buttonFontSize]],NSForegroundColorAttributeName:[UIColor blackColor]};
        
        self.messageAttributes = @{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleCallout],NSForegroundColorAttributeName:[UIColor blackColor]};
        
        __weak typeof(self) self_weak_ = self;
        self.offsetBlock = ^CGFloat{
            return self_weak_.container.frame.size.height;
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.container];
}

- (BOOL)shouldAutorotate {
    return false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addCustomeViews:(UIView *)customeView {
    [self.customeViews addObject:customeView];
    [self.container appendCustomeViews:customeView];
}

- (void)addAction:(SnailAlertAction *)action {
    [self.actions addObject:action];
}

- (void)addActions:(NSArray<SnailAlertAction *> *)actions {
    [self.actions addObjectsFromArray:actions];
    [self.container refeshWithActions:self.actions];
}

- (NSMutableArray<SnailAlertAction *> *)actions {
    if (!_actions) _actions = [NSMutableArray new];
    return _actions;
}

- (NSMutableArray<UIView *> *)customeViews {
    if (!_customeViews) _customeViews = [NSMutableArray new];
    return _customeViews;
}

- (SnailAlertContainerView *)container {
    if (!_container) {
        
        CGFloat scrwidth = MIN(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
        CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
        
        __weak typeof(self) self_weak_ = self;
        CGFloat width = scrwidth * .7;
        if (self.style == UIAlertControllerStyleActionSheet) {
            width = scrwidth * .85;
        }
        
        
        _container = [[SnailAlertContainerView alloc] initWithFrame:CGRectMake((scrwidth - width) * .5, 0, width, 0)];
        _container.actionBlock = ^(SnailAlertAction *action) {
            [self_weak_ dismissViewControllerAnimated:true completion:^{
                if (action.block) action.block();
            }];
        };
        __weak typeof(_container) _container_weak_ = _container;
        _container.afterRefeshBlock = ^{
            CGRect frame = self_weak_.container.frame;
            switch (self_weak_.style) {
                case UIAlertControllerStyleAlert:
                {
                    frame.origin.x = (UIScreen.mainScreen.bounds.size.width - frame.size.width) * .5;
                    frame.origin.y = (screenHeight - frame.size.height) * .5;
                }
                    break;
                case UIAlertControllerStyleActionSheet:
                {
                    frame.origin.x = (UIScreen.mainScreen.bounds.size.width - frame.size.width) * .5;
                    frame.origin.y = screenHeight - frame.size.height - 10;
                }
                    break;
            }
            _container_weak_.frame = frame;
        };
    }
    return _container;
}

- (void)setTitleAttributes:(NSDictionary *)titleAttributes {
    _titleAttributes = titleAttributes;
    [self.container refeshTitle:self.alertTitle Attribute:titleAttributes Message:self.alertMessage MessageAttribue:self.messageAttributes];
}

- (void)setMessageAttributes:(NSDictionary *)messageAttributes {
    _messageAttributes = messageAttributes;
    [self.container refeshTitle:self.alertTitle Attribute:self.titleAttributes Message:self.alertMessage MessageAttribue:messageAttributes];
}

- (void)setSepertorColor:(UIColor *)sepertorColor {
    self.container.sepertorColor = sepertorColor;
}

- (UIColor *)sepertorColor {
    return self.container.sepertorColor;
}

@end
