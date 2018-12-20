//
//  AppDelegate.m
//  YaZaiTechWifi
//
//  Created by cheng luo on 2018/12/4.
//  Copyright © 2018年 homeSalf. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()

@property (nonatomic,strong)AVAudioPlayer *player;

@property (nonatomic) dispatch_source_t badgeTimer;

@property (nonatomic,assign) UIBackgroundTaskIdentifier backgrounTask;

@property (nonatomic,strong)NSTimer *timer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //注册推送
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"request authorization succeeded!");
        }
    }];
//    [self player];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    //如果本身默认使用storyboard,就不需要window的初始化
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //试图数组
    NSArray *controllerArr = @[@"YZUrienViewController",@"YZSleepViewController",@"YZSetupViewController"];
    //标题数组
    NSArray *titleArr = @[NSLocalizedString(@"urine_moni", nil),NSLocalizedString(@"position_moni", nil),NSLocalizedString(@"setting", nil)];
    //图片数组
    NSArray *picArr = @[@"tab_btn_tem_default",@"tab_btn_sleep_default",@"tab_btn_setup_default"];
    
    //选中的图片数组
    NSArray *selectPicArr = @[@"tab_btn_tem_selected",@"tab_btn_sleep_selected",@"tab_btn_setup_selected"];
    
    NSMutableArray* array = [[NSMutableArray alloc]init];
    
    for(int i=0; i<picArr.count; i++)
    {
        Class cl=NSClassFromString(controllerArr[i]);
        
        UIViewController *controller = [[cl alloc]init];
        UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:controller];
        
        controller.title = titleArr[i];
        
        nv.tabBarItem.image = [[UIImage imageNamed:[NSString stringWithFormat:@"%@",picArr[i]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //设置选中时的图片
        nv.tabBarItem.selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@",selectPicArr[i]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //设置选中时字体的颜色(也可更改字体大小)
        [nv.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor yellowColor]} forState:UIControlStateSelected];
        
        [array addObject:nv];
        
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
        
    }
    UITabBarController *tabarControlloer = [[UITabBarController alloc]init];
    tabarControlloer.viewControllers = array;
    //143,39,171
//    [tabarControlloer.tabBar setBackgroundColor:[UIColor colorWithRed:140/255.0f green:0/255.0f blue:173/255.0f alpha:1.0f]];
    
    //设置tabbar的背景颜色;
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor colorWithRed:140/255.0f green:0/255.0f blue:173/255.0f alpha:1.0f];
    view.frame = tabarControlloer.tabBar.bounds;
    view.frame = CGRectMake(0, 0, tabarControlloer.tabBar.frame.size.width, tabarControlloer.tabBar.frame.size.height + 40);
    [[UITabBar appearance] insertSubview:view atIndex:0];
    
    [self.window setRootViewController:tabarControlloer];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)createTabBar
{
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /** 播放声音 */
//    [self.player play];
    
    [self stratBadgeNumberCount];
    [self backgroundMode];
    
    
}

- (AVAudioPlayer *)player{
    if (!_player){
        NSURL *url=[[NSBundle mainBundle]URLForResource:@"pomodoSound.mp3" withExtension:nil];
        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        [_player prepareToPlay];
        //一直循环播放
        _player.numberOfLoops = -1;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        [session setActive:YES error:nil];
    }
    return _player;
}

-(void)backgroundMode{
    //创建一个背景任务去和系统请求后台运行的时间
    self.backgrounTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgrounTask];
        self.backgrounTask = UIBackgroundTaskInvalid;
    }];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(applyToSystemForMoreTime) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)applyToSystemForMoreTime {
    NSLog(@"------applyToSystemForMoreTime:%.1lf",[UIApplication sharedApplication].backgroundTimeRemaining);
    if ([UIApplication sharedApplication].backgroundTimeRemaining < 30.0) {//如果剩余时间小于30秒
        [[UIApplication sharedApplication] endBackgroundTask:self.backgrounTask];
        NSLog(@"------剩余时间小于30秒");
        self.backgrounTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.backgrounTask];
            self.self.backgrounTask = UIBackgroundTaskInvalid;
        }];
    }
}

- (void)stratBadgeNumberCount{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    _badgeTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_badgeTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_badgeTimer, ^{
        
        [UIApplication sharedApplication].applicationIconBadgeNumber++;
    });
    dispatch_resume(_badgeTimer);
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    [self.player stop];
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
