//
//  VerticalButton.m
//  test
//
//  Created by yfzx-sh-baoxu on 2017/7/21.
//  Copyright © 2017年 鲍旭. All rights reserved.
//

#import "VerticalButton.h"
#import "NSString+NSStringAddition.h"

@implementation VerticalButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView.contentMode = UIViewContentModeCenter ;
        self.titleLabel.textAlignment = NSTextAlignmentCenter ;
        self.titleLabel.numberOfLines = 0 ;
    }
    return self ;
}

- (void)layoutSubviews {
    [super layoutSubviews] ;
    
    CGFloat imageHeight = self.imageView.image.size.height ;
    CGFloat imageWidth  = self.imageView.image.size.width ;
    if(self.imageSize.width != 0 && self.imageSize.height != 0) {
        imageWidth = self.imageSize.width ;
        imageHeight = self.imageSize.height ;
    }
    CGFloat imageX = (self.bounds.size.width - imageWidth) / 2.0 ;
    CGFloat imageY = 0;
    CGFloat imageH = imageHeight;
    CGFloat imageW = imageWidth;
    self.imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    
    CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width ;
    CGSize titleSize = sizeOfString(self.currentTitle, CGSizeMake(ScreenWidth, MAXFLOAT), self.titleLabel.font) ;
    CGFloat titleY = imageH + imageY + _spaceBetweenImageTitle;
    CGFloat titleX = (self.bounds.size.width - titleSize.width) / 2.0 ;
    CGFloat titleW = titleSize.width ;
    CGFloat titleH = titleSize.height ;
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
}

- (void)setSpaceBetweenImageTitle:(CGFloat)spaceBetweenImageTitle {
    _spaceBetweenImageTitle = spaceBetweenImageTitle ;
    CGRect titleFrame = self.titleLabel.frame ;
    self.titleLabel.frame = CGRectMake(titleFrame.origin.x, titleFrame.origin.y + spaceBetweenImageTitle, titleFrame.size.width, titleFrame.size.height) ;
}

CGSize sizeOfString(NSString *string, CGSize constrainedSize, UIFont *font) {
    return [string stringWithSize:constrainedSize font:font];
}
@end
