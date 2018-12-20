//
//  YZTool.h
//  YaZaiTechWifi
//
//  Created by cheng luo on 2018/12/4.
//  Copyright © 2018年 homeSalf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZTool : NSObject

/**
 
  *     添加导航栏透明效果
 
  *     参数：hidden （YES透明效果，NO不透明效果）
 
  */

+ (void)setTransparencyHidden:(BOOL)hidden with:(UIViewController *)vc;
/**
 获取当前Wifi的方法
 返回：wifi名
 */
+(NSString*)getWifiName;

/**
 NSData转NSString
 */
+ (NSString *)convertDataToHexStr:(NSData *)data;

/**
 获取手机的UUID
 */
+ (NSString *)getPhoneUUID;

/**
 * 获取到UUID后存入系统中的keychain中，保证以后每次可以得到相同的唯一标志
 * 不用添加plist文件，当程序删除后重装，仍可以得到相同的唯一标示
 * 但是当系统升级或者刷机后，系统中的钥匙串会被清空，再次获取的UUID会与之前的不同
 * @return keychain中存储的UUID
 */
+ (NSString *)getUUIDInKeychain;

/**
 * 删除存储在keychain中的UUID
 * 如果删除后，重新获取用户的UUID会与之前的UUID不同
 */
+ (void)deleteKeyChain;

/**
 MD5加密成16位
 参数:任何字串
 */
+ (NSString *)md5HashToLower16Bit:(NSString *)inputStr;

/**
 MD5加密成32位
 参数:任何字串
 */
+ (NSString *)md5HashToLower32Bit:(NSString *)inputStr;

@end

NS_ASSUME_NONNULL_END
