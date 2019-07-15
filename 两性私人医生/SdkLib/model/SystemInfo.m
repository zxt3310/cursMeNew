//
//  SystemInfo.m
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#import "SystemInfo.h"
#import "Gloabal.h"
#import "NSString+MACAddress.h"
#import "Config.h"
#import <UIKit/UIDevice.h>

static SystemInfo *ins = nil;

@implementation SystemInfo

//获得单例
+(id)getSingleton
{
    @synchronized(self)
    {
        if (ins == nil) {
            ins = [[self alloc] init];
        }
    }
    return ins;
}

- (void)dealloc
{
    self.phoneNum = nil;  //手机号	可以为空
    self.imsi = nil;      //Sim卡串号
    self.imei = nil;      //设备串口	不能为空取不到用MAC地址代替
    self.device = nil;    //设备型号
    self.brand = nil;     //厂商
    self.osver = nil;     //系统版本	格式：2.1，2.3,4.0
    self.language = nil;  //系统语言
    self.pnToken = nil;      //pn在手机上的唯一标识
    self.pnType = nil;       //pn的类型，和信的pn还是google的pn
    _location = nil;
}

- (id)init
{
    if(self = [super init]){
        //获取手机号码
        self.phoneNum = @"";
        //self.phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"SBFormattedPhoneNumber"];
        
        //Sim卡串号imsi
        self.imsi = @"";
        
        //设备imei 最大64位
        NSString *IFDA = [CureMeUtils defaultCureMeUtil].UDID;
        self.imei = @"867451022317702"; //[IFDA stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        //设备型号
        self.device = [[UIDevice currentDevice] systemVersion];
        
        //厂商
        self.brand = @"apple";
        
        //系统版本
        self.osver = [[UIDevice currentDevice] systemVersion];
        //系统语言
        self.language = [self getPreferredLanguage];
        //pn在手机上的唯一标识
        self.pnToken = @""; //ED20B74F5B60B64FE9646D14
        
        //pn的类型，和信的pn还是google的pn
        self.pnType = @"APNS_double";
//        [[NSUserDefaults standardUserDefaults] setObject:dTokenStr forKey:NSU_PN_TOKEN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        self.pnToken = [Config getPnToken];
    }
    return  self;
}

- (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}

@end
