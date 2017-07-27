//
//  customDeleteTableViewCell.h
//  test
//
//  Created by yfzx-sh-baoxu on 2017/7/26.
//  Copyright © 2017年 鲍旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol deleteButtonClickedDelegate <NSObject>
- (void)cellDeletebuttonClickedWithCell:(UITableViewCell *)cell ;
@end

@interface CustomDeleteTableViewCell : UITableViewCell

@property (nonatomic, weak) id<deleteButtonClickedDelegate> delegate ;

@end
