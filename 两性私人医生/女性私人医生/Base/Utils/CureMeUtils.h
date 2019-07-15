//
//  CureMeUtils.h
//  CureMe
//
//  Created by Tim on 12-8-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//
// 主要用户存放程序运行中的全局变量，例如，是否登录成功

//10 美容
//11 妇科
//12 产科
//13 皮肤科
//14 眼科
//15 中医

#import "NetUtils.h"
#import "FileUtils.h"
#import "Notifications.h"
#import "ImageDownloadHelper.h"
#import <Foundation/Foundation.h>
#import "LocateUtils.h"
#import "WXApi.h"
#import "WXApiObject.h"

#define MAX_BACK_BUTTON_WIDTH 160.0
#define OFFICEINFO_CELLHEIGHT 68
#define CHATINFO_CELLHEIGHT 90

// 用户登录信息及个人信息
#define USER_ID @"UserID"
#define USER_SWT_ID @"UserSWTID"
#define USER_REGISTERNAME @"UserRegisterName"
#define USER_PERSONALNAME @"UserPersonalName"
#define USER_PASSWORD @"UserPassword"
#define USER_REGION @"UserRegion"   // 用户所在省份/直辖市
#define USER_CITY @"UserCity"       // 用户所在城市/区
#define USER_CITY_NAME @"UserCityName"  // 用户所在城市/区的中文名
#define USER_PHONENO @"UserPhone"
#define USER_AGE @"UserAge"
#define USER_LASTUSERID @"UserLastUserID"
#define HAS_FIRST_USED @"Stat_HasFirstUsed"
#define OFFICE_SUBTYPE_DICT @"OfficeSubTypeDict"
#define OFFICE_SUPERTYPE_ARRAY @"OfficeSuperTypeArray"
#define WX_HEAD @"weixinHeadImg"

#define HAS_SENT_LOCATIONINFO @"HasSentLocationInfo"
#define LAST_SEND_LOCATION_TIME @"LastSendLocationTime" 

#define DOMAIN_NAME @"new.medapp.ranknowcn.com"
// 是否同意过用户协议
#define HAS_AGREEPROTOCOL @"HasAgreeProtocol"

// 是否已为App打分
#define HAS_MARKAPP @"HasMarkApp"
#define LAST_REFUSEMARK_TIME @"LastRefuseMarkTime"

// 服务端返回的用户唯一ID
#define USER_UNIQUE_ID @"UserUniqueID"
// 苹果Push返回的设备Token
#define PUSH_TOKEN @"ApplePushToken"
#define PUSH_TOKEN_NSDATA @"AppleOringPushToken"

#define LOCATION_ADDRESS @"LocationAddress"

//虚拟定位
#define EMULATE_LOCATION @"emulateLocationAddress"
#define EMULATE_LOCATION_PROVINCE @"emulateProvince"
#define EMULATE_LOCATION_CITY @"emulateCity"

#define APP_LAUNCHOPTION @"AppLaunchingOptions"

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//1(私密健康医生).2（1-apple,2-91, 5-haima）.3.0(ver)
#define APP_VERSION @"1.1.3.0"

#define Hichat_App_Key @"805372035"
#define Hichat_account @"test@126.com"
#define Hichat_password @"123654"

//微信appId
#define WX_MAN_ID @"wx3a0c3463cb54741d"
#define WX_WOMAN_ID @"wxfc3858980f3bd564"
#define WX_WOMAN_SECRET @"a76b122163eb5e584ca7c015ce154bc8"
#define WX_BOTH_ID @"wx9d1831a765a664c7"
#define WX_BOTH_SECRET  @"0996b282be2ce2a52cdb98d65cc5bd95"
//第三方统计appkey
#define MIXPANEL_TOKEN @"1b5624603568968790c834eb08ebf147"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

typedef enum {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

enum InfoListType {
    LIST_DOCTOR = 10,
    LIST_HOSPITAL = 11,
    LIST_BOOK = 12
};

enum OfficeType {
    OFFICE_GENERAL = 0,
    OFFICE_NANKE = 17,
    OFFICE_QIANLIEXIAN = 19,
    OFFICE_MEIRONG = 10,
    OFFICE_FUKE = 11,
    OFFICE_CHANKE = 12,
    OFFICE_PIFUKE = 13,
    OFFICE_YANKE = 14,
    OFFICE_ZHONGYI = 15,
    OFFICE_KOUQIANG = 16,
    OFFICE_GANGCHANG = 18,
    OFFICE_JIAKANG = 20,
    OFFICE_GANBING = 21,
    OFFICE_NAOTAN = 22,
    OFFICE_GUKE = 23,
    OFFICE_DIANXIAN = 24,
    OFFICE_BYBY = 25,
    OFFICE_XINZANG = 26,
    OFFICE_SHENJING = 27,
    OFFICE_ERBIHOU = 28,
    OFFICE_WEICHANG = 29,
    OFFICE_TANGNIAOBING = 30,
    OFFICE_ZHONGLIU = 31
};

enum
{
    REPLYTYPE_LIMIT = 0,
    REPLYTYPE_UNLIMIT
};

@protocol wxBackDelegate <NSObject>
-(void)recieveAuthResponse:(BOOL)isSucced code:(NSString *)code;

@end
@interface WeixinBackTools : NSObject <WXApiDelegate>
-(void)sendAuthRequest;
+ (WeixinBackTools *)sharedInstance;
@property id <wxBackDelegate> wxBackDelegate;
@end


#pragma mark Tag definitions:
// 也被用作Tag
enum UserType
{
    JUST_ME = 100,
    ALL_USER = 101,
    END
};
#define AnswerHeadImageViewTag 90

@class Doctor;
@class Hospital;
@class Question;
@class Answer;
@class Office;
@class QuestionAnswers;
@class JSONDecoder;

// 基站接口
@class CLGetGsmInfo;
@class GSMInfoData;

NSString *officeStringWithType(NSInteger officeType);

@interface CureMeUtils : NSObject<LocateUtilsDelegate>

{
    LocateUtils *locateUtils;
    CLGetGsmInfo *gsmInfo;
}

// 基站信息
//@property (nonatomic, strong, readonly) GSMInfoData *gsmData;

// 上次咨询输入的内容
@property (nonatomic, strong) NSString *lastQueryString;

// 未读消息数
@property NSInteger unreadMessageCount;

// 手机定位后获得的省份信息，不一定是用户保存的地区设置
// 定位获得的省份
@property (nonatomic, strong) NSString *province;
// 定位获得的城市或者区
@property (nonatomic, strong) NSString *cityOrDistrict;

@property NSInteger cityCode;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

@property (nonatomic, strong) NSString *uniID;
// 手机定位后获得的地址详细信息，不一定是用户保存的地区设置
@property (nonatomic, strong) NSString *encodedLocateInfo;

@property NSInteger curChatHeartBreakSeed;

@property (nonatomic, readonly, strong) JSONDecoder *jsonDecoder;

@property (nonatomic, readonly, strong) UIImage *queryListSeparatorLineImage;

@property (nonatomic,readonly) NSString *appVersion;

@property bool hasLogin;
@property (nonatomic, readonly, strong) NSDateFormatter *detailDateFormatter;
@property (nonatomic, readonly, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly, strong) NSDateFormatter *shortDateFormatter;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *phoneNo;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *personalName;
@property NSInteger userRegion;
@property NSInteger userCity;
@property (nonatomic, strong) NSString *userCityName;
@property NSInteger userAge;
@property NSInteger userID;
@property NSInteger userSWTID;
@property NSInteger lastUserID;
@property bool canUpdateUnread;
@property (nonatomic, strong) NSMutableDictionary *fullCityDictionary;
// action=login会获得本次Login服务端的有效Cookie
@property (nonatomic, strong) NSString *loginCookie;
// loop query server IP
@property (nonatomic, strong) NSString *pollServer;
// loop query server port
@property (nonatomic, strong) NSString *pollServerPort;

@property (nonatomic, strong) NSString *UDID;

@property bool isInNewQuery;

// 该账户是否为“未注册登录”账户
- (bool)isUnRegLoginUser;

//- (NSString *)getGSMCellID;

- (BOOL)isPureInt:(NSString*)string;
- (BOOL)isPureFloat:(NSString*)string;

- (void)updateUnreadMsgCount;
- (void)updatePollServerInfo:(NSString *)jsonString;

- (void)startLocationing;
- (void)stopLocationing;
- (void)initUserLoginInfo;
- (void)initUserPersonalInfo;
- (void)clearUserInfoStore;
- (void)resetUserInfo;


// 更新用户信息
- (void)updateUserInfo:(NSInteger)userID;

// 发送用户位置信息
- (void)sendUserLocationInfo;

#pragma mark gets and sets
- (NSDictionary *)regionDictionaryForUser;
- (NSArray *)regionSortedKeys;
- (NSString *)regionWithRegionID:(NSInteger)regionID;
- (NSNumber *)regionIDWithRegionName:(NSString *)regionName;

- (NSArray *)cityArrayWithRegionID:(NSInteger)regionID;
- (void)updateUserRegion:(NSNumber *)regionID;
- (void)updateUserCity:(NSNumber *)cityID andCityName:(NSString *)cityName;

- (UIImage *)queryListSeparatorLineImage;

- (NSString *)getTimeSpanFromNow:(NSDate *)msgTime;

+ (CureMeUtils *)defaultCureMeUtil;

- (void)getReplyList:(NSInteger)questionID andQAInfo:(QuestionAnswers *)questionAnswer;

- (UIImage *)getImageByKey:(NSString *)key andSize:(NSString *)size;
- (bool)saveImage:(NSData *)image withKey:(NSString *)imageKey andSize:(NSString *)size;
- (NSString *)getImageName:(NSString *)imageKey andSize:(NSString *)size;

#pragma mark Image operations
- (UIImage *)resizeImageWithConstraint:(UIImage *)oriImage andMaxSize:(float)maxSize;

#pragma mark parse special json data

#pragma mark parse methods
- (Doctor *)parseDoctorInfoFromJson:(NSDictionary *)doctorJson andDoctor:(Doctor*)doct;
- (Hospital *)parseHospitalInfoFromJson:(NSDictionary *)hospitalJson andHospital:(Hospital *)hospital;
- (Question *)parseQuestionInfoFromJson:(NSDictionary *)questionJson andQuestion:(Question *)question;
- (Answer *)parseAnswerInfoFromJson:(NSDictionary *)answerJson andAnswer:(Answer *)answer;
- (Office *)parseOfficeInfoFromJson:(NSDictionary *)officeJson andOffice:(Office*)office;

@end
