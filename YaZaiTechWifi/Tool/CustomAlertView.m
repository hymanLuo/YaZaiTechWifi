//
//  CustomAlertView.m
//  IOTCamViewer
//
//  Created by ossgo on 2015/1/9.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#import "CustomAlertView.h"


//黃色配色
//#define kAlertBackgroundColor   [UIColor colorWithRed:246/255.0 green:172/255.0 blue:39/255.0 alpha:1.0]
//#define kAlertBackgroundColor   [UIColor colorWithRed:108/255.0 green:120/255.0 blue:166/255.0 alpha:1.0]
//#define kAlertTextColor         [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]
#define kButtonTextColor_SVW        [UIColor colorWithRed:4.0/255.0 green:177.0/255.0 blue:235.0/255.0 alpha:1.0]
#define kAlertBackgroundColor   [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]
#define kAlertTextColor         [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]
#define kButtonTextColor        [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]
#define kButtonPressTextcolor   [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]
#define kButtonPressBGcolor     [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0]
#define kLineColor              [UIColor colorWithRed:126/255.0 green:138/255.0 blue:158/255.0 alpha:1.0]

#define kAlertSizeWidth 260

#define kContentTitleFontSize 16
#define kContentMsgFontSize 16
#define kButtonFontSize 16

@interface CustomAlertView()
{
    AlertTypes alertTypes;
}



typedef void (^OKBlock)(void);
typedef BOOL (^OKBlock2)(NSArray *textArr);
typedef void (^CancelBlock)(void);

@property (nonatomic, assign)id delegate;
@property (nonatomic, copy) OKBlock pressOKBlock;
@property (nonatomic, copy) OKBlock2 pressOKBlock2;
@property (nonatomic, copy) CancelBlock pressCancelBlock;
@property (nonatomic, assign) UIImageView *contentView;
@property (nonatomic, retain) UIView *blackView;
@property (nonatomic, retain) NSArray *buttonTitleArr;

//輸入帳號密碼Alert
@property (nonatomic, retain) NSArray *textFieldTitleArr;       //存放textFied的Title
@property (nonatomic, retain) NSArray *textFieldPlaceHolderArr; //存放textFied的PlaceHolder
@property (nonatomic, retain) NSMutableArray *textFieldArr;            //存放textFied

//之前的alertView
@property (nonatomic, retain) CustomAlertView *lastCustomAlertView;

@end

@implementation CustomAlertView

@synthesize pressOKBlock = _pressOKBlock;
@synthesize pressCancelBlock = _pressCancelBlock;
@synthesize contentView = _contentView;
@synthesize textFieldTitleArr = _textFieldTitleArr;
@synthesize textFieldPlaceHolderArr = _textFieldPlaceHolderArr;
@synthesize lastCustomAlertView = _lastCustomAlertView;


//正常alert
- (id)initWithAlertDelegate:(id)delegate
                      title:(NSString*)titleStr
                    message:(NSString*)msg
                buttonTitle:(NSArray*)buttonTitleArr
                    pressOK:(void(^)(void))pressOKBlock
                pressCancel:(void(^)(void))pressCancelBlock
{
    //先預設一個空間 後面調整大小
    self = [super initWithFrame:CGRectMake(0, 0, [self getScreenSize].width, [self getScreenSize].height)];
    if (self)
    {
        
//        NSAssert(msg!=nil, @"msg 不能為空");
        
        self.backgroundColor = [UIColor clearColor];
        
        alertTypes              = ALERTTYPE_DEFAULT;
        
        self.pressOKBlock       = pressOKBlock;
        self.pressCancelBlock   = pressCancelBlock;
        self.delegate           = delegate;
        self.title              = titleStr;
        self.msg                = msg;
        self.buttonTitleArr     = buttonTitleArr;
        
        
        //黑幕
        UIView *tempBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self getScreenSize].width, [self getScreenSize].height)];
        tempBlackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.48];
        self.blackView = tempBlackView;
        self.blackView.userInteractionEnabled = YES;
        [self addSubview:self.blackView];
        
        //背景
        UIImageView *tempContentView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kAlertSizeWidth, 100)]; //暫時100
        tempContentView.contentMode = UIViewContentModeScaleToFill;
        tempContentView.userInteractionEnabled = YES;
        
        self.contentView = tempContentView;
        [self addSubview:tempContentView];
        
        self.contentView.backgroundColor = kAlertBackgroundColor;
        self.contentView.layer.cornerRadius = 8;
        self.contentView.clipsToBounds = YES;
        
        //title
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, kAlertSizeWidth, 0)];
        //titleLab.backgroundColor = [UIColor redColor];
        if (titleStr!=nil)
        {
            titleLab.textAlignment = NSTextAlignmentCenter;
            titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
            titleLab.font = [UIFont boldSystemFontOfSize:kContentTitleFontSize];
            titleLab.textColor = kAlertTextColor;
            
            CGSize maxSize = CGSizeMake(MAXFLOAT, 40);
            
            CGRect labelRect = [self.title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titleLab.font} context:nil];
            titleLab.frame = CGRectMake(10, 10, kAlertSizeWidth-10*2, labelRect.size.height);
            
            titleLab.text = NSLocalizedString(self.title, 0);
            [self.contentView addSubview:titleLab];
            
        }
        
        
        //message
        UILabel *messageLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, kAlertSizeWidth, 20)];
        if (msg!=nil)
        {
            //messageLab.backgroundColor = [UIColor clearColor];
            messageLab.textAlignment = NSTextAlignmentCenter;
            messageLab.lineBreakMode = NSLineBreakByWordWrapping;
            messageLab.font = [UIFont systemFontOfSize:kContentMsgFontSize];
            messageLab.numberOfLines = 0;
            messageLab.textColor = kAlertTextColor;
            
            CGSize maxSize = CGSizeMake(kAlertSizeWidth-10*2, MAXFLOAT);
            
            CGRect labelRect = [self.msg boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:messageLab.font} context:nil];
            
            //如果沒有title
            if (titleLab.frame.size.height==0)
            {
                messageLab.frame = CGRectMake(10, CGRectGetMaxY(titleLab.frame)+10, kAlertSizeWidth-10*2, labelRect.size.height);
                
            }else{
                
                messageLab.frame = CGRectMake(10, CGRectGetMaxY(titleLab.frame)+10, kAlertSizeWidth-10*2, labelRect.size.height);
                
            }
            
            messageLab.text = NSLocalizedString(self.msg, 0);
            [self.contentView addSubview:messageLab];
            
        }
        
        
        //調整messageLab高度,太少字且沒有title時就置中
        if (titleStr==nil && messageLab.frame.size.height<50)
        {
            messageLab.frame = CGRectMake(messageLab.frame.origin.x, messageLab.frame.origin.y, messageLab.frame.size.width, 50);
        }
        
        self.contentView.frame = CGRectMake(0, 0, kAlertSizeWidth, CGRectGetMaxY(messageLab.frame)+10);
        
        
        //判斷幾個按鈕
        NSAssert([self.buttonTitleArr count]>0 , @"按鈕至少要給一個名稱");
        int btnWidth = kAlertSizeWidth/[self.buttonTitleArr count];
        int bntHeight = 44;
        
        for (int i=0; i<[self.buttonTitleArr count]; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor =[UIColor redColor];
            btn.frame = CGRectMake(i*btnWidth,CGRectGetMaxY(self.contentView.frame)+10, btnWidth, bntHeight);
            btn.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
            [btn setTitle:NSLocalizedString(self.buttonTitleArr[i], @"")  forState:UIControlStateNormal];
#if SVW
            [btn setTitleColor:kButtonTextColor_SVW forState:UIControlStateNormal];
#else
            [btn setTitleColor:kButtonTextColor forState:UIControlStateNormal];
#endif


            [btn setTitleColor:kButtonPressTextcolor forState:UIControlStateHighlighted];
            
            [btn setBackgroundImage:[self imageWithColor:kAlertBackgroundColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[self imageWithColor:kButtonPressBGcolor] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
            
            btn.tag = i;
            [self.contentView addSubview:btn];
        }
        
        //畫線
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.contentView.frame)+10, kAlertSizeWidth, 1)];
        line1.backgroundColor = kLineColor;
        [self.contentView addSubview:line1];
        
        //直線
        if ([self.buttonTitleArr count]>1)
        {
            for (int i=1; i<[self.buttonTitleArr count]; i++)
            {
                UIView *line = [[UIView alloc]initWithFrame:CGRectMake(i*btnWidth,CGRectGetMaxY(self.contentView.frame)+10, 1, bntHeight)];
                line.backgroundColor = kLineColor;
                [self.contentView addSubview:line];
            }
        }
        
        self.contentView.frame = CGRectMake(0, 0, kAlertSizeWidth, CGRectGetMaxY(self.contentView.frame)+bntHeight+10);
        self.contentView.center = CGPointMake([self getScreenSize].width/2, [self getScreenSize].height/2-10);
        
        //先縮小
        self.contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self.contentView.alpha = 0.0;
        self.blackView.alpha = 0.0;
    }
    
    return self;
}

//按钮横屏弹框
- (id)initWithAlertDelegate2:(id)delegate
                      title:(NSString*)titleStr
                    message:(NSString*)msg
                buttonTitle:(NSArray*)buttonTitleArr
                    pressOK:(void(^)(void))pressOKBlock
                pressCancel:(void(^)(void))pressCancelBlock
{
    //先預設一個空間 後面調整大小
    self = [super initWithFrame:CGRectMake(0, 0, [self getScreenSize].height, [self getScreenSize].width)];
    if (self)
    {
        
        //        NSAssert(msg!=nil, @"msg 不能為空");
        
        self.backgroundColor = [UIColor clearColor];
        
        alertTypes              = ALERTTYPE_DEFAULT;
        
        self.pressOKBlock       = pressOKBlock;
        self.pressCancelBlock   = pressCancelBlock;
        self.delegate           = delegate;
        self.title              = titleStr;
        self.msg                = msg;
        self.buttonTitleArr     = buttonTitleArr;
        
        
        //黑幕
        UIView *tempBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self getScreenSize].height, [self getScreenSize].width)];
        tempBlackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.48];
        self.blackView = tempBlackView;
        self.blackView.userInteractionEnabled = YES;
        [self addSubview:self.blackView];
        
        //背景
        UIImageView *tempContentView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kAlertSizeWidth, 100)]; //暫時100
        tempContentView.contentMode = UIViewContentModeScaleToFill;
        tempContentView.userInteractionEnabled = YES;
        
        self.contentView = tempContentView;
        [self addSubview:tempContentView];
        
        self.contentView.backgroundColor = kAlertBackgroundColor;
        self.contentView.layer.cornerRadius = 8;
        self.contentView.clipsToBounds = YES;
        
        //title
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, kAlertSizeWidth, 0)];
        //titleLab.backgroundColor = [UIColor redColor];
        if (titleStr!=nil)
        {
            titleLab.textAlignment = NSTextAlignmentCenter;
            titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
            titleLab.font = [UIFont boldSystemFontOfSize:kContentTitleFontSize];
            titleLab.textColor = kAlertTextColor;
            
            CGSize maxSize = CGSizeMake(MAXFLOAT, 40);
            
            CGRect labelRect = [self.title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titleLab.font} context:nil];
            titleLab.frame = CGRectMake(10, 10, kAlertSizeWidth-10*2, labelRect.size.height);
            
            titleLab.text = NSLocalizedString(self.title, 0);
            [self.contentView addSubview:titleLab];
            
        }
        
        
        //message
        UILabel *messageLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, kAlertSizeWidth, 20)];
        if (msg!=nil)
        {
            //messageLab.backgroundColor = [UIColor clearColor];
            messageLab.textAlignment = NSTextAlignmentCenter;
            messageLab.lineBreakMode = NSLineBreakByWordWrapping;
            messageLab.font = [UIFont systemFontOfSize:kContentMsgFontSize];
            messageLab.numberOfLines = 0;
            messageLab.textColor = kAlertTextColor;
            
            CGSize maxSize = CGSizeMake(kAlertSizeWidth-10*2, MAXFLOAT);
            
            CGRect labelRect = [self.msg boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:messageLab.font} context:nil];
            
            //如果沒有title
            if (titleLab.frame.size.height==0)
            {
                messageLab.frame = CGRectMake(10, CGRectGetMaxY(titleLab.frame)+10, kAlertSizeWidth-10*2, labelRect.size.height);
                
            }else{
                
                messageLab.frame = CGRectMake(10, CGRectGetMaxY(titleLab.frame)+10, kAlertSizeWidth-10*2, labelRect.size.height);
                
            }
            
            messageLab.text = NSLocalizedString(self.msg, 0);
            [self.contentView addSubview:messageLab];
            
        }
        
        
        //調整messageLab高度,太少字且沒有title時就置中
        if (titleStr==nil && messageLab.frame.size.height<50)
        {
            messageLab.frame = CGRectMake(messageLab.frame.origin.x, messageLab.frame.origin.y, messageLab.frame.size.width, 50);
        }
        
        self.contentView.frame = CGRectMake(0, 0, kAlertSizeWidth, CGRectGetMaxY(messageLab.frame)+10);
        
        
        //判斷幾個按鈕
        NSAssert([self.buttonTitleArr count]>0 , @"按鈕至少要給一個名稱");
        int btnWidth = kAlertSizeWidth/[self.buttonTitleArr count];
        int bntHeight = 44;
        
        for (int i=0; i<[self.buttonTitleArr count]; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor =[UIColor redColor];
            btn.frame = CGRectMake(i*btnWidth,CGRectGetMaxY(self.contentView.frame)+10, btnWidth, bntHeight);
            btn.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
            [btn setTitle:NSLocalizedString(self.buttonTitleArr[i], @"")  forState:UIControlStateNormal];
#if SVW
            [btn setTitleColor:kButtonTextColor_SVW forState:UIControlStateNormal];
#else
            [btn setTitleColor:kButtonTextColor forState:UIControlStateNormal];
#endif
            
            
            [btn setTitleColor:kButtonPressTextcolor forState:UIControlStateHighlighted];
            
            [btn setBackgroundImage:[self imageWithColor:kAlertBackgroundColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[self imageWithColor:kButtonPressBGcolor] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
            
            btn.tag = i;
            [self.contentView addSubview:btn];
        }
        
        //畫線
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.contentView.frame)+10, kAlertSizeWidth, 1)];
        line1.backgroundColor = kLineColor;
        [self.contentView addSubview:line1];
        
        //直線
        if ([self.buttonTitleArr count]>1)
        {
            for (int i=1; i<[self.buttonTitleArr count]; i++)
            {
                UIView *line = [[UIView alloc]initWithFrame:CGRectMake(i*btnWidth,CGRectGetMaxY(self.contentView.frame)+10, 1, bntHeight)];
                line.backgroundColor = kLineColor;
                [self.contentView addSubview:line];
            }
        }
        
        self.contentView.frame = CGRectMake(0, 0, kAlertSizeWidth, CGRectGetMaxY(self.contentView.frame)+bntHeight+10);
        self.contentView.center = CGPointMake([self getScreenSize].height/2, [self getScreenSize].width/2-10);
        
        //先縮小
        self.contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self.contentView.alpha = 0.0;
        self.blackView.alpha = 0.0;
    }
    
    return self;
}

- (id)initWithAlertDelegate:(id)delegate
                      title:(NSString*)titleStr
                buttonTitle:(NSArray*)buttonTitleArr
         textFieldTitleText:(NSArray*)textFieldTitleArr
       textFieldPlaceHolder:(NSArray*)textFieldPlaceHolderArr
                    pressOK:(BOOL(^)(NSArray *textArr))pressOKBlock
                pressCancel:(void(^)(void))pressCancelBlock
{
    //先預設一個空間 後面調整大小
    self = [super initWithFrame:CGRectMake(0, 0, [self getScreenSize].width, [self getScreenSize].height)];
    if (self)
    {
        
        self.backgroundColor = [UIColor clearColor];
        
        alertTypes              = ALERTTYPE_TEXTINPUT;
        
        self.pressOKBlock2      = pressOKBlock;
        self.pressCancelBlock   = pressCancelBlock;
        self.delegate           = delegate;
        self.title              = titleStr;
        self.buttonTitleArr     = buttonTitleArr;
        self.textFieldTitleArr  = textFieldTitleArr;
        self.textFieldPlaceHolderArr  = textFieldPlaceHolderArr;
        

        
        //黑幕
        UIView *tempBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self getScreenSize].width, [self getScreenSize].height)];
        tempBlackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.48];
        self.blackView = tempBlackView;
        self.blackView.userInteractionEnabled = YES;
        [self addSubview:self.blackView];
        
        //背景
        UIImageView *tempContentView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kAlertSizeWidth, 100)]; //暫時100
        tempContentView.contentMode = UIViewContentModeScaleToFill;
        tempContentView.userInteractionEnabled = YES;
        
        self.contentView = tempContentView;
        [self addSubview:tempContentView];
        
        self.contentView.backgroundColor = kAlertBackgroundColor;
        self.contentView.layer.cornerRadius = 8;
        self.contentView.clipsToBounds = YES;
        
        //title
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, kAlertSizeWidth, 0)];

        if (titleStr!=nil)
        {
            titleLab.textAlignment = NSTextAlignmentCenter;
            titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
            titleLab.font = [UIFont boldSystemFontOfSize:kContentTitleFontSize];
            
            CGSize maxSize = CGSizeMake(MAXFLOAT, 40);
            
            CGRect labelRect = [self.title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titleLab.font} context:nil];
            titleLab.frame = CGRectMake(10, 10, kAlertSizeWidth-10*2, labelRect.size.height);
            
            titleLab.text = NSLocalizedString(self.title, 0);
            [self.contentView addSubview:titleLab];
            
        }
        
        int rowHeight = 36;
        
        //一個大框框
        UIView *boxView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLab.frame)+10, kAlertSizeWidth-10*2, [self.textFieldTitleArr count]*rowHeight)];
        boxView.backgroundColor = [UIColor whiteColor];
        boxView.layer.cornerRadius = 8;
        boxView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
        boxView.layer.borderWidth = 1;
        [self.contentView addSubview:boxView];
        
        
        //畫線,label
        for (int i=1; i<[self.textFieldTitleArr count]; i++)
        {
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, i*rowHeight, boxView.frame.size.width, 1)];
            lineView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
            [boxView addSubview:lineView];
        }
        
        //title & textField
        NSMutableArray *aMutableArr = [[NSMutableArray alloc]init];
        self.textFieldArr = aMutableArr;
        
        for (int i=0; i<[self.textFieldTitleArr count]; i++)
        {
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, i*rowHeight+2, 80, rowHeight-2*2)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont systemFontOfSize:kContentTitleFontSize];
            titleLabel.text = NSLocalizedString(self.textFieldTitleArr[i], 0);
            titleLabel.textColor = [UIColor grayColor];
            [boxView addSubview:titleLabel];
            
            UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+5, titleLabel.frame.origin.y, 135, titleLabel.frame.size.height)];
            tf.backgroundColor = [UIColor clearColor];
            tf.font = [UIFont systemFontOfSize:kContentMsgFontSize];
            tf.placeholder = self.textFieldPlaceHolderArr[i];
            tf.tag = i;
            [boxView addSubview:tf];
            
            [self.textFieldArr addObject:tf];
        }
        
        
        self.contentView.frame = CGRectMake(0, 0, kAlertSizeWidth, CGRectGetMaxY(boxView.frame));
        
        //判斷幾個按鈕
        NSAssert([self.buttonTitleArr count]>0 , @"按鈕至少要給一個名稱");
        int btnWidth = kAlertSizeWidth/[self.buttonTitleArr count];
        int bntHeight = 44;
        
        for (int i=0; i<[self.buttonTitleArr count]; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor =[UIColor redColor];
            btn.frame = CGRectMake(i*btnWidth,CGRectGetMaxY(self.contentView.frame)+10, btnWidth, bntHeight);
            [btn setTitle:NSLocalizedString(self.buttonTitleArr[i], @"") forState:UIControlStateNormal];
#if SVW
            [btn setTitleColor:kButtonTextColor_SVW forState:UIControlStateNormal];
#else
            [btn setTitleColor:kButtonTextColor forState:UIControlStateNormal];
#endif

            [btn setBackgroundImage:[self imageWithColor:kAlertBackgroundColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[self imageWithColor:kButtonPressBGcolor] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
            btn.tag = i;
            [self.contentView addSubview:btn];
        }
        
        //畫線
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.contentView.frame)+10, kAlertSizeWidth, 1)];
        line1.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
        [self.contentView addSubview:line1];
        
        //直線
        if ([self.buttonTitleArr count]>1)
        {
            for (int i=1; i<[self.buttonTitleArr count]; i++)
            {
                UIView *line = [[UIView alloc]initWithFrame:CGRectMake(i*btnWidth,CGRectGetMaxY(self.contentView.frame)+10, 1, bntHeight)];
                line.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
                [self.contentView addSubview:line];
            }
        }
        
        self.contentView.frame = CGRectMake(0, 0, kAlertSizeWidth, CGRectGetMaxY(self.contentView.frame)+bntHeight+10);
        self.contentView.center = CGPointMake([self getScreenSize].width/2, [self getScreenSize].height/2-10);
        
    }
    
    return self;
}

- (id)initWithAlertDelegate:(id)delegate
                      title:(NSString*)titleStr
                       view:(UIView*)view
                buttonTitle:(NSArray*)buttonTitleArr
                    pressOK:(void(^)(void))pressOKBlock
                pressCancel:(void(^)(void))pressCancelBlock
{
    //先預設一個空間 後面調整大小
    self = [super initWithFrame:CGRectMake(0, 0, [self getScreenSize].width, [self getScreenSize].height)];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        alertTypes              = ALERTTYPE_DEFAULT;
        
        self.pressOKBlock       = pressOKBlock;
        self.pressCancelBlock   = pressCancelBlock;
        self.delegate           = delegate;
        self.title              = titleStr;
        self.view                = view;
        self.buttonTitleArr     = buttonTitleArr;
        
        
        //黑幕
        UIView *tempBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self getScreenSize].width, [self getScreenSize].height)];
        tempBlackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.48];
        self.blackView = tempBlackView;
        self.blackView.userInteractionEnabled = YES;
        [self addSubview:self.blackView];
        
        //背景
        UIImageView *tempContentView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kAlertSizeWidth, 100)]; //暫時100
        tempContentView.contentMode = UIViewContentModeScaleToFill;
        tempContentView.userInteractionEnabled = YES;
        
        self.contentView = tempContentView;
        [self addSubview:tempContentView];
        
        self.contentView.backgroundColor = kAlertBackgroundColor;
        self.contentView.layer.cornerRadius = 8;
        self.contentView.clipsToBounds = YES;
        
        //title
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, kAlertSizeWidth, 0)];
        //titleLab.backgroundColor = [UIColor redColor];
        if (titleStr!=nil)
        {
            titleLab.textAlignment = NSTextAlignmentCenter;
            titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
            titleLab.font = [UIFont boldSystemFontOfSize:kContentTitleFontSize];
            titleLab.textColor = kAlertTextColor;
            
            CGSize maxSize = CGSizeMake(MAXFLOAT, 40);
            
            CGRect labelRect = [self.title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titleLab.font} context:nil];
            titleLab.frame = CGRectMake(10, 10, kAlertSizeWidth-10*2, labelRect.size.height);
            
            titleLab.text = NSLocalizedString(self.title, 0);
            [self.contentView addSubview:titleLab];
            
        }
        
        
        //message
        UIView  *customView = [[UIView alloc] init];
        
        if (view!=nil)
        {
            //messageLab.backgroundColor = [UIColor clearColor];
            customView = view;
            customView.backgroundColor = kAlertBackgroundColor;
            
//            //如果沒有title
//            if (titleLab.frame.size.height==0)
//            {
//                messageLab.frame = CGRectMake(10, CGRectGetMaxY(titleLab.frame)+10, kAlertSizeWidth-10*2, labelRect.size.height);
//                
//            }else{
//                
//                messageLab.frame = CGRectMake(10, CGRectGetMaxY(titleLab.frame)+10, kAlertSizeWidth-10*2, labelRect.size.height);
//                
//            }
            
//            messageLab.text = NSLocalizedString(self.msg, 0);
            [self.contentView addSubview:customView];
            
        }
        
        
        //調整messageLab高度,太少字且沒有title時就置中
        if (titleStr==nil && customView.frame.size.height<50)
        {
            customView.frame = CGRectMake(customView.frame.origin.x, customView.frame.origin.y, customView.frame.size.width, 50);
        }
        
        self.contentView.frame = CGRectMake(0, 0, kAlertSizeWidth, CGRectGetMaxY(customView.frame)+10);
        
        
        //判斷幾個按鈕
//        NSAssert([self.buttonTitleArr count]>0 , @"按鈕至少要給一個名稱");
        int btnWidth  = 0;
        int bntHeight = 0;
        if (self.buttonTitleArr.count > 0) {
             btnWidth = kAlertSizeWidth/[self.buttonTitleArr count];
            bntHeight = 44;

        }
        
        for (int i=0; i<[self.buttonTitleArr count]; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor =[UIColor redColor];
            btn.frame = CGRectMake(i*btnWidth,CGRectGetMaxY(self.contentView.frame)+10, btnWidth, bntHeight);
            btn.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
            [btn setTitle:NSLocalizedString(self.buttonTitleArr[i], @"")  forState:UIControlStateNormal];
            
            [btn setTitleColor:kButtonTextColor forState:UIControlStateNormal];
            [btn setTitleColor:kButtonPressTextcolor forState:UIControlStateHighlighted];
            
            [btn setBackgroundImage:[self imageWithColor:kAlertBackgroundColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[self imageWithColor:kButtonPressBGcolor] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
            
            btn.tag = i;
            [self.contentView addSubview:btn];
        }
        
        //畫線
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.contentView.frame)+10, kAlertSizeWidth, 1)];
        line1.backgroundColor = kLineColor;
        [self.contentView addSubview:line1];
        
        //直線
        if ([self.buttonTitleArr count]>1)
        {
            for (int i=1; i<[self.buttonTitleArr count]; i++)
            {
                UIView *line = [[UIView alloc]initWithFrame:CGRectMake(i*btnWidth,CGRectGetMaxY(self.contentView.frame)+10, 1, bntHeight)];
                line.backgroundColor = kLineColor;
                [self.contentView addSubview:line];
            }
        }
        
        self.contentView.frame = CGRectMake(0, 0, kAlertSizeWidth, CGRectGetMaxY(self.contentView.frame)+bntHeight+10);
        self.contentView.center = CGPointMake([self getScreenSize].width/2, [self getScreenSize].height/2-10);
        
        //先縮小
        self.contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self.contentView.alpha = 0.0;
        self.blackView.alpha = 0.0;
    }
    
    return self;
    
}


- (void)show
{
    //判斷先前有沒有Alert
    if ([self isShowCustomAlertView])
    {
        return;
        CustomAlertView *currentAlertView = [self getCurrentCustomAlertView];
        
        if (currentAlertView && !currentAlertView.isDismiss)
        {
            self.lastCustomAlertView = currentAlertView;
            [self.lastCustomAlertView removeFromSuperview];
        }
     
    }
    
    UIViewController *topVC = [self appRootViewController];
    [topVC.view addSubview:self];
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [UIView animateWithDuration:0.15 animations:^(void)
    {
        self.contentView.alpha = 1.0;
        self.contentView.transform = CGAffineTransformMakeScale(1.05, 1.05);
        self.blackView.alpha = 1.0;
        
    } completion:^(BOOL finished)
    {
        [UIView animateWithDuration:0.04 animations:^(void)
        {
            self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWillShow:)
                                                         name:UIKeyboardWillShowNotification
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWillHiden:)
                                                         name:UIKeyboardWillHideNotification
                                                       object:nil];
            
//            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                     selector:@selector(deviceDidRotate:)
//                                                         name:UIApplicationDidChangeStatusBarOrientationNotification
//                                                       object:nil];
            
            UITextField *tf = (UITextField*)self.textFieldArr[0];
            [tf becomeFirstResponder];
        }];
        
    }];
}


- (void)dismiss
{
    self.isDismiss = YES;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    if (alertTypes == ALERTTYPE_TEXTINPUT)
    {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
    
    if (self.lastCustomAlertView)
    {
        self.lastCustomAlertView.alpha = 0.0;
        [self.lastCustomAlertView recoveryDisplay];
    }
    
    [UIView animateWithDuration:0.14 animations:^(void)
    {
        self.contentView.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        self.blackView.alpha = 0.0;
        
        if (self.lastCustomAlertView) self.lastCustomAlertView.alpha = 1.0;
    } completion:^(BOOL finished)
    {
        [self removeFromSuperview];
    }];
}



- (void)recoveryDisplay
{
    NSLog(@"recoveryDisplay");
    UIViewController *topVC = [self appRootViewController];
    [topVC.view addSubview:self];
}



#pragma mark - UIButton
- (void)btnPress:(UIButton*)btn
{
    if ([self.buttonTitleArr count]==1) //只有確認鈕
    {
        switch (alertTypes)
        {
            case ALERTTYPE_DEFAULT:
            {
                if (self.pressOKBlock)
                {
                    self.pressOKBlock();
                }
                
                [self dismiss];
                
                break;
            }
                
            case ALERTTYPE_TEXTINPUT:
            {
                if (self.pressOKBlock2)
                {
                    
                    NSArray *tfTextArr = [self.textFieldArr valueForKeyPath:@"text"];
                    
                    if (self.pressOKBlock2(tfTextArr))
                    {
                        [self dismiss];
                    }
                    //TODO: 這邊還不會遇到
                }
                
                break;
            }
                
                
            default:
                break;
        }
        
        
    }else if ([self.buttonTitleArr count]==2)
    { //兩顆鈕
        switch (btn.tag)
        {
            case 0:
            {
                if (self.pressCancelBlock!=nil)
                {
                    self.pressCancelBlock();
                }
                
                [self dismiss];
                
                break;
            }
                
            case 1:
            {
                
                switch (alertTypes)
                {
                    case ALERTTYPE_DEFAULT:
                    {
                        if (self.pressOKBlock)
                        {
                            self.pressOKBlock();
                        }
                        
                        [self dismiss];
                        
                        break;
                    }
                        
                    case ALERTTYPE_TEXTINPUT:
                    {
                        if (self.pressOKBlock2)
                        {
                            
                            NSArray *tfTextArr = [self.textFieldArr valueForKeyPath:@"text"];
                     
                            if (self.pressOKBlock2(tfTextArr))
                            {
                                [self dismiss];
                            }
                            
                        }
                        
                        break;
                    }
                        
                        
                    default:
                        break;
                }
                
                break;
            }
                
            default:
                break;
        }
    }
    
    
}


#pragma mark - NSNotification
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.1 animations:^
    {
        if ([self getScreenSize].height-keyboardSize.height<CGRectGetMaxY(self.contentView.frame))
        {
            CGRect contextViewRect = self.contentView.frame;
            contextViewRect.origin.y = [self getScreenSize].height-keyboardSize.height-self.contentView.frame.size.height-10;
            self.contentView.frame = contextViewRect;
        }
    } completion:^(BOOL finished)
    {
        
    }];
    
    
}


- (void)keyboardWillHiden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.1 animations:^
    {
        self.contentView.center = CGPointMake([self getScreenSize].width/2, [self getScreenSize].height/2-10);
    } completion:^(BOOL finished)
    {
        
    }];
}

- (void)deviceDidRotate:(NSNotification *)notification
{
    CGSize keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.1 animations:^{
        
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        {
            self.contentView.center = CGPointMake([self getScreenSize].width/2, [self getScreenSize].height/2-10);
        }else{
            
            if (keyboardSize.width==0 && keyboardSize.height==0)
            {
                self.contentView.center = CGPointMake([self getScreenSize].width/2, [self getScreenSize].height/2-10);
            }else{
                if ([self getScreenSize].height-keyboardSize.height<CGRectGetMaxY(self.contentView.frame))
                {
                    CGRect contextViewRect = self.contentView.frame;
                    contextViewRect.origin.y = [self getScreenSize].height-keyboardSize.height-self.contentView.frame.size.height-10;
                    self.contentView.frame = contextViewRect;
                }
            }
        }
    
        //blackView的Frame
        self.blackView.frame = CGRectMake(0, 0, [self getScreenSize].width, [self getScreenSize].height);
        
        
    } completion:^(BOOL finished) {
        
    }];
    
}



#pragma mark - Other
//最上層的VC是否有CustomAlertView
- (BOOL)isShowCustomAlertView
{
    // CustomAlertView 已經出現過了,不再出現
    for (id view in [[self appRootViewController].view subviews])
    {
        if ([view isKindOfClass:[CustomAlertView class]])
        {
            NSLog(@"發現最上層有 CustomAlertView");
            return YES;
        }
    }
    
    return NO;
}


//取得當前的CustomAlertView,若沒有回nil
- (CustomAlertView*)getCurrentCustomAlertView
{
    // CustomAlertView 已經出現過了,不再出現
    for (id view in [[self appRootViewController].view subviews])
    {
        if ([view isKindOfClass:[CustomAlertView class]])
        {
            return (CustomAlertView*)view;
        }
    }
    return nil;
}


- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController)
    {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}


//取得目前螢幕高度（已根據ios8的調整）
- (CGSize)getScreenSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    return screenSize;
}


- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



@end
