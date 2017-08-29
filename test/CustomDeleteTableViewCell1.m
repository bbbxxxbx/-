//
//  CustomDeleteTableViewCell1.m
//  test
//
//  Created by yfzx-sh-baoxu on 2017/8/25.
//  Copyright © 2017年 鲍旭. All rights reserved.
//

#import "CustomDeleteTableViewCell1.h"
#import "CustomScrollView.h"

@interface CustomDeleteTableViewCell1 ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIButton *deleteBtn ;
@property (nonatomic, strong) CustomScrollView *scrollView ;
@property (nonatomic, strong) UIView *bgView ;

@end

static const CGFloat deleteBtnWidth = 80.0 ;
static const CGFloat margin = 15.0 ;

@implementation CustomDeleteTableViewCell1

+ (instancetype) cellWithTableView:(UITableView *)tableView {
    NSString *identifier = NSStringFromClass(self) ;
    CustomDeleteTableViewCell1 *cell = [tableView dequeueReusableCellWithIdentifier:identifier] ;
    if(cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    }
    return cell ;
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor] ;
        [self drawUI] ;
    }
    return self ;
}

- (void)drawUI {
    _scrollView = [[CustomScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, CellHeight)] ;
    _scrollView.contentSize = CGSizeMake(ScreenWidth + deleteBtnWidth + margin, CellHeight) ;
    _scrollView.backgroundColor = [UIColor whiteColor] ;
    _scrollView.delegate = self ;
    _scrollView.showsHorizontalScrollIndicator = NO ;
    _scrollView.scrollsToTop = NO ;
    [self.contentView addSubview:_scrollView] ;
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
    _deleteBtn.backgroundColor = [UIColor grayColor] ;
    _deleteBtn.frame = CGRectMake(ScreenWidth - deleteBtnWidth - margin, 7.5, deleteBtnWidth, CellHeight - 15) ;
    _deleteBtn.layer.cornerRadius = 5.0 ;
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal] ;
    [_deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal] ;
    _deleteBtn.titleLabel.textAlignment = NSTextAlignmentCenter ;
    _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:17.0] ;
    [_deleteBtn addTarget:self action:@selector(deleteCell) forControlEvents:UIControlEventTouchUpInside] ;
    [_scrollView addSubview:_deleteBtn] ;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(margin, 7.5, ScreenWidth - margin*2, CellHeight - 15)] ;
    bgView.layer.cornerRadius = 5.0 ;
    bgView.backgroundColor = [UIColor blueColor] ;
    bgView.userInteractionEnabled = YES ;
    [_scrollView addSubview:bgView] ;
}


- (void)deleteCell {
    if ([self.delegate respondsToSelector:@selector(cellDeletebuttonClickedWithCell:)]) {
        [self.delegate cellDeletebuttonClickedWithCell:self] ;
    }
}

- (void)clickWithCompletion:(void(^)(void))completion {
    _model.showDeleting = NO ;
    if(_scrollView.contentOffset.x > 0) {
        _scrollView.userInteractionEnabled = NO ;
        [UIView animateWithDuration:0.3 animations:^{
            [_scrollView setContentOffset:CGPointZero] ;
        } completion:^(BOOL finished) {
            _scrollView.userInteractionEnabled = YES ;
        }] ;
    }
    else {
        completion () ;
    }
}
- (void)hideDeleteBtn {
    _model.showDeleting = NO ;
    if(_scrollView.contentOffset.x > 0) {
        _scrollView.userInteractionEnabled = NO ;
        [UIView animateWithDuration:0.3 animations:^{
            [_scrollView setContentOffset:CGPointZero] ;
        } completion:^(BOOL finished) {
            _scrollView.userInteractionEnabled = YES ;
        }];
    }
}

- (void)showDeleteBtn {
    _model.showDeleting = YES ;
    _scrollView.userInteractionEnabled = NO ;
    [UIView animateWithDuration:0.2 animations:^{
        [_scrollView setContentOffset:CGPointMake(deleteBtnWidth + margin, 0)] ;
    } completion:^(BOOL finished) {
        _scrollView.userInteractionEnabled = YES ;
    }] ;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.x > 0) {
        _deleteBtn.frame = CGRectMake(scrollView.contentOffset.x + ScreenWidth - deleteBtnWidth - margin, 7.5, deleteBtnWidth, CellHeight - 15) ;
    }
    else {
        _deleteBtn.frame = CGRectMake(ScreenWidth - deleteBtnWidth - margin, 7.5, deleteBtnWidth, CellHeight - 15) ;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        if(scrollView.contentOffset.x >= 0) {
            if(scrollView.contentOffset.x < (deleteBtnWidth+margin)/2) {
                [self hideDeleteBtn] ;
            }
            else {
                [self showDeleteBtn] ;
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.x >= 0) {
        if(scrollView.contentOffset.x < (deleteBtnWidth+margin)/2) {
            [self hideDeleteBtn] ;
        }
        else {
            [self showDeleteBtn] ;
        }
    }
}

- (void)setModel:(DeleteModel *)model {
    _model = model ;
    if(model.showDeleting) {
        [_scrollView setContentOffset:CGPointMake(deleteBtnWidth + margin, 0)] ;
    }
    else {
        [_scrollView setContentOffset:CGPointZero] ;
    }
}
@end
