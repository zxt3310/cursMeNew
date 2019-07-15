//
//  CMImageUtils.h
//  私密健康医生
//
//  Created by Tim on 13-1-13.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMImageUtils : NSObject

+ (CMImageUtils *)defaultImageUtil;

@property (nonatomic, readonly, strong) UIImage *doctorDefaultBGImage;
@property (nonatomic, readonly, strong) UIImage *doctorDefaultBGMImage;
@property (nonatomic, readonly, strong) UIImage *doctorDefaultHeadSImage;
@property (nonatomic, readonly, strong) UIImage *doctorDefaultHeadMImage;
@property (nonatomic, readonly, strong) UIImage *doctorDefaultHeadLImage;
@property (nonatomic, readonly, strong) UIImage *doctorDefaultHeadImage;

@property (nonatomic, readonly, strong) UIImage *qaListQuestionImage;
@property (nonatomic, readonly, strong) UIImage *qaCellQuestionBgImage;
@property (nonatomic, readonly, strong) UIImage *qaCellQuestionBgAllImage;
@property (nonatomic, readonly, strong) UIImage *qaCellAnswerMidImage;
@property (nonatomic, readonly, strong) UIImage *qaCellAnswerTailImage;

@property (nonatomic, readonly, strong) UIImage *hospitalDefaultHeadSImage;
@property (nonatomic, readonly, strong) UIImage *hospitalDefaultHeadMImage;
@property (nonatomic, readonly, strong) UIImage *hospitalDefaultHeadLImage;

@property (nonatomic, readonly, strong) UIImage *userHeadImage;

//Logo
@property (nonatomic, strong, readonly) UIImage *logoImage;

// 咨询列表，无回复时的默认图片
@property (nonatomic, readonly, strong) UIImage *chatListNoreplyDefaultImage;
// 问题展示列表，默认问题图片
@property (nonatomic, readonly, strong) UIImage *qaListQuestionDefultImage;

// 聊天气泡图
@property (nonatomic, readonly, strong) UIImage *chatOtherBubbleImage;
@property (nonatomic, readonly, strong) UIImage *chatSelfBubbleImage;
@property (nonatomic, readonly, strong) UIImage *chatNotifyBubbleImage;

@property (nonatomic, readonly, strong) UIImage *btnBg_NImage;
@property (nonatomic, readonly, strong) UIImage *btnBg_PImage;

@property (nonatomic, readonly, strong) UIImage *chatLoadingImage;

// NavigationBar的返回按钮
@property (nonatomic, readonly, strong) UIImage *navBackBtnNormal;
@property (nonatomic, readonly, strong) UIImage *navBackBtnSelected;

// 主科室的Icon与名称字典
@property (nonatomic, strong) NSMutableDictionary *officeIconDict;
@property (nonatomic, strong) NSMutableDictionary *officeNameDict;

// 评价按钮
@property (nonatomic, strong) UIImage *hasMarkedBtnImage;
@property (nonatomic, strong) UIImage *hasNotMarkedBtnImage;
// 删除聊天记录按钮
@property (nonatomic, strong) UIImage *deleteChatBtnImage;

- (UIImage *)officeIconWithID:(NSInteger)officeID;

@end
