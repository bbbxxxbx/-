//
//  ViewController1.m
//  test
//
//  Created by yfzx-sh-baoxu on 2017/7/19.
//  Copyright © 2017年 鲍旭. All rights reserved.
//

#import "ViewController1.h"
#import "CustomDeleteTableViewCell1.h"

@interface ViewController1 ()<UITableViewDelegate, UITableViewDataSource, deleteButtonClickedDelegate>

@property (nonatomic, strong) UITableView *tableView ;
@property (nonatomic, strong) UIView *refreshView ;
@property (nonatomic, strong) UIView *fixedView ;
@property (nonatomic, strong) UIView *movedView ;

@property (nonatomic, assign) BOOL isRequird ;
@property (nonatomic, strong) NSMutableArray *data ;

@property (nonatomic, strong) NSMutableArray *smallItems ;
@property (nonatomic, strong) NSMutableArray *bigItems ;

@end

#define movedHeight 200
#define fixedNormalHeight 100
#define fixedSmallHeight 50
#define tabBarHeight 49
#define statusBarHeight 20

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _data = [NSMutableArray array] ;
    for(NSInteger index=0; index<10; index++) {
        DeleteModel *model = [[DeleteModel alloc] init] ;
        [_data addObject:model] ;
    }

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, statusBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - tabBarHeight) style:UITableViewStylePlain] ;
    _tableView.delegate = self ;
    _tableView.dataSource = self ;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    [self.view addSubview:_tableView] ;
    
    UIView *tablHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, movedHeight + fixedNormalHeight)] ;
    tablHeaderView.backgroundColor = [UIColor clearColor] ;
    _tableView.tableHeaderView = tablHeaderView ;
    
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(movedHeight + fixedNormalHeight, 0, 0, 0) ;
    
    _refreshView = [[UIView alloc]initWithFrame:CGRectMake(0, movedHeight + fixedNormalHeight - 50, [UIScreen mainScreen].bounds.size.width , 50)] ;
    _refreshView.backgroundColor = [UIColor whiteColor] ;
    UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)] ;
    tip.text = @"刷新动画" ;
    tip.textColor = [UIColor blackColor] ;
    tip.font = [UIFont systemFontOfSize:14] ;
    tip.textAlignment = NSTextAlignmentCenter ;
    [_refreshView addSubview:tip] ;
    [_tableView.tableHeaderView addSubview:_refreshView] ;
    
    _movedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, movedHeight + fixedNormalHeight)] ;
    _movedView.backgroundColor = [UIColor redColor] ;
    [_tableView addSubview:_movedView] ;
    
    _fixedView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, [UIScreen mainScreen].bounds.size.width, fixedNormalHeight)] ;
    _fixedView.backgroundColor = [UIColor yellowColor] ;
    [self.view addSubview:_fixedView] ;
 
    //大按钮模块
    _bigItems = [NSMutableArray array] ;
    CGFloat bigSpace = ([UIScreen mainScreen].bounds.size.width-53*2-50*3)/2.0 ;
    
    UIView *bigItem1 = [[UIView alloc] initWithFrame:CGRectMake(53,30,50,50)] ;
    bigItem1.backgroundColor = [UIColor blueColor] ;
    [_bigItems addObject:bigItem1] ;
    [_fixedView addSubview:bigItem1] ;
    
    UIView *bigItem2 = [[UIView alloc] initWithFrame:CGRectMake(53+50+bigSpace,30,50,50)] ;
    bigItem2.backgroundColor = [UIColor blueColor] ;
    [_bigItems addObject:bigItem2] ;
    [_fixedView addSubview:bigItem2] ;
    
    UIView *bigItem3 = [[UIView alloc] initWithFrame:CGRectMake(53+50+bigSpace+50+bigSpace,30,50,50)] ;
    bigItem3.backgroundColor = [UIColor blueColor] ;
    [_bigItems addObject:bigItem3] ;
    [_fixedView addSubview:bigItem3] ;
    
    //小按钮模块
    _smallItems = [NSMutableArray array] ;
    CGFloat smallSpace = ([UIScreen mainScreen].bounds.size.width*2/3-37*2-25*3)/2.0 ;
    UIView *smallItem1 = [[UIView alloc] initWithFrame:CGRectMake(37, 20, 25, 25)] ;
    smallItem1.backgroundColor = [UIColor blueColor] ;
    [_smallItems addObject:smallItem1] ;
    [_fixedView addSubview:smallItem1] ;
    
    UIView *smallItem2 = [[UIView alloc] initWithFrame:CGRectMake(37+25+smallSpace, 20, 25, 25)] ;
    smallItem2.backgroundColor = [UIColor blueColor] ;
    [_smallItems addObject:smallItem2] ;
    [_fixedView addSubview:smallItem2] ;
    
    UIView *smallItem3 = [[UIView alloc] initWithFrame:CGRectMake(37+25+smallSpace+25+smallSpace, 20, 25, 25)] ;
    smallItem3.backgroundColor = [UIColor blueColor] ;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CellHeight ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CustomDeleteTableViewCell1 cellWithTableView:_tableView] ;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomDeleteTableViewCell1 *myCell = (CustomDeleteTableViewCell1 *)cell ;
    myCell.delegate = self ;
    DeleteModel *model = [_data objectAtIndex:indexPath.row] ;
    myCell.model = model ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomDeleteTableViewCell1 *cell = (CustomDeleteTableViewCell1 *)[tableView cellForRowAtIndexPath:indexPath] ;
    [cell clickWithCompletion:^{
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:@"点击了cell" preferredStyle:UIAlertControllerStyleAlert] ;
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertView dismissViewControllerAnimated:YES completion:nil] ;
        }] ;
        [alertView addAction:alertAction] ;
        [self presentViewController:alertView animated:YES completion:nil];
    }] ;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat tableViewOffSetY = scrollView.contentOffset.y ;
    if(tableViewOffSetY >= 0) {
        _movedView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, movedHeight + fixedNormalHeight) ;
        if(tableViewOffSetY <= (fixedNormalHeight-fixedSmallHeight)) {
            CGRect frame = _fixedView.frame ;
            CGFloat height = fixedNormalHeight - tableViewOffSetY ;
            frame = CGRectMake(0, statusBarHeight, [UIScreen mainScreen].bounds.size.width, height) ;
            _fixedView.frame = frame ;
            
            //大图标透明度改变的位移范围为(0～0.25)*fixedNormalHeight，小图标透明度改变的位移范围为0.2*fixedNormalHeight～(fixedNormalHeight-fixedSmallHeight)
            CGFloat bigAlpha = tableViewOffSetY<(0.25*fixedNormalHeight)?(1.0-tableViewOffSetY/(0.25*fixedNormalHeight)):0.0 ;
            CGFloat smallAlpha = tableViewOffSetY>(0.2*fixedNormalHeight)?(tableViewOffSetY-0.2*fixedNormalHeight)/(fixedNormalHeight-fixedSmallHeight-0.2*fixedNormalHeight):0.0 ;
            [self adjustItems:_bigItems alpha:bigAlpha] ;
            [self adjustItems:_smallItems alpha:smallAlpha] ;
            
        }
        else {
            _fixedView.frame = CGRectMake(0, statusBarHeight, [UIScreen mainScreen].bounds.size.width, fixedSmallHeight) ;
            [self adjustItems:_bigItems alpha:0.0] ;
            [self adjustItems:_smallItems alpha:1.0] ;
        }
    }
    else {
        _movedView.frame = CGRectMake(0, tableViewOffSetY, [UIScreen mainScreen].bounds.size.width, movedHeight + fixedNormalHeight) ;
        
        _fixedView.frame = CGRectMake(0, statusBarHeight, [UIScreen mainScreen].bounds.size.width, fixedNormalHeight) ;
        [self adjustItems:_bigItems alpha:1.0] ;
        [self adjustItems:_smallItems alpha:0.0] ;
        
        if(tableViewOffSetY<-60 && [scrollView isDecelerating]) {
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

- (void)cellDeletebuttonClickedWithCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath= [_tableView indexPathForCell:cell] ;
    [_data removeObjectAtIndex:indexPath.row] ;
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade] ;
    [_tableView bringSubviewToFront:_movedView] ; //防止movedView被tableView的headerView覆盖
}
@end
