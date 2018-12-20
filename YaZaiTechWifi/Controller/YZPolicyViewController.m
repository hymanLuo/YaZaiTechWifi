//
//  YZPolicyViewController.m
//  YaZaiTechWifi
//
//  Created by cheng luo on 2018/12/17.
//  Copyright © 2018年 homeSalf. All rights reserved.
//

#import "YZPolicyViewController.h"

@interface YZPolicyViewController ()

@end

@implementation YZPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"隐私条款";
    //设置返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backButton setImage:[UIImage imageNamed:@"back_image"] forState:UIControlStateNormal];
    [backButton setTitle:@"完成" forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, 60, 40);
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    //设置背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -1, YZSCREEN_WIDTH, YZSCREEN_HEIGHT+2)];
    backgroundImageView.image = [UIImage imageNamed:@"YZBlueScan_selected"];
    [self.view addSubview:backgroundImageView];
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:[[UIScreen mainScreen] applicationFrame]];
//    webView.backgroundColor = [UIColor redColor];
    
    NSURL* url = [NSURL URLWithString:@"http://203.195.193.246:8080/media/app/yar_t8_privacy_policies.html"];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [webView loadRequest:request];//加载
    [self.view addSubview:webView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
