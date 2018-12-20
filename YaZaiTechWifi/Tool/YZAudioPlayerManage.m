//
//  YZAudioPlayManage.m
//  YaZaiTechWifi
//
//  Created by cheng luo on 2018/12/8.
//  Copyright © 2018年 homeSalf. All rights reserved.
//

#import "YZAudioPlayerManage.h"
#import <AVFoundation/AVFoundation.h>

@interface YZAudioPlayerManage()

@property (nonatomic,strong)AVAudioPlayer *audioPlayer;//音频播放器;
@property (nonatomic,assign) BOOL *isPlay;//是否在播放;
@end

@implementation YZAudioPlayerManage



static YZAudioPlayerManage *manage = nil;

+(YZAudioPlayerManage *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        manage = [[super alloc]init];
        manage = [[super allocWithZone:NULL]init];
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"song" ofType:@"mp3"];
        manage.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
        manage.audioPlayer.volume = 1.0;
        manage.audioPlayer.numberOfLoops = 0;
        [manage.audioPlayer prepareToPlay];

    });
    return manage;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    return manage;
}

-(id) copyWithZone:(NSZone *)zone
{
    return [YZAudioPlayerManage shareInstance] ;//return _instance;
}

- (id) mutableCopyWithZone {
    return [YZAudioPlayerManage shareInstance];
}

- (void)play {
    [manage.audioPlayer play];
}

- (void)stop {
    [manage.audioPlayer stop];
}

@end
