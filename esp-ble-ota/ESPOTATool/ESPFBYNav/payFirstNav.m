//
//  payFirstNav.m
//   fby
//
//  Created by  fby  on 2021/4/21.
//  Copyright © 2021年  fby . All rights reserved.
//

#import "payFirstNav.h"
#import "UILabel+LabelHeightAndWidth.h"

@implementation payFirstNav

- (instancetype)initWithLeftBtn:(NSString *)leftBtn andWithTitleLab:(NSString *)titleLab andWithRightBtn:(NSString *)rightBtn andWithBgImg:(UIImageView *)bgImg{
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, statusHeight + 44)];
    
    if (self) {
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-SCREEN_WIDTH/6, statusHeight - 6, SCREEN_WIDTH/3, 50)];
        self.titleLab.backgroundColor = [UIColor clearColor];
        self.titleLab.font = [UIFont systemFontOfSize:17.0];
        self.titleLab.textAlignment = NSTextAlignmentCenter;
        self.titleLab.text = titleLab;
        [self addSubview:_titleLab];

        self.leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, statusHeight - 6, 50, 50)];
        self.leftBtn.backgroundColor = [UIColor clearColor];
        if (leftBtn != nil) {
            [self.leftBtn setBackgroundImage:[UIImage imageNamed:leftBtn] forState:UIControlStateNormal];
        }
        [self addSubview:_leftBtn];

        self.rightBtn = [[UIButton alloc]init];
        self.rightBtn.backgroundColor = [UIColor clearColor];
        [self.rightBtn setTitleColor:[UIColor blackColor] forState:0];
        if (rightBtn != nil) {
            [self.rightBtn setTitle:rightBtn forState:0];
        }
        CGFloat width = [UILabel getWidthWithTitle:self.rightBtn.titleLabel.text font:self.rightBtn.titleLabel.font];
        self.rightBtn.frame = CGRectMake(SCREEN_WIDTH - width - 10, statusHeight - 6, width, 50);
        [self addSubview:_rightBtn];
  
    }
    return self;
}

@end
