//
//  Globaldata.m
//  YaZai
//
//  Created by admin on 2018/11/26.
//

#import "Globaldata.h"



@implementation Globaldata

static Globaldata *globaldaa = nil;
+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        globaldaa = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return globaldaa ;
}


+(id) allocWithZone:(struct _NSZone *)zone
{
    return [Globaldata shareInstance] ;
}

-(id) copyWithZone:(NSZone *)zone
{
    return [Globaldata shareInstance] ;//return _instance;
}

-(id) mutablecopyWithZone:(NSZone *)zone
{
    return [Globaldata shareInstance] ;
}


@end
