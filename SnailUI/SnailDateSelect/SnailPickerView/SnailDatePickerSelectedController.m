//
//  SnailDatePickerSelectedController.m
//  YingKeBao
//
//  Created by 罗大侠 on 2019/1/22.
//  Copyright © 2019年 com.jonnew. All rights reserved.
//

#import "SnailDatePickerSelectedController.h"
#import "SnailDatePickerView.h"

@interface SnailDatePickerSelectedController ()

@property (nonatomic ,strong) UIToolbar *bar;
@property (nonatomic ,strong) UIBarButtonItem *barTitle;
@property (nonatomic ,strong) SnailDatePickerView *picker;

@end

@implementation SnailDatePickerSelectedController

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
    
    self.picker = [SnailDatePickerView new];
    self.picker.backgroundColor = SNA_WHITE_COLOR;
    self.picker.formatorString = self.formatorString;
    
    [self.view snail_addSubviews:@[self.bar,self.picker]];
    
    self.picker.frame = CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width, 200);
    self.bar.frame = CGRectMake(0, CGRectGetMinY(self.picker.frame) - 45, self.view.bounds.size.width, 45);
    
    self.picker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
}

- (void)snailFirstAction {
    
    if (self.title) self.barTitle.title = self.title;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.date) [self.picker setDate:self.date];
        if (self.minDate) [self.picker setMinDate:self.minDate];
        if (self.maxDate) [self.picker setMaxDate:self.maxDate];
    });
    
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
