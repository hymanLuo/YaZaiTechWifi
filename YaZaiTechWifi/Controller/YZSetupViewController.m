//
//  YZSetupViewController.m
//  YaZaiTechWifi
//
//  Created by cheng luo on 2018/12/4.
//  Copyright © 2018年 homeSalf. All rights reserved.
//
#import <MediaPlayer/MPVolumeView.h>

#import "YZSetupViewController.h"
#import "YZTool.h"
#import "UIColor+PWHex.h"
#import "YZSetupViewCell.h"
#import "YZWifiConntionViewController.h"
#import "Globaldata.h"
#import "YZAudioPlayerManage.h"
#import "AFNetworking.h"
#import "YZNetworkManage.h"
#import "YZDirectionViewController.h"
#import "YZPolicyViewController.h"



@interface YZSetupViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UILabel    *dianchiLabel;
//尿湿提醒
@property (nonatomic,strong)UILabel    *niaoshiLabel;
@property (nonatomic,strong)UIButton   *niaoshiBtn;
//踢被子提醒
@property (nonatomic,strong)UILabel    *tibeiziLabel;
@property (nonatomic,strong)UIButton   *tibeiziBtn;
//睡醒提醒
@property (nonatomic,strong) UILabel   *shuixingLabel;
@property (nonatomic,strong) UIButton  *shuixingBtn;
//睡姿提醒
@property (nonatomic,strong) UIButton  *SleepDownBtn;
@property (nonatomic,strong) UIButton  *SleepUpBtn;

@property (nonatomic,strong) UIView    *babyTrouserSizeView;
@property (nonatomic,strong)UIView     *niaoshiShowView;

@end

@implementation YZSetupViewController
{
    Globaldata *globalData;
    YZAudioPlayerManage *audioPlayerManage;
    
    UIButton *volumeBackgroudView;
    UISlider *volumeSlider;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //设置背景图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -1, YZSCREEN_WIDTH, YZSCREEN_HEIGHT+2)];
    imageView.image = [UIImage imageNamed:@"YZBlueScan_selected"];
    [self.view addSubview:imageView];
    
    //设置声音按钮;
    UIButton *volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    volumeButton.backgroundColor = [UIColor grayColor];
    [volumeButton setImage:[UIImage imageNamed:@"volume"] forState:UIControlStateNormal];
//    [volumeButton setBackgroundImage:[UIImage imageNamed:@"volume"] forState:UIControlStateNormal];
//    volumeButton.contentMode = UIViewContentModeScaleAspectFit;
    volumeButton.frame = CGRectMake(0, 0, 10, 10);
    [volumeButton addTarget:self action:@selector(showPhoneVolumeView) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:volumeButton];
    
    
    [YZTool setTransparencyHidden:YES with:self];
    
    //获取到服务器数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globaldatachange:) name:YaZaiGetServerDataSuccess object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alermDataChange:) name:YaZaiAlermDataChange object:nil];
    
    globalData = [Globaldata shareInstance];
    
    [self initUI];
    
    
//    [self setServerDataWithAFNetworking];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updataButtonStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self touchVolumeViewDisAppear];
}

-(void)initUI{
    
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, YZSCREEN_WIDTH, YZSCREEN_HEIGHT-64) style:UITableViewStylePlain];
    tableview.backgroundColor = [UIColor clearColor];
    tableview.delegate = self;
    tableview.dataSource = self;
    
    [self.view addSubview:tableview];
    
    
    //调节声音的view
    volumeBackgroudView = [UIButton buttonWithType:UIButtonTypeCustom];
    volumeBackgroudView.backgroundColor = [UIColor grayColor];
    volumeBackgroudView.alpha = 0.2;
    volumeBackgroudView.frame = CGRectMake(0, 0, YZSCREEN_WIDTH, YZSCREEN_HEIGHT);
    [self.view addSubview:volumeBackgroudView];
    volumeBackgroudView.hidden = YES;
    [volumeBackgroudView addTarget:self action:@selector(touchVolumeViewDisAppear) forControlEvents:UIControlEventTouchUpInside];
    
    volumeSlider = [[UISlider alloc]initWithFrame:CGRectMake(20, [UIApplication sharedApplication].statusBarFrame.size.height + 44 +20, YZSCREEN_WIDTH - 40, 50)];
    volumeSlider.backgroundColor = [UIColor whiteColor];
    volumeSlider.hidden = YES;
    [self.view addSubview:volumeSlider];
    [volumeSlider addTarget:self action:@selector(volumeChanged:) forControlEvents:UIControlEventValueChanged];
    volumeSlider.minimumValue = 0;
    volumeSlider.maximumValue = 10;
    volumeSlider.value = globalData.volumeValue;
    
    /*
    UISlider *volumeViewSlider= nil;
    
    for (UIView *view in [volumeView subviews]){
        
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            
            volumeViewSlider = (UISlider*)view;
            //            volumeViewSlider.center = CGPointMake(volumeViewSlider.center.x, 100);
            
            break;
        }
    }
    
    //系统声音发生变化时;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];*/
    
    float leftDistance = 10;
    
    UIView *backgroundView0 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YZSCREEN_WIDTH, YZSCREEN_HEIGHT)];
    backgroundView0.backgroundColor = [UIColor clearColor];
    tableview.tableHeaderView.userInteractionEnabled = YES;
    tableview.tableHeaderView = backgroundView0;
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIImageView *baimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, YZSCREEN_WIDTH, 384)];
    baimage.image = [UIImage imageNamed:@"set_2btn_Dialog_default"];
    baimage.alpha = 0.3;
    [backgroundView0 addSubview:baimage];
    
    UILabel *dianliangLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftDistance, 0, YZSCREEN_WIDTH*0.5, 50)];
    NSString *tempStr = NSLocalizedString(@"battery_level", nil);
    dianliangLabel.text = [NSString stringWithFormat:@"|%@|",tempStr];
    dianliangLabel.textAlignment = NSTextAlignmentLeft;
    dianliangLabel.textColor = [UIColor whiteColor];
    [backgroundView0 addSubview:dianliangLabel];
    
    self.dianchiLabel = [[UILabel alloc] initWithFrame:CGRectMake(YZSCREEN_WIDTH-80, 0, 60, 50)];
    self.dianchiLabel.textAlignment = NSTextAlignmentCenter;
    self.dianchiLabel.text = [NSString stringWithFormat:@"%d%%",[Globaldata shareInstance].battayLevel] ;
    self.dianchiLabel.textColor = [UIColor whiteColor];
    [backgroundView0 addSubview:self.dianchiLabel];
    
    
    UIView *line0 = [[UIView alloc] initWithFrame:CGRectMake(8, CGRectGetMaxY(dianliangLabel.frame), YZSCREEN_WIDTH-8, 1)];
    line0.backgroundColor = [UIColor grayColor];
    [backgroundView0 addSubview:line0];
    
    //尿湿提醒===========================================================
    UILabel *niaoLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftDistance, CGRectGetMaxY(dianliangLabel.frame), YZSCREEN_WIDTH*0.5, 42)];
//    niaoLabel.text = @"|尿湿提醒|";
    NSString *niaoTempStr = NSLocalizedString(@"wetness_reminder", nil);
    niaoLabel.text = [NSString stringWithFormat:@"|%@|",niaoTempStr];
    niaoLabel.textAlignment = NSTextAlignmentLeft;
    niaoLabel.textColor = [UIColor whiteColor];
    [backgroundView0 addSubview:niaoLabel];
    
    self.niaoshiLabel = [[UILabel alloc] initWithFrame:CGRectMake(YZSCREEN_WIDTH*0.5-50, CGRectGetMaxY(dianliangLabel.frame), 100, 42)];
//    self.niaoshiLabel.text = @"200ml";
    self.niaoshiLabel.textAlignment = NSTextAlignmentCenter;
    self.niaoshiLabel.textColor = [UIColor yellowColor];
    [backgroundView0 addSubview:self.niaoshiLabel];
    
    self.niaoshiBtn = [[UIButton alloc] initWithFrame:CGRectMake(YZSCREEN_WIDTH-83, 53, 63, 42)];
    self.niaoshiBtn.selected = globalData.isHumidityAlerm;
    [self.niaoshiBtn setBackgroundImage:[UIImage imageNamed:@"shezhi_bme_img_s"] forState:UIControlStateNormal];
    [self.niaoshiBtn setBackgroundImage:[UIImage imageNamed:@"shez_img_s1"] forState:UIControlStateSelected];
    [self.niaoshiBtn addTarget:self action:@selector(niashibtn:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView0 addSubview:self.niaoshiBtn];
    
    UILabel *leftniaoLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftDistance, CGRectGetMaxY(niaoLabel.frame), 50, 32)];
    leftniaoLabel.text = NSLocalizedString(@"dry", nil);
    leftniaoLabel.textColor = [UIColor whiteColor];
    leftniaoLabel.font = [UIFont systemFontOfSize:12];
    leftniaoLabel.textAlignment = NSTextAlignmentLeft;
    [backgroundView0 addSubview:leftniaoLabel];
    
    UILabel *rightniaoLabel = [[UILabel alloc] initWithFrame:CGRectMake(YZSCREEN_WIDTH-70, CGRectGetMaxY(niaoLabel.frame), 50,32)];
    rightniaoLabel.text = NSLocalizedString(@"wet", nil);
    rightniaoLabel.textColor = [UIColor whiteColor];
    rightniaoLabel.font = [UIFont systemFontOfSize:12];
    rightniaoLabel.textAlignment = NSTextAlignmentRight;
    [backgroundView0 addSubview:rightniaoLabel];
    
    self.niaoshiShowView = [[UIView alloc]initWithFrame:CGRectMake(leftDistance, CGRectGetMaxY(self.niaoshiLabel.frame) + 5, YZSCREEN_WIDTH - 50 * 2, 40)];
    self.niaoshiShowView.center = CGPointMake(YZSCREEN_WIDTH * 0.5, self.niaoshiShowView.center.y);
//    self.niaoshiShowView.backgroundColor = [UIColor grayColor];
    [backgroundView0 addSubview:self.niaoshiShowView ];
    //裤子的大小NB,S,M,L,XL
    float niaoshiShowSpace = 5;
    float niaoshiShowWidth = (self.niaoshiShowView .frame.size.width - 3*niaoshiShowSpace)/4;
    NSArray *niaoshiShowArr = @[@"25%",@"50%",@"75%",@"100%"];
    
    UIColor *color0 = [UIColor colorWithRed:198/255.0 green:222/255.0 blue:29/255.0 alpha:1.0];
    UIColor *color1 = [UIColor colorWithRed:244/255.0 green:180/255.0 blue:40/255.0 alpha:1.0];
    UIColor *color2 = [UIColor colorWithRed:234/255.0 green:121/255.0 blue:40/255.0 alpha:1.0];
    UIColor *color3 = [UIColor colorWithRed:225/255.0 green:39/255.0 blue:39/255.0 alpha:1.0];
    
    NSArray *colorArr = @[color0,color1,color2,color3];
    for (int i = 0; i < niaoshiShowArr.count; i ++) {
        UIButton *trouserSizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        trouserSizeButton.backgroundColor = colorArr[i];
        trouserSizeButton.frame = CGRectMake(i*niaoshiShowWidth +i*niaoshiShowSpace, 0, niaoshiShowWidth, 16);
        trouserSizeButton.layer.cornerRadius = trouserSizeButton.frame.size.height*0.5;
        trouserSizeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        if (globalData.humidity == i) {
            trouserSizeButton.layer.borderWidth = 3;
        }
        else {
            trouserSizeButton.layer.borderWidth = 0;
        }
        
        [self.niaoshiShowView  addSubview:trouserSizeButton];
        [trouserSizeButton addTarget:self action:@selector(setUrineHumidityAlarm:) forControlEvents:UIControlEventTouchUpInside];
        trouserSizeButton.tag = 1000+i;
        
        UILabel *trouserSizeLabel = [[UILabel alloc]init];
        trouserSizeLabel.frame = CGRectMake(trouserSizeButton.frame.origin.x, trouserSizeButton.frame.size.height, trouserSizeButton.frame.size.width, 20);
        trouserSizeLabel.text = niaoshiShowArr[i];
        trouserSizeLabel.textAlignment = NSTextAlignmentCenter;
        trouserSizeLabel.textColor = [UIColor whiteColor];
        trouserSizeLabel.font = [UIFont systemFontOfSize:16];
        [self.niaoshiShowView  addSubview:trouserSizeLabel];
    }
    
//    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(55, CGRectGetMaxY(niaoLabel.frame), YZSCREEN_WIDTH-110, 32*YZSCREEN_HEIGHT_SCALE)];
//    slider.minimumValue = 20;
//    slider.maximumValue = 500;
//    slider.minimumTrackTintColor = [UIColor yellowColor];
//    slider.maximumTrackTintColor = [UIColor whiteColor];
//    slider.tintColor = [UIColor redColor];
//    slider.value = 200;
//    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
//    [backgroundView0 addSubview:slider];
    
    //踢被子提醒===========================================================
    UILabel *beiziLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftDistance, CGRectGetMaxY(dianliangLabel.frame)+74, YZSCREEN_WIDTH*0.5, 42)];
//    beiziLabel.text = @"|踢被子提醒|";
    NSString *kickTempStr = NSLocalizedString(@"kick_reminder", nil);
    beiziLabel.text = [NSString stringWithFormat:@"|%@|",kickTempStr];
    beiziLabel.textAlignment = NSTextAlignmentLeft;
    beiziLabel.textColor = [UIColor whiteColor];
    [backgroundView0 addSubview:beiziLabel];
    
    self.tibeiziLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(beiziLabel.frame) - 30, CGRectGetMaxY(dianliangLabel.frame)+74, 100, 42)];
    NSString *tiTempStr = NSLocalizedString(@"temperature",nil);
    self.tibeiziLabel.text = [NSString stringWithFormat:@"%d℃",globalData.kickTemperature];
    self.tibeiziLabel.textAlignment = NSTextAlignmentCenter;
    self.tibeiziLabel.textColor = [UIColor yellowColor];
    [backgroundView0 addSubview:self.tibeiziLabel];
    
    self.tibeiziBtn = [[UIButton alloc] initWithFrame:CGRectMake(YZSCREEN_WIDTH-83, 53+74, 63, 42)];
    self.tibeiziBtn.selected = globalData.isKickTemperatureAlerm;
    [self.tibeiziBtn setBackgroundImage:[UIImage imageNamed:@"shezhi_bme_img_s"] forState:UIControlStateNormal];
    [self.tibeiziBtn setBackgroundImage:[UIImage imageNamed:@"shez_img_s1"] forState:UIControlStateSelected];
    [self.tibeiziBtn addTarget:self action:@selector(tibeizibtn:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView0 addSubview:self.tibeiziBtn];
    
    UILabel *lefttibeiziLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftDistance, CGRectGetMaxY(niaoLabel.frame)+74, 50, 32)];
    lefttibeiziLabel.text = @"25℃";
    lefttibeiziLabel.textColor = [UIColor whiteColor];
    lefttibeiziLabel.font = [UIFont systemFontOfSize:12];
    lefttibeiziLabel.textAlignment = NSTextAlignmentLeft;
    [backgroundView0 addSubview:lefttibeiziLabel];
    
    UILabel *righttibeiziLabel = [[UILabel alloc] initWithFrame:CGRectMake(YZSCREEN_WIDTH-70, CGRectGetMaxY(niaoLabel.frame)+74, 50, 32)];
    righttibeiziLabel.text = @"30℃";
    righttibeiziLabel.textColor = [UIColor whiteColor];
    righttibeiziLabel.font = [UIFont systemFontOfSize:12];
    righttibeiziLabel.textAlignment = NSTextAlignmentRight;
    [backgroundView0 addSubview:righttibeiziLabel];
    
    
    UISlider *slider2 = [[UISlider alloc] initWithFrame:CGRectMake(55, CGRectGetMaxY(self.niaoshiLabel.frame)+74, YZSCREEN_WIDTH-110, 32)];
    slider2.minimumValue = 25;
    slider2.maximumValue = 30;
    slider2.minimumTrackTintColor = [UIColor yellowColor];
    slider2.maximumTrackTintColor = [UIColor whiteColor];
    slider2.tintColor = [UIColor redColor];
    slider2.value = globalData.kickTemperature;
    [slider2 addTarget:self action:@selector(sliderValueChanged2:) forControlEvents:UIControlEventValueChanged];
    [backgroundView0 addSubview:slider2];
    
    //睡醒提醒===========================================================
    UILabel *shuixingLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftDistance, CGRectGetMaxY(dianliangLabel.frame)+74*2, YZSCREEN_WIDTH*0.5, 42)];
    NSString *shuxiTempStr = NSLocalizedString(@"wake_up_reminder",nil);
    shuixingLabel.text = [NSString stringWithFormat:@"|%@|",shuxiTempStr];
    shuixingLabel.textAlignment = NSTextAlignmentLeft;
    shuixingLabel.textColor = [UIColor whiteColor];
    [backgroundView0 addSubview:shuixingLabel];
    
    self.shuixingLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shuixingLabel.frame) - 30, CGRectGetMinY(shuixingLabel.frame), 100, 42)];
    NSString *shuxiTempStr1 = NSLocalizedString(@"activites",nil);
    NSString *shuxiTempStr2 = NSLocalizedString(@"times",nil);
    self.shuixingLabel.text = [NSString stringWithFormat:@"%d%@",globalData.wakeupNumber,shuxiTempStr2];
    self.shuixingLabel.textAlignment = NSTextAlignmentCenter;
    self.shuixingLabel.textColor = [UIColor yellowColor];
    [backgroundView0 addSubview:self.shuixingLabel];
    
    self.shuixingBtn = [[UIButton alloc] initWithFrame:CGRectMake(YZSCREEN_WIDTH-83, 53+74*2, 63, 42)];
    [self.shuixingBtn setBackgroundImage:[UIImage imageNamed:@"shezhi_bme_img_s"] forState:UIControlStateNormal];
    [self.shuixingBtn setBackgroundImage:[UIImage imageNamed:@"shez_img_s1"] forState:UIControlStateSelected];
    self.shuixingBtn.selected = globalData.isWakeupAlerm;
    [self.shuixingBtn addTarget:self action:@selector(sleepbtn:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView0 addSubview:self.shuixingBtn];
    
    UILabel *leftSleepLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftDistance, CGRectGetMaxY(niaoLabel.frame)+74*2, 50, 32)];
//    leftSleepLabel.text = @"3次";
    leftSleepLabel.text = [NSString stringWithFormat:@"3%@",shuxiTempStr2];
    leftSleepLabel.textColor = [UIColor whiteColor];
    leftSleepLabel.font = [UIFont systemFontOfSize:12];
    lefttibeiziLabel.textAlignment = NSTextAlignmentLeft;
    [backgroundView0 addSubview:leftSleepLabel];
    
    UILabel *rightSleepLabel = [[UILabel alloc] initWithFrame:CGRectMake(YZSCREEN_WIDTH-50 - leftDistance, CGRectGetMaxY(niaoLabel.frame)+74*2, 50, 32)];
    rightSleepLabel.text = [NSString stringWithFormat:@"9%@",shuxiTempStr2];;
    rightSleepLabel.textColor = [UIColor whiteColor];
    rightSleepLabel.font = [UIFont systemFontOfSize:12];
    rightSleepLabel.textAlignment = NSTextAlignmentRight;
    [backgroundView0 addSubview:rightSleepLabel];
    
    
    UISlider *slider3 = [[UISlider alloc] initWithFrame:CGRectMake(55, CGRectGetMaxY(self.niaoshiLabel.frame)+74*2, YZSCREEN_WIDTH-110, 32)];
    slider3.minimumValue = 3;
    slider3.maximumValue = 9;
    slider3.minimumTrackTintColor = [UIColor yellowColor];
    slider3.maximumTrackTintColor = [UIColor whiteColor];
    slider3.tintColor = [UIColor redColor];
    slider3.value = globalData.wakeupNumber;
    [slider3 addTarget:self action:@selector(sliderValueChanged3:) forControlEvents:UIControlEventValueChanged];
    [backgroundView0 addSubview:slider3];
    
    //睡姿提醒===========================================================
    UILabel *sleepTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftDistance, CGRectGetMaxY(dianliangLabel.frame)+74*3, YZSCREEN_WIDTH*0.8, 42)];
//    sleepTypeLabel.text = @"|睡姿提醒|";
    NSString *sleepTempStr = NSLocalizedString(@"sleep_position_reminder",nil);
    sleepTypeLabel.text = [NSString stringWithFormat:@"|%@|",sleepTempStr];
    sleepTypeLabel.textAlignment = NSTextAlignmentLeft;
    sleepTypeLabel.textColor = [UIColor whiteColor];
    [backgroundView0 addSubview:sleepTypeLabel];
    
    self.SleepDownBtn = [[UIButton alloc] initWithFrame:CGRectMake(50,CGRectGetMaxY(sleepTypeLabel.frame), 150, 40)];
    self.SleepDownBtn.center = CGPointMake(YZSCREEN_WIDTH * 0.25, self.SleepDownBtn.center.y);
    self.SleepDownBtn.layer.cornerRadius = self.SleepDownBtn.frame.size.height*0.5;
    self.SleepDownBtn.layer.masksToBounds = YES;
    [self.SleepDownBtn setTitle:NSLocalizedString(@"risk_of_suffocation",nil) forState:UIControlStateNormal];
    [self.SleepDownBtn setTitleColor:[UIColor colorWithHexString:@"#FE5A8A"] forState:UIControlStateNormal];
    [self.SleepDownBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.SleepDownBtn.titleLabel.numberOfLines = 0;
    self.SleepDownBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    
    [self.SleepDownBtn setBackgroundColor:[UIColor whiteColor]];
    self.SleepDownBtn.selected = globalData.isPositionDownDangerAlerm;
    [self.SleepDownBtn setBackgroundImage:[UIImage imageNamed:@"me_img_speedbar23"] forState:UIControlStateNormal];
    [self.SleepDownBtn setBackgroundImage:[UIImage imageNamed:@"set_btn_Dialog_pressed"] forState:UIControlStateSelected];
    [self.SleepDownBtn addTarget:self action:@selector(sleepDownBtn:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView0 addSubview:self.SleepDownBtn];
    
    self.SleepUpBtn = [[UIButton alloc] initWithFrame:CGRectMake(YZSCREEN_WIDTH-50-128, CGRectGetMaxY(sleepTypeLabel.frame), 150, 40)];
    self.SleepUpBtn.center = CGPointMake(YZSCREEN_WIDTH * 0.75, self.SleepUpBtn.center.y);
    self.SleepUpBtn.layer.cornerRadius = self.SleepUpBtn.frame.size.height*0.5;
    self.SleepUpBtn.layer.masksToBounds = YES;
    [self.SleepUpBtn setTitle:NSLocalizedString(@"risk_of_falling",nil) forState:UIControlStateNormal];
    [self.SleepUpBtn setTitleColor:[UIColor colorWithHexString:@"#FE5A8A"] forState:UIControlStateNormal];
    [self.SleepUpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.SleepUpBtn.titleLabel.numberOfLines = 0;
    self.SleepUpBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    
    [self.SleepUpBtn setBackgroundColor:[UIColor whiteColor]];
    self.SleepUpBtn.selected = globalData.isWakeupDangerAlerm;
    [self.SleepUpBtn setBackgroundImage:[UIImage imageNamed:@"me_img_speedbar23"] forState:UIControlStateNormal];
    [self.SleepUpBtn setBackgroundImage:[UIImage imageNamed:@"set_btn_Dialog_pressed"] forState:UIControlStateSelected];
    [self.SleepUpBtn addTarget:self action:@selector(sleepUpBtn:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView0 addSubview:self.SleepUpBtn];
    
    
    //=================================婴儿裤码数
    UIImageView *baimage1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(baimage.frame)+20, YZSCREEN_WIDTH, 93)];
    baimage1.image = [UIImage imageNamed:@"set_2btn_Dialog_default"];
    baimage1.alpha = 0.3;
    [backgroundView0 addSubview:baimage1];
    
    UILabel *babyLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftDistance, CGRectGetMinY(baimage1.frame), YZSCREEN_WIDTH, 42)];
//    babyLabel.text = @"|婴儿裤码数|";
    NSString *babyTempStr = NSLocalizedString(@"diaper_size",nil);
    babyLabel.text = [NSString stringWithFormat:@"|%@|",babyTempStr];
    babyLabel.textColor = [UIColor whiteColor];
    //    babyLabel.font = [UIFont systemFontOfSize:14];
    [backgroundView0 addSubview:babyLabel];
    
    self.babyTrouserSizeView = [[UIView alloc]initWithFrame:CGRectMake(leftDistance, CGRectGetMaxY(babyLabel.frame) + 5, YZSCREEN_WIDTH- 2*leftDistance, 40)];
    //    babyTrouserSizeView.backgroundColor = [UIColor redColor];
    [backgroundView0 addSubview:self.babyTrouserSizeView ];
    //裤子的大小NB,S,M,L,XL
    float trouserSpace = 5;
    float trouserWidth = (self.babyTrouserSizeView .frame.size.width - 4*trouserSpace)/5;
    NSArray *trouserSizeArr = @[@"NB",@"S",@"M",@"L",@"XL"];
    for (int i = 0; i < 5; i ++) {
        UIButton *trouserSizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == globalData.trouserSize) {
            trouserSizeButton.backgroundColor = [UIColor yellowColor];
        }
        else {
            trouserSizeButton.backgroundColor = [UIColor whiteColor];
        }
        
        trouserSizeButton.frame = CGRectMake(i*trouserWidth +i*trouserSpace, 0, trouserWidth, 16);
        trouserSizeButton.layer.cornerRadius = trouserSizeButton.frame.size.height*0.5;
        [self.babyTrouserSizeView  addSubview:trouserSizeButton];
        [trouserSizeButton addTarget:self action:@selector(setTrouserSize:) forControlEvents:UIControlEventTouchUpInside];
        trouserSizeButton.tag = 1000+i;
        
        UILabel *trouserSizeLabel = [[UILabel alloc]init];
        trouserSizeLabel.frame = CGRectMake(trouserSizeButton.frame.origin.x, trouserSizeButton.frame.size.height, trouserSizeButton.frame.size.width, 20);
        trouserSizeLabel.text = trouserSizeArr[i];
        trouserSizeLabel.textAlignment = NSTextAlignmentCenter;
        trouserSizeLabel.textColor = [UIColor whiteColor];
        trouserSizeLabel.font = [UIFont systemFontOfSize:16];
        [self.babyTrouserSizeView  addSubview:trouserSizeLabel];
    }
    
    backgroundView0.frame = CGRectMake(backgroundView0.frame.origin.x, backgroundView0.frame.origin.y, backgroundView0.frame.size.width, CGRectGetMaxY(_babyTrouserSizeView.frame) + 20);
}

#pragma mark --服务器数据发生改变 通知调用
-(void)globaldatachange:(id)sender{
    NSLog(@"---globaldatachange");
    self.dianchiLabel.text = [NSString stringWithFormat:@"%d%%",[Globaldata shareInstance].battayLevel];
}

- (void)alermDataChange:(id)sender {
    [self updataButtonStatus];
}

- (void)updataButtonStatus {
    self.niaoshiBtn.selected = globalData.isHumidityAlerm;
    self.tibeiziBtn.selected = globalData.isKickTemperatureAlerm;
    self.shuixingBtn.selected = globalData.isWakeupAlerm;
    self.SleepDownBtn.selected = globalData.isPositionDownDangerAlerm;
    self.SleepUpBtn.selected = globalData.isWakeupDangerAlerm;
}

#pragma mark--Private method
//开启或关闭尿湿提醒
-(void)niashibtn:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [audioPlayerManage stop];
    }
    
    
    globalData.isHumidityAlerm = sender.selected;
    
    //设置设备参数;
    [self setServerDataWithAFNetworking];
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.selected forKey:YZ_IsHumidityAlerm];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

//开启或关闭踢被子提醒
-(void)tibeizibtn:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [audioPlayerManage stop];
    }
    globalData.isKickTemperatureAlerm = sender.selected;
    
    //设置设备参数;
    [self setServerDataWithAFNetworking];
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.selected forKey:YZ_IsKickTemperatureAlerm];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

//开启或关闭睡醒提醒
-(void)sleepbtn:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    if (!sender.selected) {
        [audioPlayerManage stop];
    }
    
    globalData.isWakeupAlerm = sender.selected;
    
    //设置设备参数;
    [self setServerDataWithAFNetworking];
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.selected forKey:YZ_IsWakeupAlerm];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

//设置尿湿值(没有用到)
-(void)sliderValueChanged:(UISlider *)slider
{
    self.niaoshiLabel.text = [NSString stringWithFormat:@"%dml",(int)slider.value];
    
    globalData.humidity = (int)slider.value;
    
    //设置设备参数;
    if (globalData.isHumidityAlerm){
        [self setServerDataWithAFNetworking];
    }
    
    
    [[NSUserDefaults standardUserDefaults] setInteger:(int)slider.value forKey:YZ_Humidity];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//设置踢被子提醒值
-(void)sliderValueChanged2:(UISlider *)slider
{
    
//    self.tibeiziLabel.text = [NSString stringWithFormat:@"%d℃",(int)slider.value];
    NSString *tiTempStr = NSLocalizedString(@"temperature",nil);
    self.tibeiziLabel.text = [NSString stringWithFormat:@"%d℃",(int)slider.value];
    
    globalData.kickTemperature = (int)slider.value;
    
    //设置设备参数;
    if (globalData.isKickTemperatureAlerm){
        [self setServerDataWithAFNetworking];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:(int)slider.value forKey:YZ_KickTemperature];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//睡醒次数提醒
-(void)sliderValueChanged3:(UISlider *)slider
{
    
//    self.shuixingLabel.text = [NSString stringWithFormat:@"%d次",(int)slider.value];
    NSString *shuxiTempStr1 = NSLocalizedString(@"activites",nil);
    NSString *shuxiTempStr2 = NSLocalizedString(@"times",nil);
    self.shuixingLabel.text = [NSString stringWithFormat:@"%d %@",(int)slider.value,shuxiTempStr2];
    
    globalData.wakeupNumber = (int)slider.value;
    
    //设置设备参数;
    if (globalData.isWakeupAlerm){
        [self setServerDataWithAFNetworking];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:(int)slider.value forKey:YZ_WakeupNumber];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//趴睡窒息危险按钮
-(void)sleepDownBtn:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    globalData.isPositionDownDangerAlerm = sender.selected;
    
    //设置设备参数;
    [self setServerDataWithAFNetworking];
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.selected forKey:YZ_IsPositionDownDangerAlerm];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//起床摔倒危险按钮
-(void)sleepUpBtn:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    globalData.isWakeupDangerAlerm = sender.selected;
    
    //设置设备参数;
    [self setServerDataWithAFNetworking];
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.selected forKey:YZ_IsWakeupDangerAlerm];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setTrouserSize:(UIButton*)sender {
    NSArray *trouserSizeArr = @[@"NB",@"S",@"M",@"L",@"XL"];
    for (int i = 0; i < 5; i ++) {
        UIButton *button = (UIButton *)[self.babyTrouserSizeView viewWithTag:(1000 + i)];
        if ((sender.tag - i) == 1000) {
            button.backgroundColor = [UIColor yellowColor];
            NSLog(@"点击的是:%@",trouserSizeArr[i]);
            
            globalData.trouserSize = i;
            
            //设置设备参数;
            [self setServerDataWithAFNetworking];
            
            [[NSUserDefaults standardUserDefaults] setInteger:i forKey:YZ_TrouserSize];
            [[NSUserDefaults standardUserDefaults] synchronize];
//            [[NSNotificationCenter defaultCenter] postNotificationName:YaZaiTrouserSizeChange object:nil];
        }
        else {
            button.backgroundColor = [UIColor whiteColor];
        }
    }
}
//设置尿湿按钮状态
- (void)setUrineHumidityAlarm:(UIButton *)sender {
    for (int i = 0; i < 5; i ++) {
        UIButton *button = (UIButton *)[self.niaoshiShowView viewWithTag:(1000 + i)];
        if ((sender.tag - i) == 1000) {
            button.layer.borderWidth = 3;
            
            globalData.humidity = i;
            
            //设置设备参数;
            if (globalData.isHumidityAlerm){
                [self setServerDataWithAFNetworking];
            }
            
            [[NSUserDefaults standardUserDefaults] setInteger:i forKey:YZ_Humidity];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
             button.layer.borderWidth = 0;
        }
    }
}

- (void)showPhoneVolumeView {
    volumeBackgroudView.hidden = !volumeBackgroudView.hidden;
    volumeSlider.hidden = !volumeSlider.hidden;
}

- (void)touchVolumeViewDisAppear {
    NSLog(@"---touchVolumeViewDisAppear");
    volumeBackgroudView.hidden = YES;
    volumeSlider.hidden = YES;
}


- (void)volumeChanged:(UISlider *)slider {
    NSLog (@"---volumeChanged");
    
    globalData.volumeValue = (int)slider.value;
    
    //设置设备参数;
    [self setServerDataWithAFNetworking];
    
    [[NSUserDefaults standardUserDefaults] setInteger:(int)slider.value forKey:YZ_VolumeValue];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

#pragma mark --设置设备参数
- (void)setServerDataWithAFNetworking {
    
    if (!globalData.serialNumberStr) {
        return;
    }
    
    NSString *urlStr = YaZaiSetDataUrlHeader;
    
    int pantsCodeNumber = globalData.trouserSize;//尿裤码数一个字节，1-4 表示S到L码；
    int urineWetRemind = globalData.isHumidityAlerm? 1:0;//尿湿提醒开关一个字节，0/1/2 0:关 1:开 2:稍后提醒
    int urineWetData = globalData.humidity;//尿湿提醒两个字节，1-5；0，25%，50%，75%，100%
    int kickQuiltSw = globalData.isKickTemperatureAlerm? 1:0;//踢被子开关一个字节:0/1/2 0关 1开 2稍后提醒；
    int temperature = globalData.kickTemperature;//踢被子温度一个字节，20-35
    int wakeUpRemind = globalData.isWakeupAlerm? 1:0;//睡醒提醒开关一个字节,0/1/2 0:关 1:开 2:稍后提醒
    int frequencyOfMotion = globalData.wakeupNumber;//小孩动的频率一个字节：3-9;
    int fallSleepRemind = globalData.isPositionDownDangerAlerm? 1:0;//趴睡提醒开头一个字节，0/1/2 0:关 1:开 2:稍后提醒
    int wakeUpFall = globalData.isWakeupDangerAlerm? 1:0;//起床摔倒提醒开关一个字节,0/1/2 0:关 1:开 2:稍后提醒
    int volume = globalData.volumeValue;//设备音量一个字节，1-10代表十档
    
    //2.封装参数
    NSDictionary *params = @{
                           @"phoneidcode": globalData.uuidStr,
                           @"serialnumber": globalData.serialNumberStr,
                           @"pantscodenumber": [NSNumber numberWithInt:pantsCodeNumber],
                           @"urinewetremind": [NSNumber numberWithInt:urineWetRemind],
                           @"urinewetdata": [NSNumber numberWithInt:urineWetData],
                           @"kickquiltsw": [NSNumber numberWithInt:kickQuiltSw],
                           @"temperature": [NSNumber numberWithInt:temperature],
                           @"wakeupremind": [NSNumber numberWithInt:wakeUpRemind],
                           @"frequencyofmotion": [NSNumber numberWithInt:frequencyOfMotion],
                           @"fallsleepremind": [NSNumber numberWithInt:fallSleepRemind],
                           @"wakeupfall": [NSNumber numberWithInt:wakeUpFall],
                           @"volume": [NSNumber numberWithInt:volume]
                           };
    
//    [manager POST:urlStr parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if (responseObject) {
//            NSDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:responseObject
//                                                                         options:NSJSONReadingAllowFragments
//                                                                           error:nil];
//            NSLog(@"success--%@",dictFromData);
//            if ([dictFromData[@"data"] isEqualToString:@"ok"]);
//            {
//                NSLog(@"设置成功");
//            }
//        }
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"failure--%@",error);
//    }];
    
    [[YZNetworkManage sharedManage] postWithPath:urlStr params:params success:^(NSDictionary * _Nonnull dict) {
        if ([dict[@"data"] isEqualToString:@"ok"]){
            NSLog(@"设置成功");
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error dict:%@",params);
        NSLog(@"failure---");
    }];
    
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 64;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *tempStr0 = NSLocalizedString(@"bud_instructions",nil);
    tempStr0 = [NSString stringWithFormat:@"|%@|",tempStr0];
    
    NSString *tempStr1 = NSLocalizedString(@"privacy_policy",nil);
    tempStr1 = [NSString stringWithFormat:@"|%@|",tempStr1];
    
    NSString *tempStr2 = NSLocalizedString(@"wifi_connection",nil);
    tempStr2 = [NSString stringWithFormat:@"|%@|",tempStr2];
    
    
    NSArray *array = @[tempStr0,tempStr1,tempStr2];
    YZSetupViewCell *cell = [YZSetupViewCell cellWithTableView:tableView];
    cell.titleLabel.text = array[indexPath.row];
    
    self.niaoshiBtn.selected = globalData.isHumidityAlerm;
    self.tibeiziBtn.selected = globalData.isKickTemperatureAlerm;
    self.shuixingBtn.selected = globalData.isWakeupAlerm;
    self.SleepDownBtn.selected = globalData.isPositionDownDangerAlerm;
    self.SleepUpBtn.selected = globalData.isWakeupDangerAlerm;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        self.hidesBottomBarWhenPushed = YES;
        YZDirectionViewController *vc = [[YZDirectionViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }
    else if (indexPath.row == 1) {
        NSLog(@"----隐私条款界面");
        self.hidesBottomBarWhenPushed = YES;
        YZPolicyViewController *vc = [[YZPolicyViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        self.hidesBottomBarWhenPushed = NO;
        
    }
    else if (indexPath.row == 2) {
        NSLog(@"----跳转WIFI连接界面");
        self.hidesBottomBarWhenPushed = YES;
        YZWifiConntionViewController *vc = [[YZWifiConntionViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        self.hidesBottomBarWhenPushed = NO;
        
    }
}

@end
