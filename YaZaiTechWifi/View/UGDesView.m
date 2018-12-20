//
//  UGDesView.m
//  YaZai
//
//  Created by admin on 2018/11/24.
//

#import "UGDesView.h"

@implementation UGDesView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self loadUI];
    }
    return self;
}
-(void)loadUI{
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.titleLab = [[UILabel alloc]initWithFrame:CGRectZero];
    [self addSubview:_imageView];
    [self addSubview:_titleLab];
}

@end
