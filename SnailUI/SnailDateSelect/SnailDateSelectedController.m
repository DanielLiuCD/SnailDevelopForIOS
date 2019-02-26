//
//  SnailDateSelectedController.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/2.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailDateSelectedController.h"
#import "SnailFadePresentationController.h"

@interface SnailDateSelectedController ()

@property (nonatomic ,strong) UIToolbar *bar;
@property (nonatomic ,strong) UIBarButtonItem *barTitle;
@property (nonatomic ,strong) UIDatePicker *picker;

@end

@implementation SnailDateSelectedController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = SnailAlertAnimation_FromeBottom;
        self.offsetBlock = ^CGFloat{
            return 245;
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSDictionary *)snailVCBaseUI {
    return @{kSVCBackgroundColor:SNA_CLEAR_COLOR};
}

- (void)snailConfigureUI {
    
    UIBarButtonItem *cancle = [[UIBarButtonItem alloc] initWithTitle:SNASLS(取消) style:UIBarButtonItemStyleDone target:self action:@selector(cancleAction)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:SNASLS(确定) style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)];
    UIBarButtonItem *fiexib0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *fiexib1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    self.barTitle = [UIBarButtonItem new];

    self.bar = [UIToolbar new];
    self.bar.items = @[cancle,fiexib0,self.barTitle,fiexib1,done];
    
    self.picker = [UIDatePicker new];
    self.picker.datePickerMode = self.dateMode;
    self.picker.backgroundColor = SNA_WHITE_COLOR;
    if (self.locale) self.picker.locale = self.locale;
    if (self.minDate) self.picker.minimumDate = self.minDate;
    if (self.maxDate) self.picker.maximumDate = self.maxDate;
    
    [self.view snail_addSubviews:@[self.bar,self.picker]];

    self.picker.frame = CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width, 200);
    self.bar.frame = CGRectMake(0, CGRectGetMinY(self.picker.frame) - 45, self.view.bounds.size.width, 45);
    
    self.picker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
}

- (void)snailFirstAction {

    if (self.title) self.barTitle.title = self.title;
    if (self.date) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.picker setDate:self.date animated:true];
        });
    }
    
}

- (void)cancleAction {
    [self dismissViewControllerAnimated:true completion:^{
        if (self.block) self.block = nil;
    }];
}

- (void)doneAction {
    [self dismissViewControllerAnimated:true completion:^{
        if (self.block) {
            self.block(self.picker.date);
            self.block = nil;
        }
    }];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.barTitle.title = title;
}

@end
