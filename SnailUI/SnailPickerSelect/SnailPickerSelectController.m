//
//  SnailPickerSelectController.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailPickerSelectController.h"

@interface SnailPickerSelectController ()<UIPickerViewDelegate,UIPickerViewDataSource>

kSPr(CGFloat pickerHeight)
kSPrStrong(UIToolbar *bar)
kSPrStrong(UIBarButtonItem *barTitle)
kSPrStrong(UIPickerView *picker)

@end

@implementation SnailPickerSelectController

- (instancetype)init {
    return [self initWithPickerHeight:300];
}

- (instancetype)initWithPickerHeight:(CGFloat)pickerHeight {
    self = [super init];
    if (self) {
        self.pickerHeight = pickerHeight;
        self.type = SnailAlertAnimation_FromeBottom;
        self.offsetBlock = ^CGFloat{
            return pickerHeight + 45;
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
    
    self.picker = [UIPickerView new];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    self.picker.backgroundColor = SNA_WHITE_COLOR;
    
    [self.view snail_addSubviews:@[self.bar,self.picker]];
    
    self.picker.frame = CGRectMake(0, self.view.bounds.size.height - self.pickerHeight, self.view.bounds.size.width, self.pickerHeight);
    self.bar.frame = CGRectMake(0, CGRectGetMinY(self.picker.frame) - 45, self.view.bounds.size.width, 45);
    
    self.picker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
}

- (void)snailFirstAction {
    
    if (self.title) self.barTitle.title = self.title;
    
    if (self.firstSelectedRows.count > 0) {
        
        [self.picker reloadAllComponents];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.firstSelectedRows enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSInteger row = obj.integerValue;
                [self.picker selectRow:row inComponent:idx animated:false];
            }];
            self.firstSelectedRows = nil;
        });
        
    }

}

#pragma mark -

- (void)reload {
    [self.picker reloadAllComponents];
}

- (void)reloadCompont:(NSInteger)compont {
    [self.picker reloadComponent:compont];
}

- (void)selectedRow:(NSInteger)row Compont:(NSInteger)compont {
    [self.picker selectRow:row inComponent:compont animated:true];
}

- (NSInteger)takeSelectedRowInCompont:(NSInteger)compont {
    return [self.picker selectedRowInComponent:compont];
}

#pragma mark -

- (void)cancleAction {
    [self dismissViewControllerAnimated:true completion:^{
        [self clear];
    }];
}

- (void)doneAction {
    [self dismissViewControllerAnimated:true completion:^{
        if (self.doneBlock) {
            NSMutableArray *tmps = [NSMutableArray new];
            for (int i = 0; i < self.picker.numberOfComponents; i++) {
                [tmps addObject:@([self.picker selectedRowInComponent:i])];
            }
            self.doneBlock(tmps);
        }
        [self clear];
    }];
}

- (void)clear {
    self.numberOfComponentsBlock = nil;
    self.numberOfRowsInComponentBlock = nil;
    self.rowHeightForComponentBlock = nil;
    self.titleForRowBlock = nil;
    self.titleAttributesForRowBlock = nil;
    self.didSelectRow = nil;
    self.doneBlock = nil;
}

#pragma mark -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.numberOfComponentsBlock) return self.numberOfComponentsBlock();
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.numberOfRowsInComponentBlock) return self.numberOfRowsInComponentBlock(component);
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    if (self.rowHeightForComponentBlock) return self.rowHeightForComponentBlock(component);
    return 40;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (self.titleForRowBlock) {
        NSString *title = self.titleForRowBlock(row,component);
        if (title.length > 0) {
            NSDictionary *attribute = nil;
            if (self.titleAttributesForRowBlock) attribute = self.titleAttributesForRowBlock(row,component);
            if (attribute == nil) {
                attribute = @{NSFontAttributeName:SNAS_SYS_FONT([UIFont labelFontSize]),NSForegroundColorAttributeName:[UIColor blackColor]};
            }
            return [[NSAttributedString alloc] initWithString:title attributes:attribute];
        }
    }
    
    return [[NSAttributedString alloc] initWithString:@""];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (self.didSelectRow) self.didSelectRow(row, component);
    
}

@end
