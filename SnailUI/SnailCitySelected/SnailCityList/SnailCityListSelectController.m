//
//  SnailCityListSelectController.m
//  FishNation
//
//  Created by JobNewMac1 on 2018/10/9.
//  Copyright © 2018年 MT. All rights reserved.
//

#import "SnailCityListSelectController.h"
#import "SnailCoreLocationManager.h"
#import "SnailTableviewIndexView.h"

#pragma mark -

#define SnailCityListDefaultFont [UIFont systemFontOfSize:15]
#define SnailCityListDefaultNameColor [UIColor blackColor]
#define SnailCityListDefaultHeaderBackgroundColor [UIColor groupTableViewBackgroundColor]
#define SnailCityListDefaultColor [UIColor whiteColor]

#pragma mark -

@interface SnailCityListCityItem : NSObject<SnailCityListItemProtocol,NSSecureCoding>

@end

@implementation SnailCityListCityItem

@synthesize snailCityListName,coor;

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.snailCityListName forKey:@"snailCityListName"];
    [aCoder encodeObject:@(self.coor.longitude) forKey:@"snaillongitude"];
    [aCoder encodeObject:@(self.coor.latitude) forKey:@"snaillatitude"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.snailCityListName = [aDecoder decodeObjectForKey:@"snailCityListName"];
        self.coor = CLLocationCoordinate2DMake([[aDecoder decodeObjectForKey:@"snaillatitude"] doubleValue], [[aDecoder decodeObjectForKey:@"snaillongitude"] doubleValue]);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return true;
}

@end

#pragma mark -

@protocol SnailCityListUIControllerProtocol<NSObject>

@required
- (void)SnailCityListUIControllerRefesh;

@end

#pragma mark -

@interface SnailCityListUIController()

@property (nonatomic ,weak) id<SnailCityListUIControllerProtocol> protocol;

@end

@implementation SnailCityListUIController

- (instancetype)init {
    self = [super init];
    if (self) {
        _searchPlaceHolder = SNASLS(搜索城市);
        _locationPlaceHolder = SNASLS(定位中...);
        _borderWidth = 1.5;
    }
    return self;
}

- (void)_sendMessage {
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendMessage) object:nil];
    [self performSelector:@selector(sendMessage) withObject:nil afterDelay:.3];
}

- (void)sendMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.protocol SnailCityListUIControllerRefesh];
    });
}

- (void)setShowLocationCity:(BOOL)showLocationCity {
    _showLocationCity = showLocationCity;
    [self _sendMessage];
}

- (void)setShowAroundSearch:(BOOL)showAroundSearch {
    _showAroundSearch = showAroundSearch;
    [self _sendMessage];
}

- (void)setShowCommonCity:(BOOL)showCommonCity {
    _showCommonCity = showCommonCity;
    [self _sendMessage];
}

- (void)setShowRightCharacterIndex:(BOOL)showRightCharacterIndex {
    _showRightCharacterIndex = showRightCharacterIndex;
    [self _sendMessage];
}

- (void)setHeaderNameFont:(UIFont *)headerNameFont {
    _headerNameFont = headerNameFont;
    [self _sendMessage];
}

- (void)setHeaderBackgroundColor:(UIColor *)headerBackgroundColor {
    _headerBackgroundColor = headerBackgroundColor;
    [self _sendMessage];
}

- (void)setHeaderNameColor:(UIColor *)headerNameColor {
    _headerNameColor = headerNameColor;
    [self _sendMessage];
}

- (void)setHeaderNameBackgroundColor:(UIColor *)headerNameBackgroundColor {
    _headerNameBackgroundColor = headerNameBackgroundColor;
    [self _sendMessage];
}

- (void)setCityNameFont:(UIFont *)cityNameFont {
    _cityNameFont = cityNameFont;
    [self _sendMessage];
}

- (void)setCityNameColor:(UIColor *)cityNameColor {
    _cityNameColor = cityNameColor;
    [self _sendMessage];
}

- (void)setCityBackgroundColor:(UIColor *)cityBackgroundColor {
    _cityBackgroundColor = cityBackgroundColor;
    [self _sendMessage];
}

- (void)setSeparatorLineColor:(UIColor *)separatorLineColor {
    _separatorLineColor = separatorLineColor;
    [self _sendMessage];
}

- (void)setCharacterIndexFontColor:(UIColor *)characterIndexFontColor {
    _characterIndexFontColor = characterIndexFontColor;
    [self _sendMessage];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self _sendMessage];
}

- (void)setSearchBackgrooundColor:(UIColor *)searchBackgrooundColor {
    _searchBackgrooundColor = searchBackgrooundColor;
    [self _sendMessage];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self _sendMessage];
}

- (void)setLocationPinImage:(UIImage *)locationPinImage {
    _locationPinImage = locationPinImage;
    [self _sendMessage];
}

- (void)setSearchPlaceHolder:(NSString *)searchPlaceHolder {
    _searchPlaceHolder = searchPlaceHolder;
    [self _sendMessage];
}

- (void)setLocationPlaceHolder:(NSString *)locationPlaceHolder {
    _locationPlaceHolder = locationPlaceHolder;
    [self _sendMessage];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self _sendMessage];
}

@end

#pragma mark -

@implementation SnailCityListDataController

@end

#pragma mark -

@interface _SnailCityListUIController : SnailCityListUIController

@end

@implementation _SnailCityListUIController

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.showLocationCity = true;
        self.showCommonCity = true;
        self.showAroundSearch = true;
        self.showRightCharacterIndex = true;
        
        self.headerNameFont = SnailCityListDefaultFont;
        self.headerBackgroundColor = SnailCityListDefaultColor;
        self.headerNameColor = SnailCityListDefaultNameColor;
        self.headerNameBackgroundColor = SnailCityListDefaultHeaderBackgroundColor;
        
        self.separatorLineColor = [UIColor groupTableViewBackgroundColor];
        self.borderColor = [UIColor groupTableViewBackgroundColor];
        self.characterIndexFontColor = [UIColor blueColor];
        self.searchBackgrooundColor = [UIColor groupTableViewBackgroundColor];
        self.backgroundColor = [UIColor whiteColor];
        
        self.cityNameFont = SnailCityListDefaultFont;
        self.headerBackgroundColor = SnailCityListDefaultColor;
        self.cityNameColor = SnailCityListDefaultNameColor;
        
    }
    return self;
}

@end

#pragma mark -

@interface _SnailCityListDataController : SnailCityListDataController

@property (nonatomic ,strong) SnailCoreLocationManager *locationManager;

@property (nonatomic ,strong) dispatch_queue_t queue;

@property (nonatomic ,strong) NSArray *tmpCharacter;
@property (nonatomic ,strong) NSDictionary *tmpResults;

@end

@implementation _SnailCityListDataController

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [self.locationManager requestPermission];
        
        self.queue = dispatch_queue_create("com.snail.citylist.data.queue", DISPATCH_QUEUE_SERIAL);
        
        __weak typeof(self) self_weak_ = self;
        
        self.prepareBlock = ^(void (^prepareSuccessBlock)(void)) {
            dispatch_async(self_weak_.queue, ^{
                
                NSString *tmpDataPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"_SnailCitySlectedListData.archive"];
                NSMutableDictionary *tmpResult = [NSKeyedUnarchiver unarchiveObjectWithFile:tmpDataPath];
                NSMutableArray *tmpCharacter;
                if (!tmpResult) {
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];
                    NSArray *city_datas = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableLeaves error:nil][@"data"];
                    
                    tmpCharacter = [NSMutableArray new];
                    tmpResult = [NSMutableDictionary new];
                    
                    for (NSDictionary *dic in city_datas) {
                        NSArray *cityList = dic[@"list"];
                        for (NSDictionary *cityDic in cityList) {
                            
                            NSString *cityName = cityDic[@"areaName"];
                            NSString *character = [self_weak_ takeFirstChar:cityName];
                            
                            NSMutableArray *tmpCityNames = tmpResult[character];
                            
                            if (!tmpCityNames) {
                                [tmpCharacter addObject:character];
                                tmpCityNames = [NSMutableArray new];
                                tmpResult[character] = tmpCityNames;
                            }
                            
                            SnailCityListCityItem *item = [SnailCityListCityItem new];
                            item.snailCityListName = cityName;
                            
                            if (![tmpCityNames containsObject:item]) {
                                [tmpCityNames addObject:item];
                            }
                            
                        }
                        
                    }
                    [NSKeyedArchiver archiveRootObject:tmpResult toFile:tmpDataPath];
                }
                else {
                    tmpCharacter = [NSMutableArray arrayWithArray:tmpResult.allKeys];
                }
                
                self_weak_.tmpResults = tmpResult.copy;
                self_weak_.tmpCharacter = tmpCharacter.copy;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    prepareSuccessBlock();
                });
                
            });
            
        };
        
        self.dataBlock = ^(void (^dataResultBlock)(NSDictionary *results, NSArray<NSString *> *resultFirstCharacters)) {
            dispatch_async(self_weak_.queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    dataResultBlock(self_weak_.tmpResults,self_weak_.tmpCharacter);
                });
            });
        };
        
        self.searchBlock = ^(NSString *searchText, void (^searchResultBlock)(NSDictionary *results, NSArray<NSString *> *resultFirstCharacters)) {
            
            dispatch_async(self_weak_.queue, ^{
               
                NSMutableDictionary *tmpDic = [NSMutableDictionary new];
                
                if (searchText.length == 0) {
                    tmpDic = self_weak_.tmpResults.copy;
                }
                else {
                    NSPredicate *pre = [NSPredicate predicateWithFormat:@"snailCityListName CONTAINS %@",searchText];
                    
                    for (NSString *key in self_weak_.tmpResults) {
                        NSArray *arrays = self_weak_.tmpResults[key];
                        NSArray *tmps = [arrays filteredArrayUsingPredicate:pre];
                        if (tmps.count > 0) {
                            tmpDic[key] = tmps;
                        }
                    }
                    
                }
                
                NSArray *allKeys = [tmpDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [obj1 compare:obj2];
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    searchResultBlock(tmpDic,allKeys);
                });
                
            });
            
        };
        
        self.locationBlock = ^(void (^locationResultBlock)(id<SnailCityListItemProtocol> results)) {
            
            self_weak_.locationManager.locationOnceWithGeoBlock = ^(CLLocationCoordinate2D coor, NSInteger tag, CLPlacemark *placeMark) {
                SnailCityListCityItem *item = [SnailCityListCityItem new];
                item.snailCityListName = placeMark.locality;
                locationResultBlock(item);
            };
            [self_weak_.locationManager locationOnce:0];
            
        };
        
        self.commonBlock = ^(void (^commonResultBlock)(NSArray<id<SnailCityListItemProtocol>> *result)) {
            
            dispatch_async(self_weak_.queue, ^{
                NSArray *tmps = [[NSUserDefaults standardUserDefaults] objectForKey:@"_SnailCityListCommonData"];
                
                NSMutableArray *datas = [NSMutableArray new];
                
                for (NSString *str in tmps) {
                    SnailCityListCityItem *item = [SnailCityListCityItem new];
                    item.snailCityListName = str;
                    [datas addObject:item];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    commonResultBlock(datas);
                });
            });
        };
        
    }
    return self;
}

- (NSString *)takeFirstChar:(NSString *)name {
    
    if ([name hasPrefix:@"重庆"]) return @"C";
    
    NSMutableString *str = [NSMutableString stringWithString:name];
    CFRange range = CFRangeMake(0, 1);
    CFStringTransform((CFMutableStringRef) str, &range, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, &range, kCFStringTransformStripDiacritics, NO);
    NSString *pinYin = [str capitalizedString];
    return [pinYin substringToIndex:1];
    
}

- (SnailCoreLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [SnailCoreLocationManager new];
    }
    return _locationManager;
}

@end

#pragma mark -

@interface SnailCityListLocationView : UIView

@property (nonatomic ,strong) UIImageView *ic;
@property (nonatomic ,strong) UILabel *nameLbl;

@end

@implementation SnailCityListLocationView

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.ic = [UIImageView new];
        self.ic.image = [UIImage imageNamed:@"snailCityselectListLocation"];
        
        self.nameLbl = [UILabel new];
        self.nameLbl.textColor = [UIColor blackColor];
        
        [self addSubview:self.ic];
        [self addSubview:self.nameLbl];
        
        [self.ic mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.leading.equalTo(self).offset(15);
        }];
        [self.nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.leading.equalTo(self.ic.mas_trailing).offset(8);
            make.trailing.lessThanOrEqualTo(self).offset(-15);
        }];
        
    }
    return self;
}

@end

#pragma mark -

@interface SnailCityListCommonCell : UITableViewCell

@property (nonatomic ,strong) UITapGestureRecognizer *tap;
@property (nonatomic ,weak) NSArray<NSValue *> *rects;

@end

@implementation SnailCityListCommonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.tap = [self.contentView snail_addTapGes:self Action:@selector(tapAction:)];
    }
    return self;
}

- (void)configureWithModels:(NSArray<id<SnailCityListItemProtocol>> *)items Rects:(NSArray<NSValue *> *)rects Fone:(UIFont *)font Color:(UIColor *)color BorderColor:(UIColor *)borderColor BorderWidth:(CGFloat)borderWidth {
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.rects = rects;
    
    for (NSInteger i = 0; i < items.count; i++) {
        
        id<SnailCityListItemProtocol> item = items[i];
        NSValue *value = rects[i];
        
        UILabel *label = [UILabel new];
        label.textColor = color;
        label.font = font;
        label.snail_corner(3);
        label.snail_border(borderWidth,borderColor);
        label.text = item.snailCityListName;
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = [value CGRectValue];
        label.tag = i;
        [self.contentView addSubview:label];
        
    }
    
}

- (void)tapAction:(UITapGestureRecognizer *)ges {
    
    CGPoint point = [ges locationInView:self.contentView];
    for (NSInteger i = 0; i < self.rects.count; i++) {
        CGRect rect = self.rects[i].CGRectValue;
        if (CGRectContainsPoint(rect, point)) {
            [self snailResponderChain:@"CommonCityClick" Extend:@(i)];
            break;
        }
    }
    
}

@end

#pragma mark -

@interface SnailCityListCityCell : UITableViewCell

@property (nonatomic ,strong) UILabel *nameLbl;
@property (nonatomic ,strong) UIView *bottomLine;

@end

@implementation SnailCityListCityCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.nameLbl = [UILabel new];
        self.nameLbl.textColor = [UIColor blackColor];
        
        self.bottomLine = [UIView new];
        self.bottomLine.backgroundColor = [UIColor blackColor];
        
        [self.contentView addSubview:self.nameLbl];
        [self.contentView addSubview:self.bottomLine];
        
        [self.nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(15);
        }];
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.leading.bottom.equalTo(self.contentView);
            make.height.equalTo(@1);
        }];
        
    }
    return self;
}

- (void)configureWithModels:(id<SnailCityListItemProtocol>)item {
    self.nameLbl.text = item.snailCityListName;
}

@end

#pragma mark -

@interface SnailCityListCityHeader : UITableViewHeaderFooterView

@property (nonatomic ,strong) UIView *nameBackView;
@property (nonatomic ,strong) UILabel *nameLbl;

@end

@implementation SnailCityListCityHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        
        self.nameBackView = [UIView new];
        self.nameBackView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.nameBackView.layer.cornerRadius = 3;
        self.nameBackView.layer.masksToBounds = true;
        
        self.nameLbl = [UILabel new];
        self.nameLbl.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:self.nameBackView];
        [self.nameBackView addSubview:self.nameLbl];
        
        [self.nameBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.top.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(10);
        }];
        [self.nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.top.equalTo(self.nameBackView);
            make.leading.equalTo(self.nameBackView).offset(5);
        }];
        
    }
    return self;
}

- (void)configureWithName:(NSString *)str {
    self.nameLbl.text = str;
}

@end

#pragma mark -

@interface SnailCityListSelectController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,SnailCityListUIControllerProtocol>

@property (nonatomic ,strong) UISearchBar *searchBar;
@property (nonatomic ,strong) SnailCityListLocationView *locationView;
@property (nonatomic ,strong) UITableView *tab;
@property (nonatomic ,strong) SnailTableviewIndexView *indexView;

@end

@interface SnailCityListSelectController()

@property (nonatomic) BOOL searching;

@property (nonatomic ,strong) SnailCoreLocationManager *locationManager;

@property (nonatomic ,strong) NSDictionary *searchDatas;
@property (nonatomic ,strong) NSArray *searchFirstCharacterDatas;

@property (nonatomic ,strong) id<SnailCityListItemProtocol> locationData;

@property (nonatomic ,strong) NSMutableArray *commonDatas;
@property (nonatomic ,strong) NSMutableArray *commonSizeDatas;
@property (nonatomic) CGFloat commonHeight;

@property (nonatomic ,strong) NSMutableArray *firstCharacterDatas;
@property (nonatomic ,strong) NSMutableDictionary *datas;

@end

@implementation SnailCityListSelectController

@synthesize uiController = __uiController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.view.backgroundColor = self.view.backgroundColor;
    
    self.commonDatas = [NSMutableArray new];
    self.commonSizeDatas = [NSMutableArray new];
    
    self.firstCharacterDatas = [NSMutableArray new];
    self.datas = [NSMutableDictionary new];
    
    if (!self.uiController) self.uiController = [_SnailCityListUIController new];
    if (!self.dataController) self.dataController = [_SnailCityListDataController new];
    
    self.searchBar = [UISearchBar new];
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleDefault;
    
    UIView *firstSubView = self.searchBar.subviews.firstObject;
    UIView *backgroundImageView = [firstSubView.subviews firstObject];
    [backgroundImageView removeFromSuperview];
    
    self.locationView = [SnailCityListLocationView new];
    [self.locationView snail_addTapGes:self Action:@selector(locationAction)];
    self.locationView.backgroundColor = self.uiController.cityBackgroundColor;
    
    if (self.uiController.showLocationCity) {
        self.locationView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 50);
        self.locationView.hidden = false;
    }
    else {
        self.locationView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 0);
        self.locationView.hidden = true;
    }
    
    self.tab = [UITableView new];
    self.tab.delegate = self;
    self.tab.dataSource = self;
    self.tab.tableHeaderView = self.locationView;
    self.tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab.tableFooterView = UIView.new;
    [self.tab registerClass:SnailCityListCommonCell.class forCellReuseIdentifier:@"common"];
    [self.tab registerClass:SnailCityListCityCell.class forCellReuseIdentifier:@"city"];
    [self.tab registerClass:SnailCityListCityHeader.class forHeaderFooterViewReuseIdentifier:@"header"];
    
    __weak typeof(self) self_weak_ = self;
    
    self.indexView = [SnailTableviewIndexView new];
    self.indexView.selectedBlock = ^(NSInteger index, NSString *character) {
        NSIndexPath *indexPath = nil;
        if (self_weak_.searching) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        }
        else if (self_weak_.uiController.showCommonCity) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:index+1];
        }
        else indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        [self_weak_.tab scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:false];
    };
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tab];
    [self.view addSubview:self.indexView];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    [self.tab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.leading.bottom.equalTo(self.view);
        make.top.equalTo(self.searchBar.mas_bottom).offset(10);
    }];
    [self.indexView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.width.equalTo(@30);
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reload];
    });
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)reload {
    
    if (self.uiController.showAroundSearch) {
        self.searchBar.hidden = false;
        [self.tab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom).offset(10);
        }];
    }
    else {
        [self.tab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
        }];
    }
    
    self.tab.separatorColor = self.uiController.separatorLineColor;
    self.indexView.color = self.uiController.characterIndexFontColor;
    self.view.backgroundColor = self.uiController.backgroundColor;
    
    self.searchBar.placeholder = self.uiController.searchPlaceHolder;
    
    self.locationView.backgroundColor = self.uiController.cityBackgroundColor;
    self.locationView.nameLbl.font = self.uiController.cityNameFont;
    self.locationView.nameLbl.textColor = self.uiController.cityNameColor;
    if (self.uiController.locationPinImage) self.locationView.ic.image = self.uiController.locationPinImage;
    else self.locationView.ic.image = [UIImage imageNamed:@"snailCityselectListLocation"];
    
    UIView *firstSubView = self.searchBar.subviews.firstObject;
    firstSubView.backgroundColor = self.uiController.searchBackgrooundColor;
    
    if (self.uiController.showLocationCity) {
        self.locationView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 50);
        self.tab.tableHeaderView = self.locationView;
        self.locationView.hidden = false;
    }
    else {
        self.locationView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 0);
        self.tab.tableHeaderView = self.locationView;
        self.locationView.hidden = true;
    }
    
    if (self.uiController.showRightCharacterIndex) {
        self.indexView.hidden = false;
    }
    else {
        self.indexView.hidden = true;
    }
    
    if (self.dataController.prepareBlock) {
        __weak typeof(self) self_weak_ = self;
        self.dataController.prepareBlock(^{
            [self_weak_ refeshLocationData];
            [self_weak_ refeshCommonData];
            [self_weak_ refeshCityData];
        });
    }
    else {
        [self refeshLocationData];
        [self refeshCommonData];
        [self refeshCityData];
    }

}

#pragma mark -

- (void)refeshLocationData {
    if (self.uiController.showLocationCity && self.dataController.locationBlock) {
        self.locationView.nameLbl.text = self.uiController.locationPlaceHolder;
        __weak typeof(self) self_weak_ = self;
        self.dataController.locationBlock(^(id<SnailCityListItemProtocol> results) {
            self_weak_.locationData = results;
            [self_weak_ refeshLocationUI];
        });
    }
}

- (void)refeshLocationUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locationView.nameLbl.text = self.locationData.snailCityListName;
    });
}

#pragma mark -

- (void)refeshCommonData {
    
    if (self.uiController.showCommonCity && self.dataController.commonBlock) {
        __weak typeof(self) self_weak_ = self;
        self.dataController.commonBlock(^(NSArray<id<SnailCityListItemProtocol>> *result) {
            
            [self_weak_.commonDatas removeAllObjects];
            [self_weak_.commonSizeDatas removeAllObjects];
            
            if (result.count > 0) {
                
                [self_weak_.commonDatas addObjectsFromArray:result];
                
                CGFloat leading = 15;
                CGFloat top = 10;
                int count = 4;
                CGFloat spaceing = 10.0;
                CGFloat width = ceil(((self_weak_.view.bounds.size.width - leading * 2) - (count - 1) * spaceing) / count);
                CGFloat height = 40;
                
                CGFloat x = leading;
                CGFloat y = top;
                for (NSInteger i = 0; i < result.count; i++) {
                    CGRect rect = CGRectMake(x, y, width, height);
                    [self.commonSizeDatas addObject:[NSValue valueWithCGRect:rect]];
                    if ((i+1) % count == 0) {
                        x = leading;
                        y += (height + spaceing);
                    }
                    else x += (spaceing + width);
                }
                
                self_weak_.commonHeight = CGRectGetMaxY([self.commonSizeDatas.lastObject CGRectValue]) + top;
                
            }
            else self.commonHeight = 10;
            
            [self_weak_ refeshCommonUI];
            
        });
    }
    else self.commonHeight = 10;
    
}

- (void)refeshCommonUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tab reloadData];
        /*
        [self.tab beginUpdates];
        SnailCityListCommonCell *cell = [self.tab cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell configureWithModels:self.commonDatas Rects:self.commonSizeDatas Fone:self.uiController.cityNameFont Color:self.uiController.cityNameColor];
        [self.tab endUpdates];
         */
    });
}

- (void)refeshCityData {
    
    if (self.dataController.dataBlock) {
        __weak typeof(self) self_weak_ = self;
        self.dataController.dataBlock(^(NSDictionary *results, NSArray<NSString *> *resultFirstCharacters) {
            
            NSArray *tmps = [resultFirstCharacters sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj1 compare:obj2];
            }];
            
            [self_weak_.datas removeAllObjects];
            [self_weak_.firstCharacterDatas removeAllObjects];
            [self_weak_.firstCharacterDatas addObjectsFromArray:tmps];
            [self_weak_.datas setDictionary:results];
            [self_weak_ refeshCityUI];
        });
    }
    
}

- (void)refeshCityUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tab reloadData];
        if (self.uiController.showRightCharacterIndex) {
            self.indexView.characters = self.firstCharacterDatas;
        }
    });
}

#pragma mark -

- (void)locationAction {
    [self callBackItem:self.locationData];
}

- (void)callBackItem:(id<SnailCityListItemProtocol>)item {
    if (self.selectedCityBlock) {
        
        if ([self.dataController isKindOfClass:_SnailCityListDataController.class]) {
            
            NSMutableArray *tmps = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"_SnailCityListCommonData"]];
            if (!tmps) {
                tmps = [NSMutableArray new];
            }
            
            if (![tmps containsObject:item.snailCityListName]) {
                if (tmps.count >= 8) {
                    [tmps removeLastObject];
                }
                [tmps insertObject:item.snailCityListName atIndex:0];
            }
            else {
                NSInteger index = [tmps indexOfObject:item.snailCityListName];
                [tmps removeObjectAtIndex:index];
                [tmps insertObject:item.snailCityListName atIndex:0];
            }
            [[NSUserDefaults standardUserDefaults] setObject:tmps forKey:@"_SnailCityListCommonData"];
            
        }
        if (self.dataController.selectedBlock) {
            self.dataController.selectedBlock(item);
        }
        
        if (self.geocodeAddress && CLLocationCoordinate2DIsValid(item.coor)) {
            __weak typeof(self) self_weak_ = self;
            [self.locationManager geocodeAddressString:item.snailCityListName completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                if (placemarks.count > 0) {
                    CLPlacemark *placemark = placemarks.firstObject;
                    item.coor = placemark.location.coordinate;
                }
                self_weak_.selectedCityBlock(item);
            }];
        }
        else self.selectedCityBlock(item);
        
    }
}

#pragma mark -

- (void)snailResponderChain:(NSString *)event Extend:(id)extend {
    if ([event isEqualToString:@"CommonCityClick"]) {
        [self callBackItem:self.commonDatas[[extend integerValue]]];
    }
}

#pragma mark -

- (BOOL)searching {
    return self.searchBar.text.length > 0;
}

#pragma mark -

- (void)SnailCityListUIControllerRefesh {
    [self reload];
}

#pragma mark -

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:true];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:true animated:true];
    self.searchBar.showsCancelButton = true;
    [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    return true;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:false animated:true];
    self.searchBar.showsCancelButton = false;
    [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    return true;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    __weak typeof(self) self_weak_ = self;
    self.dataController.searchBlock(searchText, ^(NSDictionary *results, NSArray<NSString *> *resultFirstCharacters) {
        self_weak_.searchDatas = results;
        self_weak_.searchFirstCharacterDatas = resultFirstCharacters;
        [self_weak_.tab reloadData];
        if (self_weak_.uiController.showRightCharacterIndex) {
            self_weak_.indexView.characters = resultFirstCharacters;
        }
    });
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.searching) {
        return self.searchFirstCharacterDatas.count;
    }
    return self.uiController.showCommonCity?self.firstCharacterDatas.count+1:self.firstCharacterDatas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.searching) {
        return [self.searchDatas[self.searchFirstCharacterDatas[section]] count];
    }
    
    if (self.uiController.showCommonCity) {
        if (section == 0) {
            return 1;
        }
        else return [self.datas[self.firstCharacterDatas[section - 1]] count];
    }
    return [self.datas[self.firstCharacterDatas[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id<SnailCityListItemProtocol> item;
    
    if (self.searching) item = [self.searchDatas[self.searchFirstCharacterDatas[indexPath.section]] objectAtIndex:indexPath.row];
    else if (self.uiController.showCommonCity) {
        if (indexPath.section == 0) {
            SnailCityListCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"common"];
            [cell configureWithModels:self.commonDatas Rects:self.commonSizeDatas Fone:self.uiController.cityNameFont Color:self.uiController.cityNameColor BorderColor:self.uiController.borderColor BorderWidth:self.uiController.borderWidth];
            cell.contentView.backgroundColor = self.uiController.cityBackgroundColor;
            return cell;
        }
        else {
            item = [self.datas[self.firstCharacterDatas[indexPath.section - 1]] objectAtIndex:indexPath.row];
        }
    }
    else item = [self.datas[self.firstCharacterDatas[indexPath.section]] objectAtIndex:indexPath.row];
    
    SnailCityListCityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"city"];
    cell.nameLbl.font = self.uiController.cityNameFont;
    cell.nameLbl.textColor = self.uiController.cityNameColor;
    cell.contentView.backgroundColor = self.uiController.cityBackgroundColor;
    cell.bottomLine.backgroundColor = self.uiController.separatorLineColor;
    [cell configureWithModels:item];
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SnailCityListCityHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    header.nameLbl.font = self.uiController.headerNameFont;
    header.nameLbl.textColor = self.uiController.headerNameColor;
    header.contentView.backgroundColor = self.uiController.headerBackgroundColor;
    header.nameBackView.backgroundColor = self.uiController.headerNameBackgroundColor;
    
    if (self.searching) [header configureWithName:self.searchFirstCharacterDatas[section]];
    else if (self.uiController.showCommonCity) {
        if (section == 0) {
            [header configureWithName:SNASLS(常用城市)];
        }
        else [header configureWithName:self.firstCharacterDatas[section - 1]];
    }
    else [header configureWithName:self.firstCharacterDatas[section]];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searching) return 44;
    if (self.uiController.showCommonCity) {
        if (indexPath.section == 0) {
            return self.commonHeight;
        }
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        id<SnailCityListItemProtocol> item;
        if (self.searching) item = [self.searchDatas[self.searchFirstCharacterDatas[indexPath.section]] objectAtIndex:indexPath.row];
        else if (self.uiController.showCommonCity) {
            if (indexPath.section != 0) {
                item = [self.datas[self.firstCharacterDatas[indexPath.section - 1]] objectAtIndex:indexPath.row];
            }
        }
        else item = [self.datas[self.firstCharacterDatas[indexPath.section]] objectAtIndex:indexPath.row];
        
        [self callBackItem:item];
    });
    
}

#pragma mark -

- (void)setUiController:(SnailCityListUIController *)uiController {
    __uiController = uiController;
    __uiController.protocol = self;
}

- (SnailCityListUIController *)uiController {
    if (!__uiController) {
        __uiController = [_SnailCityListUIController new];
        __uiController.protocol = self;
    }
    return __uiController;
}

- (SnailCoreLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [SnailCoreLocationManager new];
    }
    return _locationManager;
}

@end
