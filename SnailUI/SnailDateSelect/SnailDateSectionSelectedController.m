//
//  SnailDateSectionSelectedController.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/11/30.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailDateSectionSelectedController.h"

@interface _SnailDateSectionSelectedPicker : UIView

@property (nonatomic ,strong) UILabel *tiLbl;
@property (nonatomic ,strong) UIDatePicker *picker;

@end

@implementation _SnailDateSectionSelectedPicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tiLbl = [UILabel new];
        self.tiLbl.font = [UIFont systemFontOfSize:15];
        self.tiLbl.textColor = UIColor.blackColor;
        self.tiLbl.textAlignment = NSTextAlignmentCenter;
        
        self.picker = [UIDatePicker new];
        self.picker.backgroundColor = SNA_WHITE_COLOR;
        
        [self addSubview:self.tiLbl];
        [self addSubview:self.picker];
        
        self.tiLbl.frame = CGRectMake(0, 10, frame.size.width, self.tiLbl.font.lineHeight);
        self.picker.frame = CGRectMake(0, 10 + self.tiLbl.font.lineHeight, frame.size.width, frame.size.height - (10 + self.tiLbl.font.lineHeight));
        
        self.tiLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        self.picker.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        
    }
    return self;
}

@end

@interface SnailDateSectionSelectedController ()

@property (nonatomic ,strong) UIToolbar *bar;
@property (nonatomic ,strong) UIBarButtonItem *barTitle;
@property (nonatomic ,strong) _SnailDateSectionSelectedPicker *startPicker;
@property (nonatomic ,strong) _SnailDateSectionSelectedPicker *endPicker;

@end

@implementation SnailDateSectionSelectedController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = SnailAlertAnimation_FromeBottom;
        _errorCorrection = true;
        self.offsetBlock = ^CGFloat{
            return 245;
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    self.startPicker = [[_SnailDateSectionSelectedPicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width * .5, 200)];
    self.startPicker.picker.datePickerMode = self.startDateMode;
    self.startPicker.backgroundColor = SNA_WHITE_COLOR;
    self.startPicker.tiLbl.text = SNASLS(开始时间);
    
    self.endPicker = [[_SnailDateSectionSelectedPicker alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * .5, self.view.bounds.size.height - 200, self.view.bounds.size.width * .5, 200)];
    self.endPicker.picker.datePickerMode = self.startDateMode;
    self.endPicker.backgroundColor = SNA_WHITE_COLOR;
    self.endPicker.tiLbl.text = SNASLS(结束时间);
    
    [self.view snail_addSubviews:@[self.bar,self.startPicker,self.endPicker]];
    
    self.bar.frame = CGRectMake(0, CGRectGetMinY(self.startPicker.frame) - 45, self.view.bounds.size.width, 45);
    
    self.startPicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.endPicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    [self.startPicker.picker addTarget:self action:@selector(startDateChange:) forControlEvents:UIControlEventValueChanged];
    [self.endPicker.picker addTarget:self action:@selector(endDateChange:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)snailFirstAction {
    
    if (self.title) self.barTitle.title = self.title;
    if (self.startDate) {
        if (self.errorCorrection) self.endPicker.picker.minimumDate = self.startDate;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.startPicker.picker setDate:self.startDate animated:true];
        });
    }
    if (self.endDate) {
        if (self.errorCorrection) self.startPicker.picker.maximumDate = self.endDate;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.endPicker.picker setDate:self.endDate animated:true];
        });
    }
    
}

- (void)startDateChange:(UIDatePicker *)picker {
    if (self.errorCorrection) self.endPicker.picker.minimumDate = picker.date;
}

- (void)endDateChange:(UIDatePicker *)picker {
    if (self.errorCorrection) self.startPicker.picker.maximumDate = picker.date;
}

- (void)cancleAction {
    [self dismissViewControllerAnimated:true completion:^{
        if (self.block) self.block = nil;
    }];
}

- (void)doneAction {
    [self dismissViewControllerAnimated:true completion:^{
        if (self.block) {
            self.block(self.startPicker.picker.date,self.endPicker.picker.date);
            self.block = nil;
        }
    }];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.barTitle.title = title;
}

- (void)setErrorCorrection:(BOOL)errorCorrection {
    _errorCorrection = errorCorrection;
    if (errorCorrection) {
        self.startPicker.picker.maximumDate = self.endPicker.picker.date;
        self.endPicker.picker.minimumDate = self.startPicker.picker.date;
    }
    else {
        self.startPicker.picker.maximumDate = nil;
        self.endPicker.picker.minimumDate = nil;
    }
}

@end
