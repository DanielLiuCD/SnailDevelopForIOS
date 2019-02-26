//
//  SnailShareController.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/12/5.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailShareController.h"

#define SnailShareControllerActivityWidth  60
#define SnailShareControllerActivityImageTitleSpaceing 5
#define SnailShareControllerActivitySpaceing 10
#define SnailShareControllerActivityAvailableNumber 5

#define SnailShareControllerActivityFont  [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2]

@implementation SnailShareControllerItem

+ (instancetype):(NSString *)title :(UIImage *)image {
    SnailShareControllerItem *item = [SnailShareControllerItem new];
    item.title = title;
    item.image = image;
    return item;
}

@end

@implementation SnailShareControllerSectionData

+ (instancetype):(SnailShareControllerScrollerDircetion)dircetion :(NSArray<SnailShareControllerItem *> *)items {
    SnailShareControllerSectionData *item = [SnailShareControllerSectionData new];
    item.dircetion = dircetion;
    item.items = items;
    return item;
}

@end

@implementation SnailShareControllerData

+ (instancetype):(SnailShareControllerStyle)style :(NSArray<SnailShareControllerSectionData *> *)datas {
    SnailShareControllerData *item = [SnailShareControllerData new];
    item.style = style;
    item.datas = datas;
    return item;
}

@end

@interface SnailShareControllerActivity : UIControl

@property (nonatomic ,strong) UIImageView *imageView;
@property (nonatomic ,strong) UILabel *titleLabel;
@property (nonatomic ,weak) SnailShareControllerItem *item;

@end

@implementation SnailShareControllerActivity

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.clipsToBounds = true;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        
        self.titleLabel = [UILabel new];
        self.titleLabel.font = SnailShareControllerActivityFont;
        self.titleLabel.textColor = [UIColor colorWithRed:47 / 255.0 green:79 / 255.0 blue:79 / 255.0 alpha:1];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        self.titleLabel.numberOfLines = 2;
        
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
        
        self.imageView.frame = CGRectMake(0, 0, frame.size.width, SnailShareControllerActivityWidth);
        self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + SnailShareControllerActivityImageTitleSpaceing, frame.size.width, self.titleLabel.font.lineHeight * 2 + 2);
        
    }
    return self;
}

+ (CGFloat)sna_height {
    return SnailShareControllerActivityWidth + SnailShareControllerActivityImageTitleSpaceing + SnailShareControllerActivityFont.lineHeight * 2 + 2;
}

- (void)setItem:(SnailShareControllerItem *)item {
    _item = item;
    self.imageView.image = item.image;
    
    NSString *str = item.title?:@"Item";
    
    NSMutableParagraphStyle *paty = [NSMutableParagraphStyle new];
    paty.lineSpacing = 0;
    paty.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSParagraphStyleAttributeName:paty}];
    
    self.titleLabel.attributedText = attr;
    CGSize tmpSize = [self.titleLabel sizeThatFits:CGSizeMake(self.frame.size.width, self.titleLabel.font.lineHeight * 2 + 2)];
    CGRect frame = self.titleLabel.frame;
    frame.size.height = tmpSize.height;
    self.titleLabel.frame = frame;
    
}

@end

@interface SnailShareControllerSectionView : UIView

@property (nonatomic ,strong) UIScrollView *scro;
@property (nonatomic ,weak) SnailShareControllerSectionData *data;
@property (nonatomic ,copy) void(^block)(SnailShareControllerItem *item);

@end

@implementation SnailShareControllerSectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.scro = [UIScrollView new];
        self.scro.showsHorizontalScrollIndicator = false;
        self.scro.showsVerticalScrollIndicator = false;
        self.scro.frame = self.bounds;
        self.scro.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.scro];
    }
    return self;
}

- (void)refeshUI {
    [self.scro.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSInteger count = self.data.items.count;
    CGFloat width = SnailShareControllerActivityWidth;
    CGFloat spaceing = ceil((self.frame.size.width - width * SnailShareControllerActivityAvailableNumber) / (SnailShareControllerActivityAvailableNumber - 1));
    switch (self.data.dircetion) {
        case SnailShareControllerScrollerDircetionH:
        {
            for (int i = 0; i < count; i++) {
                CGFloat x = i * width;
                x += i * spaceing;
                CGFloat y = 0;
                CGRect frame = CGRectMake(x, y, SnailShareControllerActivityWidth, [SnailShareControllerActivity sna_height]);
                SnailShareControllerActivity *activity = [self activity:frame Item:self.data.items[i]];
                [self.scro addSubview:activity];
                if (i == count - 1) {
                    [self.scro setContentSize:CGSizeMake(CGRectGetMaxX(frame), CGRectGetHeight(frame))];
                }
            }
        }
            break;
        case SnailShareControllerScrollerDircetionV:
        {
            NSInteger row = count / SnailShareControllerActivityAvailableNumber + 1;
            if (count % SnailShareControllerActivityAvailableNumber == 0) row--;
            
            CGFloat height = [SnailShareControllerActivity sna_height];
            
            for (int i = 0; i < row; i++) {
                for (int j = 0; j < SnailShareControllerActivityAvailableNumber; j++) {
                    int index = i + SnailShareControllerActivityAvailableNumber + j;
                    if (index < count) {
                        CGFloat x = j * width;
                        x += j * spaceing;
                        CGFloat y = i * height;
                        y += i * SnailShareControllerActivitySpaceing;
                        CGRect frame = CGRectMake(x, y, width, height);
                        SnailShareControllerActivity *activity = [self activity:frame Item:self.data.items[index]];
                        [self.scro addSubview:activity];
                    }
                }
            }
            [self.scro setContentSize:CGSizeMake(self.frame.size.width, row * height + (row - 1) * SnailShareControllerActivitySpaceing)];
        }
            break;
        default:
            break;
    }
}

- (SnailShareControllerActivity *)activity:(CGRect)frame Item:(SnailShareControllerItem *)item {
    SnailShareControllerActivity *activity = [[SnailShareControllerActivity alloc] initWithFrame:frame];
    activity.item = item;
    [activity addTarget:self action:@selector(activityItemAction:) forControlEvents:UIControlEventTouchUpInside];
    return activity;
}

- (void)activityItemAction:(SnailShareControllerActivity *)activity {
    if (self.block) self.block(activity.item);
}

+ (CGFloat)sna_value:(SnailShareControllerSectionData *)data {
    switch (data.dircetion) {
        case SnailShareControllerScrollerDircetionH:
            return [SnailShareControllerActivity sna_height];
            break;
        case SnailShareControllerScrollerDircetionV:
        {
            CGFloat height = [SnailShareControllerActivity sna_height];
            NSInteger count = data.items.count;
            NSInteger row = count / SnailShareControllerActivityAvailableNumber + 1;
            if (count % SnailShareControllerActivityAvailableNumber == 0) row--;
            return row * height + (row - 1) * SnailShareControllerActivitySpaceing;
        }
            break;
        default:
            break;
    }
}

- (void)setData:(SnailShareControllerSectionData *)data {
    _data = data;
    [self refeshUI];
}

@end

@interface SnailShareController ()

@property (nonatomic ,strong) UIToolbar *background;
@property (nonatomic ,strong) UIScrollView *backgroundScro;
@property (nonatomic ,strong) UIToolbar *bottomBar;

@property (nonatomic ,strong) SnailShareControllerData *data;

@property (nonatomic ,strong) NSMutableArray<SnailShareControllerSectionView *> *sectionViews;

@end

@implementation SnailShareController

- (instancetype)initWithData:(SnailShareControllerData *)data {
    self = [super init];
    if (self) {
        __weak typeof(self) self_weak_ = self;
        self.data = data;
        self.type = SnailAlertAnimation_FromeBottom;
        self.offsetBlock = ^CGFloat{
            return [SnailShareController sna_preparedHeight:self_weak_.data];
        };
    }
    return self;
}

+ (CGFloat)sna_preparedHeight : (SnailShareControllerData *)data {
    
    NSInteger count = data.datas.count;
    CGFloat backgroundHeight = 15 + 15;
    for (int i = 0; i < count; i++) {
        SnailShareControllerSectionData *section = data.datas[i];
        backgroundHeight += [SnailShareControllerSectionView sna_value:section];
        backgroundHeight += SnailShareControllerActivitySpaceing;
    }
    
    if (backgroundHeight > [UIScreen mainScreen].bounds.size.height * .5) {
        backgroundHeight = [UIScreen mainScreen].bounds.size.height * .5;
    }
    
    CGFloat height = 0;
    
    switch (data.style) {
        case SnailShareControllerStyleSheet: {
            height = backgroundHeight + 8 + 50 + 8;
        };
            break;
        case SnailShareControllerStyleGrid: {
            height = backgroundHeight + 50;
        };
            break;
    }
    
    return height;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.background = [UIToolbar new];
    self.background.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    
    self.bottomBar = [UIToolbar new];
    self.bottomBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    
    [self.background layoutIfNeeded];
    [self.bottomBar layoutIfNeeded];
    
    [self.view addSubview:self.background];
    [self.view addSubview:self.bottomBar];
    
    self.backgroundScro = [UIScrollView new];
    self.backgroundScro.showsVerticalScrollIndicator = false;
    self.backgroundScro.showsHorizontalScrollIndicator = false;
    self.backgroundScro.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    switch (self.data.style) {
        case SnailShareControllerStyleSheet:[self sheetUI];
            break;
        case SnailShareControllerStyleGrid:[self girdUI];
            break;
    }
    
    
    self.backgroundScro.frame = CGRectInset(self.background.bounds, 15, 15);
    [self.background addSubview:self.backgroundScro];
    
    UIButton *cancle = [UIButton new];
    cancle.frame = self.bottomBar.bounds;
    [cancle setTitle:SNASLS(取消) forState:UIControlStateNormal];
    [cancle addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
    cancle.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [cancle setTitleColor:[UIColor colorWithRed:0 green:122 / 255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    cancle.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    [self.bottomBar addSubview:cancle];
    
    [self refeshActivityUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)sheetUI {
    
    CGFloat width = self.view.bounds.size.width - 16;
    
    self.bottomBar.frame = CGRectMake(8, self.view.bounds.size.height - 8 - 50, width, 50);
    self.bottomBar.layer.cornerRadius = 10;
    self.bottomBar.layer.masksToBounds = true;
    
    NSInteger count = self.data.datas.count;
    CGFloat backgroundHeight = 15 + 15;
    for (int i = 0; i < count; i++) {
        SnailShareControllerSectionData *section = self.data.datas[i];
        backgroundHeight += [SnailShareControllerSectionView sna_value:section];
        backgroundHeight += SnailShareControllerActivitySpaceing;
    }
    
    CGFloat showBackgroundHeight = backgroundHeight;
    if (backgroundHeight > self.view.bounds.size.height * .5) {
        showBackgroundHeight = self.view.bounds.size.height * .5;
    }
    
    self.background.frame = CGRectMake(8, CGRectGetMinY(self.bottomBar.frame) - 8 - showBackgroundHeight, width, showBackgroundHeight);
    self.background.layer.cornerRadius = 10;
    self.background.layer.masksToBounds = true;
    
    self.backgroundScro.contentSize = CGSizeMake(width - 30, backgroundHeight - 30);
    
}

- (void)girdUI {
    
    CGFloat width = self.view.bounds.size.width;
    self.bottomBar.frame = CGRectMake(0, self.view.bounds.size.height - 50, width, 50);
    
    NSInteger count = self.data.datas.count;
    CGFloat backgroundHeight = 15 + 15;
    for (int i = 0; i < count; i++) {
        SnailShareControllerSectionData *section = self.data.datas[i];
        backgroundHeight += [SnailShareControllerSectionView sna_value:section];
        backgroundHeight += SnailShareControllerActivitySpaceing;
    }
    
    self.background.frame = CGRectMake(0, CGRectGetMinY(self.bottomBar.frame) - backgroundHeight, width, backgroundHeight);
    
    CGFloat showBackgroundHeight = backgroundHeight;
    if (backgroundHeight > self.view.bounds.size.height * .5) {
        showBackgroundHeight = self.view.bounds.size.height * .5;
    }
    
    self.background.frame = CGRectMake(0, CGRectGetMinY(self.bottomBar.frame)- showBackgroundHeight, width, showBackgroundHeight);
    self.backgroundScro.contentSize = CGSizeMake(width - 30, backgroundHeight - 30);
    
}

- (void)refeshActivityUI {
    
    [self.sectionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.sectionViews removeAllObjects];
    
    NSInteger count = self.data.datas.count;
    
    CGFloat y = 0;
    
    __weak typeof(self) self_weak_ = self;
    
    for (int i = 0; i < count; i++) {
        SnailShareControllerSectionData *data = self.data.datas[i];
        CGFloat height = [SnailShareControllerSectionView sna_value:data];
        SnailShareControllerSectionView *section  = [[SnailShareControllerSectionView alloc] initWithFrame:CGRectMake(0, y, self.backgroundScro.frame.size.width, height)];
        section.data = data;
        section.block = ^(SnailShareControllerItem *item) {
            [self_weak_ cancleAction];
            if (self_weak_.didSelectedItemBlock) self_weak_.didSelectedItemBlock(item);
        };
        [self.backgroundScro addSubview:section];
        [self.sectionViews addObject:section];
        y += height;
        if (i != count - 1) y += SnailShareControllerActivitySpaceing;
    }
    
}

- (void)cancleAction {
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}

- (NSMutableArray<SnailShareControllerSectionView *> *)sectionViews {
    if (!_sectionViews) {
        _sectionViews = [NSMutableArray new];
    }
    return _sectionViews;
}

@end
