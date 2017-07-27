//
//  customDeleteTableViewCell.m
//  test
//
//  Created by yfzx-sh-baoxu on 2017/7/26.
//  Copyright © 2017年 鲍旭. All rights reserved.
//

#import "CustomDeleteTableViewCell.h"

@implementation CustomDeleteTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
    }
    return self ;
}

- (void)layoutSubviews {
    [super layoutSubviews] ;
    for(UIView *view in self.subviews) {
        //找到系统原生的删除页面
        if([view isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
            view.backgroundColor = [UIColor whiteColor] ;
            for(UIView *subView in view.subviews) {
                if([subView isKindOfClass:[UIButton class]]) {
                    //删除系统原生的按钮
                    [subView removeFromSuperview] ;
                }
            }
            UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
            deleteBtn.backgroundColor = [UIColor grayColor] ;
            deleteBtn.frame = CGRectMake(10, 5, view.frame.size.width - 20, view.frame.size.height - 10) ;
            deleteBtn.layer.cornerRadius = 5.0 ;
            [deleteBtn setTitle:@"删除" forState:UIControlStateNormal] ;
            [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] ;
            deleteBtn.titleLabel.textAlignment = NSTextAlignmentCenter ;
            deleteBtn.titleLabel.font = [UIFont systemFontOfSize:17.0] ;
            [deleteBtn addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside] ;
            [view addSubview:deleteBtn] ;
        }
    }  
}
- (void)deleteCell:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(cellDeletebuttonClickedWithCell:)]) {
        [self.delegate cellDeletebuttonClickedWithCell:self] ;
    }
}
@end
