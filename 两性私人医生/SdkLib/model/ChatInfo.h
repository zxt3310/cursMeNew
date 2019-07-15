//
//  ChatInfo.h
//  HiChat
//
//  Created by xiaoshoucun on 15/10/29.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import "TidyChatInfo.h"
#import "MessageInfo.h"
#import "AccountInfo.h"

@protocol ChatInfo @end

@interface ChatInfo : TidyChatInfo

@property (nonatomic, assign)int chatUnread;
@property (nonatomic, assign)int chatTotalMsg;
@property (nonatomic, strong)MessageInfo *chatLastMsg;
@property (nonatomic, assign)long chatLastTime;
@property (nonatomic, strong)NSArray<AccountInfo> * memberList;
@property (nonatomic, assign)long createTime;

@end

