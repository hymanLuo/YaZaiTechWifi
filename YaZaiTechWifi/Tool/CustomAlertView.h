//
//  CustomAlertView.h
//  IOTCamViewer
//
//  Created by ossgo on 2015/1/9.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum alertTypes
{
    ALERTTYPE_DEFAULT,
    ALERTTYPE_TEXTINPUT
    
} AlertTypes;


/* 自訂alertView
=====================================
* 特色
* 1. 允許連續呼叫alertView，會保留之前的
* 2. 允許正常與輸入文字的款式  
* 3. 注意：在pressOK的block裡面暫時先不要再生一個Alert,因為show的時候會保留先前的,造成畫面無法tocu
===================================*/

@interface CustomAlertView : UIView{



}

@property (nonatomic, retain)NSString *title;
@property (nonatomic, retain)NSString *msg;
@property (nonatomic, assign)BOOL isDismiss;
@property (nonatomic, strong)UIView *view;

//正常alert
-(id)initWithAlertDelegate:(id)delegate
                     title:(NSString*)titleStr
                   message:(NSString*)msg
               buttonTitle:(NSArray*)buttonTitleArr
                   pressOK:(void(^)(void))pressOKBlock
               pressCancel:(void(^)(void))pressCancelBlock;

//按钮横屏弹框
-(id)initWithAlertDelegate2:(id)delegate
                     title:(NSString*)titleStr
                   message:(NSString*)msg
               buttonTitle:(NSArray*)buttonTitleArr
                   pressOK:(void(^)(void))pressOKBlock
               pressCancel:(void(^)(void))pressCancelBlock;

//可輸入文字
-(id)initWithAlertDelegate:(id)delegate
                     title:(NSString*)titleStr
               buttonTitle:(NSArray*)buttonTitleArr
        textFieldTitleText:(NSArray*)textFieldTitleArr
      textFieldPlaceHolder:(NSArray*)textFieldPlaceHolderArr
                   pressOK:(BOOL(^)(NSArray *textArr))pressOKBlock
               pressCancel:(void(^)(void))pressCancelBlock;

//自定义view
-(id)initWithAlertDelegate:(id)delegate
                     title:(NSString*)titleStr
                      view:(UIView*)view
               buttonTitle:(NSArray*)buttonTitleArr
                   pressOK:(void(^)(void))pressOKBlock
               pressCancel:(void(^)(void))pressCancelBlock;

- (void)show;
- (void)dismiss;

//當有其他alert蓋過此實體後會暫時removeFromSuperView，利用這個家回來
-(void)recoveryDisplay;




@end
