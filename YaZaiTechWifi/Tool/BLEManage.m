//
//  BLEManage.m
//  YaZai
//
//  Created by admin on 2018/11/26.
//

#import "BLEManage.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "YZTool.h"



@interface BLEManage ()<CBCentralManagerDelegate,CBPeripheralDelegate>

/// 中央管理者 -->管理设备的扫描 --连接
@property (nonatomic, strong) CBCentralManager *centralManager;

// 存储的设备数组
@property (nonatomic, strong) NSMutableArray *peripherals;

// 蓝牙状态
@property (nonatomic, assign) CBManagerState peripheralState;

@end

@implementation BLEManage

static BLEManage *manage = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        manage = [[super allocWithZone:NULL] init] ;
        manage.centralManager  = [[CBCentralManager alloc] initWithDelegate:manage queue:nil];
        manage.peripherals = [NSMutableArray array];
    }) ;
    
    return manage ;
}


+(id) allocWithZone:(struct _NSZone *)zone
{
    return [BLEManage shareInstance] ;
}

-(id) copyWithZone:(NSZone *)zone
{
    return [BLEManage shareInstance] ;//return _instance;
}

-(id) mutablecopyWithZone:(NSZone *)zone
{
    return [BLEManage shareInstance] ;
}

//开始搜索
-(void)starSacn{
    
    [self.centralManager stopScan];
    NSLog(@"扫描设备");
    if (self.peripheralState ==  CBManagerStatePoweredOn)
    {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

//结束搜索
-(void)stopSacn{
    
    [self.centralManager stopScan];
    [self.peripherals removeAllObjects];
}

// 状态更新时调用
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:{
            NSLog(@"未知状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateResetting:
        {
            NSLog(@"重置状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnsupported:
        {
            NSLog(@"不支持的状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnauthorized:
        {
            NSLog(@"未授权的状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@"关闭状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@"开启状态－可用状态");
            self.peripheralState = central.state;
        }
            break;
        default:
            break;
    }
}
/**
 扫描到设备
 
 @param central 中心管理者
 @param peripheral 扫描到的设备
 @param advertisementData 广告信息
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
//    NSLog(@"发现设备,设备名:%@",peripheral.name);

    if (![self.peripherals containsObject:peripheral] && [peripheral.name rangeOfString:@"LN-"].location != NSNotFound && peripheral.name != nil)
    {
        [self.peripherals addObject:peripheral];
        NSLog(@"添加%@,%@",peripheral.name,advertisementData);
        
        NSDictionary *dic = advertisementData;
        NSData *data = [dic objectForKey:@"kCBAdvDataManufacturerData"];
        
        NSData *companyData =  [data subdataWithRange:NSMakeRange(0, 3)];
        NSData *deviceData =  [data subdataWithRange:NSMakeRange(3, 3)];
        
        NSString *company = [YZTool convertDataToHexStr:companyData];
        NSString *device = [YZTool convertDataToHexStr:deviceData];
        
        NSString *btLimitAddrStr = [NSString stringWithFormat:@"%@%@",company,device];//btLimitAddr
        NSLog(@"btLimitAddr:%@",btLimitAddrStr);
        [[NSNotificationCenter defaultCenter]postNotificationName:YaZaiDiscoverNewBluetoothDevice object:@{@"bluetoothName":peripheral.name,@"btLimitAddr":btLimitAddrStr}];
    }
}



@end

