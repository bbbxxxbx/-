//
//  CustomScrollView.m
//  test
//
//  Created by yfzx-sh-baoxu on 2017/8/25.
//  Copyright © 2017年 鲍旭. All rights reserved.
//

#import "CustomScrollView.h"

@implementation CustomScrollView

//使scrollView上的触摸事件能够传递到父页面上
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

@end
