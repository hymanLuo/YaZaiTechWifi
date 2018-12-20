//
//  SleepData.m
//  YaZai
//
//  Created by admin on 2018/11/24.
//

#import "SleepData.h"

@implementation SleepData

+(SleepData*)initWithtitle:(NSString*)title
                     image:(NSString*)image
                  bigimage:(NSString*)bigimage{
    SleepData * data = [[SleepData alloc]init];
    data.title = title;
    data.image = image;
    data.bigimage = bigimage;
    return data;
}
@end
