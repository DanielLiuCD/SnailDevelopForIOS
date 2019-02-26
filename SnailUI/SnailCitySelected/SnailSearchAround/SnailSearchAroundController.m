//
//  SnailSearchAroundController.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/11/14.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailSearchAroundController.h"
#import "SnailCoreLocationManager.h"

#define SNAILSEARCHAROUND_TITLEFONT  17.0f
#define SNAILSEARCHAROUND_ADDRESSFONT 15.0F
#define SNAILSEARCHAROUND_COLOR [UIColor whiteColor]
#define SNAILSEARCHAROUND_TITLECOLOR [UIColor blackColor]
#define SNAILSEARCHAROUND_ADDRESSCOLOR [UIColor lightGrayColor]
#define SNAILSEARCHAROUND_TITLESAPCEING 5.0f
#define SNAILSEARCHAROUND_SEARCHBACKGROUNDCOLOR [UIColor groupTableViewBackgroundColor]
#define SNAILSEARCHAROUND_SEARCHPLACEHOLDER NSLocalizedString(@"搜索附近位置", nil)
#define SNAILSEARCHAROUND_SEPERATECOLOR [UIColor groupTableViewBackgroundColor]

@protocol SnailSearchAroundUIChangeProtocol<NSObject>

- (void)SnailSearchAroundUIRefesh;

@end

@interface SnailSearchAroundUIController()

@property (nonatomic ,weak) id<SnailSearchAroundUIChangeProtocol> protocol;

@end

@implementation SnailSearchAroundUIController

- (void)sendMessage {
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(_sendMessage) object:nil];
    [self performSelector:@selector(_sendMessage) withObject:nil afterDelay:.25];
    
}

- (void)_sendMessage {
    if (self.protocol) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.protocol SnailSearchAroundUIRefesh];
        });
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self sendMessage];
}

- (void)setCellBackgroundColor:(UIColor *)cellBackgroundColor {
    _cellBackgroundColor = cellBackgroundColor;
    [self sendMessage];
}

- (void)setSearchPlaceholder:(NSString *)searchPlaceholder {
    self.searchPlaceholderAttributeString = [[NSAttributedString alloc] initWithString:searchPlaceholder attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:SNAILSEARCHAROUND_TITLEFONT],NSForegroundColorAttributeName:SNAILSEARCHAROUND_COLOR}];
}

- (NSString *)searchPlaceholder {
    return self.searchPlaceholderAttributeString.string;
}

- (void)setSearchPlaceholderAttributeString:(NSAttributedString *)searchPlaceholderAttributeString {
    _searchPlaceholderAttributeString = searchPlaceholderAttributeString;
    [self sendMessage];
}

- (void)setSearchBackgroundColor:(UIColor *)searchBackgroundColor {
    _searchBackgroundColor = searchBackgroundColor;
    [self sendMessage];
}

- (void)setTitleAttribute:(NSDictionary *)titleAttribute {
    _titleAttribute = titleAttribute;
    [self sendMessage];
}

- (void)setAddressAttribute:(NSDictionary *)addressAttribute {
    _addressAttribute = addressAttribute;
    [self sendMessage];
}

- (void)setSeperateColor:(UIColor *)seperateColor {
    _seperateColor = seperateColor;
    [self sendMessage];
}

- (void)setSeperateInsets:(UIEdgeInsets)seperateInsets {
    _seperateInsets = seperateInsets;
    [self sendMessage];
}

- (void)setSeperateHeight:(CGFloat)seperateHeight {
    _seperateHeight = seperateHeight;
    [self sendMessage];
}

- (void)setRowHeight:(CGFloat)rowHeight {
    _rowHeight = rowHeight;
    [self sendMessage];
}

- (void)setTitleSpaceing:(CGFloat)titleSpaceing {
    _titleSpaceing = titleSpaceing;
    [self sendMessage];
}

@end

@implementation SnailSearchAroundDataController

@end

@interface sna_SnailSearchAroundData : NSObject<SnailSearchAroundDataProtocol>

@end

@implementation sna_SnailSearchAroundData
@synthesize title,address,coor,rowHeight;

@end

@interface sna_SnailSearchAroundDataController : SnailSearchAroundDataController

@property (nonatomic) CLLocationCoordinate2D coor;
@property (nonatomic ,strong) SnailCoreLocationManager *locationManager;
@property (nonatomic ,copy) void(^preparedCompleteBlock)(BOOL success);

@end

@implementation sna_SnailSearchAroundDataController

- (instancetype)init {
    self = [super init];
    if (self) {
        __weak typeof(self) self_weak_ = self;
        self.locationManager.locationAuthStatusChangeBlock = ^(BOOL isAllowed) {
            if (isAllowed) {
                [self_weak_ location];
            }
        };
        self.locationManager.locationOnceBlock = ^(CLLocationCoordinate2D coor, NSInteger tag) {
            self_weak_.coor = coor;
            self_weak_.preparedCompleteBlock(true);
        };
        [self.locationManager requestPermission];
        
        self.datasBlock = ^(void (^completeBlock)(NSArray<id<SnailSearchAroundDataProtocol>> *results)) {
            [self_weak_ searchText:NSLocalizedString(@"街道", nil) Block:^(NSArray *datas) {
                completeBlock(datas);
            }];
        };
        self.searchBlock = ^(NSString *text, void (^completeBlock)(NSArray<id<SnailSearchAroundDataProtocol>> *results)) {
            [self_weak_ searchText:text Block:^(NSArray *datas) {
                completeBlock(datas);
            }];
        };
        self.preparedBlock = ^(void (^completeBlock)(BOOL success)) {
            self_weak_.preparedCompleteBlock = completeBlock;
            [self_weak_ location];
        };
    }
    return self;
}

- (void)searchText:(NSString *)text Block:(void(^)(NSArray *))block{
    __weak typeof(self) self_weak_ = self;
    [self.locationManager searchAround:text Coor:self.coor Distance:50000 Block:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        block([self_weak_ detailSearchResult:response]);
    }];
}


- (NSArray *)detailSearchResult:(MKLocalSearchResponse *)response {
    NSMutableArray *tmps = [NSMutableArray new];
    for (MKMapItem *item in response.mapItems) {
        sna_SnailSearchAroundData *data = [sna_SnailSearchAroundData new];
        data.coor = item.placemark.location.coordinate;
        data.title = item.name;
        data.address = [item.placemark.addressDictionary[@"FormattedAddressLines"] firstObject];
        [tmps addObject:data];
    }
    return tmps.copy;
}

- (void)location {
    [self.locationManager locationOnce:0];
}

- (SnailCoreLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [SnailCoreLocationManager new];
    }
    return _locationManager;
}

@end

@interface sna_SnailSearchAroundUIController : SnailSearchAroundUIController

@end

@implementation sna_SnailSearchAroundUIController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = SNAILSEARCHAROUND_COLOR;
        self.cellBackgroundColor = SNAILSEARCHAROUND_COLOR;
        
        self.searchPlaceholderAttributeString = [[NSAttributedString alloc] initWithString:SNAILSEARCHAROUND_SEARCHPLACEHOLDER attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:SNAILSEARCHAROUND_TITLEFONT],NSForegroundColorAttributeName:SNAILSEARCHAROUND_COLOR}];
        self.searchBackgroundColor = SNAILSEARCHAROUND_SEARCHBACKGROUNDCOLOR;
        
        self.titleAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:SNAILSEARCHAROUND_TITLEFONT],NSForegroundColorAttributeName:SNAILSEARCHAROUND_TITLECOLOR};
        self.addressAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:SNAILSEARCHAROUND_ADDRESSFONT],NSForegroundColorAttributeName:SNAILSEARCHAROUND_ADDRESSCOLOR};
        self.seperateColor = SNAILSEARCHAROUND_SEPERATECOLOR;
        self.seperateHeight = 1.0;
        self.seperateInsets = UIEdgeInsetsZero;
        self.rowHeight = 0.0;
        self.titleSpaceing = SNAILSEARCHAROUND_TITLESAPCEING;
    }
    return self;
}

@end

@interface sna_SnailSearchAroundLabel : UILabel

@property (nonatomic) CGFloat bottomSpaceing;

@end

@implementation sna_SnailSearchAroundLabel

- (UIEdgeInsets)alignmentRectInsets {
    return UIEdgeInsetsMake(0, 0, -self.bottomSpaceing, 0);
}

- (void)setBottomSpaceing:(CGFloat)bottomSpaceing {
    if (_bottomSpaceing != bottomSpaceing) {
        _bottomSpaceing = bottomSpaceing;
    }
}

@end

@interface SnailSearchAroundCell : UITableViewCell

@property (nonatomic ,strong) sna_SnailSearchAroundLabel *titleLbl;
@property (nonatomic ,strong) UILabel *addressLbl;
@property (nonatomic ,strong) UIView *bottomLine;

@end

@implementation SnailSearchAroundCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.titleLbl = [sna_SnailSearchAroundLabel new];
        self.titleLbl.numberOfLines = 0;
        
        self.addressLbl = [UILabel new];
        self.addressLbl.numberOfLines = 0;
        
        self.bottomLine = [UIView new];
        self.bottomLine.backgroundColor = [UIColor blackColor];
        
        [self.contentView addSubview:self.titleLbl];
        [self.contentView addSubview:self.addressLbl];
        [self.contentView addSubview:self.bottomLine];
        
        [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(15);
            make.trailing.lessThanOrEqualTo(self.contentView).offset(-15);
            make.top.equalTo(self.contentView).offset(20);
        }];
        [self.addressLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(15);
            make.trailing.lessThanOrEqualTo(self.contentView).offset(-15);
            make.top.equalTo(self.titleLbl.mas_bottom).offset(0);
        }];
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.bottom.equalTo(self.contentView);
            make.height.equalTo(@1);
        }];
    }
    return self;
}

- (void)configureWithModel:(id<SnailSearchAroundDataProtocol>)data UI:(SnailSearchAroundUIController *)ui {
    
    NSAttributedString *titleAttribiteStr = objc_getAssociatedObject(data, "com.snail.title.searcharound.attribute");
    if (!titleAttribiteStr && data.title) {
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:data.title attributes:ui.titleAttribute];
        objc_setAssociatedObject(data, "com.snail.title.searcharound.attribute", attr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        titleAttribiteStr = attr;
    }
    
    NSAttributedString *addressAttribiteStr = objc_getAssociatedObject(data, "com.snail.address.searcharound.attribute");
    if (!addressAttribiteStr && data.address) {
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:data.address attributes:ui.addressAttribute];
        objc_setAssociatedObject(data, "com.snail.address.searcharound.attribute", attr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        addressAttribiteStr = attr;
    }
    
    self.titleLbl.attributedText = titleAttribiteStr;
    self.addressLbl.attributedText = addressAttribiteStr;
    self.bottomLine.backgroundColor = ui.seperateColor;
    
    self.titleLbl.bottomSpaceing = ui.titleSpaceing;
    [self.bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(ui.seperateHeight));
        make.bottom.equalTo(self.contentView).offset(ui.seperateInsets.bottom);
        make.leading.equalTo(self.contentView).offset(ui.seperateInsets.left);
        make.trailing.equalTo(self.contentView).offset(ui.seperateInsets.right);
    }];
    
    self.contentView.backgroundColor = ui.cellBackgroundColor;
}

@end

@interface SnailSearchAroundFooterView : UIView

@property (nonatomic ,strong) UIActivityIndicatorView *indicator;

@end

@implementation SnailSearchAroundFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicator.hidesWhenStopped = true;
        [self addSubview:self.indicator];
        [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

- (void)startAnimating {
    [self.indicator startAnimating];
}

- (void)stopAnimating {
    [self.indicator stopAnimating];
}

@end

@interface SnailSearchAroundController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,SnailSearchAroundUIChangeProtocol>

@property (nonatomic ,strong) UISearchBar *searchBar;
@property (nonatomic ,strong) UITableView *tab;
@property (nonatomic ,strong) SnailSearchAroundFooterView *footer;

@property (nonatomic ,strong) NSMutableArray<id<SnailSearchAroundDataProtocol>> *datas;
@property (nonatomic ,strong) NSMutableArray<id<SnailSearchAroundDataProtocol>> *searchDatas;

@property (nonatomic) BOOL decelerate;

@end

@implementation SnailSearchAroundController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.view.backgroundColor = self.view.backgroundColor;
    
    if (!self.uiController) self.uiController = [sna_SnailSearchAroundUIController new];
    if (!self.dataController) self.dataController = [sna_SnailSearchAroundDataController new];
    
    self.searchBar = [UISearchBar new];
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleDefault;
    
    UIView *firstSubView = self.searchBar.subviews.firstObject;
    UIView *backgroundImageView = [firstSubView.subviews firstObject];
    [backgroundImageView removeFromSuperview];
    
    self.tab = [UITableView new];
    self.tab.delegate = self;
    self.tab.dataSource = self;
    self.tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab.tableFooterView = UIView.new;
    [self.tab registerClass:SnailSearchAroundCell.class forCellReuseIdentifier:@"c"];
    
    self.footer = [SnailSearchAroundFooterView new];
    self.footer.frame= CGRectMake(0, 0, self.view.bounds.size.width, 50);
    self.tab.tableFooterView = self.footer;
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tab];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
    [self.tab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.leading.bottom.equalTo(self.view);
        make.top.equalTo(self.searchBar.mas_bottom).offset(10);
    }];
    
    __weak typeof(self) self_weak_ = self;
    self.dataController.preparedBlock(^(BOOL success) {
        [self_weak_ reload];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)reload {
    [self reloadUI];
    [self reloadData];
}

- (void)reloadData {
    
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(_reloadData) object:nil];
    [self performSelector:@selector(_reloadData) withObject:nil afterDelay:.25];
    
}

- (void)_reloadData {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) self_weak_ = self;
        if (self.searching) {
            self.dataController.searchBlock(self.searchBar.text, ^(NSArray<id<SnailSearchAroundDataProtocol>> *results) {
                self_weak_.searchDatas = results.mutableCopy;
                [self_weak_.tab reloadData];
            });
        }
        else {
            self.dataController.datasBlock(^(NSArray<id<SnailSearchAroundDataProtocol>> *results) {
                self_weak_.datas = results.mutableCopy;
                [self_weak_.tab reloadData];
            });
        }
    });
    
}


- (void)reloadUI {
    
    self.view.backgroundColor = self.uiController.backgroundColor;
    self.navigationController.view.backgroundColor = self.view.backgroundColor;
    
    self.tab.backgroundColor = self.uiController.cellBackgroundColor;
    
    self.searchBar.placeholder = self.uiController.searchPlaceholder;
    self.searchBar.returnKeyType = self.dataController.enableImmediatelySearch?UIReturnKeyDone:UIReturnKeySearch;
    
    UIView *firstSubView = self.searchBar.subviews.firstObject;
    firstSubView.backgroundColor = self.uiController.searchBackgroundColor;
    
    [self.tab reloadData];
}

#pragma mark -

- (BOOL)searching {
    return self.searchBar.text.length > 0;
}

#pragma mark -

- (void)SnailSearchAroundUIRefesh {
    [self reloadUI];
}

#pragma mark -

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:true];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:true animated:true];
    self.searchBar.showsCancelButton = true;
//    [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_topLayoutGuide);
//    }];
    return true;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:false animated:true];
    self.searchBar.showsCancelButton = false;
//    [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_topLayoutGuide);
//    }];
    [self.tab reloadData];
    return true;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (!self.dataController.enableImmediatelySearch) {
        [self reloadData];
    }
    [self.searchBar endEditing:true];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.searching && self.dataController.enableImmediatelySearch) {
        [self reloadData];
    }
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searching?self.searchDatas.count:self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SnailSearchAroundCell *cell = [tableView dequeueReusableCellWithIdentifier:@"c"];
    [cell configureWithModel:self.searching?self.searchDatas[indexPath.row]:self.datas[indexPath.row] UI:self.uiController];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:true];
    });
    if (self.selectedBlock) {
        self.selectedBlock(self.searching?self.searchDatas[indexPath.row]:self.datas[indexPath.row]);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<SnailSearchAroundDataProtocol> data = self.searching?self.searchDatas[indexPath.row]:self.datas[indexPath.row];
    if (data.rowHeight > 0) return data.rowHeight;
    else if (self.uiController.rowHeight > 0) return self.uiController.rowHeight;
    else {
        
        CGFloat titleHeight = [data.title boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:self.uiController.titleAttribute context:nil].size.height;
        CGFloat addressHeight = [data.address boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:self.uiController.addressAttribute context:nil].size.height;
        CGFloat height = titleHeight + addressHeight + 40;
        if (titleHeight > 0 && addressHeight > 0) {
            height += self.uiController.titleSpaceing;
        }
        
        data.rowHeight = height;
        return height;
        
    }
    return 50.0f;
}

#pragma mark -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadMoreData:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadMoreData:scrollView];
    }
}

- (void)loadMoreData:(UIScrollView *)scrollView {
    
    if (self.dataController.nextPageBlock) {
        CGFloat currentOffsetY = scrollView.contentOffset.y;
        
        if (currentOffsetY + scrollView.frame.size.height  > scrollView.contentSize.height - 50 && !self.footer.indicator.animating && self.footer.indicator.hidden){
            [self.footer startAnimating];
            __weak typeof(self) self_weak_ = self;
            self.dataController.nextPageBlock(^(NSArray<id<SnailSearchAroundDataProtocol>> *results) {
                
                NSMutableArray *tmpDatas = self_weak_.searching?self_weak_.searchDatas:self_weak_.datas;
                
                BOOL isEmpty = tmpDatas.count == 0;
                
                [self_weak_.footer stopAnimating];
                
                if (isEmpty) {
                    [tmpDatas addObjectsFromArray:results];
                    [self_weak_.tab reloadData];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *indexs = [NSMutableArray new];
                        NSInteger tmpCount = tmpDatas.count;
                        for (NSInteger i = 0; i < results.count; i++) {
                            [tmpDatas addObject:results[i]];
                            [indexs addObject:[NSIndexPath indexPathForRow:tmpCount + i inSection:0]];
                        }
                        [self_weak_.tab beginUpdates];
                        [self_weak_.tab insertRowsAtIndexPaths:indexs withRowAnimation:UITableViewRowAnimationFade];
                        [self_weak_.tab endUpdates];
                    });
                }
                
            });
        }
    }
    
}

#pragma mark -

- (NSMutableArray<id<SnailSearchAroundDataProtocol>> *)datas {
    if (!_datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (NSMutableArray<id<SnailSearchAroundDataProtocol>> *)searchDatas {
    if (!_searchDatas) {
        _searchDatas = [NSMutableArray new];
    }
    return _searchDatas;
}

@end
