//
//  SnailSimpleTextInputController.m
//  lesan
//
//  Created by JobNewMac1 on 2018/7/26.
//  Copyright © 2018年 ning. All rights reserved.
//

#import "SnailSimpleTextInputController.h"
#import "SnailFadePresentationController.h"

@interface SnailSimpleTextInputAnimate : NSObject<UIViewControllerAnimatedTransitioning>

kSPr(BOOL isShow)

@end

@implementation SnailSimpleTextInputAnimate

- (instancetype)initWithShow:(BOOL)show {
    self = [super init];
    if (self) self.isShow = show;
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    if (self.isShow) [self showAnimated:transitionContext];
    else [self hiddenAnimated:transitionContext];
    
}

- (void)showAnimated:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *container = [transitionContext containerView];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.frame = CGRectMake(0, 0, container.bounds.size.width, container.bounds.size.height);
    [container addSubview:toView];
    [transitionContext completeTransition:true];
    
}

- (void)hiddenAnimated:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *fromeView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [fromeView removeFromSuperview];
    [transitionContext completeTransition:true];
    
}

@end

@interface SnailSimpleTextInputController ()<UIViewControllerTransitioningDelegate,SnailTextViewDelegate,UITextViewDelegate>

kSPrStrong(NSString *inputed)
kSPrStrong(NSString *placeHolder)
kSPrStrong(void(^doneBlock)(NSString *text))

kSPrStrong(UIView *back)
kSPrStrong(UIView *tvBack)
kSPrStrong(SnailTextView *tv)

@end

@implementation SnailSimpleTextInputController

+ (void)showFromeVc:(UIViewController *)vc Text:(NSString *)texted PlaceHolder:(NSString *)holder Block:(void(^)(NSString *text))block {
    
    SnailSimpleTextInputController *tvc = [SnailSimpleTextInputController new];
    tvc.doneBlock = block;
    tvc.inputed = texted.copy;
    tvc.placeHolder = holder.copy;
    [vc presentViewController:tvc animated:true completion:^{
        
    }];
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tv becomeFirstResponder];
}

#pragma mark -

- (NSDictionary *)snailVCBaseUI {
    return @{kSVCBackgroundColor:SNA_CLEAR_COLOR};
}

- (void)snailConfigureUI {
    
    self.back = [UIView new];
    self.back.backgroundColor = SNA_WHITE_COLOR;
    
    self.tv = [SnailTextView new];
    self.tv.backgroundColor = SNA_CLEAR_COLOR;
    self.tv.placeHolder = self.placeHolder;
    self.tv.font = SNAS_SYS_FONT(17);
    self.tv.bounces = false;
    self.tv.showsVerticalScrollIndicator = false;
    
    self.tv.delegate = self;
    self.tv.sadelegate = self;
    self.tv.returnKeyType = UIReturnKeyDone;
    self.tv.text = self.inputed;
    
    CGFloat tvH = self.tv.font.lineHeight + 8 * 2;
    
    self.tvBack = [UIView new];
    self.tvBack.backgroundColor = SNA_CLEAR_COLOR;
    self.tvBack.snail_border(1,SNA_RGBA_COLOR(225, 225, 225, 1));
    self.tvBack.snail_corner(5);
    
    [self.tvBack addSubview:self.tv];
    [self.back addSubview:self.tvBack];
    [self.view addSubview:self.back];
    
    [self.tvBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.back);
        make.leading.equalTo(self.back).offset(15);
        make.top.equalTo(self.back).offset(10);
    }];
    [self.tv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.top.equalTo(self.tvBack);
        make.leading.equalTo(self.tvBack).offset(7);
        make.height.equalTo(@(tvH));
    }];
    [self.back mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.leading.bottom.equalTo(self.view);
    }];

}

- (void)snailFirstAction {
    if (self.inputed.length > 0) {
        [self refeshTVUI:self.inputed];
    }
    [self.view layoutIfNeeded];
}

#pragma mark -

- (void)refeshTVUI:(NSString *)text {
    UIFont *font = self.tv.font;
    CGFloat height = [text snail_calculate_height:CGSizeMake(self.view.bounds.size.width - 30 - 30, CGFLOAT_MAX) attributes:@{NSFontAttributeName:font}];
    height += self.tv.placeTopSpaceing * 2;
    if (height < 30) height = 30;
    else if (height > 250) height = 250;
    if (height != self.tv.frame.size.height) {
        [self.tv mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
}

#pragma mark -

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        if (self.doneBlock) self.doneBlock(self.tv.text);
        SNA_END_EDIT;
        return NO;
    }
    return YES;
    
}

#pragma mark -

- (void)SnailTextViewTextChange:(NSString *)text {
    [self refeshTVUI:text];
}

#pragma mark -

- (void)keyboardWillShow:(NSNotification *)aNotification {
    
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    
    [self.back mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-height);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    
    [self.back mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(0);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:true completion:^{
            if (self.doneBlock) self.doneBlock = nil;
        }];
    }];
    
}

#pragma mark -

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[SnailSimpleTextInputAnimate alloc] initWithShow:true];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
   return [[SnailSimpleTextInputAnimate alloc] initWithShow:false];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[SnailFadePresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end
