//
//  SnailPhotoFlowLayout.m
//  lesan
//
//  Created by liu on 2018/7/22.
//  Copyright © 2018年 ning. All rights reserved.
//

#import "SnailPhotoFlowLayout.h"

@interface SnailPhotoFlowLayout()

kSPr(NSInteger totalCount)
kSPr(CGFloat contentWidth)
kSPr(CGFloat spaceing)
kSPr(CGFloat itemWidth)
kSPr(CGFloat leading)
kSPr(CGFloat miniScale)

@end

@implementation SnailPhotoFlowLayout

- (void)prepareLayout {
    
    [super prepareLayout];
    
    self.itemWidth = self.collectionView.bounds.size.width * 0.75;
    
    self.spaceing = 0;
    
    self.leading = (self.collectionView.bounds.size.width - self.itemWidth) * 0.5;
    
    self.miniScale = (self.itemWidth - 40.0) / self.itemWidth;
    
    self.totalCount = [self.collectionView numberOfItemsInSection:0];
    
    self.contentWidth = self.totalCount * self.itemWidth + (self.totalCount - 1) * self.spaceing + self.leading * 2;
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return true;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.contentWidth, self.collectionView.bounds.size.height);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSInteger startIndex = floor(rect.origin.x / self.itemWidth);
    if (startIndex < 0) startIndex = 0;
    NSInteger endIndex = ceil(CGRectGetMaxX(rect) / self.itemWidth);
    if (endIndex > self.totalCount - 1) endIndex = self.totalCount - 1;
    
    NSMutableArray *temps = [NSMutableArray new];
    for (NSInteger i = startIndex; i <= endIndex; i++) {
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [temps addObject:attr];
    }
    
    return temps;
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat x = indexPath.row * self.itemWidth + indexPath.row * self.spaceing + self.leading;
    
    CGFloat visiableMidX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width * 0.5;
    
    CGFloat centerX = x + self.itemWidth * 0.5;
    
    CGFloat offset = centerX - visiableMidX;
    
    CGFloat maxOffset = self.itemWidth + self.spaceing;
    
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attr.frame = CGRectMake(x, 0, self.itemWidth, self.collectionView.bounds.size.height);
    
    CGFloat scale = 1 - fabs(offset / maxOffset) * (40 / self.itemWidth);
    if (scale < self.miniScale) scale = self.miniScale;
    
    attr.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    
    return attr;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    CGRect contentFrame;
    contentFrame.size = self.collectionView.frame.size;
    contentFrame.origin = proposedContentOffset;
    
    NSArray *array = [self layoutAttributesForElementsInRect:contentFrame];
    
    CGFloat minCenterX = CGFLOAT_MAX;
    CGFloat collectionViewCenterX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if(ABS(attrs.center.x - collectionViewCenterX) < ABS(minCenterX)){
            minCenterX = attrs.center.x - collectionViewCenterX;
        }
    }
    
    return CGPointMake(proposedContentOffset.x + minCenterX, proposedContentOffset.y);

}

@end
