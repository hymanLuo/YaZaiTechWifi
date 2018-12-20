//
//  MTNetworkManage.h
//  MTPostDemo
//
//  Created by cheng luo on 2018/12/12.
//  Copyright © 2018年 miotone. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^HttpSuccessBlock)(NSDictionary *dict);
typedef void (^HttpFailureBlock)(NSError *error);

@interface YZNetworkManage : NSObject

+ (YZNetworkManage*)sharedManage;

/**
 post网络请求
 
 @param path url地址
 @param params url参数 NSDictionary类型
 @param success 请求成功 返回NSDictionary或NSArray
 @param failure 请求失败 返回NSError
 */
- (void)postWithPath:(NSString *)path
              params:(NSDictionary *)params
             success:(HttpSuccessBlock)success
             failure:(HttpFailureBlock)failure;
@end

NS_ASSUME_NONNULL_END
