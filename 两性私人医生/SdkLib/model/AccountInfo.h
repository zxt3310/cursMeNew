//
//  AccountInfo.h
//  Exer
//
//  Created by xiaoshoucun on 15/10/29.
//  Copyright (c) 2015年 Hesine. All rights reserved.
//

#import "TidyAccountInfo.h"

@protocol AccountInfo @end

@interface AccountInfo : TidyAccountInfo

@property (nonatomic, strong)NSString *pnToken;
@property (nonatomic, assign)int connectType;//0 、手机端登录  1、网页端登录
/**
 * 不同PN类型:HPNS/APNS/GCM…
 */
@property (nonatomic, strong)NSString *pnType;

/**
 * 用户类型（0-普通用户，1-服务号，2-普通客服，3-管理员）
 */
@property (nonatomic, assign)int userType;
@property (nonatomic, strong)NSString *appKey;

/**
 * 终端类型（0-手机，1-网页，2-pc）
 */
@property (nonatomic, assign)int terminalType;
@property (nonatomic, strong)NSDate *createTime;
@property (nonatomic, strong)NSDate *updateTime;

@end
