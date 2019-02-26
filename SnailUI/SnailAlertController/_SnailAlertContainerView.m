//
//  SnailAlertContainerView.m
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2019/1/4.
//  Copyright © 2019年 com.jonnew. All rights reserved.
//

#import "_SnailAlertContainerView.h"
#import "SnailAlertAction.h"

#define SNAIL_ALERT_ITEM_HEIGHT 45.f
#define SNAIL_ALERT_ITEM_SEPETOR_COLOR [UIColor grayColor]
#define SNAIL_ALERT_SPACEING 15.f
#define SNAIL_ALERT_TITLE_MESSAGE_SPACEING 8.f

@interface SnailAlertActionItem : UIView

@property (nonatomic ,strong) UIButton *btn;
@property (nonatomic ,strong) UIView *bottomLine;
@property (nonatomic ,weak) SnailAlertAction *action;
@property (nonatomic ,copy) void(^clickBlock)(SnailAlertAction *action);

@end

@implementation SnailAlertActionItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.btn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
        self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 1)];
        self.bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        self.bottomLine.backgroundColor = SNAIL_ALERT_ITEM_SEPETOR_COLOR;
        [self addSubview:self.btn];
        [self addSubview:self.bottomLine];
    }
    return self;
}

- (void)btnAction {
    if (self.clickBlock) {
        self.clickBlock(self.action);
    }
}

- (void)refesh {
    [self.btn setAttributedTitle:[[NSAttributedString alloc] initWithString:self.action.name attributes:self.action.attribute] forState:UIControlStateNormal];
    self.bottomLine.hidden = !self.action.seperator;
}

- (void)setAction:(SnailAlertAction *)action {
    _action = action;
    [self refesh];
}

@end

@interface SnailAlertContainerView()

@property (nonatomic ,strong) UIToolbar *backgroundBar;

@property (nonatomic ,strong) UIView *topBackgroundView;
@property (nonatomic ,strong) UILabel *titleLbl;
@property (nonatomic ,strong) UILabel *messageLbl;

@property (nonatomic ,strong) UIView *customeBackgroundView;

@property (nonatomic ,strong) UIView *itemBackgroundView;  //注意itemBackgroundViewj是没有距离父视图的边距的
@property (nonatomic ,strong) UIView *itemBackgroundViewTopLine;

@property (nonatomic) CGFloat marin;

@end

@implementation SnailAlertContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = true;
        self.layer.cornerRadius = 15;
        
        self.marin = 12;
        
        self.backgroundBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.backgroundBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.backgroundBar.alpha = .98;
        
        self.topBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.marin, self.marin, frame.size.width - self.marin * 2, 0)];
        self.customeBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.marin, CGRectGetMaxY(self.topBackgroundView.frame), frame.size.width - self.marin * 2, 0)];
        
        CGFloat itemBackgroundLeadeing = 0;
        
        self.itemBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(itemBackgroundLeadeing, CGRectGetMaxY(self.customeBackgroundView.frame), frame.size.width - itemBackgroundLeadeing * 2, 0)];
        
        self.itemBackgroundViewTopLine = [UIView new];
        self.itemBackgroundViewTopLine.frame = CGRectMake(0, 0, CGRectGetWidth(self.itemBackgroundView.frame), 1);
        self.itemBackgroundViewTopLine.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        
        [self.itemBackgroundView addSubview:self.itemBackgroundViewTopLine];
        
        self.titleLbl = [UILabel new];
        self.titleLbl.numberOfLines = 0;
        self.titleLbl.textAlignment = NSTextAlignmentCenter;
        
        self.messageLbl = [UILabel new];
        self.messageLbl.numberOfLines = 0;
        self.messageLbl.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.backgroundBar];
        [self addSubview:self.topBackgroundView];
        [self addSubview:self.customeBackgroundView];
        [self addSubview:self.itemBackgroundView];
        
        [self.topBackgroundView addSubview:self.titleLbl];
        [self.topBackgroundView addSubview:self.messageLbl];
        
    }
    return self;
}

- (void)refeshTitle:(NSString *)title Attribute:(NSDictionary *)titleAttribute Message:(NSString *)message MessageAttribue:(NSDictionary *)messageAttribute {
    
    CGFloat maxWidth = self.topBackgroundView.frame.size.width;
    {
        CGSize titleSize = [title boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:titleAttribute context:nil].size;
        self.titleLbl.frame = CGRectMake(0, 0, maxWidth, titleSize.height);
        self.titleLbl.attributedText = [[NSAttributedString alloc] initWithString:title?:@"" attributes:titleAttribute];
    }
    {
        
        CGFloat y = 0;
        if (self.titleLbl.frame.size.height > 0) y = CGRectGetMaxY(self.titleLbl.frame) + SNAIL_ALERT_TITLE_MESSAGE_SPACEING;
        
        CGSize messageSize = [message boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:titleAttribute context:nil].size;
        self.messageLbl.frame = CGRectMake(0, y, maxWidth, messageSize.height);
        self.messageLbl.attributedText = [[NSAttributedString alloc] initWithString:message?:@"" attributes:messageAttribute];
    }
    {
        CGRect frame = self.topBackgroundView.frame;
        frame.size.height = self.titleLbl.frame.size.height + SNAIL_ALERT_TITLE_MESSAGE_SPACEING + self.messageLbl.frame.size.height;
        self.topBackgroundView.frame = frame;
    }
    [self refesh];
    
}

- (void)appendCustomeViews:(UIView *)customeView {
    
    CGFloat maxWidth = self.customeBackgroundView.frame.size.width;
    CGRect frame = customeView.frame;
    if (frame.size.width > maxWidth) {
        CGFloat scale = frame.size.height / frame.size.width;
        frame.size.width = maxWidth;
        frame.size.height = maxWidth * scale;
    }
    frame.origin.y = self.customeBackgroundView.frame.size.height;
    frame.origin.x = (maxWidth - frame.size.width) * .5;
    customeView.frame = frame;
    [self.customeBackgroundView addSubview:customeView];
    
    {
        CGRect frame = self.customeBackgroundView.frame;
        frame.size.height = CGRectGetMaxY(customeView.frame);
        self.customeBackgroundView.frame = frame;
    }
    
    [self refesh];
    
}

- (void)refeshWithActions:(NSArray<SnailAlertAction *> *)actions {
    
    __weak typeof(self) self_weak_ = self;
    
    [self.itemBackgroundView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:SnailAlertActionItem.class]) {
            [obj removeFromSuperview];
        }
    }];
    
    CGFloat maxWidth = self.itemBackgroundView.frame.size.width;
    
    if (actions.count != 2) {
        [actions enumerateObjectsUsingBlock:^(SnailAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SnailAlertActionItem *item = [[SnailAlertActionItem alloc] initWithFrame:CGRectMake(0, idx * SNAIL_ALERT_ITEM_HEIGHT, maxWidth, SNAIL_ALERT_ITEM_HEIGHT)];
            item.action = obj;
            item.clickBlock = ^(SnailAlertAction *action) {
                if (self_weak_.actionBlock) self_weak_.actionBlock(action);
            };
            item.bottomLine.backgroundColor = self.sepertorColor?:SNAIL_ALERT_ITEM_SEPETOR_COLOR;
            [self.itemBackgroundView addSubview:item];
        }];
        {
            CGRect frame = self.itemBackgroundView.frame;
            frame.size.height = SNAIL_ALERT_ITEM_HEIGHT * actions.count;
            self.itemBackgroundView.frame = frame;
        }
    }
    else {
        
        SnailAlertActionItem *item1 = [[SnailAlertActionItem alloc] initWithFrame:CGRectMake(0, 0, maxWidth * .5 - .5, SNAIL_ALERT_ITEM_HEIGHT)];
        item1.action = actions.firstObject;
        item1.bottomLine.hidden = true;
        item1.clickBlock = ^(SnailAlertAction *action) {
            if (self_weak_.actionBlock) self_weak_.actionBlock(action);
        };
        
        SnailAlertActionItem *item2 = [[SnailAlertActionItem alloc] initWithFrame:CGRectMake(maxWidth * .5 + .5, 0, maxWidth * .5 - .5, SNAIL_ALERT_ITEM_HEIGHT)];
        item2.action = actions.lastObject;
        item2.bottomLine.hidden = true;
        item2.clickBlock = ^(SnailAlertAction *action) {
            if (self_weak_.actionBlock) self_weak_.actionBlock(action);
        };
        

        UIView *midleLine = [UIView new];
        {
            CGFloat middleLineY = 0;
            midleLine.backgroundColor = self.sepertorColor?:SNAIL_ALERT_ITEM_SEPETOR_COLOR;
            midleLine.frame = CGRectMake(CGRectGetMaxX(item1.frame), middleLineY, 1, SNAIL_ALERT_ITEM_HEIGHT - middleLineY * 2);
        }
        
        [self.itemBackgroundView addSubview:item1];
        [self.itemBackgroundView addSubview:item2];
        [self.itemBackgroundView addSubview:midleLine];
        
        {
            CGRect frame = self.itemBackgroundView.frame;
            frame.size.height = SNAIL_ALERT_ITEM_HEIGHT;
            self.itemBackgroundView.frame = frame;
        }
    }
    
    [self refesh];
    
}

- (void)refesh {
    
    CGFloat topHeight = self.topBackgroundView.frame.size.height;
    CGFloat customeHeight = self.customeBackgroundView.frame.size.height;
    CGFloat itemHeight = self.itemBackgroundView.frame.size.height;
    
    {
        CGRect frame = self.topBackgroundView.frame;
        if (topHeight > 0) {
            frame.origin.y = self.marin;
            self.topBackgroundView.frame = frame;
        }
    }
    {
        CGRect frame = self.customeBackgroundView.frame;
        if (topHeight == 0 && customeHeight > 0) {
            frame.origin.y = self.marin;
        }
        else if (topHeight > 0) {
            frame.origin.y = CGRectGetMaxY(self.topBackgroundView.frame) + SNAIL_ALERT_SPACEING;
        }
        
        self.customeBackgroundView.frame = frame;
    }
    {
        CGRect frame = self.itemBackgroundView.frame;
        if (topHeight == 0 && customeHeight == 0 && itemHeight > 0) {
            frame.origin.y = self.marin;
        }
        else if (topHeight > 0 || customeHeight > 0) {
            frame.origin.y = CGRectGetMaxY(self.customeBackgroundView.frame) + SNAIL_ALERT_SPACEING;
        }
        
        self.itemBackgroundView.frame = frame;
    }
    
    CGFloat tempHeight = CGRectGetMaxY(self.itemBackgroundView.frame);
    
    CGRect frame =  self.frame;
    frame.size.height = tempHeight;
    self.frame = frame;
    
    if (self.afterRefeshBlock) self.afterRefeshBlock();
    
}

- (void)setSepertorColor:(UIColor *)sepertorColor {
    _sepertorColor = sepertorColor;
    [self.itemBackgroundView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:SnailAlertActionItem.class]) {
            SnailAlertActionItem *item = obj;
            item.bottomLine.backgroundColor = sepertorColor;
        }
        else {
            obj.backgroundColor = sepertorColor;
        }
    }];
}

@end
