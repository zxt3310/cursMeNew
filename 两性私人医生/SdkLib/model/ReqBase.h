//
//  ReqBase.h
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#import "JSONModel.h"
#import "SystemInfo.h"
#import "ClientInfo.h"
#import "ActionInfo.h"

@interface ReqBase : JSONModel

@property (nonatomic, strong)SystemInfo *systemInfo;
@property (nonatomic, strong)ClientInfo *clientInfo;
@property (nonatomic, strong)ActionInfo *actionInfo;

@end