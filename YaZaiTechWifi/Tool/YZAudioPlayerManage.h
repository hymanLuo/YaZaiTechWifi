//
//  YZAudioPlayManage.h
//  YaZaiTechWifi
//
//  Created by cheng luo on 2018/12/8.
//  Copyright © 2018年 homeSalf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZAudioPlayerManage : NSObject

+ (YZAudioPlayerManage *)shareInstance;

- (void)play;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
