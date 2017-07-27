//
//  NSString+NSStringAddition.m
//  test
//
//  Created by yfzx-sh-baoxu on 2017/7/24.
//  Copyright © 2017年 鲍旭. All rights reserved.
//

#import "NSString+NSStringAddition.h"

@implementation NSString (NSStringAddition)

//NSStringDrawingUsesLineFragmentOrigin 将以每行文字所占据的矩形为单位计算整个文本的大小
- (CGSize)stringWithSize:(CGSize)maxSize font:(UIFont *)font {
    return [self boundingRectWithSize:maxSize
                              options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:@{NSFontAttributeName: font}
                              context:nil].size ;
}
@end
