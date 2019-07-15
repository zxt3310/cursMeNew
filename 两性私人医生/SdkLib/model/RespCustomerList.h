//
//  RespCustomerList.h
//  HiChat
//
//  Created by xiaoshoucun on 15/11/2.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import "RespBase.h"
#import "CustomerInfo.h"

@interface RespCustomerList : RespBase

@property (nonatomic, strong)NSArray<CustomerInfo> *customerInfoList;

@end