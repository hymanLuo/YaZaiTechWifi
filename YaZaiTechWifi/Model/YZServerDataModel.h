//
//  YZServerDataModel.h
//  YaZaiTechWifi
//
//  Created by cheng luo on 2018/12/8.
//  Copyright © 2018年 homeSalf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZServerDataModel : NSObject

@property (nonatomic,assign)int serverId;
@property (nonatomic,strong)NSString *serialNumber;//通过wifi连接设备获取的设备串号
@property (nonatomic,strong)NSString *deviceName;//设备名
@property (nonatomic,strong)NSString *btdeviceaddr;//传感器地址
@property (nonatomic,strong)NSString *datetime; //设备传到服务的时间
@property (nonatomic,assign)int accX; //x加速度
@property (nonatomic,assign)int accY; //y加速度
@property (nonatomic,assign)int accZ; //z加速度
@property (nonatomic,assign)int buckle; //开闭扣0x0
@property (nonatomic,assign)int wetData; //尿湿数据
@property (nonatomic,assign)int batteryVoltage; //电池电压值
@property (nonatomic,assign)int temperature;  //温度值
@property (nonatomic,assign)int sleepPosture; //睡姿
@property (nonatomic,assign)int staticFlag; //静止监测标志

@end

NS_ASSUME_NONNULL_END
