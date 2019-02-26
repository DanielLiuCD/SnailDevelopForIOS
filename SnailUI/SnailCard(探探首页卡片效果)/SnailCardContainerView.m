//
//  SnailCardContainerView.m
//  SnailTanTanCard
//
//  Created by JobNewMac1 on 2018/7/18.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailCardContainerView.h"

#pragma mark -

@interface SnailCardShowCellFrameModel : NSObject<NSCopying>

kSPr(CGSize size)
kSPr(CGPoint center)

@end

@implementation SnailCardShowCellFrameModel

- (id)copyWithZone:(NSZone *)zone {
    
    SnailCardShowCellFrameModel *model = [[SnailCardShowCellFrameModel alloc] init];
    model.size = self.size;
    model.center = self.center;
    return model;
    
}

@end

#pragma mark -

@implementation SnailCardContainerDataSource

@end

#pragma mark -

@implementation SnailCardContainerViewDelegate

@end

#pragma mark -

static const CGFloat SnailCardCellTranslate = 10;
static const CGFloat SnailCardContainerAreaWidth = 0.45;
static const CGFloat SnailCardContainerAreaHeight = 0.10;

#pragma mark -

@interface SnailCardContainerView(Ges)<UIGestureRecognizerDelegate>

- (void)tapGesAction:(UITapGestureRecognizer *)tap;
- (void)panGesAction:(UIPanGestureRecognizer *)pan;

- (void)nextCellAnimal;

@end

#pragma mark -

@interface SnailCardContainerView()

kSPrStrong(NSMutableArray<SnailCardShowCell *> *cells)
kSPrStrong(UITapGestureRecognizer *tapGes)
kSPrStrong(UIPanGestureRecognizer *panGes)

kSPr(NSInteger showCount)
kSPr(NSInteger totalCount)
kSPr(CGSize cellSize)

kSPrStrong(NSMutableArray<SnailCardShowCellFrameModel *> *cellFrames)
kSPrStrong(NSLock *lock)

kSPr(CGFloat maxOffset) //拖拽的最大偏移量

kSPr(CGRect leftRect)
kSPr(CGRect rightRect)
kSPr(CGRect topRect)
kSPr(CGRect bottomRect)

kSPr(BOOL havePrepare)

kSPr(BOOL canDragCell)
kSPr(BOOL isAnimaleing)

kSPr(SnailCardContainerAreaType area)

kSPrWeak(SnailCardShowCell *dragCell)

kSPr(NSInteger currentIndex)

@end

@implementation SnailCardContainerView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesAction:)];
        self.panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesAction:)];
        self.panGes.delegate = self;
        [self addGestureRecognizer:self.tapGes];
        [self addGestureRecognizer:self.panGes];
    }
    return self;
}

- (void)layoutSubviews {
    if (self.havePrepare == false) {
        [self reloadData];
        self.havePrepare = true;
    }
}

#pragma mark -

- (void)reloadData {
    
    [self.cells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.cells removeAllObjects];
    
    self.showCount = -1;
    self.totalCount = -1;
    self.cellSize = CGSizeZero;
    self.dragCell = nil;
    self.currentIndex = 0;
    
    CGFloat tmpMaxOffsetX = (self.bounds.size.width - self.cellSize.width) / 2.0;
    CGFloat tmpMaxOffsetY = (self.bounds.size.height - self.cellSize.height) / 2.0;
    self.maxOffset = MIN(tmpMaxOffsetX, tmpMaxOffsetY);
    
    CGFloat areaWidth = self.bounds.size.width * SnailCardContainerAreaWidth;
    CGFloat areaHeight = self.bounds.size.height * SnailCardContainerAreaHeight;
    
    self.leftRect = CGRectMake(0, areaHeight, areaWidth, self.bounds.size.height - areaHeight * 2);
    self.rightRect = CGRectMake(self.bounds.size.width - areaWidth, areaHeight, areaWidth, self.bounds.size.height - areaHeight * 2);
    self.topRect = CGRectMake(0, 0, self.bounds.size.width, areaHeight);
    self.bottomRect = CGRectMake(0, self.bounds.size.height - areaHeight, self.bounds.size.width, areaHeight);
    
    self.area = SnailCardContainerArea_Center;
    
    [self.cellFrames removeAllObjects];
    
    if (self.dataSource == nil) return;
    
    self.showCount = 4;
    self.totalCount = self.dataSource.countBlock();
    self.cellSize = self.dataSource.showCellSizeBlock();
    
//    if (self.totalCount < self.showCount) self.showCount = self.totalCount;
    
    [self.lock lock];
    
    for (NSInteger i = 0; i < self.showCount; i++) {
        SnailCardShowCell *cell = self.dataSource.createShowCellBlock(i);
        [self.cells addObject:cell];
        [self addSubview:cell];
    }
    
    [self.lock unlock];
    
    [self resetCellUIS];
    
    if (self.cells.count > 0) {
        self.dataSource.configureShowCellBlock(self.cells[0], self.currentIndex);
        self.dataSource.configureShowCellBlock(self.cells[1], self.currentIndex+1);
        self.dataSource.showCellBlock(self.cells[0], self.currentIndex);
    }
    
}

- (void)resetCellUIS {
    
    if (self.cells.count == 0) return;
    
    [self.lock lock];
    
    SnailCardShowCell *lastCell = nil;
    CGFloat whs = (self.cellSize.width * 1.0) / self.cellSize.height;
    for (NSInteger i = 0; i < self.cells.count - 1; i++) {
        
        CGFloat width = self.cellSize.width - i * SnailCardCellTranslate * 2;
        CGFloat height = width / whs;
        
        CGFloat x = self.bounds.size.width / 2.0;
        CGFloat y = lastCell?lastCell.center.y:self.bounds.size.height / 2.0;
    
        if (lastCell) y = y + lastCell.frame.size.height - height;
        
        SnailCardShowCell *cell = self.cells[i];
        cell.frame = (CGRect){.origin=CGPointZero,.size=CGSizeMake(width, height)};
        cell.center = CGPointMake(x, y);
        
        [self sendSubviewToBack:cell];
        
        SnailCardShowCellFrameModel *model = [SnailCardShowCellFrameModel new];
        model.size = cell.frame.size;
        model.center = cell.center;
        
        [self.cellFrames addObject:model];
        
        lastCell = cell;
        
    }
    
    SnailCardShowCellFrameModel *lastModel = self.cellFrames.lastObject;
    
    SnailCardShowCell *cell = self.cells.lastObject;
    cell.frame = (CGRect){.origin=CGPointZero,.size=lastModel.size};
    cell.center = lastModel.center;
    [self sendSubviewToBack:cell];
    
    [self.cellFrames addObject:lastModel.copy];
    
    [self.lock unlock];

}

- (void)next {
    
    if (self.isAnimaleing) return;
    
    NSInteger nextIndex = self.currentIndex + 1;
    if (nextIndex >= self.totalCount) return;
    
    self.canDragCell = true;
    self.dragCell = self.cells.firstObject;
    
    [self nextCellAnimal];
    
    
    
}

- (NSInteger)takeCurrentIndex {
    return self.currentIndex;
}

#pragma mark -

- (NSMutableArray<SnailCardShowCell *> *)cells {
    if (!_cells) {
        _cells = [NSMutableArray new];
    }
    return _cells;
}

- (NSMutableArray<SnailCardShowCellFrameModel *> *)cellFrames {
    if (!_cellFrames) _cellFrames = [NSMutableArray new];
    return _cellFrames;
}

- (NSLock *)lock {
    if (!_lock) {
        _lock = [NSLock new];
    }
    return _lock;
}

#pragma mark -

- (void)setArea:(SnailCardContainerAreaType)area {
    if (_area != area) {
        self.delegate.resginAreaBlock(self.dragCell, self.currentIndex, _area);
        _area = area;
        self.delegate.becomeAreaBlock(self.dragCell, self.currentIndex, _area);
    }
}

@end

#pragma mark -

@implementation SnailCardContainerView(Ges)

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return !self.isAnimaleing;
}

- (void)tapGesAction:(UITapGestureRecognizer *)tap {
    
    if (self.delegate) {
        [self.lock lock];
        SnailCardShowCell *cell = self.cells.firstObject;
        self.delegate.didSelectedBlock(cell, self.currentIndex);
        [self.lock unlock];
    }
    
}

- (void)panGesAction:(UIPanGestureRecognizer *)pan {
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [pan locationInView:self];
        SnailCardShowCell *cell = self.cells.firstObject;
        if (CGRectContainsPoint(cell.frame, point)) {
            self.canDragCell = true;
            self.dragCell = cell;
        }
        
    }
    else if (pan.state == UIGestureRecognizerStateEnded) {
        
        if (self.area == SnailCardContainerArea_Center || self.area == SnailCardContainerArea_Top || self.area == SnailCardContainerArea_Bottom) [self resetCellAnimal];
        else if (self.area == SnailCardContainerArea_Right || self.area == SnailCardContainerArea_Left) [self nextCellAnimal];
        
    }
    else {
        
        if (self.canDragCell == false) return;
        
        SnailCardShowCellFrameModel *model = self.cellFrames.firstObject;
        
        CGPoint trans = [pan translationInView:self];
        CGPoint point = CGPointApplyAffineTransform(model.center, CGAffineTransformMakeTranslation(trans.x, trans.y));
        self.dragCell.center = point;
        [self cellAnimales:trans];
     //   point = [pan locationInView:self];
        [self cellActions:point];
        
    }
    
}

- (void)cellAnimales:(CGPoint)point {
    
    CGFloat transOffset = sqrt(pow(point.x, 2) + pow(point.y, 2));
    CGFloat scale = transOffset / self.maxOffset;
    
  //  NSLog(@"scale:%f",scale);
    
    CGFloat whs = (self.cellSize.width * 1.0) / self.cellSize.height;
    
    for (int i = 1; i < self.cells.count - 1; i++) {
        
        SnailCardShowCellFrameModel *lastModel = self.cellFrames[i - 1];
        SnailCardShowCellFrameModel *model = self.cellFrames[i];
        
        CGFloat width = model.size.width + (lastModel.size.width - model.size.width) * scale;
        if (width > lastModel.size.width) width = lastModel.size.width;
        
        CGFloat height = width / whs;
        
        CGFloat y = lastModel.center.y + (lastModel.size.height - height);
        if (y < lastModel.center.y) y = lastModel.center.y;
        
        SnailCardShowCell *cell = self.cells[i];
        cell.frame = (CGRect){.origin=CGPointZero,.size = CGSizeMake(width, height)};
        cell.center = CGPointMake(model.center.x, y);
        
    }
    
}

- (void)cellActions:(CGPoint)point {
    
    if (CGRectContainsPoint(self.leftRect, point)) self.area = SnailCardContainerArea_Left;
    else if (CGRectContainsPoint(self.rightRect, point)) self.area = SnailCardContainerArea_Right;
    else if (CGRectContainsPoint(self.topRect, point)) self.area = SnailCardContainerArea_Top;
    else if (CGRectContainsPoint(self.bottomRect, point)) self.area = SnailCardContainerArea_Bottom;
    else self.area = SnailCardContainerArea_Center;
    
}

- (void)resetCellAnimal {
    
    [self.lock lock];
    self.isAnimaleing = true;
    [self.lock unlock];
    
    [UIView animateWithDuration:0.5 delay:0.01 usingSpringWithDamping:0.7 initialSpringVelocity:2 options:UIViewAnimationOptionCurveLinear animations:^{
        SnailCardShowCellFrameModel *model = self.cellFrames.firstObject;
        self.dragCell.center = model.center;
        [self cellAnimales:CGPointZero];
    } completion:^(BOOL finished) {
        self.area = SnailCardContainerArea_Center;
        self.canDragCell = false;
        self.dragCell = nil;
        [self.lock lock];
        self.isAnimaleing = false;
        [self.lock unlock];
    }];
    
}

- (void)nextCellAnimal {
    
    NSInteger nextIndex = self.currentIndex + 1;
    if (nextIndex >= self.totalCount) {
        [self resetCellAnimal];
        return;
    }
    
    [self.lock lock];
    self.isAnimaleing = true;
    [self.lock unlock];
    
    SnailCardShowCellFrameModel *model = self.cellFrames.firstObject;
    
    CGFloat y = 0;
    if (self.dragCell.center.y > model.center.y) y =  - CGRectGetMinY(self.dragCell.frame) + 20;
    else y = self.bounds.size.height - CGRectGetMaxY(self.dragCell.frame) - 20;
    
    CGFloat x = 0;
    if (self.dragCell.center.x < model.center.x) x = -CGRectGetMaxX(self.dragCell.frame);
    else x = self.bounds.size.width - CGRectGetMinX(self.dragCell.frame);
    
    CGAffineTransform transTransform = CGAffineTransformMakeTranslation(x, y);
    CGAffineTransform routeForm = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2 / 2.0);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.dragCell.transform = CGAffineTransformConcat(transTransform, routeForm);
        self.dragCell.alpha = 0;
    } completion:^(BOOL finished) {
        self.canDragCell = false;
    }];
    
    [UIView animateWithDuration:0.5 delay:0.01 usingSpringWithDamping:0.7 initialSpringVelocity:2 options:UIViewAnimationOptionCurveLinear animations:^{
        
        for (NSInteger i = 1; i < self.cells.count; i++) {
            SnailCardShowCellFrameModel *model = self.cellFrames[i-1];
            SnailCardShowCell *cell = self.cells[i];
            cell.frame = (CGRect){.origin=CGPointZero,.size = model.size};
            cell.center = model.center;
        }
        
    } completion:^(BOOL finished) {
        
        self.delegate.didAreaBlock(self.dragCell, self.currentIndex, self.area);
        self.area = SnailCardContainerArea_Center;
        self.currentIndex = nextIndex;
        
        [self.lock lock];
        
        SnailCardShowCell *one = self.cells[0];
        [self.cells removeObjectAtIndex:0];
        [self.cells addObject:one];
        
        self.dataSource.showCellBlock(self.cells[0], self.currentIndex);
        
        self.dataSource.configureShowCellBlock(self.cells[1], self.currentIndex+1);
        
        SnailCardShowCellFrameModel *model = self.cellFrames.lastObject;
        
        self.dragCell.transform = CGAffineTransformIdentity;
        self.dragCell.frame = (CGRect){.origin=CGPointZero,.size = model.size};
        self.dragCell.center = model.center;
        self.dragCell.alpha = 1;
        [self sendSubviewToBack:self.dragCell];
        self.dragCell = nil;
        
        self.isAnimaleing = false;
        
        [self.lock unlock];
    
    }];
    
}

@end
