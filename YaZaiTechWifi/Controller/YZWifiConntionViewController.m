//
//  YZWifiConntionViewController.m
//  YaZaiTech
//
//  Created by cheng luo on 2018/12/4.
//  Copyright © 2018年 Can He Chan. All rights reserved.
//

#import "YZWifiConntionViewController.h"
#import "YZTool.h"
#import "BLEManage.h"
#import "GCDAsyncSocket.h"
#import "CustomAlertView.h"

@interface YZWifiConntionViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation YZWifiConntionViewController
{
    UIButton *bluetoothAddressButton;
    NSMutableArray *discoverBluetoothArr;
    UITableView *mTableView;
    UIView *bluetoothAddressView;
    UILabel *currentWifiNameDetailLabel;
    UILabel *deviceWifiDetailLabel;
    UITextField *currentWifiPasswordField;//密码输入框;
    UITextField *serveAddressField;//服务器输入框;
    
    NSString *usableWifiName;
    NSString *usableWifiPassword;
    NSString *bluetoothAddressStr;
    
    GCDAsyncSocket *socket;
    
    BLEManage *bleManage;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    
    discoverBluetoothArr = [[NSMutableArray alloc]init];
    
    bleManage = [BLEManage shareInstance];
    [bleManage performSelector:@selector(starSacn) withObject:nil afterDelay:0.1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleManagePerChange:) name:YaZaiDiscoverNewBluetoothDevice object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [bleManage stopSacn];
    [self socketDisconnect];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YaZaiDiscoverNewBluetoothDevice object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor redColor];
    
    bluetoothAddressStr = [[NSString alloc]init];
    usableWifiName = [[NSString alloc]init];
    usableWifiPassword = [[NSString alloc]init];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -1, YZSCREEN_WIDTH, YZSCREEN_HEIGHT+2)];
    imageView.image = [UIImage imageNamed:@"YZBlueScan_selected"];
    [self.view addSubview:imageView];

    self.title = @"WIFI设备配网";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    backButton.backgroundColor = [UIColor grayColor];
    backButton.frame = CGRectMake(0, 0, 40, 40);
    [backButton setImage:[UIImage imageNamed:@"back_image"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    CGFloat navigationHeight = [UIApplication sharedApplication].statusBarFrame.size.height + 44;
    
    //1.请先连接有网的Wifi并输入密码，点击确认；
    UILabel *step1Label = [[UILabel alloc]initWithFrame:CGRectMake(5, navigationHeight + 10, 150, 20)];
    step1Label.text = @"一、连接有网的Wifi";
    step1Label.textColor = [UIColor redColor];
    step1Label.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:step1Label];
    
    //当前连接的WiFi名
    UILabel *currentWifiNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(step1Label.frame) + 20, 150, 20)];
    currentWifiNameLabel.text = @"当前连接的Wifi:";
    currentWifiNameLabel.textColor = [UIColor whiteColor];
    currentWifiNameLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:currentWifiNameLabel];
    currentWifiNameDetailLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(currentWifiNameLabel.frame), currentWifiNameLabel.frame.origin.y, YZSCREEN_WIDTH - CGRectGetMaxX(currentWifiNameLabel.frame) - 10, 20)];
    currentWifiNameDetailLabel.text = nil;
    currentWifiNameDetailLabel.textColor = [UIColor whiteColor];
    currentWifiNameDetailLabel.font = [UIFont systemFontOfSize:16];
    currentWifiNameDetailLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:currentWifiNameDetailLabel];
    
    //当前连接WIFi密码
    UILabel *currentWifiPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,CGRectGetMaxY(currentWifiNameLabel.frame) + 20, 150, 20)];
    currentWifiPasswordLabel.text = @"当前连接Wifi密码:";
    currentWifiPasswordLabel.textColor = [UIColor whiteColor];
    currentWifiPasswordLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:currentWifiPasswordLabel];
    
    //WIFi密码输入框
    currentWifiPasswordField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(currentWifiPasswordLabel.frame), currentWifiPasswordLabel.frame.origin.y, YZSCREEN_WIDTH - CGRectGetMaxX(currentWifiPasswordLabel.frame) - 10, 20)];
//    currentWifiPasswordField.secureTextEntry = YES;
    currentWifiPasswordField.backgroundColor = [UIColor whiteColor];
    currentWifiPasswordField.text = @"wwwwww374@126.com";
    [self.view addSubview:currentWifiPasswordField];
    
    //确认按钮
    UIButton *confirmCurrentWifiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmCurrentWifiButton setTitle:@"确认" forState:UIControlStateNormal];
    confirmCurrentWifiButton.frame = CGRectMake(5, CGRectGetMaxY(currentWifiPasswordLabel.frame) + 20, 90, 30);
    confirmCurrentWifiButton.center = CGPointMake(YZSCREEN_WIDTH * 0.5, confirmCurrentWifiButton.center.y);
    confirmCurrentWifiButton.layer.cornerRadius = confirmCurrentWifiButton.frame.size.height * 0.5;
    confirmCurrentWifiButton.backgroundColor = [UIColor grayColor];
    [self.view addSubview:confirmCurrentWifiButton];
    [confirmCurrentWifiButton addTarget:self action:@selector(confirmCurrentWifi) forControlEvents:UIControlEventTouchUpInside];
    
    
    //2.再连接到以ESP_开头的设备Wifi\n3.点击选择传感器蓝牙地址;
    UILabel *step2Label = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(confirmCurrentWifiButton.frame) + 20, 300, 20)];
    step2Label.text = @"二、连接ESP_开头的设备Wifi";
    step2Label.textColor = [UIColor redColor];
    step2Label.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:step2Label];
    
    //设备wifi
    UILabel *deviceWifiLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,CGRectGetMaxY(step2Label.frame) + 20, 150, 20)];
    deviceWifiLabel.text = @"WIFI设备SSID:";
    deviceWifiLabel.textColor = [UIColor whiteColor];
    deviceWifiLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:deviceWifiLabel];
    deviceWifiDetailLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(deviceWifiLabel.frame), deviceWifiLabel.frame.origin.y, YZSCREEN_WIDTH - CGRectGetMaxX(deviceWifiLabel.frame) - 10, 20)];
    if ([[YZTool getWifiName] hasPrefix:@"ESP_"]) {
        deviceWifiDetailLabel.text = [YZTool getWifiName];
    }
    else {
        deviceWifiDetailLabel.text = nil;
    }
    
    deviceWifiDetailLabel.textColor = [UIColor whiteColor];
    deviceWifiDetailLabel.font = [UIFont systemFontOfSize:16];
    deviceWifiDetailLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:deviceWifiDetailLabel];
    
    //蓝牙地址
    UILabel *bluetoothAddressLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,CGRectGetMaxY(deviceWifiLabel.frame) + 20, 150, 20)];
    bluetoothAddressLabel.text = @"传感器蓝牙地址:";
    bluetoothAddressLabel.textColor = [UIColor whiteColor];
    bluetoothAddressLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:bluetoothAddressLabel];
    
    //显示蓝牙地址按钮
    bluetoothAddressButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bluetoothAddressButton setTitle:@"点击获取" forState:UIControlStateNormal];
    bluetoothAddressButton.titleLabel.font = [UIFont systemFontOfSize:16];
    bluetoothAddressButton.frame = CGRectMake(CGRectGetMaxX(bluetoothAddressLabel.frame), bluetoothAddressLabel.frame.origin.y, YZSCREEN_WIDTH - CGRectGetMaxX(bluetoothAddressLabel.frame) - 10, 20);
    bluetoothAddressButton.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:bluetoothAddressButton];
    [bluetoothAddressButton addTarget:self action:@selector(showBluetoothView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //服务器地址
    UILabel *serveAddressLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,CGRectGetMaxY(bluetoothAddressLabel.frame) + 20, 150, 20)];
    serveAddressLabel.text = @"服务器地址:";
    serveAddressLabel.textColor = [UIColor whiteColor];
    serveAddressLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:serveAddressLabel];
    
    //服务器地址输入框
    serveAddressField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(serveAddressLabel.frame), serveAddressLabel.frame.origin.y, YZSCREEN_WIDTH - CGRectGetMaxX(serveAddressLabel.frame) - 10, 20)];
    serveAddressField.backgroundColor = [UIColor whiteColor];
    serveAddressField.text = @"http://203.195.193.246:8080";
    [self.view addSubview:serveAddressField];
    
    //连接按钮
    UIButton *connectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [connectionButton setTitle:@"连接" forState:UIControlStateNormal];
    connectionButton.frame = CGRectMake(5, CGRectGetMaxY(serveAddressLabel.frame) + 20, 90, 30);
    connectionButton.center = CGPointMake(YZSCREEN_WIDTH * 0.5, connectionButton.center.y);
    connectionButton.layer.cornerRadius = connectionButton.frame.size.height * 0.5;
    connectionButton.backgroundColor = [UIColor grayColor];
    [self.view addSubview:connectionButton];
    [connectionButton addTarget:self action:@selector(connectDevice) forControlEvents:UIControlEventTouchUpInside];
    
    //显示蓝牙地址的view
    bluetoothAddressView = [[UIView alloc]init];
    bluetoothAddressView.backgroundColor = [UIColor whiteColor];
    bluetoothAddressView.frame = CGRectMake(bluetoothAddressButton.frame.origin.x, CGRectGetMaxY(bluetoothAddressButton.frame), bluetoothAddressButton.frame.size.width, 40);
    [self.view addSubview:bluetoothAddressView];
    bluetoothAddressView.hidden = YES;
    
    //提示
    UILabel *hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,CGRectGetMaxY(connectionButton.frame) + 20, YZSCREEN_WIDTH - 10, 80)];
    hintLabel.text = @"具体步骤:\n1.请先连接有网的Wifi并输入密码，点击确认；\n2.再连接到以ESP_开头的设备Wifi\n3.点击选择传感器蓝牙地址;";
    hintLabel.textColor = [UIColor redColor];
    hintLabel.font = [UIFont systemFontOfSize:14];
    hintLabel.numberOfLines = 0;
    [hintLabel sizeToFit];
    [self.view addSubview:hintLabel];
    
    mTableView = [[UITableView alloc] initWithFrame:bluetoothAddressView.bounds style:UITableViewStylePlain];
    mTableView.backgroundColor = [UIColor clearColor];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    UIView *footview = [[UIView alloc]init];
    mTableView.tableFooterView = footview;
    [bluetoothAddressView addSubview:mTableView];
    
    [self updataWifiName];
}


#pragma mark --Private Method
-(void)bleManagePerChange:(NSNotification *)sender{
    NSLog(@"有新蓝牙发现：%@",sender);
    NSDictionary *dic = [sender object];
    NSMutableString *btLimitAddrMuStr = [[NSMutableString alloc]initWithString:dic[@"btLimitAddr"]];
    
    [btLimitAddrMuStr insertString:@":" atIndex:2];
    [btLimitAddrMuStr insertString:@":" atIndex:5];
    [btLimitAddrMuStr insertString:@":" atIndex:8];
    [btLimitAddrMuStr insertString:@":" atIndex:11];
    [btLimitAddrMuStr insertString:@":" atIndex:14];
    
    if (![discoverBluetoothArr containsObject:[btLimitAddrMuStr copy]]) {
        [discoverBluetoothArr addObject:[btLimitAddrMuStr copy]];
        [mTableView reloadData];
    }
//    [bluetoothAddressButton setTitle:btLimitAddrMuStr forState:UIControlStateNormal];
}

- (void)showBluetoothView:(id)sender {
    bluetoothAddressView.hidden = !bluetoothAddressView.hidden;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updataWifiName {
    NSString *wifiNameStr = [YZTool getWifiName];
    if ([wifiNameStr hasPrefix:@"ESP_"]) {
//        currentWifiNameDetailLabel.text = nil;
        deviceWifiDetailLabel.text = wifiNameStr;
    }
    else if (wifiNameStr ==nil||wifiNameStr.length == 0){
        
    }
    else {
        currentWifiNameDetailLabel.text = wifiNameStr;
        deviceWifiDetailLabel.text = nil;
    }
}

- (void)confirmCurrentWifi {
    if (currentWifiNameDetailLabel.text != nil && currentWifiNameDetailLabel.text.length !=0 && currentWifiPasswordField.text != nil && currentWifiPasswordField.text.length !=0) {
        usableWifiName = currentWifiNameDetailLabel.text;
        usableWifiPassword = currentWifiPasswordField.text;
        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:nil message:@"成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alerView show];
    }
    else {
        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:nil message:@"Wifi名或密码不能为空!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alerView show];
    }
    
}

- (void)connectDevice {
    
    if (deviceWifiDetailLabel.text ==nil || deviceWifiDetailLabel.text.length ==0) {
        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:nil message:@"请先连接设备Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alerView show];
        return ;
    }
//    if (bluetoothAddressStr == nil || bluetoothAddressStr.length == 0) {
//        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:nil message:@"请选择要连接的蓝牙" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alerView show];
//        return;
//    }
    
    if (serveAddressField.text == nil || serveAddressField.text.length == 0) {
        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:nil message:@"请输入服务器地址" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alerView show];
        return;
    }
    
    [self socketConnectHost];
    
}

#pragma mark ---GCDAsyncSocket method
// 建立socket连接
-(void)socketConnectHost{
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSLog(@"连接服务器");
    NSError *error = nil;
    
    [socket connectToHost:@"192.168.4.1" onPort:8266 withTimeout:30 error:&error];
}

// socket成功连接回调
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"成功连接到%@:%d",host,port);
    [self sendConnet];
    [socket readDataWithTimeout:-1 tag:10];
}

- (void)socketDisconnect {
    [socket disconnect];
}

// 发消息
- (void)sendMessage:(NSData *)data {
    [socket writeData:data withTimeout:30 tag:10];
}

// wirte成功
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // 持续接收数据
    // 超时设置为附属，表示不会使用超时
    NSLog(@"---写入成功");
    [socket readDataWithTimeout:-1 tag:tag];
}

//接收数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // 在这里处理消息
    NSString *str = [[NSString alloc]initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    NSLog(@"---接收数据:%@",str);
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err= nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    // {"index": "sn","SerialNumber": "Homsafe_143390_305844","ret": "ok"}
    NSLog(@"----SerialNumber:%@",dic[@"SerialNumber"]);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:dic[@"SerialNumber"] forKey:@"SerialNumber"];
    [userDefaults synchronize];
    
//    [self back];
    if (dic[@"SerialNumber"] !=nil) {
        //接收数据成功;
        [self responeConnet];
    }
    
    //持续接收服务端的数据
    [sock readDataWithTimeout:-1 tag:tag];
}


- (void)sendConnet {
   NSDictionary *param = @{@"ssid":usableWifiName,@"passwd":usableWifiPassword,@"serverReqStr":serveAddressField.text,@"btLimitAddr":bluetoothAddressStr};
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"写入数据的json:%@",jsonString);
    [self sendMessage:jsonData];
}

-  (void)responeConnet {
    NSString *reponseStr = @"esp8266reboot";
    NSData *reponseData =[reponseStr dataUsingEncoding:NSUTF8StringEncoding];
    [[NSNotificationCenter defaultCenter] postNotificationName:YaZaiConnectDeviceSuccess object:nil];
    [self sendMessage:reponseData];
    CustomAlertView *alerView = [[CustomAlertView alloc]initWithAlertDelegate:self title:nil message:@"连接成功" buttonTitle:@[@"OK"] pressOK:nil pressCancel:nil];
    [alerView show];
}

#pragma mark ---enterForegroundNotification
- (void)applicationWillEnterForegroundNotification:(id)sender {
    NSLog(@"----applicationWillEnterForegroundNotification");
    [self updataWifiName];
}


#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return discoverBluetoothArr.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//    cell.backgroundColor = [UIColor grayColor];
    cell.textLabel.text = discoverBluetoothArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *tempStr = discoverBluetoothArr[indexPath.row];
    bluetoothAddressStr = [tempStr stringByReplacingOccurrencesOfString:@":" withString:@""];
    [bluetoothAddressButton setTitle:tempStr forState:UIControlStateNormal];
    
    bluetoothAddressView.hidden = YES;
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
