//
//  TidyAccountInfo.h
//  HiChat
//
//  Created by xiaoshoucun on 15/11/6.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import "JSONModel.h"

@protocol TidyAccountInfo @end

@interface TidyAccountInfo : JSONModel

@property (nonatomic, strong)NSString<JMPrimaryKey> *userId;
@property (nonatomic, strong)NSString *nickName;
/**
 * 用户状态[0:下线,1:上线]
 */
@property (nonatomic, assign)int userState;

@end