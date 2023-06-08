//
//  UILabel+LabelHeightAndWidth.h
//   fby 
//
//  Created by  fby  on 2021/6/8.
//  Copyright © 2021年  fby . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (LabelHeightAndWidth)

+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont*)font;

+ (CGFloat)getWidthWithTitle:(NSString *)title font:(UIFont *)font;

@end
