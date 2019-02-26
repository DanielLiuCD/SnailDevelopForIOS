//
//  SnailSimpleSearchBox.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/25.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailSimpleSearchBox.h"

@interface SnailSimpleSearchBox()

@property (nonatomic ,strong) UIView *leftView;
@property (nonatomic ,strong) UITextField *filed;
@property (nonatomic ,strong) UIView *rightView;

@end

@implementation SnailSimpleSearchBox

+ (instancetype)PlaceHolder:(NSString *)placeHolder LeftImage:(UIImage *)leftIcon RightImage:(UIImage *)rightIcon {
    
    SnailSimpleSearchBox *box = [SnailSimpleSearchBox new];
    box.filed.placeholder = placeHolder;
    if (leftIcon) {
        box.filed.leftView = [self takeLRView:leftIcon];
        box.filed.leftViewMode = UITextFieldViewModeAlways;
    }
    if (rightIcon) {
        box.filed.rightView = [self takeLRView:rightIcon];
        box.filed.rightViewMode = UITextFieldViewModeAlways;
    }
    return box;
}

+ (UIView *)takeLRView:(UIImage *)icon {
    
    UIImageView *vim = [[UIImageView alloc] initWithImage:icon];
    vim.frame = CGRectMake(10, 0, icon.size.width, icon.size.height);
    UIView *tmp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, icon.size.width + 20, icon.size.height)];
    [tmp addSubview:vim];
    return tmp;
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.filed = [UITextField new];
        [self addSubview:self.filed];
        [self updateLayout];
    }
    return self;
}

- (void)updateLayout {
    [self.filed mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(self.insert.left);
        make.top.equalTo(self).offset(self.insert.top);
        make.bottom.equalTo(self).offset(-self.insert.bottom);
        make.trailing.equalTo(self).offset(-self.insert.right);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.filed.leftView) {
        CGRect frame = self.filed.leftView.frame;
        frame.origin.y = (self.filed.bounds.size.height - frame.size.height) / 2.0;
        self.filed.leftView.frame = frame;
    }
    if (self.filed.rightView) {
        CGRect frame = self.filed.rightView.frame;
        frame.origin.y = (self.filed.bounds.size.height - frame.size.height) / 2.0;
        self.filed.rightView.frame = frame;
    }
}

- (void)setInsert:(UIEdgeInsets)insert {
    if (!UIEdgeInsetsEqualToEdgeInsets(insert, self.insert)) {
        _insert = insert;
        [self updateLayout];
    }
}

- (CGSize)intrinsicContentSize {
    return self.frame.size;
}

@end
