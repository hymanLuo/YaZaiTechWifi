//
//  BLEManage.h
//  YaZai
//
//  Created by admin on 2018/11/26.
//

#import <Foundation/Foundation.h>



@interface BLEManage : NSObject

//初始化
+(instancetype) shareInstance;

//开始搜索
-(void)starSacn;

//结束搜索
-(void)stopSacn;

@end
