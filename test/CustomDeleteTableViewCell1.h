//
//  CustomDeleteTableViewCell1.h
//  test
//
//  Created by yfzx-sh-baoxu on 2017/8/25.
//  Copyright © 2017年 鲍旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomDeleteTableViewCell.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define CellHeight 175

@interface CustomDeleteTableViewCell1 : UITableViewCell

@property (nonatomic, weak) id<deleteButtonClickedDelegate> delegate ;

+ (instancetype) cellWithTableView:(UITableView *)tableView ;

- (void)clickWithCompletion:(void(^)(void))completion ;

@end
