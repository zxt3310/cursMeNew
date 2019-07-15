//
//  DataUtils.h
//  CureMe
//
//  Created by Tim on 12-11-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>


enum {
    MYCHAT_LASTTYPE_USER = 0,
    MYCHAT_LASTTYPE_DOCTOR = 1
};

// 用于我的对话列表
@interface MyChatInfoUnit : NSObject

@property BOOL isSWT;
@property NSInteger chatID;
@property NSInteger userID;
//@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *lastMsgTime;
@property (nonatomic, strong) NSDate *addTime;
@property NSInteger doctorID;
@property NSInteger hospitalID;
/**
 *  @author Zxt, 17-04-05 15:04:33
 *
 *  医爱淘 新增对话删除，需要questionID，对话分配类型chattype
 */
@property NSInteger questionID;
@property (nonatomic, strong) NSString *chattype;

@property NSInteger unreadCount;
@property (nonatomic, strong) NSString *doctorName;
@property (nonatomic, strong) NSString *doctorTitle;
@property (nonatomic, strong) NSString *doctorImageKey;
@property (nonatomic, strong) NSString *hospitalName;
@property NSInteger totalCount;
@property (nonatomic, strong) NSString *lastMsg;
@property (nonatomic, strong) NSString *lastMsgUserType;
@property NSInteger markPoint;
@property (nonatomic, strong) NSString *markComment;
@property float lastWordSubViewHeight;

@end


// 用于“我的预约列表”
@interface BookInfoUnit : NSObject

@property NSInteger bookID;
@property NSInteger hospitalID;
@property NSInteger officeID;
@property NSInteger age;
@property (nonatomic) NSInteger bookState;
@property (nonatomic, strong) NSDate *bookDate;
@property (nonatomic, strong) NSString *bookNumber;
@property (nonatomic, strong) NSString *telephone;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *hospitalName;
@property (nonatomic, strong) NSString *officeName;
@property (nonatomic, strong) NSString *doctorName;
@property (nonatomic, strong) NSString *doctorInfo;
@property (nonatomic, strong) NSString *doctorReply;
@property (nonatomic, strong) NSString *memory;
@property (nonatomic, strong) NSString *doctorImageKey;

@end

// 预约详情数据结构
@interface BookDetail : NSObject

@property NSInteger bookID;                             // 预约ID
@property (nonatomic, strong) NSString *bookNumber;     // 预约单号
@property NSInteger succeed;                            // 预约是否成功
@property (nonatomic, strong) NSString *name;           // 预约用户名
@property (nonatomic, strong) NSString *hospitalName;   // 预约医院名
@property (nonatomic, strong) NSString *officeName;     // 预约科室名
@property NSInteger hospitalID;                         // 医院ID
@property NSInteger officeID;                           // 科室ID
@property (nonatomic, strong) NSDate *bookTime;         // 预约时间
@property (nonatomic, strong) NSDate *submitTime;       // 提交预约时间
@property (nonatomic, strong) NSString *telephone;      // 电话
@property NSInteger age;                                // 年龄
@property (nonatomic, strong) NSString *memory;         // 用户备注
@property (nonatomic, strong) NSString *hospitalReply;  // 医院回复
@property (nonatomic, strong) NSString *hospitalImage;  // 医院图片

@end


#pragma mark OfficeTypeUnit
// 咨询列表，下拉的科室类型列表元素
@interface OfficeTypeUnit : NSObject

@property (nonatomic, strong) UIImage *officeIcon;
@property NSInteger officeID;
@property (nonatomic, strong) NSString *officeName;

+ (OfficeTypeUnit *)unitWithID:(NSInteger)officeID andName:(NSString *)officeName andIcon:(UIImage *)officeIcon;

@end


#pragma mark OfficeSubTypeUnit
@interface OfficeSubTypeUnit : NSObject

@property (nonatomic, strong) NSNumber *subTypeID;
@property (nonatomic, strong) NSNumber *parentTypeID;
@property (nonatomic, strong) NSString *subTypeName;

@end


#pragma mark DataUtils for 科室信息、子科室信息
@interface CMDataUtils : NSObject

+ (CMDataUtils *)defaultDataUtil;

@property (readonly, strong) NSMutableDictionary *officeTypeDict;
@property (readonly, strong) NSArray *officeTypeArray;
@property (readonly, strong) NSDictionary *officeSuperTypeDict;

- (void)initAllOfficeSubTypeData;

@end
