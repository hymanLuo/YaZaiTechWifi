//
//  Globaldata.h
//  YaZai
//
//  Created by admin on 2018/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum sleepPosition{
    sleepPosition_down = 1,
    sleepPosition_right = 2,
    sleepPosition_up = 4,
    sleepPosition_letf = 8,
    sleepPosition_sit = 16
}sleepPosition;

typedef enum urineHumidity{
    urineHumidity_25,
    urineHumidity_50,
    urineHumidity_75,
    urineHumidity_100
}urineHumidity;

@interface Globaldata : NSObject

@property (nonatomic,strong)NSString *serialNumberStr;//请求服务器的设备SN号
@property (nonatomic,strong)NSString *uuidStr;//手机的UUID;

//尿尿检测;
@property (assign, nonatomic) float temperature;//温度
@property (assign, nonatomic) float  urineVolume;//尿量
@property (strong, nonatomic) NSString *urlneCount;//预测尿次数
@property (nonatomic,assign) int urineRate;//尿量百分比;

//计算是否睡醒;
@property (nonatomic,assign)int accX; //x加速度
@property (nonatomic,assign)int accY; //y加速度
@property (nonatomic,assign)int accZ; //z加速度

//睡姿检测
@property (nonatomic, assign) sleepPosition position;//睡眠姿势

//设置界面
@property (nonatomic,assign)int battayLevel;//电量

@property (nonatomic,assign)urineHumidity humidity;//设置提醒尿湿值;
@property (nonatomic,assign)BOOL isHumidityAlerm;//是否开启尿湿值提醒;

@property (nonatomic,assign)int kickTemperature;//设置踢被子提醒温度值;
@property (nonatomic,assign)BOOL isKickTemperatureAlerm;//是否开启踢被子温度提醒;

@property (nonatomic,assign)int wakeupNumber;//睡醒次数提醒;
@property (nonatomic,assign)BOOL isWakeupAlerm;//是否开启睡醒次数提醒;
@property (nonatomic,assign)BOOL isPositionDownDangerAlerm;//是否开启趴睡窒息危险提醒;
@property (nonatomic,assign)BOOL isWakeupDangerAlerm;//是否开启起床摔倒危险提醒;

@property (nonatomic,assign)int trouserSize;//婴儿裤码;

@property (nonatomic,assign)int volumeValue;//设置设备音量;


+(instancetype) shareInstance;
@end

NS_ASSUME_NONNULL_END
