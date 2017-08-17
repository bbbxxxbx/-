//
//  ViewController.m
//  test
//
//  Created by yfzx-sh-baoxu on 2017/6/19.
//  Copyright © 2017年 鲍旭. All rights reserved.
//

#import "ViewController.h"
#import "VerticalButton.h"
#import "CustomDeleteTableViewCell.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, deleteButtonClickedDelegate>

@property (nonatomic, strong) UITableView *tableView ;
@property (nonatomic, strong) UIView *refreshView ;
@property (nonatomic, strong) UIView *movedView ;
@property (nonatomic, strong) UIView *fixedView ;

@property (nonatomic, assign) BOOL isRequird ;
@property (nonatomic, strong) NSMutableArray *data ;

@property (nonatomic, strong) NSMutableArray *bigItems ;
@property (nonatomic, strong) NSMutableArray *smallItems ;

@end

#define movedHeight 200
#define fixedNormalHeight 100
#define fixedSmallHeight 55
#define tabBarHeight 49

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _isRequird = NO ;
    _data = [NSMutableArray array] ;
    for(NSInteger index=0; index<10; index++) {
        [_data addObject:@(index)] ;
    }
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - tabBarHeight) style:UITableViewStylePlain] ;
    _tableView.delegate = self ;
    _tableView.dataSource = self ;
    _tableView.bounces = YES ;
    [self.view addSubview:_tableView] ;
    
    //用一个透明的view将tableView的header撑开
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, movedHeight)] ;
    tableHeaderView.backgroundColor = [UIColor clearColor] ;
    _tableView.tableHeaderView = tableHeaderView ;
    
    //用一个透明的view将tableView的footer撑开
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, fixedSmallHeight)] ;
    tableHeaderView.backgroundColor = [UIColor clearColor] ;
    _tableView.tableFooterView = tableFooterView ;

    //修改scrollIndicatorInsets。仿造出tableView从下方开始的效果
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(movedHeight, 0, 0, 0);
    
    //再在header下方添加一个刷新用的view
    _refreshView = [[UIView alloc]initWithFrame:CGRectMake(0, movedHeight - 50, [UIScreen mainScreen].bounds.size.width , 50)] ;
    _refreshView.backgroundColor = [UIColor whiteColor] ;
    UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)] ;
    tip.text = @"刷新动画" ;
    tip.textColor = [UIColor blackColor] ;
    tip.font = [UIFont systemFontOfSize:14] ;
    tip.textAlignment = NSTextAlignmentCenter ;
    [_refreshView addSubview:tip] ;
    [_tableView.tableHeaderView addSubview:_refreshView] ;
    
    
    _movedView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width ,movedHeight)] ;
    _movedView.backgroundColor = [UIColor redColor] ;
    
    //展示用的movedView需要添加在tableView上来进行联动
    [self.tableView addSubview:_movedView] ;
    [self.tableView bringSubviewToFront:_movedView] ;

    _fixedView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - tabBarHeight - fixedNormalHeight, [UIScreen mainScreen].bounds.size.width, fixedNormalHeight)] ;
    _fixedView.backgroundColor = [UIColor yellowColor] ;
    [self.view addSubview:_fixedView] ;
    
    //大按钮模块
    _bigItems = [NSMutableArray array] ;
    CGFloat bigSpace = ([UIScreen mainScreen].bounds.size.width-53*2-50*3)/2.0 ;
    
    VerticalButton *bigItem1 = [self addBigItemWithFrame:CGRectMake(53,30,50,fixedNormalHeight-30*2) image:[UIImage imageNamed:@"付款码"] title:@"付款码"] ;
    bigItem1.tag = 100 ;
    [_bigItems addObject:bigItem1] ;
    [_fixedView addSubview:bigItem1] ;
    
    VerticalButton *bigItem2 = [self addBigItemWithFrame:CGRectMake(53+50+bigSpace,30,50,fixedNormalHeight-30*2) image:[UIImage imageNamed:@"扫一扫"] title:@"扫一扫"] ;
    bigItem2.tag = 101 ;
    [_bigItems addObject:bigItem2] ;
    [_fixedView addSubview:bigItem2] ;
    
    VerticalButton *bigItem3 = [self addBigItemWithFrame:CGRectMake(53+50+bigSpace+50+bigSpace,30,50,fixedNormalHeight-30*2) image:[UIImage imageNamed:@"转账"] title:@"转账"] ;
    bigItem3.tag = 102 ;
    [_bigItems addObject:bigItem3] ;
    [_fixedView addSubview:bigItem3] ;
    
    //小按钮模块
    _smallItems = [NSMutableArray array] ;
    CGFloat smallSpace = ([UIScreen mainScreen].bounds.size.width*2/3-37*2-25*3)/2.0 ;

    UIButton *smallItem1 = [self addSmallItemWithFrame:CGRectMake(37, 15+(fixedNormalHeight-fixedSmallHeight), 25, fixedSmallHeight-15*2) image:[UIImage imageNamed:@"付款码"]] ;
    smallItem1.tag = 100 ;
    [_smallItems addObject:smallItem1] ;
    [_fixedView addSubview:smallItem1] ;
    
    UIButton *smallItem2 = [self addSmallItemWithFrame:CGRectMake(37+25+smallSpace, 15+(fixedNormalHeight-fixedSmallHeight), 25, fixedSmallHeight-15*2) image:[UIImage imageNamed:@"扫一扫"]] ;
    smallItem2.tag = 101 ;
    [_smallItems addObject:smallItem2] ;
    [_fixedView addSubview:smallItem2] ;
    
    UIButton *smallItem3 = [self addSmallItemWithFrame:CGRectMake(37+25+smallSpace+25+smallSpace, 15+(fixedNormalHeight-fixedSmallHeight), 25, fixedSmallHeight-15*2) image:[UIImage imageNamed:@"转账"]] ;
    smallItem3.tag = 102 ;
    [_smallItems addObject:smallItem3] ;
    [_fixedView addSubview:smallItem3] ;
    
    [self adjustItems:_smallItems alpha:0.0] ;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
    [_tableView reloadData] ;
}

- (void)adjustItems:(NSArray <UIButton *>*)items alpha:(CGFloat)alpha {
    [items enumerateObjectsUsingBlock:^(UIButton *item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.alpha = alpha ;
    }] ;
}

- (VerticalButton *)addBigItemWithFrame:(CGRect)frame image:(UIImage *)image title:(NSString *)title {
    VerticalButton *item = [[VerticalButton alloc] initWithFrame:frame] ;
    [item setImage:image forState:UIControlStateNormal] ;
    item.imageSize = CGSizeMake(32.0, 32.0) ;
    [item setTitle:title forState:UIControlStateNormal] ;
    [item setTitleColor:[UIColor blackColor] forState:UIControlStateNormal] ;
    item.titleLabel.font = [UIFont boldSystemFontOfSize:10.0] ;
    item.spaceBetweenImageTitle = 10.0 ;
    [item addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside] ;
    return item ;
}

- (UIButton *)addSmallItemWithFrame:(CGRect)frame image:(UIImage *)image {
    UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom] ;
    item.frame = frame ;
    [item setImage:image forState:UIControlStateNormal] ;
    [item addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside] ;
    return item ;
}

- (void)clickItem:(UIButton *)item {
    NSString *message = nil ;
    switch (item.tag) {
        case 100:
            message = @"点击付款码" ;
            break;
        case 101:
            message = @"点击扫一扫" ;
            break ;
        case 102:
            message = @"点击转账" ;
            break ;
        default:
            break ;
    }
    if(message != nil) {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert] ;
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertView dismissViewControllerAnimated:YES completion:nil] ;
        }] ;
        [alertView addAction:alertAction] ;
        [self presentViewController:alertView animated:YES completion:nil];
    }
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat tableViewoffsetY = scrollView.contentOffset.y ;
    
    if (tableViewoffsetY >= 0) {
        //当滑动的offset大于等于0时,movedView随tableView滑动
        _movedView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, movedHeight) ;
        //fixedView处理
        if(tableViewoffsetY <= (fixedNormalHeight-fixedSmallHeight)) {
            CGRect frame = _fixedView.frame ;
            CGFloat height = fixedNormalHeight - tableViewoffsetY ;
            frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-tabBarHeight-height, [UIScreen mainScreen].bounds.size.width, height) ;
            _fixedView.frame = frame ;
            
            //大图标透明度改变的位移范围为(0～0.25)*fixedNormalHeight，小图标透明度改变的位移范围为0.2*fixedNormalHeight~(fixedNormalHeight-fixedSmallHeight)
            CGFloat bigAlpha = tableViewoffsetY<(0.25*fixedNormalHeight)?(1.0-tableViewoffsetY/(0.25*fixedNormalHeight)):0.0 ;
            CGFloat smallAlpha = tableViewoffsetY>(0.2*fixedNormalHeight)?(tableViewoffsetY-0.2*fixedNormalHeight)/(fixedNormalHeight-fixedSmallHeight-0.2*fixedNormalHeight):0.0 ;
            [self adjustItems:_bigItems alpha:bigAlpha] ;
            [self adjustItems:_smallItems alpha:smallAlpha] ;
            
            //滑动过程中保证小图标位置不变
            [_smallItems enumerateObjectsUsingBlock:^(UIButton *item, NSUInteger idx, BOOL * _Nonnull stop) {
                CGRect smallFrame = item.frame ;
                smallFrame.origin.y = 15 + (fixedNormalHeight-fixedSmallHeight) - tableViewoffsetY ;
                item.frame = smallFrame ;
            }] ;
        }
        else {
            _fixedView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-tabBarHeight-fixedSmallHeight, [UIScreen mainScreen].bounds.size.width, fixedSmallHeight) ;
            
            [_smallItems enumerateObjectsUsingBlock:^(UIButton *item, NSUInteger idx, BOOL * _Nonnull stop) {
                CGRect smallFrame = item.frame ;
                smallFrame.origin.y = 15 ;
                item.frame = smallFrame ;
            }] ;
            [self adjustItems:_bigItems alpha:0.0] ;
            [self adjustItems:_smallItems alpha:1.0] ;
        }
    }
    else if(tableViewoffsetY < 0){
        //当滑动的offset小于0时，movedView保持不动
        
        /*
         滑动时，虽然tableView的frame.origin.y不会变化，但是tableView的bounds.origin.y会变化，所以tableView上所有子页面相对于tableView父页面的位置就会发生变化，如果不进行处理，movedView就会随着tableView一起滑动。因此为了使movedView固定在父页面上，需要不断改变movedView的frame.origin.y
        */
        _movedView.frame = CGRectMake(0, tableViewoffsetY, [UIScreen mainScreen].bounds.size.width, movedHeight) ;
        //fixedView保持不变
        _fixedView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - tabBarHeight - fixedNormalHeight, [UIScreen mainScreen].bounds.size.width, fixedNormalHeight) ;
        [self adjustItems:_bigItems alpha:1.0] ;
        [self adjustItems:_smallItems alpha:0.0] ;
        
        //刷新View
        if(tableViewoffsetY<-60 && [scrollView isDecelerating]) {
            [self requird] ;
            [self.tableView setContentOffset:CGPointMake(0, -50) animated:YES] ;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        if(scrollView.contentOffset.y >= 0) {
            if(scrollView.contentOffset.y < fixedSmallHeight*0.5) {
                [scrollView setContentOffset:CGPointMake(0, 0) animated:YES] ;
            }
            else if(scrollView.contentOffset.y < fixedSmallHeight) {
                [scrollView setContentOffset:CGPointMake(0, fixedSmallHeight) animated:YES] ;
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y >= 0) {
        if(scrollView.contentOffset.y < fixedSmallHeight*0.5) {
            [scrollView setContentOffset:CGPointMake(0, 0) animated:YES] ;
        }
        else if(scrollView.contentOffset.y < fixedSmallHeight) {
            [scrollView setContentOffset:CGPointMake(0, fixedSmallHeight) animated:YES] ;
        }
    }
}

- (void)requird {
    if(_isRequird) {
        return ;
    }
    _isRequird = YES ;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isRequird = NO ;
        [self.tableView setContentOffset:CGPointZero animated:YES] ;
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellidentifier = @"cellidentifier" ;
    CustomDeleteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier] ;
    if (cell == nil) {
        cell = [[CustomDeleteTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellidentifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone ;
        cell.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:100.0/255.0 blue:255.0/255.0 alpha:1.0] ;
        cell.delegate = self ;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[_data objectAtIndex:indexPath.row]] ;
    return cell ;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"                  ";//这里空格的长度是删除按钮的长度
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)cellDeletebuttonClickedWithCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath= [_tableView indexPathForCell:cell] ;
    [_data removeObjectAtIndex:indexPath.row] ;
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade] ;
    [_tableView bringSubviewToFront:_movedView] ; //防止movedView被tableView的headerView覆盖
}
@end
