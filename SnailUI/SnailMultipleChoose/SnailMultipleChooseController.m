//
//  SnailMultipleChooseController.m
//  lesan
//
//  Created by liu on 2018/8/17.
//  Copyright © 2018年 ning. All rights reserved.
//

#import "SnailMultipleChooseController.h"
#import "SnailCoolectionViewVM.h"

#pragma mark -

@interface SnailMultipleChooseModel : NSObject

kSPrStrong(NSString *title)
kSPr(CGFloat width)
kSPr(CGFloat height)
kSPr(BOOL selected)

@end

@implementation SnailMultipleChooseModel

- (void)updateWithFont:(UIFont *)font {
    
    CGSize size = [self.title snail_calculate_size:CGSizeMake(SNA_SCREEN_WIDTH - 30, CGFLOAT_MAX) attributes:@{NSFontAttributeName:font}];
    
    self.width = size.width + 10;
    self.height = size.height + 10;
    
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        _title = title;
    }
}

@end

#pragma mark -

@interface SnailMultipleChooseController ()

kSPrStrong(UIToolbar *bar)
kSPrStrong(UIBarButtonItem *barTitle)
kSPrStrong(UICollectionView *coll)

kSPrStrong(UIFont *titleFont)
kSPrStrong(UIColor *borderColor)
kSPrStrong(UIColor *unSelectTitleColor)
kSPrStrong(UIColor *selectTitleColor)
kSPrStrong(UIColor *unSelectBackgroundColor)
kSPrStrong(UIColor *selectBackgroundColor)

kSPrStrong(SnailCoolectionViewVM *vm)
kSPrStrong(NSMutableArray<SnailMultipleChooseModel *> *caches_ar)

@end

@implementation SnailMultipleChooseController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = SnailAlertAnimation_FromeBottom;
        self.offsetBlock = ^CGFloat{
            return 345;
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
    
    self.coll = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:UICollectionViewFlowLayout.new];
    self.coll.backgroundColor = SNA_WHITE_COLOR;
    self.coll.bounces = false;
    
    [self.view snail_addSubviews:@[self.bar,self.coll]];
    
    self.coll.frame = CGRectMake(0, self.view.bounds.size.height - 300, self.view.bounds.size.width, 300);
    self.bar.frame = CGRectMake(0, CGRectGetMinY(self.coll.frame) - 45, self.view.bounds.size.width, 45);
    
    self.coll.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
}

- (void)snailBindModelAndView {
    
    if (self.titleFontBlock) self.titleFont = self.titleFontBlock();
    else self.titleFont = SNAS_SYS_FONT(15);
    
    if (self.selectTitleColorBlock) self.selectTitleColor = self.selectTitleColorBlock();
    else self.selectTitleColor = SNA_WHITE_COLOR;
    
    if (self.unSelectTitleColorBlock) self.unSelectTitleColor = self.unSelectTitleColorBlock();
    else self.unSelectTitleColor = SNA_BLACK_COLOR;
    
    if (self.borderColorBlock) self.borderColor = self.borderColorBlock();
    else self.borderColor = SNA_BLACK_COLOR;
    
    if (self.selectBckgroundColorBlock) self.selectBackgroundColor = self.selectBckgroundColorBlock();
    else self.selectBackgroundColor = SNA_BLACK_COLOR;
    
    if (self.unSelectBckgroundColorBlock) self.unSelectBackgroundColor = self.unSelectBckgroundColorBlock();
    else self.unSelectBackgroundColor = SNA_WHITE_COLOR;
    
    @weakify(self);
    self.vm = [[SnailCoolectionViewVM alloc] initWithCollectionView:self.coll];
    [self.vm registeCells:^NSArray<SnailTCReg *> *{
        return @[[SnailTCReg :[UICollectionViewCell class] :@"c"]];
    }];
    self.vm.numberOfSection = ^NSInteger{
        return 1;
    };
    self.vm.sectionInsets = ^UIEdgeInsets(NSInteger section, __kindof id model) {
        return UIEdgeInsetsMake(15, 15, 15, 15);
    };
    self.vm.minimumLineSpacing = ^CGFloat(NSInteger section, __kindof id model) {
        return 10.0;
    };
    self.vm.minimumInteritemSpacing = ^CGFloat(NSInteger section, __kindof id model) {
        return 10.0;
    };
    self.vm.numberOfRowsInSection = ^NSInteger(NSInteger section, __kindof id sectionModel) {
        if (self_weak_.totalCountBlock) return self_weak_.totalCountBlock();
        return 0;
    };
    self.vm.cellModel = ^__kindof id(NSIndexPath *indexPath, __kindof id sectionModel) {
        SnailMultipleChooseModel *model = nil;
        if (indexPath.row < self_weak_.caches_ar.count) model = self_weak_.caches_ar[indexPath.row];
        if (!model) {
            NSString *ti = self_weak_.titleBlock(indexPath.row);
            model = [SnailMultipleChooseModel new];
            model.title = ti;
            [model updateWithFont:self_weak_.titleFont];
            [self_weak_.caches_ar addObject:model];
            if (self_weak_.titleIsSelectedBlock) model.selected = self_weak_.titleIsSelectedBlock(ti,indexPath.row);
        }
        return model;
    };
    self.vm.cellIdentifer = ^NSString *(NSIndexPath *indexPath, __kindof id model) {
        return @"c";
    };
    self.vm.configureCell = ^(__kindof UICollectionViewCell *cell, NSIndexPath *indexPath, __kindof id model, SnailScrollerTrackInfo trackInfo) {
        
        SnailMultipleChooseModel *tm = (SnailMultipleChooseModel *)model;
        [self_weak_ configureCellWithModel:tm Cell:cell];
        
    };
    self.vm.cellSize = ^CGSize(NSIndexPath *indexPath, __kindof id model) {
        
        SnailMultipleChooseModel *tm = (SnailMultipleChooseModel *)model;
        return CGSizeMake(tm.width, tm.height);
        
    };
    self.vm.didSelectRow = ^(NSIndexPath *indexPath, __kindof id model, __kindof UICollectionViewCell *cell, NSIndexPath *lastSelectedIndexPath, __kindof id lastSelectedModel, __kindof UICollectionViewCell *lastCell) {
        
        SnailMultipleChooseModel *tm = (SnailMultipleChooseModel *)model;
        tm.selected = !tm.selected;
        [self_weak_ configureCellWithModel:tm Cell:cell];
        
    };
    
}

- (void)configureCellWithModel:(SnailMultipleChooseModel *)tm Cell:(UICollectionViewCell *)cell {
    
    UIView *tmp = [cell viewWithTag:-1];
    UILabel *ti = [tmp viewWithTag:-2];
    if (!tmp) {
        
        tmp = [UIView new];
        tmp.tag = -1;
        
        ti = [UILabel new];
        ti.textAlignment = NSTextAlignmentCenter;
        ti.font = SNAS_SYS_FONT(15);
        tmp.tag = -2;
        
        [tmp addSubview:ti];
        [cell addSubview:tmp];
        
        [tmp mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell);
        }];
        [ti mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(tmp);
        }];
        
    }
    
    ti.text = tm.title;
    if (tm.selected) {
        ti.textColor = self.selectTitleColor;
        tmp.backgroundColor = self.selectBackgroundColor;
        tmp.snail_border(0,self.borderColor);
    }
    else {
        ti.textColor = self.unSelectTitleColor;
        tmp.backgroundColor = self.unSelectBackgroundColor;
        tmp.snail_border(2,self.borderColor);
    }
    
}

#pragma mark -

- (void)reload {
    
    [self.caches_ar removeAllObjects];
    [self.coll reloadData];
    
}

- (void)cancleAction {
    [self dismissViewControllerAnimated:true completion:^{
        [self clear];
    }];
}

- (void)doneAction {
    
    [self dismissViewControllerAnimated:true completion:^{
        
        if (self.doneBlock) {
            NSMutableArray *indexs = [NSMutableArray new];
            for (int i = 0; i < self.caches_ar.count; i++) {
                SnailMultipleChooseModel *model = self.caches_ar[i];
                if (model.selected) {
                    [indexs addObject:@(i)];
                }
            }
            self.doneBlock(indexs);
        }
        
        [self clear];
    }];
    
}

- (void)clear {
    
    if (self.doneBlock) self.doneBlock = nil;
    if (self.totalCountBlock) self.totalCountBlock = nil;
    if (self.borderColorBlock) self.borderColorBlock = nil;
    if (self.unSelectTitleColorBlock) self.unSelectTitleColorBlock = nil;
    if (self.selectTitleColorBlock) self.selectTitleColorBlock = nil;
    if (self.unSelectBckgroundColorBlock) self.unSelectBckgroundColorBlock = nil;
    if (self.selectBckgroundColorBlock) self.selectBckgroundColorBlock = nil;
    if (self.titleBlock) self.titleBlock = nil;
    if (self.titleFontBlock) self.titleFontBlock = nil;
    if (self.titleIsSelectedBlock) self.titleIsSelectedBlock = nil;
    self.caches_ar = nil;
    
}

#pragma mark -

- (NSMutableArray<SnailMultipleChooseModel *> *)caches_ar {
    if (!_caches_ar) _caches_ar = [NSMutableArray new];
    return _caches_ar;
}

@end
