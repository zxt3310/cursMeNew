//
//  Notifications.h
//  CureMe
//
//  Created by Tim on 12-8-17.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

// 登录成功
#define NTF_LoginCompleted @"N_loginComplete"
// 注册成功
#define NTF_RegisterComplated @"N_registerComplete"

// 点击了某个回复的回复者头像
#define NTF_AnswerHeadSelected @"N_answerHeadSelected"
// 选中了某个问题的回答者View
#define NTF_AnswerSelected @"N_answerSelected"
// 点击了某个咨询
#define NTF_QuestionCellSelected @"N_questionCellSelected"

// 点击了回答者头像
#define NTF_TalkHeadImageSelected @"N_talkHeadImageSelected"

// 点击了聊天记录列表的某一项
#define NTF_BubbleCellSelected @"N_bubbleCellSelected"

// 用户选择了预约日期和时间
#define NTF_BookDatePicked @"N_bookDatePicked"
// 用户选择了预约科室并确认
#define NTF_BookOfficePicked @"N_bookOfficePicked"

// 通知对聊天消息进行Pull
#define NTF_PullNewChatMsgs @"N_pullNewChatMsgs"

// 通知缩略图已经点击
#define NTF_ChatMsgThumbnailClick @"N_chatMsgThumbnailClick"

// 通知，用户地区信息已选择完成
#define NTF_UserRegionSelected @"N_userRegionSelected"

// 通知定位位置已经获得
#define NTF_LocationComfirmed @"N_locationComfirmed"

// 通知，无网络通知
#define NTF_NetNotReachable @"N_netNotReachable"

// 通知定位服务没有打开
#define NTF_LocateServiceNotAvailable @"N_locateServiceNotAvailable"

// 通知“未读消息”数已经获得
#define NTF_UNREADMSGCOUNT_UPDATED @"N_unreadMsgCountUpdated"

@interface Notifications : NSObject

@end
