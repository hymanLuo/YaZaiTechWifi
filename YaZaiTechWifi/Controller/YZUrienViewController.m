//
//  YZUrleViewController.m
//  YaZaiTechWifi
//
//  Created by cheng luo on 2018/12/4.
//  Copyright © 2018年 homeSalf. All rights reserved.
//

#import "YZUrienViewController.h"
#import "YZTool.h"
#import "Globaldata.h"
#import "AFNetworking.h"
#import "YZAudioPlayerManage.h"
#import "CustomAlertView.h"
#import "YZNetworkManage.h"


//稍后提醒时间
#define YaZaiLaterTime 30

@interface YZUrienViewController ()

@end

@implementation YZUrienViewController
{
    UILabel *tempLabel;
    UIImageView *humidityImageView;
    UILabel *niaoTimesLabe;
    UILabel *niaoMlLabel;
    Globaldata *globalData;
    
//    NSString *serialNumberStr;//请求服务器的设备SN号;
    
    NSTimer *serverDataTimer;
    YZAudioPlayerManage *audioPlayerManage;//闹铃;
    
    NSMutableArray *wakeUpMuArr;
    
    //尿湿提醒弹框
    CustomAlertView *urienAlertView;
    BOOL isLaterUrienAlert;
    //踢被子提醒弹框
    CustomAlertView *kickAlertView;
    BOOL isLaterkickAlert;
    //睡醒提醒弹框
    CustomAlertView *wakeupAlertView;
    BOOL isLaterWakeupAlert;
    //睡姿提醒弹框
    CustomAlertView *downDangerAlertView;
    BOOL isLaterDownDangerAlert;
    CustomAlertView *wakeupDangerAlertView;
    BOOL isLaterWakeupDangerAlert;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor greenColor];
    // Do any additional setup after loading the view.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

   
    //test
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:@"Homsafe_112388_105594" forKey:@"SerialNumber"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -1, YZSCREEN_WIDTH, YZSCREEN_HEIGHT+2)];
    imageView.image = [UIImage imageNamed:@"YZBlueScan_selected"];
    [self.view addSubview:imageView];
    
    audioPlayerManage = [YZAudioPlayerManage shareInstance];
    wakeUpMuArr = [[NSMutableArray alloc]init];
    
    [self initGlobalData];
    [self setUI];
    
    [YZTool setTransparencyHidden:YES with:self];
    
    
    serverDataTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getServerDataWithAFNetworking) userInfo:nil repeats:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    globalData.serialNumberStr = [userDefaults valueForKey:@"SerialNumber"];
    NSString *tempStr = [YZTool getUUIDInKeychain];
    globalData.uuidStr = [YZTool md5HashToLower16Bit:tempStr];
    
    if (globalData.serialNumberStr  == nil) {
        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"not_wifi_device", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
        [alerView show];
        [serverDataTimer setFireDate:[NSDate distantFuture]];
    }
    else {
//        [self getServeData];
        [self getServerDataWithAFNetworking];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globaldatachange:) name:YaZaiGetServerDataSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectDeviceSuccess) name:YaZaiConnectDeviceSuccess object:nil];
    
    [self initAlertView];
    
}

//设置弹框的初始化;
- (void)initAlertView {
    //尿湿提醒弹框
    urienAlertView = [[CustomAlertView alloc]initWithAlertDelegate:self title:nil message:NSLocalizedString(@"wetness_reminder", nil) buttonTitle:@[NSLocalizedString(@"close_reminder", nil),NSLocalizedString(@"remind_later", nil)] pressOK:^{
        NSLog(@"----稍后提醒");
        isLaterUrienAlert = YES;
        [self setServerDataWithAFNetworking];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(YaZaiLaterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isLaterUrienAlert = NO;
        });
    } pressCancel:^{
        NSLog(@"----关闭提醒");
        globalData.isHumidityAlerm = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:YZ_IsHumidityAlerm];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:YaZaiAlermDataChange object:nil];//参数发生了改变
        //这里要发命令给服务器，关闭提醒；
        [self setServerDataWithAFNetworking];
        
    }];
    
    //踢被子提醒弹框
    kickAlertView = [[CustomAlertView alloc]initWithAlertDelegate:self title:nil message:NSLocalizedString(@"kick_reminder", nil) buttonTitle:@[NSLocalizedString(@"close_reminder", nil),NSLocalizedString(@"remind_later", nil)] pressOK:^{
        NSLog(@"----稍后提醒");
        isLaterkickAlert = YES;
        [self setServerDataWithAFNetworking];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(YaZaiLaterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isLaterkickAlert = NO;
        });
    } pressCancel:^{
        NSLog(@"----关闭提醒");
        globalData.isKickTemperatureAlerm = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:YZ_IsKickTemperatureAlerm];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:YaZaiAlermDataChange object:nil];//参数发生了改变
        
        [self setServerDataWithAFNetworking];
    }];
    
    //睡醒提醒弹框
    wakeupAlertView = [[CustomAlertView alloc]initWithAlertDelegate:self title:nil message:NSLocalizedString(@"wake_up_reminder", nil) buttonTitle:@[NSLocalizedString(@"close_reminder", nil),NSLocalizedString(@"remind_later", nil)] pressOK:^{
        NSLog(@"----稍后提醒");
        isLaterWakeupAlert = YES;
        [self setServerDataWithAFNetworking];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(YaZaiLaterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isLaterWakeupAlert = NO;
        });
    } pressCancel:^{
        NSLog(@"----关闭提醒");
        globalData.isWakeupAlerm = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:YZ_IsWakeupAlerm];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:YaZaiAlermDataChange object:nil];//参数发生了改变
        
        [self setServerDataWithAFNetworking];
    }];
    
    //睡姿提醒弹框
    downDangerAlertView = [[CustomAlertView alloc]initWithAlertDelegate:self title:nil message:NSLocalizedString(@"risk_of_suffocation", nil) buttonTitle:@[NSLocalizedString(@"close_reminder", nil),NSLocalizedString(@"remind_later", nil)] pressOK:^{
        NSLog(@"----稍后提醒");
        isLaterDownDangerAlert = YES;
        [self setServerDataWithAFNetworking];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(YaZaiLaterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isLaterDownDangerAlert = NO;
        });
    } pressCancel:^{
        NSLog(@"----关闭提醒");
        globalData.isPositionDownDangerAlerm = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:YZ_IsPositionDownDangerAlerm];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:YaZaiAlermDataChange object:nil];//参数发生了改变
        [self setServerDataWithAFNetworking];
    }];
    
    wakeupDangerAlertView = [[CustomAlertView alloc]initWithAlertDelegate:self title:nil message:NSLocalizedString(@"risk_of_falling", nil) buttonTitle:@[NSLocalizedString(@"close_reminder", nil),NSLocalizedString(@"remind_later", nil)] pressOK:^{
        NSLog(@"----稍后提醒");
        isLaterWakeupDangerAlert = YES;
        [self setServerDataWithAFNetworking];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(YaZaiLaterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isLaterWakeupDangerAlert = NO;
        });
    } pressCancel:^{
        NSLog(@"----关闭提醒");
        globalData.isWakeupDangerAlerm = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:YZ_IsWakeupDangerAlerm];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:YaZaiAlermDataChange object:nil];//参数发生了改变
        [self setServerDataWithAFNetworking];
        
    }];
}

#pragma mark --设置设备参数
- (void)setServerDataWithAFNetworking{
    
    if (!globalData.serialNumberStr) {
        return;
    }
    
    NSString *urlStr = YaZaiSetDataUrlHeader;
    
    int pantsCodeNumber = globalData.trouserSize;//尿裤码数一个字节，1-4 表示S到L码；
    int urineWetRemind;// = globalData.isHumidityAlerm? 1:0;//尿湿提醒开关一个字节，0/1/2 0:关 1:开 2:稍后提醒
    //尿湿提醒；
    //是否按了稍后提醒;
    if (!isLaterUrienAlert) {
        urineWetRemind = globalData.isHumidityAlerm? 1:0;//尿湿提醒开关一个字节，0/1/2 0:关 1:开 2:稍后提醒
    }
    else {
        urineWetRemind = 2;
    }
    int urineWetData = globalData.humidity;//尿湿提醒两个字节，1-5；0，25%，50%，75%，100%
    
    //踢被子提醒;
    int kickQuiltSw;// = globalData.isKickTemperatureAlerm? 1:0;//踢被子开关一个字节:0/1/2 0关 1开 2稍后提醒；
    if (!isLaterkickAlert) {
        kickQuiltSw = globalData.isKickTemperatureAlerm? 1:0;//踢被子开关一个字节:0/1/2 0关 1开 2稍后提醒；
    }
    else {
        kickQuiltSw = 2;
    }
    int temperature = globalData.kickTemperature;//踢被子温度一个字节，20-35
    
    //睡醒提醒
    int wakeUpRemind;//= globalData.isWakeupAlerm? 1:0;//睡醒提醒开关一个字节,0/1/2 0:关 1:开 2:稍后提醒
    if (!isLaterWakeupAlert) {
        wakeUpRemind = globalData.isWakeupAlerm? 1:0;//睡醒提醒开关一个字节,0/1/2 0:关 1:开 2:稍后提醒
    }
    else {
        wakeUpRemind = 2;
    }
    int frequencyOfMotion = globalData.wakeupNumber;//小孩动的频率一个字节：3-9;
    
    //趴睡提醒
    int fallSleepRemind;//= globalData.isPositionDownDangerAlerm? 1:0;//趴睡提醒开头一个字节，0/1/2 0:关 1:开 2:稍后提醒
    if (!isLaterDownDangerAlert) {
        fallSleepRemind = globalData.isPositionDownDangerAlerm? 1:0;//趴睡提醒开头一个字节，0/1/2 0:关 1:开 2:稍后提醒
    }
    else {
        fallSleepRemind = 2;
    }
    //起床摔倒提醒
    int wakeUpFall;//= globalData.isWakeupDangerAlerm? 1:0;//起床摔倒提醒开关一个字节,0/1/2 0:关 1:开 2:稍后提醒
    if (!isLaterWakeupDangerAlert) {
        wakeUpFall = globalData.isWakeupDangerAlerm? 1:0;//起床摔倒提醒开关一个字节,0/1/2 0:关 1:开 2:稍后提醒
    }
    else {
        wakeUpFall = 2;
    }
    
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
    
    NSLog (@"---params:%@",params);
    
    [[YZNetworkManage sharedManage] postWithPath:urlStr params:params success:^(NSDictionary * _Nonnull dict) {
        if ([dict[@"data"] isEqualToString:@"ok"]){
            NSLog(@"设置成功");
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error dict:%@",params);
        NSLog(@"failure---");
    }];
    
}



- (void)initGlobalData {
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    globalData = [Globaldata shareInstance];
    
    //尿湿提醒
    globalData.humidity = [[userDefaults objectForKey:YZ_Humidity] intValue];
    globalData.isHumidityAlerm = [userDefaults boolForKey:YZ_IsHumidityAlerm];
    
    //踢被子提醒
    globalData.kickTemperature = 25;
    if ([userDefaults objectForKey:YZ_KickTemperature] !=nil) {
        globalData.kickTemperature = [[userDefaults objectForKey:YZ_KickTemperature] intValue];
    }
    globalData.isKickTemperatureAlerm = [userDefaults boolForKey:YZ_IsKickTemperatureAlerm];
    
    //睡醒提醒
    globalData.wakeupNumber = 3;
    if ([[userDefaults objectForKey:YZ_WakeupNumber] intValue] != 0) {
        globalData.wakeupNumber = [[userDefaults objectForKey:YZ_WakeupNumber] intValue];
    }
    globalData.isWakeupAlerm = [userDefaults boolForKey:YZ_IsWakeupAlerm];
    
    //睡姿提醒
    globalData.isPositionDownDangerAlerm = [userDefaults boolForKey:YZ_IsPositionDownDangerAlerm];
    globalData.isWakeupDangerAlerm = [userDefaults boolForKey:YZ_IsWakeupDangerAlerm];
    
    //婴儿裤码
    globalData.trouserSize = [[userDefaults objectForKey:YZ_TrouserSize] intValue];
    
    //音量
    globalData.volumeValue = [[userDefaults objectForKey:YZ_VolumeValue] intValue];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self initGlobalData];
//    [self getServerDataWithAFNetworking];
    
    [[YZAudioPlayerManage shareInstance]play];
}


#pragma mark --裤码发生变化;
- (void)N_TrouserSizeChange{
    
}

#pragma mark ---Private Method
-(void)setUI{

    UIImageView *tempImage = [[UIImageView alloc] initWithFrame:CGRectMake(24, NavAndStatusHight+12, 12, 20)];
    tempImage.image = [UIImage imageNamed:@"img_tb_temp"];
    [self.view addSubview:tempImage];

    tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, NavAndStatusHight, 180, 53)];
    tempLabel.textColor = [UIColor whiteColor];
    tempLabel.text = @"26.5℃";
    tempLabel.font = [UIFont systemFontOfSize:38];
    [self.view addSubview:tempLabel];

    UILabel *tempBottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(tempLabel.frame), CGRectGetMaxY(tempLabel.frame), 53, 12)];
    tempBottomLabel.text = @"TEMP";
    tempBottomLabel.font = [UIFont systemFontOfSize:12];
    tempBottomLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:tempBottomLabel];

    UIImageView *NiaoKuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 222, 305, 201)];
    NiaoKuImageView.center = CGPointMake(YZSCREEN_WIDTH * 0.5, YZSCREEN_HEIGHT * 0.44);
    NiaoKuImageView.image = [UIImage imageNamed:@"trouser_Image"];
    NiaoKuImageView.alpha = 0.2;
    [self.view addSubview:NiaoKuImageView];

    humidityImageView = [[UIImageView alloc] initWithFrame:CGRectMake((YZSCREEN_WIDTH-146)*0.5, CGRectGetMinY(NiaoKuImageView.frame)+10, 146, 146)];
    humidityImageView.image = [UIImage imageNamed:@"img_message_0"];
    [self.view addSubview:humidityImageView];

//    niaoTimesLabe = [[UILabel alloc] initWithFrame:CGRectMake(33, self.view.frame.size.height-70-40, 119, 40)];
//    niaoTimesLabe.backgroundColor = MainBgColor;
//    niaoTimesLabe.textColor = [UIColor whiteColor];
//    niaoTimesLabe.layer.cornerRadius = 20;
//    niaoTimesLabe.layer.masksToBounds = YES;
//    niaoTimesLabe.font = [UIFont systemFontOfSize:12];
//    niaoTimesLabe.text = [NSString stringWithFormat:@"预测尿次数：%d次",0];
//    niaoTimesLabe.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:niaoTimesLabe];

    niaoMlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
    niaoMlLabel.backgroundColor = MainBgColor;
    niaoMlLabel.textColor = [UIColor whiteColor];
    niaoMlLabel.layer.cornerRadius = 20;
    niaoMlLabel.layer.masksToBounds = YES;
    niaoMlLabel.font = [UIFont systemFontOfSize:12];
    NSString *tempStr = NSLocalizedString(@"urine_show", nil);
    niaoMlLabel.text = [NSString stringWithFormat:@"%@%dml",tempStr,0];
    niaoMlLabel.textAlignment = NSTextAlignmentCenter;
    niaoMlLabel.center = CGPointMake(YZSCREEN_WIDTH * 0.5, YZSCREEN_HEIGHT * 0.70);
    [self.view addSubview:niaoMlLabel];
}

- (void)getServerDataWithAFNetworking {
//    NSLog(@"----getServerDataWithAFNetworking");
    NSString *urlHeaderStr = YaZaiGetDataUrlHeader;
    NSString *deviceSN = globalData.serialNumberStr;
    /*
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 3.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    //2.封装参数
    NSString *urlHeaderStr = YaZaiGetDataUrlHeader;
    NSString *deviceSN = globalData.serialNumberStr;
    [manager POST:[NSString stringWithFormat:@"%@%@",urlHeaderStr,deviceSN] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSLog(@"%@",dict);
        dispatch_async(dispatch_get_main_queue(), ^{
            globalData.temperature = [self temperature:[dict[@"temperature"] floatValue]];
            globalData.urineVolume = [self humidityAmount:[dict[@"wetData"] intValue] withType:globalData.trouserSize];
            globalData.urineRate = [self humidityPercent:[dict[@"wetData"] intValue] withType:globalData.trouserSize];
            globalData.battayLevel = [self batteryLevel:[dict[@"batteryVoltage"] intValue]];
            globalData.position = [dict[@"sleepPosture"] intValue];
            
            //添加睡醒提醒的数组;
            int accX = [dict[@"accX"] intValue];
            int accY = [dict[@"accY"] intValue];
            int accZ = [dict[@"accZ"] intValue];
            
            if (globalData.accX == 0) {
                globalData.accX = accX;
                globalData.accY = accY;
                globalData.accZ = accZ;
            }
            else if (abs(globalData.accX - accX) > 50 || abs(globalData.accY - accY) > 50 || abs(globalData.accY - accY) > 50){
                //说明宝宝动了一次；
                //如果宝宝一分钟动了N次刚触发睡醒提醒闹钟;
                NSString *datetimeStr = dict[@"datetime"];
                [wakeUpMuArr addObject:datetimeStr];
                if (wakeUpMuArr.count > 1 && abs([wakeUpMuArr.lastObject longLongValue] - [wakeUpMuArr.firstObject longLongValue] > 60))
                    [wakeUpMuArr removeObject:wakeUpMuArr.firstObject];
                globalData.accX = accX;
                globalData.accY = accY;
                globalData.accZ = accZ;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:YaZaiGetServerDataSuccess object:nil];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure--%@",error);
    }];*/
    
    [[YZNetworkManage sharedManage] postWithPath:[NSString stringWithFormat:@"%@%@",urlHeaderStr,deviceSN] params:nil success:^(NSDictionary * _Nonnull dict) {
//        NSLog(@"----dict:%@",dict);
        globalData.temperature = [self temperature:[dict[@"temperature"] floatValue]];
        globalData.urineVolume = [self humidityAmount:[dict[@"wetData"] intValue] withType:globalData.trouserSize];
        globalData.urineRate = [self humidityPercent:[dict[@"wetData"] intValue] withType:globalData.trouserSize];
        globalData.battayLevel = [self batteryLevel:[dict[@"batteryVoltage"] intValue]];
        globalData.position = [dict[@"sleepPosture"] intValue];
        
        //添加睡醒提醒的数组;
        int accX = [dict[@"accX"] intValue];
        int accY = [dict[@"accY"] intValue];
        int accZ = [dict[@"accZ"] intValue];
        
//        NSLog (@"----%d,%d,%d",abs(globalData.accX - accX),abs(globalData.accY - accY),abs(globalData.accZ - accZ));
//        NSLog (@"----%d,%d,%d",accX,accY,accZ);
        if (globalData.accX == 0) {
            globalData.accX = accX;
            globalData.accY = accY;
            globalData.accZ = accZ;
        }
        else if (abs(globalData.accX - accX) > 50 || abs(globalData.accY - accY) > 50 || abs(globalData.accY - accY) > 50){
            //说明宝宝动了一次；
            //如果宝宝一分钟动了N次刚触发睡醒提醒闹钟;
            NSString *datetimeStr = dict[@"datetime"];
            [wakeUpMuArr addObject:datetimeStr];
            if (wakeUpMuArr.count > 1 && abs([wakeUpMuArr.lastObject longLongValue] - [wakeUpMuArr.firstObject longLongValue] > 60))
                [wakeUpMuArr removeObject:wakeUpMuArr.firstObject];
            globalData.accX = accX;
            globalData.accY = accY;
            globalData.accZ = accZ;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:YaZaiGetServerDataSuccess object:nil];
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"failure--");
    }];
    
}

//获取服务器的值
-(void)globaldatachange:(id)sender{
    //温度
    tempLabel.text = [NSString stringWithFormat:@"%0.1f℃",globalData.temperature];
    //尿量
    NSString *urineVolimage = @"img_message_0";
    if(globalData.urineRate<10){
        urineVolimage = @"img_message_0";
    }else if(globalData.urineRate<20){
        urineVolimage = @"img_message_10";
    }else if(globalData.urineRate<25){
        urineVolimage = @"img_message_20";
    }else if(globalData.urineRate<30){
        urineVolimage = @"img_message_25";
    }else if(globalData.urineRate<35){
        urineVolimage = @"img_message_30";
    }else if(globalData.urineRate<40){
        urineVolimage = @"img_message_45";
    }else if(globalData.urineRate<50){
        urineVolimage = @"img_message_40";
    }else if(globalData.urineRate<60){
        urineVolimage = @"img_message_50";
    }else if(globalData.urineRate<70){
        urineVolimage = @"img_message_60";
    }else if(globalData.urineRate<75){
        urineVolimage = @"img_message_70";
    }else if(globalData.urineRate<80){
        urineVolimage = @"img_message_75";
    }else if(globalData.urineRate<90){
        urineVolimage = @"img_message_80";
    }else if(globalData.urineRate<100){
        urineVolimage = @"img_message_90";
    }else{
        urineVolimage = @"img_message_100";
    }
    humidityImageView.image = [UIImage imageNamed:urineVolimage];
    NSString *tempStr = NSLocalizedString(@"urine_show", nil);
    niaoMlLabel.text = [NSString stringWithFormat:@"%@%0.2fml",tempStr,globalData.urineVolume];
    
    //设置手机报警铃声;
    
    //尿湿提醒:当前尿湿高于设定的尿湿时提醒;
    if (globalData.isHumidityAlerm && !isLaterUrienAlert) {
        int tempHumidity = 0;
        switch (globalData.humidity) {
            case urineHumidity_25:
                tempHumidity = 25;
                break;
            case urineHumidity_50:
                tempHumidity = 50;
                break;
            case urineHumidity_75:
                tempHumidity = 75;
                break;
            case urineHumidity_100:
                tempHumidity = 100;
                break;
                
            default:
                break;
        }
        if (globalData.urineRate > tempHumidity - 1) {
            [audioPlayerManage play];
            [urienAlertView show];
        }
        else {
            [urienAlertView dismiss];
        }
    }
    
    //踢被子提醒: 踢被子后温度会降低，当温度低于设置值时提示报警;
    if (globalData.isKickTemperatureAlerm && globalData.temperature < (float)globalData.kickTemperature && !isLaterkickAlert) {
        [audioPlayerManage play];
        [kickAlertView show];
    }else {
        [kickAlertView dismiss];
    }
    
    
    //睡醒提醒:通过计算x,y,z大于50时算一次；
    if (globalData.isWakeupAlerm) {
        [self wakeUpAlert:globalData.wakeupNumber];
    }
    
    //睡姿提醒：检测宝宝的睡姿
    //趴睡窒息危险
    if (globalData.isPositionDownDangerAlerm && globalData.position == sleepPosition_down && !isLaterDownDangerAlert) {
        [audioPlayerManage play];
        [downDangerAlertView show];
    }else {
        [downDangerAlertView dismiss];
    }
    //起床摔倒危险
    if (globalData.isWakeupDangerAlerm && globalData.position == sleepPosition_sit && !isLaterWakeupDangerAlert) {
        [audioPlayerManage play];
        [wakeupDangerAlertView show];
    }else {
        [wakeupDangerAlertView dismiss];
    }
    
    
}

//睡醒提醒实现方法,参数是一分钟内动了number次。
-(void)wakeUpAlert:(int)number {
    if (wakeUpMuArr.count > (number - 1) && !isLaterWakeupAlert ) {
        [audioPlayerManage play];
        [wakeupAlertView show];
        [wakeUpMuArr removeAllObjects];
    }
}

//尿量容量的计算（毫升量的处理）
- (int)humidityAmount:(int)voltage withType:(int)diaperType {
    /*
     int[] a= { 10, 20, 25, 30, 40, 50, 60, 70, 75, 80, 90,100,120};//amount table ML
     int[] v= {498,440,396,332,250,200,171,150,141,126,104, 89, 65};//value table according to C
     
     int[] K= new int[a.length-1];//slope
     for(int i=0;i<K.length;i++)
     {
     K[i]=1000*(a[i+1]-a[i])/(v[i]-v[i+1]);//K is a scaled 1000 times slope
     }
     if(voltage > v[0]) //c is the read value from the sensor. Amount is not detectable now
     {
     //textViewCC.setText("0ml");
     tempV = 0;
     }
     else if(voltage < v[v.length-1]) //amount over the max measurable value
     {
     //textViewCC.setText(">" + a[a.length-1]+ "ml");
     tempV = a[a.length - 1]+10;
     }
     else {  //amount measurable
     for (int i = 0; i < K.length; i++) {
     if (voltage < v[i] && voltage > v[i+1]) {
     tempV= a[i] + K[i] * ( v[i] - voltage ) / 1000;
     //textViewCC.setText(tempV+ "ml");
     break;
     }
     }
     }*/
    int tempV = -1;//尿量容量;
    
    NSArray *preUrineVolumeArr = [[NSArray alloc]init];
    NSArray *voltageArr = [[NSArray alloc]init];//电压数组;
    
    NSMutableArray *urineVolumeMutArr = [[NSMutableArray alloc]init];
    
    if (diaperType == 0) {
        preUrineVolumeArr = @[@10,@20,@25,@30,@40,@50,@60,@70,@75,@80,@90,@100,@120];//尿量预测值数组;
        voltageArr = @[@498,@440,@396,@332,@250,@200,@171,@150,@141,@126,@104,@89,@65];//电压数组;
    }else if (diaperType == 1){
        preUrineVolumeArr = @[@12, @24, @30, @36, @48, @60, @70, @80, @85, @90,@100,@110,@120];//尿量预测值数组;
        voltageArr = @[@498,@440,@396,@332,@250,@200,@171,@150,@141,@126,@104, @89, @65];//电压数组;
    }else if (diaperType == 2){
        preUrineVolumeArr = @[@14,@28,@35,@42,@56,@70,@82,@94,@100,@105,@120,@130,@150];//尿量预测值数组;
        voltageArr = @[@488,@385,@340,@300,@240,@200,@162,@136,@126,@112,@91,@77,@55];//电压数组;
    }else if (diaperType == 3){
        preUrineVolumeArr = @[@18,@36,@45,@52,@66,@80,@96,@112,@120,@126,@138,@150,@180];//尿量预测值数组;
        voltageArr = @[@480,@340,@300,@265,@218,@184,@148,@124,@114,@102,@85,@72,@50];//电压数组;
    }else if (diaperType == 4){
        preUrineVolumeArr = @[@20,@40,@50,@58,@74,@90,@106,@122,@130,@140,@160,@180,@200];//尿量预测值数组;
        voltageArr = @[@440,@306,@265,@244,@203,@162,@134,@106,@92,@83,@65,@47,@35];//电压数组;
    }
    
    for (int i = 0; i < preUrineVolumeArr.count - 1; i ++) {
        NSInteger k = 1000*([preUrineVolumeArr[i + 1] intValue] - [preUrineVolumeArr[i] intValue])/([voltageArr[i] intValue] - [voltageArr[i + 1] intValue]);
        [urineVolumeMutArr addObject:[NSNumber numberWithInteger:k]];
    }
    if (voltage > [voltageArr[0] intValue]) {
        tempV = 0;
    }
    else if (voltage < [voltageArr.lastObject intValue]){
        tempV = [voltageArr.lastObject intValue] + 10;
    }
    else {
        for (int i = 0; i < urineVolumeMutArr.count; i ++) {
            if (voltage > [voltageArr[i+1] intValue] && voltage < [voltageArr[i] intValue]) {
                tempV = [preUrineVolumeArr[i] intValue] + [urineVolumeMutArr[i] intValue]*([voltageArr[i] intValue] - voltage)/1000;
                break;
            }
        }
    }
    return tempV;
}

//尿量对应百分比的计算
- (int)humidityPercent:(int)voltage withType:(int)diaperType {
    /*
     int humiditys=0;
     
     if(CCfactor == 0){   //NB 码
     int[] h= { 12, 24, 30, 42, 66, 90,110,130,140,160,200,240};//容量值
     if (DataValue >= h[11]) {
     humiditys=100;
     } else if (DataValue >= h[10]) {
     humiditys=90;
     } else if (DataValue >= h[9]) {
     humiditys=80;
     } else if (DataValue >= h[8]) {
     humiditys=75;
     } else if (DataValue >= h[7]) {
     humiditys=70;
     } else if (DataValue >= h[6]) {
     humiditys=60;
     } else if (DataValue >= h[5]) {
     humiditys=50;
     } else if (DataValue >= h[4]) {
     humiditys=40;
     } else if (DataValue >= h[3]) {
     humiditys=30;
     } else if (DataValue >= h[2]) {
     humiditys=25;
     } else if (DataValue >= h[1]) {
     humiditys=20;
     } else if (DataValue >= h[0]) {
     humiditys=10;
     } else {
     humiditys=0;
     }
     
     }*/
    
    int DataValue = 0;
    if (voltage != 0) {
        int tempV = 24000 / voltage;
        if (tempV < 50) {
            DataValue = (101760 / voltage - 192);
        } else {
            DataValue = tempV - 30;
        }
        if (DataValue < 0){
            DataValue = 0;
        }
        //LogUtils.e(TAG,"DataValue="+DataValue);
    }
    
    int humiditys = -1;
    NSArray *voltageArr = [[NSArray alloc]init];
    if (diaperType == 0) {
        voltageArr = @[@12,@24,@30,@42,@66,@90,@110,@130,@140,@160,@200,@240];
    }else if (diaperType == 1) {
        voltageArr = @[@12,@24,@30,@42,@66,@90,@110,@130,@140,@160,@200,@240];
    }else if (diaperType == 2) {
        voltageArr = @[@16,@32,@40,@50,@70,@90,@118,@146,@160,@184,@232,@280];
    }else if (diaperType == 3) {
        voltageArr = @[@20,@40,@50,@60,@80,@100,@132,@164,@180,@204,@252,@300];
    }else if (diaperType == 4) {
        voltageArr = @[@24,@48,@60,@68,@88,@118,@149,@196,@230,@259,@339,@480];
    }
    
    if (DataValue >[voltageArr.lastObject intValue] || DataValue == [voltageArr.lastObject intValue]) {
        humiditys=100;
    }else if (DataValue >[voltageArr[10] intValue]|| DataValue == [voltageArr[10] intValue]){
        humiditys=90;
    }else if (DataValue >[voltageArr[9] intValue]|| DataValue == [voltageArr[9] intValue]){
        humiditys=80;
    }else if (DataValue >[voltageArr[8] intValue]|| DataValue == [voltageArr[8] intValue]){
        humiditys=75;
    }else if (DataValue >[voltageArr[7] intValue]|| DataValue == [voltageArr[7] intValue]){
        humiditys=70;
    }else if (DataValue >[voltageArr[6] intValue]|| DataValue == [voltageArr[6] intValue]){
        humiditys=60;
    }else if (DataValue >[voltageArr[5] intValue]|| DataValue == [voltageArr[5] intValue]){
        humiditys=50;
    }else if (DataValue >[voltageArr[4] intValue]|| DataValue == [voltageArr[4] intValue]){
        humiditys=40;
    }else if (DataValue >[voltageArr[3] intValue]|| DataValue == [voltageArr[3] intValue]){
        humiditys=30;
    }else if (DataValue >[voltageArr[2] intValue]|| DataValue == [voltageArr[2] intValue]){
        humiditys=25;
    }else if (DataValue >[voltageArr[1] intValue]|| DataValue == [voltageArr[1] intValue]){
        humiditys=20;
    }else if (DataValue >[voltageArr[0] intValue]|| DataValue == [voltageArr[0] intValue]){
        humiditys=10;
    }else {
        humiditys=0;
    }
    
    return humiditys;
    
}

- (CGFloat)temperature:(CGFloat)value {
    return 0.5 * value;
}

//电池电量计算
- (CGFloat)batteryLevel:(int)batterVoltage {
    float currentBattery = 2.00 + 0.01 * batterVoltage;
    CGFloat batterValue = 0;
    if (currentBattery > 3.2 || currentBattery == 3.2) {
        batterValue = 100;
    }
    else if (currentBattery < 2.1 || currentBattery == 2.1) {
        batterValue = 0;
    }
    else {
        batterValue = (currentBattery - 2.1)/1.1 * 100;
    }
    return batterValue;
}

- (void)connectDeviceSuccess {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    globalData.serialNumberStr  = [userDefaults valueForKey:@"SerialNumber"];
    
    [serverDataTimer setFireDate:[NSDate distantPast]];
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
