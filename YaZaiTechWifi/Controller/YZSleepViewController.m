//
//  YZSleepViewController.m
//  YaZaiTechWifi
//
//  Created by cheng luo on 2018/12/4.
//  Copyright © 2018年 homeSalf. All rights reserved.
//

#import "YZSleepViewController.h"
#import "YZTool.h"
#import "SleepData.h"
#import "UIView+Frame.h"
#import "Globaldata.h"

@interface YZSleepViewController ()
@property (nonatomic,strong)NSArray *sleepPositionArray;//宝宝总共的睡姿
@property (nonatomic,strong) SleepData *selectdata; //宝宝当前姿势

@property (nonatomic,strong)UIImageView *babyStateImageView;//
@property (nonatomic,strong)UIImageView *babyStateBgImageView;

@property (nonatomic,strong)UILabel *babyStateLabel;//

@end

@implementation YZSleepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -1, YZSCREEN_WIDTH, YZSCREEN_HEIGHT+2)];
    imageView.image = [UIImage imageNamed:@"YZBlueScan_selected"];
    [self.view addSubview:imageView];
    
    [YZTool setTransparencyHidden:YES with:self];
    
    //获取到服务器数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globaldatachange:) name:YaZaiGetServerDataSuccess object:nil];
    
    _babyStateBgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 200, YZSCREEN_WIDTH - 40, YZSCREEN_WIDTH - 40)];
    _babyStateBgImageView.center = CGPointMake(YZSCREEN_WIDTH * 0.5, YZSCREEN_HEIGHT * 0.4);
    [self.view addSubview:_babyStateBgImageView];
    _babyStateBgImageView.image = [UIImage imageNamed:@"shezhi_biaome_img_s"];
    //宝宝状态的背景图
    CGSize babyStateBgImageSize = [UIImage imageNamed:@"shezhi_biaome_img_s"].size;
    CGSize babyStateImageSize = [UIImage imageNamed:@"img_message_1"].size;
    CGFloat bgAndStateRate = babyStateBgImageSize.width/babyStateImageSize.width;
    CGFloat babyStateImageWidth = _babyStateBgImageView.frame.size.width / bgAndStateRate;
    //宝宝的状态图
    _babyStateImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, babyStateImageWidth, babyStateImageWidth)];
    _babyStateImageView.center = _babyStateBgImageView.center;
    _babyStateImageView.image = [UIImage imageNamed:@"img_message_1"];
    [self.view addSubview:_babyStateImageView];

    //宝宝状态的UILabel
    _babyStateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_babyStateBgImageView.frame), 200, 20)];
    _babyStateLabel.center = CGPointMake(YZSCREEN_WIDTH*0.5, _babyStateLabel.center.y);
    _babyStateLabel.text = NSLocalizedString(@"up_sleep", nil);
    _babyStateLabel.textAlignment = NSTextAlignmentCenter;
    _babyStateLabel.textColor = [UIColor yellowColor];
    [self.view addSubview:_babyStateLabel];
    
    [self loadData];
}

//初始化页面所需数据
-(void)loadData{
    SleepData *data2 = [SleepData initWithtitle:NSLocalizedString(@"up_sleep", nil) image:@"img_message_1" bigimage:@"img_message_1 copy"];
    SleepData *data3 = [SleepData initWithtitle:NSLocalizedString(@"left_sleep", nil) image:@"img_message_2" bigimage:@"img_message_2 copy"];
    SleepData *data1 = [SleepData initWithtitle:NSLocalizedString(@"right_sleep", nil) image:@"img_message_3" bigimage:@"img_message_3 copy"];
    SleepData *data0 = [SleepData initWithtitle:NSLocalizedString(@"down_sleep", nil) image:@"img_message_4" bigimage:@"img_message_4 copy"];
    SleepData *data4 = [SleepData initWithtitle:NSLocalizedString(@"sit_up", nil) image:@"img_message_5" bigimage:@"img_message_5 copy"];
    self.sleepPositionArray = [NSArray arrayWithObjects:data0,data1,data2,data3,data4, nil];
    
    Globaldata *data = [Globaldata shareInstance];
    self.selectdata = _sleepPositionArray[data.position];
    //当前睡姿图片
    _babyStateImageView.image = [UIImage imageNamed:self.selectdata.image];
    _babyStateLabel.text = self.selectdata.title;
    
    //其它四种睡姿图片
    CGFloat viewWidth = YZSCREEN_WIDTH/4;
    float viewY = CGRectGetMaxY(_babyStateLabel.frame)+21;
    NSMutableArray *otherSleepPositionMuArr = [[NSMutableArray alloc]initWithArray:_sleepPositionArray];
    [otherSleepPositionMuArr removeObject:self.selectdata];
    for (NSInteger i=0; i<4; i++) {
        UGDesView *temview = [[UGDesView alloc]initWithFrame:CGRectMake(viewWidth*i, viewY, viewWidth, viewWidth+16)];
        temview.tag = 1000+i;
        SleepData *temdata = [otherSleepPositionMuArr objectAtIndex:i];
        [temview.imageView setImage:[UIImage imageNamed:temdata.image]];
        [temview.imageView setSize:CGSizeMake(viewWidth, viewWidth)];
        [temview.titleLab setFrame:CGRectMake(0, viewWidth, viewWidth, 16)];
        temview.titleLab.font = [UIFont systemFontOfSize:12];
        temview.titleLab.textColor = [UIColor whiteColor];
        temview.titleLab.textAlignment = NSTextAlignmentCenter;
        temview.titleLab.text = temdata.title;
        [self.view addSubview:temview];
    }
}

////设置当前选中的睡觉姿势
//-(void)setSelectdata:(SleepData *)selectdata{
//    if (_selectdata == selectdata) {
//        return;
//    }
//    NSInteger temindex = [_sleepPositionArray indexOfObject:selectdata];
//    UGDesView *temview = [self.view viewWithTag:1000+temindex];
//    [temview.imageView setImage:[UIImage imageNamed:selectdata.image]];
//    temview.titleLab.text = selectdata.title;
//    _selectdata = selectdata;
//    [_babyStateImageView setImage:[UIImage imageNamed:selectdata.image]];
//    _babyStateLabel.text = selectdata.title;
//}

- (void)updateSleepPosition {
    
}

#pragma GLOBALDATACHANGE 通知调用
-(void)globaldatachange:(id)sender{
    
    Globaldata *data = [Globaldata shareInstance];
//    data.position = 4;
    
    switch (data.position) {
        case sleepPosition_down:
            _selectdata = _sleepPositionArray[0];
            break;
        case sleepPosition_right:
            _selectdata = _sleepPositionArray[1];
            break;
        case sleepPosition_up:
            _selectdata = _sleepPositionArray[2];
            break;
        case sleepPosition_letf:
            _selectdata = _sleepPositionArray[3];
            break;
        case sleepPosition_sit:
            _selectdata = _sleepPositionArray[4];
            break;
            
        default:
            break;
    }
    _babyStateImageView.image = [UIImage imageNamed:self.selectdata.image];
    _babyStateLabel.text = self.selectdata.title;
    
    NSMutableArray *otherSleepPositionMuArr = [[NSMutableArray alloc]initWithArray:_sleepPositionArray];
    [otherSleepPositionMuArr removeObject:self.selectdata];
    for (int i = 0; i < 4; i ++) {
        UGDesView *temview =(UGDesView*)[self.view viewWithTag:(1000+i)];
        SleepData *temdata = [otherSleepPositionMuArr objectAtIndex:i];
        [temview.imageView setImage:[UIImage imageNamed:temdata.image]];
        temview.titleLab.text = temdata.title;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
