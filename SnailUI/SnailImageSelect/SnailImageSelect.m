//
//  SnailImageSelected.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/21.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailImageSelect.h"

@interface SnailImageSelectModel()

@property (nonatomic ,strong) UIImage *image;
@property (nonatomic ,strong) NSString *imageName;
@property (nonatomic ,strong) NSString *imagePath;
@property (nonatomic ,strong) NSString *imageUrl;

@end

@implementation SnailImageSelectModel

+ (instancetype)Image:(UIImage *)image Name:(NSString *)name {
    return [self Image:image Name:name Path:nil Url:nil];
}

+ (instancetype)Image:(UIImage *)image Name:(NSString *)name Path:(NSString *)path {
    return [self Image:image Name:name Path:path Url:nil];
}

+ (instancetype)Image:(UIImage *)image Name:(NSString *)name Url:(NSString *)url {
    return [self Image:image Name:name Path:nil Url:url];
}

+ (instancetype)Image:(UIImage *)image Name:(NSString *)name Path:(NSString *)path Url:(NSString *)url {
    SnailImageSelectModel *model = [SnailImageSelectModel new];
    model.image = image;
    model.imageName = name;
    model.imagePath = path;
    model.imageUrl = url;
    return model;
}

@end

#define ANGLE_TO_RADIAN(angle) ((angle)/180.0 * M_PI)

@class SnailImageSelectCell;

@protocol SnailImageSelectCellProtocol<NSObject>

- (void)SnailImageSelectCellDeAction:(SnailImageSelectCell *)cell;

@end

@interface SnailImageSelectCell : UICollectionViewCell

@property (nonatomic ,strong) UIImageView *bc;
@property (nonatomic ,strong) UIButton *de;

@property (nonatomic ,weak) id<SnailImageSelectCellProtocol> protocol;

@end

@implementation SnailImageSelectCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bc = [UIImageView new];
        self.de = [UIButton new];
        [self.de setImage:[UIImage imageNamed:@"SnailImageSelectedDeleteIcon"] forState:UIControlStateNormal];
        [self.de addTarget:self action:@selector(deAction) forControlEvents:UIControlEventTouchUpInside];
        self.de.hidden = true;
        [self.contentView addSubview:self.bc];
        [self.contentView addSubview:self.de];
        [self.bc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [self.de mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView).offset(5);
            make.top.equalTo(self.contentView).offset(-5);
            make.width.height.equalTo(@16);
        }];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.de.hidden && CGRectContainsPoint(self.de.frame, point)) {
        return self.de;
    }
    return [super hitTest:point withEvent:event];
}

- (void)deAction {
    [self.protocol SnailImageSelectCellDeAction:self];
}

- (void)startShake {
    CAKeyframeAnimation *keyA = [CAKeyframeAnimation animation];
    keyA.keyPath = @"transform.rotation";
    keyA.values = @[@(ANGLE_TO_RADIAN(-2)),@(ANGLE_TO_RADIAN(0)),@(ANGLE_TO_RADIAN(2)),@(ANGLE_TO_RADIAN(-2))];
    keyA.duration = .25f;
    keyA.removedOnCompletion = true;
    keyA.repeatCount = CGFLOAT_MAX;
    [self.layer addAnimation:keyA forKey:@"shake"];
    self.de.hidden = false;
}

- (void)stopShake {
    [self.layer removeAnimationForKey:@"shake"];
    self.de.hidden = true;;
}

@end

@interface SnailImageSelect()<UICollectionViewDelegate,UICollectionViewDataSource,SnailImageSelectCellProtocol>

@property (nonatomic ,strong) UICollectionView *coll;

@property (nonatomic ,strong) UILongPressGestureRecognizer *longGes;
@property (nonatomic) BOOL isShakeAnimale;
@property (nonatomic ,weak) UICollectionViewCell *panCell;
@property (nonatomic ,weak) UICollectionViewCell *panLastCell;

@property (nonatomic) SnailImageSelectStyle style;
@property (nonatomic) NSInteger maxNum;
@property (nonatomic) CGSize itemSize;
@property (nonatomic ,strong) UIImage *icon;
@property (nonatomic) CGFloat lineSpace;
@property (nonatomic) CGFloat interSpace;

@property (nonatomic ,strong) NSMutableArray *datas;

@end

@implementation SnailImageSelect

+ (instancetype)Style:(SnailImageSelectStyle)style MaxNum:(NSInteger)maxNum ItemSize:(CGSize)itemSize Icon:(UIImage *)icon{
    SnailImageSelect *vi = [SnailImageSelect new];
    vi.style = style;
    vi.maxNum = maxNum;
    vi.itemSize = itemSize;
    vi.icon = icon;
    vi.lineSpace = 10;
    vi.interSpace = 10;
    [vi _createUI];
    return vi;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesAction)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotify) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundNotify) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)enterForegroundNotify {
    [self changeAnimale];
}

- (void)enterBackgroundNotify {
    if (self.isShakeAnimale) {
        [CATransaction begin];
        NSArray *tmps = [self.coll visibleCells];
        for (SnailImageSelectCell *cell in tmps) {
            NSIndexPath *tmpPath = [self.coll indexPathForCell:cell];
            if (tmpPath.row != self.datas.count) {
                [cell stopShake];
            }
        }
        [CATransaction commit];
    }
}

- (void)_createUI {
    
    UICollectionViewFlowLayout *flow = [UICollectionViewFlowLayout new];
    flow.scrollDirection = self.style == SnailImageSelect_H?UICollectionViewScrollDirectionHorizontal:UICollectionViewScrollDirectionVertical;
    flow.itemSize = self.itemSize;
    flow.minimumLineSpacing = self.lineSpace;
    flow.minimumInteritemSpacing = self.interSpace;
    flow.sectionInset = UIEdgeInsetsMake(8, 0, 0, 0);
    
    self.coll = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    self.coll.backgroundColor = [UIColor clearColor];
    self.coll.delegate = self;
    self.coll.dataSource = self;
    [self.coll registerClass:[SnailImageSelectCell class] forCellWithReuseIdentifier:@"c"];
    [self.coll addGestureRecognizer:self.longGes];
    [self addSubview:self.coll];
    
    [self.coll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.leading.equalTo(self);
        make.top.bottom.equalTo(self);
        make.height.equalTo(@([self _calHeight]));
    }];
    
}

- (CGFloat)_calHeight {
    
    CGFloat hegiht = 0;
    
    switch (self.style) {
        case SnailImageSelect_H:
            hegiht = ceil(self.itemSize.height) + 10;
            break;
         case SnailImageSelect_V:
            {
                NSInteger row = [self _calRow];
                hegiht = ceil((row - 1) * self.lineSpace + row * self.itemSize.height) + 10;
            }
            break;
        default:
            break;
    }
    
    return hegiht;
    
}

- (NSInteger)_calRow {
    
    CGFloat x = 0.0;
    NSInteger count = [self _showCount];
    CGFloat maxWidth = self.bounds.size.width;
    NSInteger row = maxWidth == 0?0:1;
    
    for (int i = 0; i < count; i++) {
        
        CGFloat nextX = 0;
        if (i != count - 1) nextX = x + self.itemSize.width + self.lineSpace;
        else nextX = x + self.itemSize.width;
        
        if (nextX > maxWidth) {
            x = 0.0;
            row++;
        }
        else x += (self.itemSize.width + self.lineSpace);
        
    }
    
    return row;
    
}

- (NSInteger)_showCount {
    NSInteger count = self.datas.count;
    if (count != self.maxNum) count++;
    return count;
}

- (void)appendImages:(NSArray<SnailImageSelectModel *> *)images {
    [self appendImages:images Animale:false];
}

- (void)appendImages:(NSArray<SnailImageSelectModel *> *)images Animale:(BOOL)animale {
    
    NSInteger datasCount = self.datas.count;
    
    if (datasCount + images.count > self.maxNum) {
        NSArray *tmps = [images subarrayWithRange:NSMakeRange(0, self.maxNum - datasCount)];
        images = tmps;
    }
    
    [self.datas addObjectsFromArray:images];
    [self refeshUI];
    if (animale) {
        
        NSMutableArray *appends = [NSMutableArray new];
        NSMutableArray *reloads = [NSMutableArray new];
        for (int i = 0; i < images.count; i++) {
            NSInteger index = datasCount + i;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            if (index == self.maxNum - 1) [reloads addObject:indexPath];
            else [appends addObject:indexPath];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (reloads.count > 0) [self.coll reloadItemsAtIndexPaths:reloads];
            if (appends.count > 0) [self.coll insertItemsAtIndexPaths:appends];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.coll reloadData];
        });
    }
}

- (void)replaceAtIndex:(NSInteger)index Model:(SnailImageSelectModel *)model {
    [self replaceAtIndex:index Model:model Animale:false];
}

- (void)replaceAtIndex:(NSInteger)index Model:(SnailImageSelectModel *)model Animale:(BOOL)animale {
    @synchronized(self) {
        if (index < self.datas.count) {
            self.datas[index] = model;
        }
        if (animale) [self.coll reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
        else [self.coll reloadData];
    }
}

- (void)deleteAtIndex:(NSInteger)index {
    [self deleteAtIndex:index Animale:false];
}

- (void)deleteAtIndex:(NSInteger)index Animale:(BOOL)animale {
    
    NSInteger datasCount = self.datas.count;
    [self.datas removeObjectAtIndex:index];
    [self refeshUI];
    
    if (animale) {
        NSMutableArray *deletes = [NSMutableArray new];
        NSMutableArray *reloads = [NSMutableArray new];
        if (datasCount == self.maxNum) {
            for (NSInteger i = index; i < datasCount; i++) {
                [reloads addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        else {
            [deletes addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (deletes.count > 0) [self.coll deleteItemsAtIndexPaths:deletes];
            if (reloads.count > 0) [self.coll reloadItemsAtIndexPaths:reloads];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.coll reloadData];
        });
    }
    
}

- (NSArray<SnailImageSelectModel *> *)takeSelectedImages {
    return self.datas;
}

- (void)refeshUI {
    if (self.style == SnailImageSelect_V) {
        
        CGFloat height = [self _calHeight];
    
        [self.coll mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(height));
        }];
        if (height != self.bounds.size.height) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.heightChangeBlock) self.heightChangeBlock(height);
            });
        }
        
    }
}

- (void)longGesAction {
    
    if (self.datas.count == 0) return;
    
    CGPoint point = [self.longGes locationInView:self.coll];
    
    switch (self.longGes.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *indexPath = [self.coll indexPathForItemAtPoint:point];
            if (indexPath && indexPath.row != self.datas.count) self.isShakeAnimale = true;
            else self.isShakeAnimale = false;
            [self changeAnimale];
            if (self.isShakeAnimale) {
                [self.coll beginInteractiveMovementForItemAtIndexPath:indexPath];
                self.panCell = [self.coll cellForItemAtIndexPath:indexPath];
                if (self.datas.count < self.maxNum) {
                    self.panLastCell = [self.coll cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.datas.count inSection:0]];
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGRect panFrame = self.panCell.frame;
            CGRect panLastFrame =  CGRectMake(self.panLastCell.frame.origin.x, self.panLastCell.frame.origin.y, self.bounds.size.width - self.panLastCell.frame.origin.x, self.panLastCell.frame.size.height);
            if ( self.style == SnailImageSelect_V && self.bounds.size.height > self.itemSize.height + 10) {
                panLastFrame = self.panLastCell.frame;
            }
            
            CGRect tmp = CGRectMake(point.x - panFrame.size.width * .5, point.y - panFrame.size.height * .5, panFrame.size.width, panFrame.size.height);
            
            if (tmp.origin.x < 0) {
                point.x = panFrame.size.width * .5;
                tmp.origin.x = 0;
            }
            if (CGRectGetMaxX(tmp) > CGRectGetMaxX(self.bounds)) {
                point.x = CGRectGetMaxX(self.bounds) - panFrame.size.width * .5;
                tmp.origin.x = CGRectGetMaxX(self.bounds) - panFrame.size.width;
            }
            
            if (tmp.origin.y < 10) {
                point.y = panFrame.size.height * .5 + 10;
                tmp.origin.y = 10;
            }
            if (CGRectGetMaxY(tmp) > CGRectGetMaxY(self.bounds)) {
                point.y = CGRectGetMaxY(self.bounds) - panFrame.size.height * .5;
                tmp.origin.y = CGRectGetMaxY(self.bounds) - panFrame.size.height;
            }
            
            if (!(self.panLastCell && CGRectIntersectsRect(tmp, panLastFrame))) {
                [self.coll updateInteractiveMovementTargetPosition:point];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.coll endInteractiveMovement];
            self.panCell = nil;
            self.panLastCell = nil;
        }
            break;
        default:
        {
            [self.coll cancelInteractiveMovement];
            self.panCell = nil;
            self.panLastCell = nil;
        }
            break;
    }
    
}

- (void)changeAnimale {
    [CATransaction begin];
    NSArray *tmps = [self.coll visibleCells];
    for (SnailImageSelectCell *cell in tmps) {
        NSIndexPath *tmpPath = [self.coll indexPathForCell:cell];
        if (tmpPath.row != self.datas.count) {
            if (self.isShakeAnimale) [cell startShake];
            else [cell stopShake];
        }
    }
    [CATransaction commit];
}

- (void)SnailImageSelectCellDeAction:(SnailImageSelectCell *)cell {
    NSIndexPath *indexPath = [self.coll indexPathForCell:cell];
    if (self.deleteAction) {
        SnailImageSelectModel *model = self.datas[indexPath.row];
        self.deleteAction(indexPath.row, model);
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self _showCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SnailImageSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"c" forIndexPath:indexPath];
    
    if (indexPath.row < self.datas.count) {
        
        SnailImageSelectModel *model = self.datas[indexPath.row];
        
        if (model.image) cell.bc.image = model.image;
        else if (model.imagePath) cell.bc.image = [UIImage imageWithContentsOfFile:model.imagePath];
        else if (model.imageUrl && self.configureImageBlock) self.configureImageBlock(cell.bc, model.imageUrl);
        
        cell.protocol = self;
        if (self.isShakeAnimale) [cell startShake];
        else [cell stopShake];
        
    }
    else {
        cell.bc.image = self.icon;
        cell.protocol = nil;
        [cell stopShake];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isShakeAnimale) {
        self.isShakeAnimale = false;
        [self changeAnimale];
    }

    if (indexPath.row < self.datas.count) {
        SnailImageSelectModel *model = self.datas[indexPath.row];
        if (self.clickAction) self.clickAction(indexPath.row, model);
    }
    else if (self.selectAction) self.selectAction();
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row < self.datas.count;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    SnailImageSelectModel *model = self.datas[sourceIndexPath.row];
    [self.datas removeObjectAtIndex:sourceIndexPath.row];
    [self.datas insertObject:model atIndex:destinationIndexPath.row];
}

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

@end
