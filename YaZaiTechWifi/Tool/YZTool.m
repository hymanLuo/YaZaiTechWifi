//
//  YZTool.m
//  YaZaiTechWifi
//
//  Created by cheng luo on 2018/12/4.
//  Copyright © 2018年 homeSalf. All rights reserved.
//

#import "YZTool.h"
#import<SystemConfiguration/CaptiveNetwork.h>
#import<SystemConfiguration/SystemConfiguration.h>
#import <NetworkExtension/NEHotspotConfigurationManager.h>

#import<CommonCrypto/CommonDigest.h>

@implementation YZTool

NSString * const kUUIDKey = @"com.myApp.uuid";

+ (void)setTransparencyHidden:(BOOL)hidden with:(UIViewController *)vc {
    
    vc.navigationController.navigationBar.translucent = hidden;
    
    UIColor * color = [UIColor clearColor];
    
    if (hidden == NO) {
        
        color = [UIColor greenColor];//该颜色可以自定义
        
    }
    
    CGRect rect = CGRectMake(0, 0, vc.view.bounds.size.width, 64);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [vc.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    vc.navigationController.navigationBar.clipsToBounds = hidden;
    
    vc.navigationController.navigationBar.alpha = 1;
}

//获取当前已连接wifi名
+(NSString*)getWifiName{
    
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}

//nsdata转nsstring
+ (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

// 普通的获取UUID的方法
+ (NSString *)getPhoneUUID {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    result = [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return result;
}


//16位
+ (NSString *)md5HashToLower16Bit:(NSString *)inputStr {
    NSString *md5Str = [YZTool md5HashToLower32Bit:inputStr];
    
    NSString *string;
    for (int i=0; i<24; i++) {
        string=[md5Str substringWithRange:NSMakeRange(8, 16)];
    }
//    NSLog(@"uuid----%@",string);
    return string;
}

//32位
+ (NSString *)md5HashToLower32Bit:(NSString *)inputStr {
    const char *input = [inputStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
//    NSLog(@"MD5加密前:%@,加密后:%@",inputStr,digest);
    return digest;
}

#pragma mark - 获取到UUID后存入系统中的keychain中
+ (NSString *)getUUIDInKeychain {
    // 1.直接从keychain中获取UUID
    NSString *getUDIDInKeychain = (NSString *)[YZTool load:kUUIDKey];
    //    NSLog(@"从keychain中获取UUID%@", getUDIDInKeychain);
    
    // 2.如果获取不到，需要生成UUID并存入系统中的keychain
    if (!getUDIDInKeychain || [getUDIDInKeychain isEqualToString:@""] || [getUDIDInKeychain isKindOfClass:[NSNull class]]) {
        // 2.1 生成UUID
        CFUUIDRef puuid = CFUUIDCreate(nil);
        CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
        NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
//        NSLog(@"生成UUID：%@",result);
        // 2.2 将生成的UUID保存到keychain中
        [YZTool save:kUUIDKey data:result];
        // 2.3 从keychain中获取UUID
        getUDIDInKeychain = (NSString *)[YZTool load:kUUIDKey];
    }
    
    return getUDIDInKeychain;
}


#pragma mark - 删除存储在keychain中的UUID

+ (void)deleteKeyChain {
    [self delete:kUUIDKey];
}


#pragma mark - keychain私有方法

+ (NSMutableDictionary *)getKeyChainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassGenericPassword,(id)kSecClass,service,(id)kSecAttrService,service,(id)kSecAttrAccount,(id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible, nil];
}

// 从keychain中获取UUID
+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeyChainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *exception) {
            //            NSLog(@"Unarchive of %@ failed: %@", service, exception);
        }
        @finally {
            //            NSLog(@"finally");
        }
    }
    
    if (keyData) {
        CFRelease(keyData);
    }
    //    NSLog(@"ret = %@", ret);
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeyChainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

// 将生成的UUID保存到keychain中
+ (void)save:(NSString *)service data:(id)data {
    // Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeyChainQuery:service];
    // Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    // Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    // Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}


@end
