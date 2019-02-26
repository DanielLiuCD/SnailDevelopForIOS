//
//  SnailSimpleInputItem.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/22.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailSimpleInputItem.h"

@interface SnailSimpleInputItemConfigure()<NSCopying>

@end

@implementation SnailSimpleInputItemConfigure

- (id)copyWithZone:(NSZone *)zone {
    SnailSimpleInputItemConfigure *objc = [SnailSimpleInputItemConfigure allocWithZone:zone];
    
    objc.titleFont = self.titleFont.copy;
    objc.filedFont = self.filedFont.copy;
    objc.titleColor = self.titleColor.copy;
    objc.filedColor = self.filedColor.copy;
    
    objc.backgroundColor = self.backgroundColor.copy;
    
    objc.title = self.title;
    objc.text = self.text;
    objc.placeHolder = self.placeHolder;
    objc.rightImage = self.rightImage;
    
    objc.titleWidth = self.titleWidth;
    objc.titleLeading = self.titleLeading;
    objc.rightTrailing = self.rightTrailing;
    
    objc.showTitle = self.showTitle;
    objc.showInputFiled = self.showInputFiled;
    objc.showRightImage = self.showRightImage;
    objc.showBottomLine = self.showBottomLine;
    
    objc.canInput = self.canInput;
    
    objc.clickBlock = self.clickBlock;
    objc.rightViewActionBlock = self.clickBlock;
    
    return objc;
    
}

@end

#define FILED_TITLE_SPACEING  10.0

@interface SnailSimpleInputItem()

@property (nonatomic ,strong) UILabel *titleLbl;
@property (nonatomic ,strong) UITextField *filed;
@property (nonatomic ,strong) UIImageView *right;
@property (nonatomic ,strong) UIView *bli;
@property (nonatomic ,strong) UIButton *mask;

@end

@implementation SnailSimpleInputItem
{
    CGFloat _auto_title_Width;
}

+ (instancetype)createWithConfigure:(SnailSimpleInputItemConfigure *)configure {
    
    SnailSimpleInputItem *item = [self new];
    
    item.titleWidth = configure.titleWidth;
    item.titleLeading = configure.titleLeading;
    item.rightTrailing = configure.rightTrailing;
    item.showTitle = configure.showTitle;
    item.showInputFiled = configure.showInputFiled;
    item.showRightImage = configure.showRightImage;
    item.showBottomLine = configure.showBottomLine;
    item.canInput = configure.canInput;
    item.title = configure.title;
    item.text = configure.text;
    item.placeHolder = configure.placeHolder;
    item.rightImage = configure.rightImage;
    item.clickBlock = configure.clickBlock;
    item.rightViewActionBlock = configure.rightViewActionBlock;
    item.filed.textAlignment = configure.filedTextAlignment;
    if (configure.bottomLineColor) item.bli.backgroundColor = configure.bottomLineColor;
    
    if (configure.titleFont) item.titleLbl.font = configure.titleFont;
    if (configure.titleColor) item.titleLbl.textColor = configure.titleColor;
    if (configure.filedFont) item.filed.font = configure.filedFont;
    if (configure.filedColor) item.filed.textColor = configure.filedColor;
    if (configure.backgroundColor) item.backgroundColor = configure.backgroundColor;
    
    return item;
}

+ (instancetype)createWithConfigure:(SnailSimpleInputItemConfigure *)configure Tag:(NSInteger)tag {
    
    SnailSimpleInputItem *item = [self createWithConfigure:configure];
    if (configure.otherUIBlock) configure.otherUIBlock(item,tag);
    return item;
    
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.titleLbl = [UILabel new];
        self.titleLbl.font = [UIFont systemFontOfSize:15];
        
        self.filed = [UITextField new];
        self.filed.font = [UIFont systemFontOfSize:15];
        
        self.right = [UIImageView new];
        self.right.userInteractionEnabled = true;
        
        [self.right setContentHuggingPriority:252 forAxis:UILayoutConstraintAxisHorizontal];
        [self.filed setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightAction)];
        [self.right addGestureRecognizer:tap];
        
        self.bli = [UIView new];
        self.bli.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        self.mask = [UIButton new];
        [self.mask addTarget:self action:@selector(maskAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.titleLbl];
        [self addSubview:self.filed];
        [self addSubview:self.right];
        [self addSubview:self.bli];
        [self addSubview:self.mask];
        
        [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.leading.equalTo(self);
        }];
        [self.filed mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.trailing.equalTo(self.right.mas_leading).offset(-10);
            make.leading.equalTo(self.titleLbl.mas_trailing).offset(FILED_TITLE_SPACEING);
        }];
        [self.right mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.trailing.equalTo(self);
        }];
        [self.bli mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.bottom.equalTo(self);
            make.leading.equalTo(self);
            make.height.equalTo(@1);
        }];
        [self.mask mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.top.leading.equalTo(self);
            make.trailing.equalTo(self.right.mas_leading);
        }];
        
        [self refeshTitleUI];
        [self refeshFiledUI];
        [self refeshRightUI];
        [self refeshBottomLineUI];
        
    }
    return self;
    
}

- (void)refeshTitleUI {
    [self.titleLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(self.showTitle?(self.titleWidth>0?self.titleWidth:self->_auto_title_Width):0));
        make.leading.equalTo(self).offset(self.titleLeading);
    }];
    [self.filed mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLbl.mas_trailing).offset(self.showTitle?FILED_TITLE_SPACEING:0);
    }];
    self.titleLbl.hidden = !self.showTitle;
}

- (void)refeshFiledUI {
    self.filed.userInteractionEnabled = self.showInputFiled;
    self.filed.hidden = !self.showInputFiled;
}

- (void)refeshRightUI {
    if (self.showRightImage == false) {
        self.right.image = nil;
        [self.right mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.equalTo(@0);
            make.trailing.equalTo(self).offset(self.rightTrailing);
        }];
    }
    else {
        [self.right mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.trailing.equalTo(self).offset(self.rightTrailing);
        }];
        self.right.image = self.rightImage;
    }
    [self.filed mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.right.mas_leading).offset(self.showRightImage?-10:0);
    }];
    self.right.hidden = !self.showRightImage;
}

- (void)refeshBottomLineUI {
    self.bli.hidden = !self.showBottomLine;
}

- (void)maskAction {
    if (self.canInput && [self.filed canBecomeFirstResponder] && self.userInteractionEnabled) {
        [self.filed becomeFirstResponder];
    }
    else if (self.clickBlock) {
        self.clickBlock(self);
    }
}

- (void)rightAction {
    if (self.rightViewActionBlock) self.rightViewActionBlock(self);
    else [self maskAction];
}

- (void)setText:(NSString *)text {
    self.filed.text = text;
}

- (NSString *)text {
    return self.filed.text;
}

- (void)setTitle:(NSString *)title {
    CGSize tmp = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.titleLbl.font.lineHeight) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLbl.font} context:nil].size;
    if (self.titleWidth <= 0) {
        if (tmp.width != _auto_title_Width) {
            _auto_title_Width = tmp.width;
            [self refeshTitleUI];
        }
    }
    self.titleLbl.text = title;
}

- (NSString *)title {
    return self.titleLbl.text;
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    self.filed.placeholder = placeHolder;
}

- (NSString *)placeHolder {
    return self.filed.placeholder;
}

- (void)setRightImage:(UIImage *)rightImage {
    _rightImage = rightImage;
    self.right.image = rightImage;
}


- (void)setShowTitle:(BOOL)showTitle {
    if (_showTitle != showTitle) {
        _showTitle = showTitle;
        [self refeshTitleUI];
    }
}

- (void)setShowInputFiled:(BOOL)showInputFiled {
    if (_showInputFiled != showInputFiled) {
        _showInputFiled = showInputFiled;
        [self refeshFiledUI];
    }
}

- (void)setShowRightImage:(BOOL)showRightImage {
    if (_showRightImage != showRightImage) {
        _showRightImage = showRightImage;
        [self refeshRightUI];
    }
}

- (void)setShowBottomLine:(BOOL)showBottomLine {
    if (_showBottomLine != showBottomLine) {
        _showBottomLine = showBottomLine;
        [self refeshBottomLineUI];
    }
}

- (void)setTitleLeading:(CGFloat)titleLeading {
    if (_titleLeading != titleLeading) {
        _titleLeading = titleLeading;
        [self refeshTitleUI];
    }
}

- (void)setRightTrailing:(CGFloat)rightTrailing {
    if (_rightTrailing != rightTrailing) {
        _rightTrailing = rightTrailing;
        [self refeshRightUI];
    }
}

- (void)setTitleWidth:(CGFloat)titleWidth {
    if (_titleWidth != titleWidth) {
        _titleWidth = titleWidth;
        [self refeshTitleUI];
    }
}

@end
