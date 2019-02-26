//
//  SnailCityPickerSelectedController.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/9/18.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailCityPickerSelectedController.h"
#import "SnailCityPickerView.h"

@interface SnailCityPickerSelectedController ()

@property (nonatomic ,strong) UIToolbar *bar;
@property (nonatomic ,strong) UIBarButtonItem *barTitle;
@property (nonatomic ,strong) SnailCityPickerView *picker;

@end

@implementation SnailCityPickerSelectedController

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
    
    UIBarButtonItem *cancle = [[UIBarButtonItem alloc] initWithTitle:SNASLS(取消) style:UIBarButtonItemStyleDone target:self action:@selector(cancleAction)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:SNASLS(确定) style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)];
    UIBarButtonItem *fiexib0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *fiexib1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    self.barTitle = [UIBarButtonItem new];
    
    self.bar = [UIToolbar new];
    self.bar.items = @[cancle,fiexib0,self.barTitle,fiexib1,done];
    
    self.picker = [SnailCityPickerView new];
    self.picker.backgroundColor = SNA_WHITE_COLOR;
    
    [self.view snail_addSubviews:@[self.bar,self.picker]];
    
    self.picker.frame = CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width, 200);
    self.bar.frame = CGRectMake(0, CGRectGetMinY(self.picker.frame) - 45, self.view.bounds.size.width, 45);
    
    self.picker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)snailFirstAction {
    if (self.title) self.barTitle.title = self.title;
}

- (void)cancleAction {
    [self dismissViewControllerAnimated:true completion:^{
        if (self.block) self.block = nil;
    }];
}

- (void)doneAction {
    [self dismissViewControllerAnimated:true completion:^{
        if (self.block) {
            [self.picker takeSelectedInfo:self.block];
            self.block = nil;
        }
    }];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.barTitle.title = title;
}

@end
