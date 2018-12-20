//
//  YZSetupViewCell.h
//  YaZaiTech
//
//  Created by DongWu on 2018/7/6.
//  Copyright © 2018年 Can He Chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YZSetupViewCell : UITableViewCell

@property (nonatomic,strong) UILabel   *titleLabel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
