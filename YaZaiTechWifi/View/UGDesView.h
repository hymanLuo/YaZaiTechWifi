//
//  UGDesView.h
//  YaZai
//
//  Created by admin on 2018/11/24.
//

#import <UIKit/UIKit.h>

@interface UGDesView : UIView

@property(strong,nonatomic)UIImageView *imageView;//宝宝睡觉姿势imageview
@property(strong,nonatomic)UILabel *titleLab;//宝宝睡觉姿势描述lab

// 初始化
-(instancetype)initWithFrame:(CGRect)frame;

@end
