//
//  SnailSimpleFiledController.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/12/4.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailSimpleFiledController.h"

@interface SnailSimpleFiledController ()

@property (nonatomic ,strong) UITextField *filed;

@end

@implementation SnailSimpleFiledController

@dynamic text;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.returnKeyType = UIReturnKeyDone;
        self.keyboardType = UIKeyboardTypeDefault;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = SNA_GTB_COLOR;
    self.filed = [UITextField new];
    self.filed.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
    self.filed.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
    self.filed.leftViewMode = UITextFieldViewModeAlways;
    self.filed.rightViewMode = UITextFieldViewModeAlways;
    if (self.font) self.filed.font = self.font;
    if (self.placeHolder && self.placeHolderColor)  self.filed.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeHolder attributes:@{NSForegroundColorAttributeName:self.placeHolderColor}];
    else self.filed.placeholder = self.placeHolder;
    self.filed.text = self.text;
    if (self.textColor) self.filed.textColor = self.textColor;
    self.filed.keyboardType = self.keyboardType;
    self.filed.returnKeyType = self.returnKeyType;
    self.filed.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.filed];
    [self.filed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.leading.equalTo(self.view);
        make.height.equalTo(@50);
        make.top.equalTo(self.mas_topLayoutGuide).offset(15);
    }];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:SNASLS(完成) style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)doneAction {
    if (self.block) {
        self.block(self.filed.text);
    }
}

- (NSString *)text {
    return self.filed.text;
}

- (void)setText:(NSString *)text {
    self.filed.text = text;
}

@end
