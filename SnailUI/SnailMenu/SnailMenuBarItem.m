//
//  SnailMenuBarItem.m
//  SnailMenu
//
//  Created by JobNewMac1 on 2018/10/24.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailMenuBarItem.h"
#import <objc/runtime.h>

#define SNAILMENUBARITEM_PROTECTED_ACCESS

#import "SnailMenuBarItem+Private.h"

#define SnailMenuBarItemDefaultTitle @"Item"

#define SnaimMenuTextIsTintColorKey @"SnaimMenuTextIsTintColorKey"

@interface SnailMenuBarItem()

@property (nonatomic) CGFloat spaceing;

@property (nonatomic) SnailMenuBarItemState state;
@property (nonatomic ,weak) UIViewController *viewController;

@property (nonatomic ,strong) NSMutableDictionary<NSNumber *,NSValue *> *cacheSize;
@property (nonatomic ,strong) NSMutableDictionary<NSNumber *,NSValue *> *cacheBadgeSize;

@property (nonatomic ,strong) NSMutableDictionary<NSNumber *,NSDictionary *> *cacheAttributes;
@property (nonatomic ,strong) NSMutableDictionary<NSNumber *,NSDictionary *> *cacheBadgeAttributes;

@end

@implementation SnailMenuBarItem
{
    CGAffineTransform _affineTransform;
    CGAffineTransform _selectedAffineTransform;
}

@dynamic affineTransform,selectedAffineTransform;

- (instancetype)init {
    return [self initWithTitle:nil Image:nil SelectedTitle:nil SelectedImage:nil];
}

- (instancetype)initWithTitle:(NSString *)title Image:(UIImage *)image {
    return [self initWithTitle:title Image:image SelectedTitle:nil SelectedImage:nil];
}

- (instancetype)initWithTitle:(NSString *)title Image:(UIImage *)image SelectedTitle:(NSString *)selectedTitle SelectedImage:(UIImage *)selectedImage {
    self = [super init];
    if (self) {
        _spaceing = 8.0;
        _tintColor = [UIColor blueColor];
        self.title = title;
        self.image = image;
        self.selectedTitle = selectedTitle;
        self.selectedImage = selectedImage;
        _affineTransform = CGAffineTransformIdentity;
        _selectedAffineTransform = CGAffineTransformIdentity;
    }
    return self;
}

- (void)_sendContentChangeMessage {
    if ([self.bar conformsToProtocol:@protocol(SnailMenuBarItemProtocol)]) {
        id<SnailMenuBarItemProtocol> pro = (id<SnailMenuBarItemProtocol>)self.bar;
        [pro SnailMenuBarItemUpdateContent:self];
    }
}

- (void)_sendBadgeChangeMessage {
    if ([self.bar conformsToProtocol:@protocol(SnailMenuBarItemProtocol)]) {
        id<SnailMenuBarItemProtocol> pro = (id<SnailMenuBarItemProtocol>)self.bar;
        [pro SnailMenuBarItemUpdateBadge:self];
    }
}

- (void)setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes forState:(SnailMenuBarItemState)state {
    [self _setTitleTextAttributes:attributes forState:state];
    [self _clearSize:state];
    [self _sendContentChangeMessage];
}

- (void)_setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes forState:(SnailMenuBarItemState)state {
    self.cacheAttributes[@(state)] = attributes;
}

- (NSDictionary<NSString *,id> *)titleTextAttributesForState:(SnailMenuBarItemState)state {
    NSDictionary *dic = self.cacheAttributes[@(state)];
    if (!dic) {
        dic = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:self.tintColor,SnaimMenuTextIsTintColorKey:@1};
        [self _setTitleTextAttributes:dic forState:state];
    }
    else if (!dic[NSForegroundColorAttributeName]) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:dic];
        tmp[NSForegroundColorAttributeName] = self.tintColor;
        tmp[SnaimMenuTextIsTintColorKey] = @1;
        dic = tmp.copy;
        [self _setTitleTextAttributes:dic forState:state];
    }
    return dic;
}

- (void)setBadgeTextAttributes:(NSDictionary<NSString *,id> *)badgeAttributes forState:(SnailMenuBarItemState)state {
    [self _setBadgeTextAttributes:badgeAttributes forState:state];
    [self _clearBadgeSize:state];
    [self _sendBadgeChangeMessage];
}

- (void)_setBadgeTextAttributes:(NSDictionary<NSString *,id> *)badgeAttributes forState:(SnailMenuBarItemState)state {
    self.cacheBadgeAttributes[@(state)] = badgeAttributes;
}

- (NSDictionary<NSString *,id> *)badgeTextAttributesForState:(SnailMenuBarItemState)state {
    NSDictionary *dic = self.cacheBadgeAttributes[@(state)];
    if (!dic) {
        dic = @{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor whiteColor]};
        [self _setBadgeTextAttributes:dic forState:state];
    }
    return dic;
}

- (void)_refeshTintColor {
    BOOL needUpdate = false;
    NSDictionary *tmpcache = self.cacheAttributes.copy;
    for (id key in tmpcache) {
        NSDictionary *dic = tmpcache[key];
        if ([dic[SnaimMenuTextIsTintColorKey] boolValue]) {
            NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:dic];
            tmp[NSForegroundColorAttributeName] = self.tintColor;
            [self _setTitleTextAttributes:tmp.copy forState:[key charValue]];
            needUpdate = true;
        }
    }
    if (needUpdate) [self _sendContentChangeMessage];
}

#pragma mark -

- (void)setTitle:(NSString *)title {
    if (!title) title = SnailMenuBarItemDefaultTitle;
    if (![_title isEqualToString:title]) {
        _title = title;
        [self _clearSize:SnailMenuBarItemStateNormal];
        if (!self._sna_have_selected_status) [self _clearSize:SnailMenuBarItemStateSelected];
        [self size:SnailMenuBarItemStateNormal];
        if (self.state == SnailMenuBarItemStateNormal) [self _sendContentChangeMessage];
    }
}

- (void)setSelectedTitle:(NSString *)selectedTitle {
    if (![_selectedTitle isEqualToString:selectedTitle]) {
        _selectedTitle = selectedTitle;
        [self _clearSize:SnailMenuBarItemStateSelected];
        [self size:SnailMenuBarItemStateSelected];
        if (self.state == SnailMenuBarItemStateSelected) [self _sendContentChangeMessage];
    }
}

- (void)setImage:(UIImage *)image {
    if (![_image isEqual:image]) {
        _image = image;
        [self _clearSize:SnailMenuBarItemStateNormal];
        [self size:SnailMenuBarItemStateNormal];
        if (self.state == SnailMenuBarItemStateNormal) [self _sendContentChangeMessage];
    }
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    if (![_selectedImage isEqual:selectedImage]) {
        _selectedImage = selectedImage;
        [self _clearSize:SnailMenuBarItemStateSelected];
        [self size:SnailMenuBarItemStateSelected];
        if (self.state == SnailMenuBarItemStateSelected) [self _sendContentChangeMessage];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    if (![_tintColor isEqual:tintColor]) {
        _tintColor = tintColor;
        [self _refeshTintColor];
    }
}

- (void)setAffineTransform:(CGAffineTransform)affineTransform {
    @synchronized(self) {
        if (!CGAffineTransformEqualToTransform(affineTransform, _affineTransform)) {
            _affineTransform = affineTransform;
            [self _clearSize:SnailMenuBarItemStateNormal];
            [self size:SnailMenuBarItemStateNormal];
            if (self.state == SnailMenuBarItemStateNormal) [self _sendContentChangeMessage];
        }
    }
}

- (void)setSelectedAffineTransform:(CGAffineTransform)selectedAffineTransform {
    @synchronized(self) {
        if (!CGAffineTransformEqualToTransform(selectedAffineTransform, _selectedAffineTransform)) {
            _selectedAffineTransform = selectedAffineTransform;
            [self _clearSize:SnailMenuBarItemStateSelected];
            [self size:SnailMenuBarItemStateSelected];
            if (self.state == SnailMenuBarItemStateSelected) [self _sendContentChangeMessage];
        }
    }
}

- (CGAffineTransform)affineTransform {
    @synchronized(self) {
        return _affineTransform;
    }
}

- (CGAffineTransform)selectedAffineTransform {
    @synchronized(self) {
        return _selectedAffineTransform;
    }
}

- (void)setBadgeValue:(NSString *)badgeValue {
    if (![badgeValue isEqualToString:_badgeValue]) {
        _badgeValue = badgeValue;
        [self _clearBadgeSize:SnailMenuBarItemStateNormal];
        [self _clearBadgeSize:SnailMenuBarItemStateSelected];
        [self badgeSize:SnailMenuBarItemStateNormal];
        [self badgeSize:SnailMenuBarItemStateSelected];
        [self _sendBadgeChangeMessage];
    }
}

- (NSMutableDictionary<NSNumber *,NSValue *> *)cacheSize {
    if (!_cacheSize) _cacheSize = [NSMutableDictionary new];
    return _cacheSize;
}

- (NSMutableDictionary<NSNumber *,NSValue *> *)cacheBadgeSize {
    if (!_cacheBadgeSize) _cacheBadgeSize = [NSMutableDictionary new];
    return _cacheBadgeSize;
}

- (NSMutableDictionary<NSNumber *,NSDictionary *> *)cacheAttributes {
    if (!_cacheAttributes) _cacheAttributes = [NSMutableDictionary new];
    return _cacheAttributes;
}

- (NSMutableDictionary<NSNumber *,NSDictionary *> *)cacheBadgeAttributes {
    if (!_cacheBadgeAttributes) _cacheBadgeAttributes = [NSMutableDictionary new];
    return _cacheBadgeAttributes;
}

#pragma mark -

- (UIView *)view {
    return objc_getAssociatedObject(self, @selector(view));
}

- (UIView *)bar {
    return objc_getAssociatedObject(self, @selector(bar));
}

#pragma mark -

- (BOOL)_sna_have_selected_status {
    return self.selectedTitle && self.selectedImage;
}

#pragma mark - private

- (CGSize)_caleTextSize:(SnailMenuBarItemState)state {
    
    CGSize textSize = CGSizeZero;
    NSDictionary *textAttribute = [self titleTextAttributesForState:state];
    UIFont *textAttributeFont = textAttribute[NSFontAttributeName];
    if (!textAttributeFont) textAttributeFont = [UIFont systemFontOfSize:15];
    
    NSString *str = nil;
    
    switch (state) {
        case SnailMenuBarItemStateNormal:str = self.title;
            break;
        case SnailMenuBarItemStateSelected:str = self.selectedTitle?:self.title;
            break;
    }
    
    textSize = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, textAttributeFont.lineHeight) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:textAttribute context:nil].size;
    
    return CGSizeMake(textSize.width, textSize.height);
}

- (CGSize)_caleImageSize:(SnailMenuBarItemState)state {
    
    CGSize imageSize = CGSizeZero;
    switch (state) {
        case SnailMenuBarItemStateNormal:imageSize = self.image.size;
            break;
        case SnailMenuBarItemStateSelected:imageSize = self.selectedImage?self.selectedImage.size:self.image.size;
            break;
    }
    return imageSize;
    
}

- (CGSize)_caleBadgeSize:(SnailMenuBarItemState)state {
    
    CGSize badgeSize = CGSizeZero;
    NSDictionary *badgeAttribute = [self badgeTextAttributesForState:state];
    UIFont *badgeAttributeFont = badgeAttribute[NSFontAttributeName];
    if (!badgeAttributeFont) badgeAttributeFont = [UIFont systemFontOfSize:10];
    
    NSString *str = self.badgeValue;
    badgeSize = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, badgeAttributeFont.lineHeight) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:badgeAttribute context:nil].size;
    
    if (badgeSize.width < badgeSize.height) badgeSize.width = badgeSize.height;
    
    return badgeSize;
    
}

- (CGSize)_caleSize:(SnailMenuBarItemState)state {

    CGSize size = CGSizeZero;
    CGSize textSize = [self _caleTextSize:state];
    CGSize imageSize = [self _caleImageSize:state];
    
    CGFloat width = imageSize.width + textSize.width;
    if (imageSize.width > 0) width += self.spaceing;
    
    size = CGSizeMake(ceil(width), ceil(MAX(imageSize.height, textSize.height)));
    
    CGAffineTransform transorm = CGAffineTransformIdentity;
    if (state == SnailMenuBarItemStateNormal) transorm = self.affineTransform;
    else if (state == SnailMenuBarItemStateSelected) transorm = self.selectedAffineTransform;
    
    if (!CGAffineTransformEqualToTransform(transorm, CGAffineTransformIdentity)) {
        CGSize size0 = CGSizeApplyAffineTransform(size, transorm);
        size = CGSizeMake(ceil(size0.width), ceil(size0.height));
    };
    
    return size;
    
}

- (void)_clearSize:(SnailMenuBarItemState)state {
    self.cacheSize[@(state)] = nil;
}

- (void)_clearBadgeSize:(SnailMenuBarItemState)state {
    self.cacheBadgeSize[@(state)] = nil;
}

#pragma mark -

- (void)setState:(SnailMenuBarItemState)state {
    _state = state;
}

- (void)setViewController:(UIViewController *)viewController {
    _viewController = viewController;
}

#pragma mark -

- (UIImage *)showImage {
    switch (self.state) {
        case SnailMenuBarItemStateNormal:
            return self.image;
        case SnailMenuBarItemStateSelected:
            return self.selectedImage;
    }
}

- (NSAttributedString *)showTitle {
    NSDictionary *dic = [self titleTextAttributesForState:self.state];
    NSString *str;
    if (self.state == SnailMenuBarItemStateNormal) str = self.title;
    else if (self.state == SnailMenuBarItemStateSelected) str = self.selectedTitle?:self.title;
    return [[NSAttributedString alloc] initWithString:str attributes:dic];
}

- (CGSize)size {
    return [self size:self.state];
}

- (CGSize)size:(SnailMenuBarItemState)state {
    NSValue *value = self.cacheSize[@(state)];
    if (!value) {
        CGSize size = [self _caleSize:state];
        value = [NSValue valueWithCGSize:size];
        self.cacheSize[@(state)] = value;
        return size;
    }
    return [value CGSizeValue];
}

- (BOOL)isEqualSize {
    CGSize normal = [self size:SnailMenuBarItemStateNormal];
    CGSize selected = [self size:SnailMenuBarItemStateSelected];
    return CGSizeEqualToSize(normal, selected);
}

- (CGSize)badgeSize {
    return [self badgeSize:self.state];
}

- (CGSize)badgeSize:(SnailMenuBarItemState)state {
    if (!self.badgeValue) return CGSizeZero;
    NSValue *value = self.cacheBadgeSize[@(state)];
    if (!value) {
        CGSize size = [self _caleBadgeSize:state];
        value = [NSValue valueWithCGSize:size];
        self.cacheBadgeSize[@(state)] = value;
        return size;
    }
    return [value CGSizeValue];
}

- (NSAttributedString *)showBadge {
    if (!self.badgeValue) return nil;
    NSDictionary *dic = [self badgeTextAttributesForState:self.state];
    return [[NSAttributedString alloc] initWithString:self.badgeValue attributes:dic];
}

@end
