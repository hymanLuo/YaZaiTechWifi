//
//  SleepData.h
//  YaZai
//
//  Created by admin on 2018/11/24.
//

#import <Foundation/Foundation.h>
#import "UGDesView.h"

@interface SleepData : NSObject

@property (strong, nonatomic) NSString *title;//宝宝睡觉姿势描述文字
@property (strong, nonatomic) NSString *image;//宝宝睡觉姿势图片
@property (strong, nonatomic) NSString *bigimage;//宝宝睡觉姿势在选中的时候的图


+(SleepData*)initWithtitle:(NSString*)title
                     image:(NSString*)image
                     bigimage:(NSString*)bigimage;
@end
