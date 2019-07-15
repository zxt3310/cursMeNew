//
//  SystemInfo.h
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#import "JSONModel.h"
#import "LocationInfo.h"

@interface SystemInfo : JSONModel

@property (nonatomic, strong)NSString *phoneNum;
@property (nonatomic, strong)NSString *imsi;
@property (nonatomic, strong)NSString *imei;
@property (nonatomic, strong)NSString *device;
@property (nonatomic, strong)NSString *brand;
@property (nonatomic, strong)NSString *language;
@property (nonatomic, strong)NSString *osver;
@property (nonatomic, strong)NSString *pnToken;
@property (nonatomic, strong)NSString *pnType;
@property (nonatomic, strong)NSString<Ignore> *uuid;
@property (nonatomic, strong)LocationInfo *location;

//获得单例
+(id)getSingleton;

@end
