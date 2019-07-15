//
//  ClientInfo.h
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//
#import "JSONModel.h"

@interface ClientInfo : JSONModel

@property (nonatomic, assign)int channelId;
@property (nonatomic, strong)NSString *version;
@property (nonatomic, strong)NSString *appName;

//获得单例
+(id)getSingleton;

@end