//
//  CustomerInfo.h
//  HiChat
//
//  Created by xiaoshoucun on 15/11/2.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import "TidyAccountInfo.h"
#import "TidyChatInfo.h"

@protocol CustomerInfo @end

@interface CustomerInfo : JSONModel

/**
 * 当前会话概要
 */
@property (nonatomic, assign)NSNumber<JMPrimaryKey> *Id;

/**
 * 当前会话概要
 */
@property (nonatomic, strong)TidyAccountInfo *accountInfo;
/**
 * 当日客服工作统计
 */
@property (nonatomic, strong)TidyChatInfo *lastChatInfo;

@end
