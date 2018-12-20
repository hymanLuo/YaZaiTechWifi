//
//  YZSetupViewCell.m
//  YaZaiTech
//
//  Created by DongWu on 2018/7/6.
//  Copyright © 2018年 Can He Chan. All rights reserved.
//

#import "YZSetupViewCell.h"

@implementation YZSetupViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    
    static NSString *ID = @"YZSetupViewCell";
    YZSetupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[YZSetupViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.backgroundColor=[UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // 添加cell内部的子控件
        [self setupOriginalSubviews];
        
    }
    return self;
}

-(void)setupOriginalSubviews{
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, YZSCREEN_WIDTH, 44)];
    image.image = [UIImage imageNamed:@"set_2btn_Dialog_default"];
    image.alpha = 0.3;
    [self addSubview:image];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, YZSCREEN_WIDTH*0.5, 44)];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.titleLabel];
    
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(YZSCREEN_WIDTH-28-14, 15, 7, 14)];
    arrow.image = [UIImage imageNamed:@"icom_e_img_s5"];
    [self addSubview:arrow];
    

}

@end
