//
//  TidyChatInfo.h
//  HiChat
//
//  Created by xiaoshoucun on 15/11/6.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import "JSONModel.h"

@protocol TidyChatInfo @end

@interface TidyChatInfo : JSONModel

@property (nonatomic, assign)NSNumber<JMPrimaryKey> *chatId;
@property (nonatomic, assign)int chatStatus;

@end
