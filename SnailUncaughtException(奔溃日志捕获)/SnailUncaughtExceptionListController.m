//
//  SnailUncaughtExceptionListController.m
//  KuaiYiTou
//
//  Created by 罗大侠 on 2019/2/14.
//  Copyright © 2019 com.jonnew. All rights reserved.
//

#import "SnailUncaughtExceptionListController.h"
#import "SnailUncaughtException.h"

@interface SnailUncaughtExceptionItem : NSObject

@property (nonatomic ,strong) NSString *name;
@property (nonatomic ,strong) NSString *path;

- (NSString *)content;

@end

@interface SnailUncaughtException ()

+ (NSArray<SnailUncaughtExceptionItem *> *)takeAllItem;

@end

@interface SnailUncaughtExceptionContentController : UIViewController

@property (nonatomic ,strong) UITextView *tx;

@end

@implementation SnailUncaughtExceptionContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tx = [UITextView new];
    self.tx.editable = false;
    self.tx.frame = self.view.bounds;
    self.tx.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
    self.view = self.tx;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setContent:(NSString *)content {
    self.tx.text = content;
}

- (void)backAction {
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}

@end

@interface SnailUncaughtExceptionListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tab;
@property (nonatomic ,strong) NSArray *datas;

@end

@implementation SnailUncaughtExceptionListController

+ (void)showFrome:(UIViewController *)vc {
    
    SnailUncaughtExceptionListController *tvc = [[self alloc] init];
    [vc presentViewController:[[UINavigationController alloc] initWithRootViewController:tvc] animated:true completion:^{
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"SnailUncaughtExceptionList";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    
    self.tab = [UITableView new];
    self.tab.tableFooterView = UIView.new;
    [self.tab registerClass:UITableViewCell.class forCellReuseIdentifier:@"c"];
    self.tab.separatorInset = UIEdgeInsetsZero;
    self.tab.delegate = self;
    self.tab.dataSource = self;
    self.tab.rowHeight = UITableViewAutomaticDimension;
    self.tab.estimatedRowHeight = 50;
    self.tab.frame = self.view.frame;
    self.tab.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.tab];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.datas = [SnailUncaughtException takeAllItem];
        [self.tab reloadData];
    });
    
}

- (void)backAction {
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"c"];
    UILabel *tb = [cell.contentView viewWithTag:-1];
    if (!tb) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        tb = [UILabel new];
        tb.numberOfLines = 0;
        tb.tag = -1;
        tb.translatesAutoresizingMaskIntoConstraints = false;
        [cell.contentView addSubview:tb];
        {
            NSLayoutConstraint *con0 = [NSLayoutConstraint constraintWithItem:tb attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:15];
            con0.active = true;
            
            NSLayoutConstraint *con1 = [NSLayoutConstraint constraintWithItem:tb attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-15];
            con1.active = true;
            
            NSLayoutConstraint *con2 = [NSLayoutConstraint constraintWithItem:tb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:15];
            con2.active = true;
            
            NSLayoutConstraint *con3 = [NSLayoutConstraint constraintWithItem:tb attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-15];
            con3.active = true;
        }
    }
    
    SnailUncaughtExceptionItem *item = self.datas[indexPath.row];
    tb.text = item.name;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        SnailUncaughtExceptionItem *item = self.datas[indexPath.row];
        
        SnailUncaughtExceptionContentController *vc = [SnailUncaughtExceptionContentController new];
        vc.title = item.name;
        
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:true completion:^{
            [vc setContent:item.content];
        }];
        
    });
    
}

@end
