//
//  YZDirectionViewController.m
//  YaZaiTechWifi
//
//  Created by cheng luo on 2018/12/13.
//  Copyright © 2018年 homeSalf. All rights reserved.
//

#import "YZDirectionViewController.h"

@interface YZDirectionViewController ()

@end

@implementation YZDirectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"芽仔使用说明";
    
    //设置返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"back_image"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, 40, 40);
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    //设置背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -1, YZSCREEN_WIDTH, YZSCREEN_HEIGHT+2)];
    backgroundImageView.image = [UIImage imageNamed:@"YZBlueScan_selected"];
    [self.view addSubview:backgroundImageView];

    
    CGSize imageSize = [UIImage imageNamed:@"help_doc"].size;
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"help_doc"]];
    imageView.frame = CGRectMake(0, 0, YZSCREEN_WIDTH, imageSize.height/imageSize.width *YZSCREEN_WIDTH);
//    [self.view addSubview:imageView];
    
    UIScrollView *scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, YZSCREEN_WIDTH, YZSCREEN_HEIGHT)];
    [scrollview setContentSize:CGSizeMake(YZSCREEN_WIDTH, imageSize.height/imageSize.width *YZSCREEN_WIDTH)];
    [self.view addSubview:scrollview];
    
    [scrollview addSubview:imageView];
    
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
