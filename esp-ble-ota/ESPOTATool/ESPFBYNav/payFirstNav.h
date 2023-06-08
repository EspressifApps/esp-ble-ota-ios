//
//  payFirstNav.h
//   fby 
//
//  Created by  fby  on 2021/4/21.
//  Copyright © 2021年  fby . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface payFirstNav : UIView
@property(strong,nonatomic)UIImageView *bgImg;

@property(strong,nonatomic)UIButton *rightBtn;

@property(strong,nonatomic)UILabel *titleLab;

@property(strong,nonatomic)UIButton *leftBtn;

- (instancetype)initWithLeftBtn:(NSString *)leftBtn andWithTitleLab:(NSString *)titleLab andWithRightBtn:(NSString *)rightBtn andWithBgImg:(UIImageView *)bgImg ;
@end
