//
//  MTNetworkManage.m
//  MTPostDemo
//
//  Created by cheng luo on 2018/12/12.
//  Copyright © 2018年 miotone. All rights reserved.
//

#import "YZNetworkManage.h"
#import "AFNetworking.h"

@interface YZNetworkManage()

@end

@implementation YZNetworkManage
{
    AFHTTPSessionManager *manager;
}

+ (YZNetworkManage *)sharedManage {
    static YZNetworkManage *singleton;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken,^{
        singleton = [[super alloc]initSingleton];
    });
    
    return singleton;
}

- (instancetype)initSingleton {
    if ([super init]) {
        //1.创建会话管理者
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        // 设置超时时间
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 3.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    }
    return self;
}

- (void)postWithPath:(NSString *)path params:(NSDictionary *)params success:(HttpSuccessBlock)success failure:(HttpFailureBlock)failure {
    
    NSString *urlStr = path;
    [manager POST:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        //获得的json先转换成字符串
        NSString *receiveStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:nil];
        
//        NSDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:responseObject
//                                                                     options:NSJSONReadingAllowFragments
//                                                                       error:nil];
//        NSLog(@"success--%@",dictFromData);
        success(dictFromData);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
//        NSLog(@"failure--%@",error);
        failure(error);
    }];
    
}

@end
