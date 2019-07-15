//
//  CureMeUtils.m
//  CureMe
//
//  Created by Tim on 12-8-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "CureMeUtils.h"
#import "Doctor.h"
#import "Hospital.h"
#import "Question.h"
#import "Answer.h"
#import "QuestionAnswers.h"
#import "Office.h"
#import "Reachability.h"
#import "JsonKit.h"
#import <AdSupport/AdSupport.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "HiChat.h"
#import "WebViewController.h"



@implementation WeixinBackTools

+ (WeixinBackTools *)sharedInstance{
    static WeixinBackTools *sharedBackTools = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBackTools = [self new];
    });
    return sharedBackTools;
}

-(void)sendAuthRequest{
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"new.medapp.ranknowcn.com";
    [WXApi sendReq:req];
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]] && (resp.errCode != -2)) {
        PayResp *payResp = (PayResp *)resp;
        [self wxPayResultRefresh:[NSString stringWithFormat:@"%d",payResp.errCode]];
        
        return;
    }
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if (_wxBackDelegate) {
            [_wxBackDelegate recieveAuthResponse:YES code:authResp.code];
        }
    }
    
    SendMessageToWXResp *sendResp = (SendMessageToWXResp *)resp;
    NSString *str = [NSString stringWithFormat:@"%d---%@",sendResp.errCode,sendResp.errStr];
    if (sendResp.errCode == -2) {
        
    }
    else if (sendResp.errCode == 0){
        
    }
    NSLog(@"%@",str);
}

- (void)wxPayResultRefresh:(NSString *)wxPayErrorCode{
    UIViewController *currentVc = [self getCurrentVC];
    if ([currentVc isKindOfClass:[WebViewController class]]) {
        WebViewController *webVc = (WebViewController *)currentVc;
        
        NSString *paymentId = [webVc valueForKey:@"paymentIdStr"];
        if (paymentId.length>0) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/famous_doctors/myhz_payment_result.php?paymentid=%@&errcode=%@",paymentId,wxPayErrorCode]];
            [webVc.html5View loadRequest:[NSURLRequest requestWithURL:url]];
            [webVc setValue:@"" forKey:@"paymentIdStr"];
        }
    }
}

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result.childViewControllers.lastObject;
}

@end



// 基站定位文件
//#import "CLGetGsmInfo.h"


static CureMeUtils *defaultCureMe = nil;

NSString *officeStringWithType(NSInteger officeType)
{
    NSString *strOfficeType = nil;
    
    switch (officeType) {
        case 0:
            strOfficeType = [NSString stringWithFormat:@"全科"];
            break;
        case OFFICE_MEIRONG:
            strOfficeType = [NSString stringWithFormat:@"美容"];
            break;
        case OFFICE_FUKE:
            strOfficeType = [NSString stringWithFormat:@"妇科"];
            break;
        case OFFICE_CHANKE:
            strOfficeType = [NSString stringWithFormat:@"产科"];
            break;
        case OFFICE_PIFUKE:
            strOfficeType = [NSString stringWithFormat:@"皮肤科"];
            break;
        case OFFICE_YANKE:
            strOfficeType = [NSString stringWithFormat:@"眼科"];
            break;
        case OFFICE_ZHONGYI:
            strOfficeType = [NSString stringWithFormat:@"中医"];
            break;
        case OFFICE_KOUQIANG:
            strOfficeType = [NSString stringWithFormat:@"口腔科"];
            break;
        case OFFICE_JIAKANG:
            strOfficeType = @"甲状腺";
            break;
        case OFFICE_GANBING:
            strOfficeType = @"肝病科";
            break;
        case OFFICE_NAOTAN:
            strOfficeType = @"脑瘫科";
            break;
        case OFFICE_GUKE:
            strOfficeType = @"骨科";
            break;
        case OFFICE_DIANXIAN:
            strOfficeType = @"癫痫科";
            break;
        case OFFICE_BYBY:
            strOfficeType = [NSString stringWithFormat:@"不孕不育"];
            break;
        case OFFICE_XINZANG:
            strOfficeType = [NSString stringWithFormat:@"心脏科"];
            break;
        case OFFICE_SHENJING:
            strOfficeType = [NSString stringWithFormat:@"神经科"];
            break;
        case OFFICE_ERBIHOU:
            strOfficeType = [NSString stringWithFormat:@"耳鼻喉"];
            break;
        case OFFICE_WEICHANG:
            strOfficeType = [NSString stringWithFormat:@"胃肠科"];
            break;
        case OFFICE_TANGNIAOBING:
            strOfficeType = [NSString stringWithFormat:@"糖尿病"];
            break;
        case OFFICE_ZHONGLIU:
            strOfficeType = [NSString stringWithFormat:@"肿瘤"];
            break;
        case OFFICE_GANGCHANG:
            strOfficeType = [NSString stringWithFormat:@"肛肠科"];
            break;
        default:
            strOfficeType = [NSString stringWithFormat:@""];
            break;
    }
    
    return strOfficeType;
}

@interface CureMeUtils (private)

- (NSString *)getUDID;

@end


@implementation CureMeUtils

@synthesize cityCode = _cityCode;

@synthesize appVersion = _appVersion;
@synthesize hasLogin = _hasLogin;
@synthesize userID = _userID;
@synthesize userSWTID = _userSWTID;
@synthesize phoneNo = _phoneNo;
@synthesize userName = _userName;
@synthesize personalName = _personalName;
@synthesize password = _password;
@synthesize dateFormatter = _dateFormatter;
@synthesize shortDateFormatter = _shortDateFormatter;
@synthesize detailDateFormatter = _detailDateFormatter;
@synthesize jsonDecoder = _jsonDecoder;
@synthesize queryListSeparatorLineImage = _queryListSeparatorLineImage;
@synthesize userRegion = _userRegion;
@synthesize userCity = _userCity;
@synthesize userCityName = _userCityName;
@synthesize userAge = _userAge;
@synthesize lastUserID = _lastUserID;
@synthesize curChatHeartBreakSeed = _curChatHeartBreakSeed;
// 未读消息数
@synthesize unreadMessageCount = _unreadMessageCount;
@synthesize fullCityDictionary = _fullCityDictionary;
@synthesize canUpdateUnread = _canUpdateUnread;
//@synthesize gsmData = _gsmData;
@synthesize isInNewQuery = _isInNewQuery;

+ (CureMeUtils *)defaultCureMeUtil
{
    if (!defaultCureMe) {
        NSLog(@"CureMeUtils defaultCureMeUtil");
        defaultCureMe = [[super allocWithZone:NULL] init];
    }
    
    return defaultCureMe;
}

+ (id) allocWithZone:(NSZone *)zone
{
    return [self defaultCureMeUtil];
}

- (id) init
{
    if (defaultCureMe) {
        return defaultCureMe;
    }
    
    NSLog(@"CureMeUtils init");
    _unreadMessageCount = 0;
    self = [super init];
    
    [self initUserLoginInfo];
    [self initUserPersonalInfo];
    if (!locateUtils) {
        locateUtils = [[LocateUtils alloc] init];
        [locateUtils setDelegate:self];
        [locateUtils load];
    }
    
    // 如果已登录，并且未保存地址信息，启动定位
    //    if (_hasLogin) {
    //        if (!_encodedLocateInfo || !_province) {
    [self startLocationing];
    //        }
    //    }
    //    // 自定义初始化
    //    _hasLogin = false;
    //    _lastUserID = 0;
    
    _canUpdateUnread = true;
    
    _isInNewQuery = NO;
    
    return self;
}
/*
 - (GSMInfoData *)gsmData
 {
 if (!gsmInfo) {
 // 初始化基栈获取模块
 gsmInfo = [[CLGetGsmInfo alloc] init];
 [gsmInfo cellConnect];
 }
 
 _gsmData = [gsmInfo getCellInfo2];
 
 return _gsmData;
 }*/

- (void)startLocationing
{
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    
    switch ([reachability currentReachabilityStatus]) {
        case NotReachable:
            NSLog(@"Network not reachable");
            break;
            
        case ReachableViaWiFi:
            NSLog(@"Network reachable for WiFi");
            [locateUtils startUpdating];
            break;
            
        case ReachableViaWWAN:
            NSLog(@"NetWork reachable for WWAN");
            [locateUtils startUpdating];
            break;
            
        default:
            break;
    }
}

- (void)stopLocationing
{
    if (locateUtils) {
        [locateUtils stopUpdating];
    }
}

- (void)dealloc
{
    _jsonDecoder = nil;
    _queryListSeparatorLineImage = nil;
    _dateFormatter = nil;
    _detailDateFormatter = nil;
    _userName = nil;
    _phoneNo = nil;
    _password = nil;
    _personalName = nil;
}

- (void)initUserLoginInfo
{
    NSInteger user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] integerValue];
    _userSWTID = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_SWT_ID] integerValue];
    NSString *registerName = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGISTERNAME];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PASSWORD];
    NSNumber *lastLoginID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_LASTUSERID];
    
    _userID = user_id;
    if (registerName) {
        _userName = registerName;
    }
    
    if (password) {
        _password = password;
    }
    
    if (_userID > 0 && registerName && registerName.length > 0) {
        _hasLogin = true;
    }
    else
        _hasLogin = false;
    
    if (lastLoginID) {
        _lastUserID = lastLoginID.integerValue;
    }
}

- (void)setHasLogin:(bool)hasLogin
{
    _hasLogin = hasLogin;
}

- (bool)hasLogin
{
    if (self.userID <= 0)
        return false;
    
    // 如果DeviceID与UserName相同，则是“未注册登录”账户，认为已登录
    if ([self.userName isEqualToString:self.uniID])
        return true;
    
    return _hasLogin;
}

- (bool)isUnRegLoginUser
{
    if ([_userName isEqualToString:_uniID])
        return true;
    
    return false;
}

- (NSString *)userName
{
    if (!_userName) {
        _userName = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGISTERNAME];
    }
    
    return _userName;
}

- (NSString *)uniID
{
    if (!_uniID) {
        _uniID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID];
    }
    
    return _uniID;
}

- (NSString *)appVersion{
    //获取当前版本号
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentAppVersion = infoDic[@"CFBundleShortVersionString"];
    return currentAppVersion;
}

- (NSInteger)userID
{
    if (_userID <= 0) {
        NSNumber *numUserID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID];
        if (numUserID) {
            _userID = [numUserID integerValue];
        }
    }
    
    return _userID;
}

- (void)setUserID:(NSInteger)userID
{
    _userID = userID;
}

- (NSInteger)userSWTID
{
    if (_userSWTID <= 0) {
        NSNumber *numUserSWTID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_SWT_ID];
        if (numUserSWTID) {
            _userSWTID = [numUserSWTID integerValue];
        }
    }
    
    return _userSWTID;
}

- (void)setUserSWTID:(NSInteger)userSWTID
{
    _userSWTID = userSWTID;
}

- (void)clearUserInfoStore
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_SWT_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_REGISTERNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_PASSWORD];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_PERSONALNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_PHONENO];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_REGION];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_CITY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_CITY_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_AGE];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:HAS_AGREEPROTOCOL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userType"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"weixinHeadImg"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resetUserInfo
{
    _hasLogin = false;
    _userID = 0;
    _userSWTID = 0;
    _userName = nil;
    _password = nil;
    
    _userRegion = 0;
    _userCity = 0;
    _personalName = nil;
    _phoneNo = nil;
    _userAge = 0;
    
    _unreadMessageCount = 0;
}

// {"result":true,"msg":1000001,"unreadcount":{"replycount":0,"channelcount":0,"chatcount":0},"chatservers":{"chatserver":"n2.medapp.ranknowcn.com","chatport":"3810","chatnport":"3820"}}
- (void)updatePollServerInfo:(NSString *)jsonString
{
    if (!jsonString || [jsonString length] <= 0) {
        NSLog(@"upd poll server json str empty");
        return;
    }
    
    NSDictionary *jsonData = parseJsonString(jsonString);
    if (!jsonData || [jsonData count] <= 0) {
        NSLog(@"upd poll server json str invalid: %@", jsonString);
        return;
    }
    
    NSDictionary *serverDict = [jsonData objectForKey:@"chatservers"];
    if (!serverDict || [serverDict count] <= 0) {
        NSLog(@"upd poll server server json invalid: %@", jsonData);
        return;
    }
    
    self.pollServer = [serverDict objectForKey:@"chatserver"];
    self.pollServerPort = [serverDict objectForKey:@"chatport"];
}

// 判断是否为整形
- (BOOL)isPureInt:(NSString*)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    
    return[scan scanInt:&val] && [scan isAtEnd];
}

// 判断是否为浮点数
- (BOOL)isPureFloat:(NSString*)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    
    return[scan scanFloat:&val] && [scan isAtEnd];
}

// {"result":true,"msg":{"id":1000020,"mobile":"15088888888","username":"15088888888","regdate":1347600119,"name":"1","gender":0,"age":1,"cityid":29000,"city2id":0,"intro":"","gendername":"\u5973","cityname":"\u897f\u85cf","city2name":""}}
- (void)updateUserInfo:(NSInteger)userID
{
    NSString *post = [[NSString alloc] initWithFormat:@"action=getuserinfo&userid=%ld", (long)userID];
    NSData *response = sendRequest(@"m.php", post);
    
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"updateUserInfo resp: %@", strResp);
    
    NSDictionary *jsonData = parseJsonResponse(response);
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!result || result.integerValue != 1) {
        NSLog(@"action=getuserinfo json result invalid %@", [jsonData objectForKey:@"msg"]);
        return;
    }
    
    NSDictionary *infoData = [jsonData objectForKey:@"msg"];
    if (!infoData || infoData.count <= 0) {
        NSLog(@"action=getuserinfo msgdata invalid %@", [jsonData objectForKey:@"msg"]);
        return;
    }
    
    NSNumber *ID = [infoData objectForKey:@"id"];
    if (!ID || ID.integerValue != _userID) {
        NSLog(@"action=getuserinfo returned invalid userid %@", ID);
    }
    
    NSString *mobile = [infoData objectForKey:@"mobile"];
    if (mobile) {
        [[NSUserDefaults standardUserDefaults] setObject:mobile forKey:USER_PHONENO];
    }
    
    NSString *registerName = [infoData objectForKey:@"username"];
    if (registerName && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"userType"] isEqualToString:@"weixin"]) {
        [[NSUserDefaults standardUserDefaults] setObject:registerName forKey:USER_REGISTERNAME];
    }
    
    NSString *personName = [infoData objectForKey:@"name"];
    if (personName) {
        [[NSUserDefaults standardUserDefaults] setObject:personName forKey:USER_PERSONALNAME];
    }
    
    NSNumber *age = [infoData objectForKey:@"age"];
    if (age) {
        [[NSUserDefaults standardUserDefaults] setObject:age forKey:USER_AGE];
    }
    
    NSNumber *regionID = [infoData objectForKey:@"cityid"];
    if (regionID) {
        [[NSUserDefaults standardUserDefaults] setObject:regionID forKey:USER_REGION];
    }
    
    // tim.wangj.remind
    // 这里要添加城区存储
    NSNumber *cityID = [infoData objectForKey:@"city2id"];
    if (cityID && regionID) {
        // 查找市区名字
        NSString *cityName = nil;
        NSArray *cityArray = [[CureMeUtils defaultCureMeUtil] cityArrayWithRegionID:regionID.integerValue];
        for (NSDictionary *data in cityArray) {
            NSNumber *cID = [data objectForKey:@"id"];
            if (cID && [cID integerValue] == [cityID integerValue]) {
                cityName = [data objectForKey:@"name"];
                break;
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:cityID forKey:USER_CITY];
        [[NSUserDefaults standardUserDefaults] setObject:cityName forKey:USER_CITY_NAME];
    }
    
    if (![[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"updateUserInfo getuserinfo NSUserDefaults synchronize failed!");
    }
    
    [self initUserLoginInfo];
    [self initUserPersonalInfo];
}

- (void)initUserPersonalInfo
{
    NSString *personalName = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PERSONALNAME];
    NSNumber *region = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
    NSNumber *city = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CITY];
    NSString *cityName = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CITY_NAME];
    NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PHONENO];
    NSNumber *age = [[NSUserDefaults standardUserDefaults] objectForKey:USER_AGE];
    
    if (personalName && personalName.length > 0)
        _personalName = personalName;
    else
        _personalName = @"";
    
    if (region)
        _userRegion = region.integerValue;
    else
        _userRegion = 0;
    
    if (city)
        _userCity = city.integerValue;
    else
        _userCity = 0;
    
    _userCityName = cityName;
    
    if (phone && phone.length > 0)
        _phoneNo = phone;
    else
        _phoneNo = @"";
    
    if (age)
        _userAge = age.integerValue;
    else
        _userAge = 0;
    
    _unreadMessageCount = 0;
}


- (NSString *) getUDID{
    NSString *outstring = nil;
    
    // 如果是iOS7之前的系统，获取MAC地址
    if (IOS_VERSION < 7.0) {
        int                 mib[6];
        size_t              len;
        char                *buf;
        unsigned char       *ptr;
        struct if_msghdr    *ifm;
        struct sockaddr_dl  *sdl;
        
        mib[0] = CTL_NET;
        mib[1] = AF_ROUTE;
        mib[2] = 0;
        mib[3] = AF_LINK;
        mib[4] = NET_RT_IFLIST;
        
        if ((mib[5] = if_nametoindex("en0")) == 0) {
            printf("Error: if_nametoindex error\n");
            return NULL;
        }
        
        if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
            printf("Error: sysctl, take 1\n");
            return NULL;
        }
        
        if ((buf = malloc(len)) == NULL) {
            printf("Could not allocate memory. error!\n");
            return NULL;
        }
        
        if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
            printf("Error: sysctl, take 2");
            free(buf);
            return NULL;
        }
        
        ifm = (struct if_msghdr *)buf;
        sdl = (struct sockaddr_dl *)(ifm + 1);
        ptr = (unsigned char *)LLADDR(sdl);
        outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                     *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
        free(buf);
    }
    // 如果是iOS7之后的系统，获取IDFA
    else {
        outstring = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    
    return outstring;
}

- (NSString *)UDID
{
    if (!_UDID) {
        _UDID = [self getUDID];
    }
    
    return _UDID;
}

- (NSDateFormatter *)detailDateFormatter
{
    if (!_detailDateFormatter) {
        _detailDateFormatter = [[NSDateFormatter alloc] init];
        _detailDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        // yyyy-MM-dd HH:mm:ss
        _detailDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    
    return _detailDateFormatter;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yy-MM-dd HH:mm"];
    }
    
    return _dateFormatter;
}

- (NSDateFormatter *)shortDateFormatter
{
    if (!_shortDateFormatter) {
        _shortDateFormatter = [[NSDateFormatter alloc] init];
        [_shortDateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_shortDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    return _shortDateFormatter;
}

- (NSDictionary *)regionDictionaryForUser
{
    NSDictionary *regionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"北京", @"1000", @"上海", @"2000", @"天津", @"3000", @"广东", @"4000", @"福建", @"5000", @"海南", @"8000", @"安徽", @"9000", @"贵州", @"10000", @"甘肃", @"11000", @"广西", @"12000", @"河北", @"13000", @"河南", @"14000", @"黑龙江", @"15000", @"湖北", @"16000", @"湖南", @"17000", @"吉林", @"18000", @"江苏", @"19000", @"江西", @"20000", @"辽宁", @"21000", @"内蒙古", @"22000", @"宁夏", @"23000", @"青海", @"24000", @"山东", @"25000", @"山西", @"26000", @"陕西", @"27000", @"四川", @"28000", @"西藏", @"29000", @"新疆", @"30000", @"云南", @"31000", @"浙江", @"32000", @"重庆", @"33000", @"香港", @"34000", @"台湾", @"35000", @"澳门", @"36000", nil];
    
    return regionDict;
}

- (NSArray *)regionSortedKeys
{
    NSMutableArray *keys = [[NSMutableArray alloc] initWithObjects:@"1000", @"2000", @"3000", @"4000", @"5000", @"8000", @"9000", @"10000", @"11000", @"12000", @"13000", @"14000", @"15000", @"16000", @"17000", @"18000", @"19000", @"20000", @"21000", @"22000", @"23000", @"24000", @"25000", @"26000", @"27000", @"28000", @"29000", @"30000", @"31000", @"32000", @"33000", @"34000", @"35000", @"36000", nil];
    return [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSInteger value1 = [obj1 integerValue];
        NSInteger value2 = [obj2 integerValue];
        if (value1 < value2)
            return NSOrderedAscending;
        else if (value1 == value2)
            return NSOrderedSame;
        else
            return NSOrderedDescending;
    }];
}

// 返回所有省、直辖市的所有数据
- (NSMutableDictionary *)fullCityDictionary
{
    static NSString *strFullCityJson = @"[{\"id\":1000,\"name\":\"\u5317\u4eac\",\"child\":[{\"id\":110101,\"name\":\"\u4e1c\u57ce\u533a\"},{\"id\":110102,\"name\":\"\u897f\u57ce\u533a\"},{\"id\":110103,\"name\":\"\u5d07\u6587\u533a\"},{\"id\":110104,\"name\":\"\u5ba3\u6b66\u533a\"},{\"id\":110105,\"name\":\"\u671d\u9633\u533a\"},{\"id\":110106,\"name\":\"\u4e30\u53f0\u533a\"},{\"id\":110107,\"name\":\"\u77f3\u666f\u5c71\u533a\"},{\"id\":110108,\"name\":\"\u6d77\u6dc0\u533a\"},{\"id\":110109,\"name\":\"\u95e8\u5934\u6c9f\u533a\"},{\"id\":110111,\"name\":\"\u623f\u5c71\u533a\"},{\"id\":110112,\"name\":\"\u901a\u5dde\u533a\"},{\"id\":110113,\"name\":\"\u987a\u4e49\u533a\"},{\"id\":110114,\"name\":\"\u660c\u5e73\u533a\"},{\"id\":110115,\"name\":\"\u5927\u5174\u533a\"},{\"id\":110116,\"name\":\"\u6000\u67d4\u533a\"},{\"id\":110117,\"name\":\"\u5e73\u8c37\u533a\"}]},{\"id\":2000,\"name\":\"\u4e0a\u6d77\",\"child\":[{\"id\":310101,\"name\":\"\u9ec4\u6d66\u533a\"},{\"id\":310103,\"name\":\"\u5362\u6e7e\u533a\"},{\"id\":310104,\"name\":\"\u5f90\u6c47\u533a\"},{\"id\":310105,\"name\":\"\u957f\u5b81\u533a\"},{\"id\":310106,\"name\":\"\u9759\u5b89\u533a\"},{\"id\":310107,\"name\":\"\u666e\u9640\u533a\"},{\"id\":310108,\"name\":\"\u95f8\u5317\u533a\"},{\"id\":310109,\"name\":\"\u8679\u53e3\u533a\"},{\"id\":310110,\"name\":\"\u6768\u6d66\u533a\"},{\"id\":310112,\"name\":\"\u95f5\u884c\u533a\"},{\"id\":310113,\"name\":\"\u5b9d\u5c71\u533a\"},{\"id\":310114,\"name\":\"\u5609\u5b9a\u533a\"},{\"id\":310115,\"name\":\"\u6d66\u4e1c\u65b0\u533a\"},{\"id\":310116,\"name\":\"\u91d1\u5c71\u533a\"},{\"id\":310117,\"name\":\"\u677e\u6c5f\u533a\"},{\"id\":310118,\"name\":\"\u9752\u6d66\u533a\"},{\"id\":310119,\"name\":\"\u5357\u6c47\u533a\"},{\"id\":310120,\"name\":\"\u5949\u8d24\u533a\"}]},{\"id\":3000,\"name\":\"\u5929\u6d25\",\"child\":[{\"id\":120101,\"name\":\"\u548c\u5e73\u533a\"},{\"id\":120102,\"name\":\"\u6cb3\u4e1c\u533a\"},{\"id\":120103,\"name\":\"\u6cb3\u897f\u533a\"},{\"id\":120104,\"name\":\"\u5357\u5f00\u533a\"},{\"id\":120105,\"name\":\"\u6cb3\u5317\u533a\"},{\"id\":120106,\"name\":\"\u7ea2\u6865\u533a\"},{\"id\":120107,\"name\":\"\u5858\u6cbd\u533a\"},{\"id\":120108,\"name\":\"\u6c49\u6cbd\u533a\"},{\"id\":120109,\"name\":\"\u5927\u6e2f\u533a\"},{\"id\":120110,\"name\":\"\u4e1c\u4e3d\u533a\"},{\"id\":120111,\"name\":\"\u897f\u9752\u533a\"},{\"id\":120112,\"name\":\"\u6d25\u5357\u533a\"},{\"id\":120113,\"name\":\"\u5317\u8fb0\u533a\"},{\"id\":120114,\"name\":\"\u6b66\u6e05\u533a\"},{\"id\":120115,\"name\":\"\u5b9d\u577b\u533a\"}]},{\"id\":4000,\"name\":\"\u5e7f\u4e1c\",\"child\":[{\"id\":440100,\"name\":\"\u5e7f\u5dde\u5e02\"},{\"id\":440200,\"name\":\"\u97f6\u5173\u5e02\"},{\"id\":440300,\"name\":\"\u6df1\u5733\u5e02\"},{\"id\":440400,\"name\":\"\u73e0\u6d77\u5e02\"},{\"id\":440500,\"name\":\"\u6c55\u5934\u5e02\"},{\"id\":440600,\"name\":\"\u4f5b\u5c71\u5e02\"},{\"id\":440700,\"name\":\"\u6c5f\u95e8\u5e02\"},{\"id\":440800,\"name\":\"\u6e5b\u6c5f\u5e02\"},{\"id\":440900,\"name\":\"\u8302\u540d\u5e02\"},{\"id\":441200,\"name\":\"\u8087\u5e86\u5e02\"},{\"id\":441300,\"name\":\"\u60e0\u5dde\u5e02\"},{\"id\":441400,\"name\":\"\u6885\u5dde\u5e02\"},{\"id\":441500,\"name\":\"\u6c55\u5c3e\u5e02\"},{\"id\":441600,\"name\":\"\u6cb3\u6e90\u5e02\"},{\"id\":441700,\"name\":\"\u9633\u6c5f\u5e02\"},{\"id\":441800,\"name\":\"\u6e05\u8fdc\u5e02\"},{\"id\":441900,\"name\":\"\u4e1c\u839e\u5e02\"},{\"id\":442000,\"name\":\"\u4e2d\u5c71\u5e02\"},{\"id\":445100,\"name\":\"\u6f6e\u5dde\u5e02\"},{\"id\":445200,\"name\":\"\u63ed\u9633\u5e02\"},{\"id\":445300,\"name\":\"\u4e91\u6d6e\u5e02\"}]},{\"id\":5000,\"name\":\"\u798f\u5efa\",\"child\":[{\"id\":350100,\"name\":\"\u798f\u5dde\u5e02\"},{\"id\":350200,\"name\":\"\u53a6\u95e8\u5e02\"},{\"id\":350300,\"name\":\"\u8386\u7530\u5e02\"},{\"id\":350400,\"name\":\"\u4e09\u660e\u5e02\"},{\"id\":350500,\"name\":\"\u6cc9\u5dde\u5e02\"},{\"id\":350600,\"name\":\"\u6f33\u5dde\u5e02\"},{\"id\":350700,\"name\":\"\u5357\u5e73\u5e02\"},{\"id\":350800,\"name\":\"\u9f99\u5ca9\u5e02\"},{\"id\":350900,\"name\":\"\u5b81\u5fb7\u5e02\"}]},{\"id\":8000,\"name\":\"\u6d77\u5357\",\"child\":[{\"id\":460100,\"name\":\"\u6d77\u53e3\u5e02\"},{\"id\":460200,\"name\":\"\u4e09\u4e9a\u5e02\"}]},{\"id\":9000,\"name\":\"\u5b89\u5fbd\",\"child\":[{\"id\":340100,\"name\":\"\u5408\u80a5\u5e02\"},{\"id\":340200,\"name\":\"\u829c\u6e56\u5e02\"},{\"id\":340300,\"name\":\"\u868c\u57e0\u5e02\"},{\"id\":340400,\"name\":\"\u6dee\u5357\u5e02\"},{\"id\":340500,\"name\":\"\u9a6c\u978d\u5c71\u5e02\"},{\"id\":340600,\"name\":\"\u6dee\u5317\u5e02\"},{\"id\":340700,\"name\":\"\u94dc\u9675\u5e02\"},{\"id\":340800,\"name\":\"\u5b89\u5e86\u5e02\"},{\"id\":341000,\"name\":\"\u9ec4\u5c71\u5e02\"},{\"id\":341100,\"name\":\"\u6ec1\u5dde\u5e02\"},{\"id\":341200,\"name\":\"\u961c\u9633\u5e02\"},{\"id\":341300,\"name\":\"\u5bbf\u5dde\u5e02\"},{\"id\":341400,\"name\":\"\u5de2\u6e56\u5e02\"},{\"id\":341500,\"name\":\"\u516d\u5b89\u5e02\"},{\"id\":341600,\"name\":\"\u4eb3\u5dde\u5e02\"},{\"id\":341700,\"name\":\"\u6c60\u5dde\u5e02\"},{\"id\":341800,\"name\":\"\u5ba3\u57ce\u5e02\"}]},{\"id\":10000,\"name\":\"\u8d35\u5dde\",\"child\":[{\"id\":520100,\"name\":\"\u8d35\u9633\u5e02\"},{\"id\":520200,\"name\":\"\u516d\u76d8\u6c34\u5e02\"},{\"id\":520300,\"name\":\"\u9075\u4e49\u5e02\"},{\"id\":520400,\"name\":\"\u5b89\u987a\u5e02\"},{\"id\":522200,\"name\":\"\u94dc\u4ec1\u5730\u533a\"},{\"id\":522300,\"name\":\"\u9ed4\u897f\u5357\u5e03\u4f9d\u65cf\u82d7\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":522400,\"name\":\"\u6bd5\u8282\u5730\u533a\"},{\"id\":522600,\"name\":\"\u9ed4\u4e1c\u5357\u82d7\u65cf\u4f97\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":522700,\"name\":\"\u9ed4\u5357\u5e03\u4f9d\u65cf\u82d7\u65cf\u81ea\u6cbb\u5dde\"}]},{\"id\":11000,\"name\":\"\u7518\u8083\",\"child\":[{\"id\":620100,\"name\":\"\u5170\u5dde\u5e02\"},{\"id\":620200,\"name\":\"\u5609\u5cea\u5173\u5e02\"},{\"id\":620300,\"name\":\"\u91d1\u660c\u5e02\"},{\"id\":620400,\"name\":\"\u767d\u94f6\u5e02\"},{\"id\":620500,\"name\":\"\u5929\u6c34\u5e02\"},{\"id\":620600,\"name\":\"\u6b66\u5a01\u5e02\"},{\"id\":620700,\"name\":\"\u5f20\u6396\u5e02\"},{\"id\":620800,\"name\":\"\u5e73\u51c9\u5e02\"},{\"id\":620900,\"name\":\"\u9152\u6cc9\u5e02\"},{\"id\":621000,\"name\":\"\u5e86\u9633\u5e02\"},{\"id\":621100,\"name\":\"\u5b9a\u897f\u5e02\"},{\"id\":621200,\"name\":\"\u9647\u5357\u5e02\"},{\"id\":622900,\"name\":\"\u4e34\u590f\u56de\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":623000,\"name\":\"\u7518\u5357\u85cf\u65cf\u81ea\u6cbb\u5dde\"}]},{\"id\":12000,\"name\":\"\u5e7f\u897f\",\"child\":[{\"id\":450100,\"name\":\"\u5357\u5b81\u5e02\"},{\"id\":450200,\"name\":\"\u67f3\u5dde\u5e02\"},{\"id\":450300,\"name\":\"\u6842\u6797\u5e02\"},{\"id\":450400,\"name\":\"\u68a7\u5dde\u5e02\"},{\"id\":450500,\"name\":\"\u5317\u6d77\u5e02\"},{\"id\":450600,\"name\":\"\u9632\u57ce\u6e2f\u5e02\"},{\"id\":450700,\"name\":\"\u94a6\u5dde\u5e02\"},{\"id\":450800,\"name\":\"\u8d35\u6e2f\u5e02\"},{\"id\":450900,\"name\":\"\u7389\u6797\u5e02\"},{\"id\":451000,\"name\":\"\u767e\u8272\u5e02\"},{\"id\":451100,\"name\":\"\u8d3a\u5dde\u5e02\"},{\"id\":451200,\"name\":\"\u6cb3\u6c60\u5e02\"},{\"id\":451300,\"name\":\"\u6765\u5bbe\u5e02\"},{\"id\":451400,\"name\":\"\u5d07\u5de6\u5e02\"}]},{\"id\":13000,\"name\":\"\u6cb3\u5317\",\"child\":[{\"id\":130100,\"name\":\"\u77f3\u5bb6\u5e84\u5e02\"},{\"id\":130200,\"name\":\"\u5510\u5c71\u5e02\"},{\"id\":130300,\"name\":\"\u79e6\u7687\u5c9b\u5e02\"},{\"id\":130400,\"name\":\"\u90af\u90f8\u5e02\"},{\"id\":130500,\"name\":\"\u90a2\u53f0\u5e02\"},{\"id\":130600,\"name\":\"\u4fdd\u5b9a\u5e02\"},{\"id\":130700,\"name\":\"\u5f20\u5bb6\u53e3\u5e02\"},{\"id\":130800,\"name\":\"\u627f\u5fb7\u5e02\"},{\"id\":130900,\"name\":\"\u6ca7\u5dde\u5e02\"},{\"id\":131000,\"name\":\"\u5eca\u574a\u5e02\"},{\"id\":131100,\"name\":\"\u8861\u6c34\u5e02\"}]},{\"id\":14000,\"name\":\"\u6cb3\u5357\",\"child\":[{\"id\":410100,\"name\":\"\u90d1\u5dde\u5e02\"},{\"id\":410200,\"name\":\"\u5f00\u5c01\u5e02\"},{\"id\":410300,\"name\":\"\u6d1b\u9633\u5e02\"},{\"id\":410400,\"name\":\"\u5e73\u9876\u5c71\u5e02\"},{\"id\":410500,\"name\":\"\u5b89\u9633\u5e02\"},{\"id\":410600,\"name\":\"\u9e64\u58c1\u5e02\"},{\"id\":410700,\"name\":\"\u65b0\u4e61\u5e02\"},{\"id\":410800,\"name\":\"\u7126\u4f5c\u5e02\"},{\"id\":410900,\"name\":\"\u6fee\u9633\u5e02\"},{\"id\":411000,\"name\":\"\u8bb8\u660c\u5e02\"},{\"id\":411100,\"name\":\"\u6f2f\u6cb3\u5e02\"},{\"id\":411200,\"name\":\"\u4e09\u95e8\u5ce1\u5e02\"},{\"id\":411300,\"name\":\"\u5357\u9633\u5e02\"},{\"id\":411400,\"name\":\"\u5546\u4e18\u5e02\"},{\"id\":411500,\"name\":\"\u4fe1\u9633\u5e02\"},{\"id\":411600,\"name\":\"\u5468\u53e3\u5e02\"},{\"id\":411700,\"name\":\"\u9a7b\u9a6c\u5e97\u5e02\"}]},{\"id\":15000,\"name\":\"\u9ed1\u9f99\u6c5f\",\"child\":[{\"id\":230100,\"name\":\"\u54c8\u5c14\u6ee8\u5e02\"},{\"id\":230200,\"name\":\"\u9f50\u9f50\u54c8\u5c14\u5e02\"},{\"id\":230300,\"name\":\"\u9e21\u897f\u5e02\"},{\"id\":230400,\"name\":\"\u9e64\u5c97\u5e02\"},{\"id\":230500,\"name\":\"\u53cc\u9e2d\u5c71\u5e02\"},{\"id\":230600,\"name\":\"\u5927\u5e86\u5e02\"},{\"id\":230700,\"name\":\"\u4f0a\u6625\u5e02\"},{\"id\":230800,\"name\":\"\u4f73\u6728\u65af\u5e02\"},{\"id\":230900,\"name\":\"\u4e03\u53f0\u6cb3\u5e02\"},{\"id\":231000,\"name\":\"\u7261\u4e39\u6c5f\u5e02\"},{\"id\":231100,\"name\":\"\u9ed1\u6cb3\u5e02\"},{\"id\":231200,\"name\":\"\u7ee5\u5316\u5e02\"},{\"id\":232700,\"name\":\"\u5927\u5174\u5b89\u5cad\u5730\u533a\"}]},{\"id\":16000,\"name\":\"\u6e56\u5317\",\"child\":[{\"id\":420100,\"name\":\"\u6b66\u6c49\u5e02\"},{\"id\":420200,\"name\":\"\u9ec4\u77f3\u5e02\"},{\"id\":420300,\"name\":\"\u5341\u5830\u5e02\"},{\"id\":420500,\"name\":\"\u5b9c\u660c\u5e02\"},{\"id\":420600,\"name\":\"\u8944\u6a0a\u5e02\"},{\"id\":420700,\"name\":\"\u9102\u5dde\u5e02\"},{\"id\":420800,\"name\":\"\u8346\u95e8\u5e02\"},{\"id\":420900,\"name\":\"\u5b5d\u611f\u5e02\"},{\"id\":421000,\"name\":\"\u8346\u5dde\u5e02\"},{\"id\":421100,\"name\":\"\u9ec4\u5188\u5e02\"},{\"id\":421200,\"name\":\"\u54b8\u5b81\u5e02\"},{\"id\":421300,\"name\":\"\u968f\u5dde\u5e02\"},{\"id\":422800,\"name\":\"\u6069\u65bd\u571f\u5bb6\u65cf\u82d7\u65cf\u81ea\u6cbb\u5dde\"}]},{\"id\":17000,\"name\":\"\u6e56\u5357\",\"child\":[{\"id\":430100,\"name\":\"\u957f\u6c99\u5e02\"},{\"id\":430200,\"name\":\"\u682a\u6d32\u5e02\"},{\"id\":430300,\"name\":\"\u6e58\u6f6d\u5e02\"},{\"id\":430400,\"name\":\"\u8861\u9633\u5e02\"},{\"id\":430500,\"name\":\"\u90b5\u9633\u5e02\"},{\"id\":430600,\"name\":\"\u5cb3\u9633\u5e02\"},{\"id\":430700,\"name\":\"\u5e38\u5fb7\u5e02\"},{\"id\":430800,\"name\":\"\u5f20\u5bb6\u754c\u5e02\"},{\"id\":430900,\"name\":\"\u76ca\u9633\u5e02\"},{\"id\":431000,\"name\":\"\u90f4\u5dde\u5e02\"},{\"id\":431100,\"name\":\"\u6c38\u5dde\u5e02\"},{\"id\":431200,\"name\":\"\u6000\u5316\u5e02\"},{\"id\":431300,\"name\":\"\u5a04\u5e95\u5e02\"},{\"id\":433100,\"name\":\"\u6e58\u897f\u571f\u5bb6\u65cf\u82d7\u65cf\u81ea\u6cbb\u5dde\"}]},{\"id\":18000,\"name\":\"\u5409\u6797\",\"child\":[{\"id\":220100,\"name\":\"\u957f\u6625\u5e02\"},{\"id\":220200,\"name\":\"\u5409\u6797\u5e02\"},{\"id\":220300,\"name\":\"\u56db\u5e73\u5e02\"},{\"id\":220400,\"name\":\"\u8fbd\u6e90\u5e02\"},{\"id\":220500,\"name\":\"\u901a\u5316\u5e02\"},{\"id\":220600,\"name\":\"\u767d\u5c71\u5e02\"},{\"id\":220700,\"name\":\"\u677e\u539f\u5e02\"},{\"id\":220800,\"name\":\"\u767d\u57ce\u5e02\"},{\"id\":222400,\"name\":\"\u5ef6\u8fb9\u671d\u9c9c\u65cf\u81ea\u6cbb\u5dde\"}]},{\"id\":19000,\"name\":\"\u6c5f\u82cf\",\"child\":[{\"id\":320100,\"name\":\"\u5357\u4eac\u5e02\"},{\"id\":320200,\"name\":\"\u65e0\u9521\u5e02\"},{\"id\":320300,\"name\":\"\u5f90\u5dde\u5e02\"},{\"id\":320400,\"name\":\"\u5e38\u5dde\u5e02\"},{\"id\":320500,\"name\":\"\u82cf\u5dde\u5e02\"},{\"id\":320600,\"name\":\"\u5357\u901a\u5e02\"},{\"id\":320700,\"name\":\"\u8fde\u4e91\u6e2f\u5e02\"},{\"id\":320800,\"name\":\"\u6dee\u5b89\u5e02\"},{\"id\":320900,\"name\":\"\u76d0\u57ce\u5e02\"},{\"id\":321000,\"name\":\"\u626c\u5dde\u5e02\"},{\"id\":321100,\"name\":\"\u9547\u6c5f\u5e02\"},{\"id\":321200,\"name\":\"\u6cf0\u5dde\u5e02\"},{\"id\":321300,\"name\":\"\u5bbf\u8fc1\u5e02\"}]},{\"id\":20000,\"name\":\"\u6c5f\u897f\",\"child\":[{\"id\":360100,\"name\":\"\u5357\u660c\u5e02\"},{\"id\":360200,\"name\":\"\u666f\u5fb7\u9547\u5e02\"},{\"id\":360300,\"name\":\"\u840d\u4e61\u5e02\"},{\"id\":360400,\"name\":\"\u4e5d\u6c5f\u5e02\"},{\"id\":360500,\"name\":\"\u65b0\u4f59\u5e02\"},{\"id\":360600,\"name\":\"\u9e70\u6f6d\u5e02\"},{\"id\":360700,\"name\":\"\u8d63\u5dde\u5e02\"},{\"id\":360800,\"name\":\"\u5409\u5b89\u5e02\"},{\"id\":360900,\"name\":\"\u5b9c\u6625\u5e02\"},{\"id\":361000,\"name\":\"\u629a\u5dde\u5e02\"},{\"id\":361100,\"name\":\"\u4e0a\u9976\u5e02\"}]},{\"id\":21000,\"name\":\"\u8fbd\u5b81\",\"child\":[{\"id\":210100,\"name\":\"\u6c88\u9633\u5e02\"},{\"id\":210200,\"name\":\"\u5927\u8fde\u5e02\"},{\"id\":210300,\"name\":\"\u978d\u5c71\u5e02\"},{\"id\":210400,\"name\":\"\u629a\u987a\u5e02\"},{\"id\":210500,\"name\":\"\u672c\u6eaa\u5e02\"},{\"id\":210600,\"name\":\"\u4e39\u4e1c\u5e02\"},{\"id\":210700,\"name\":\"\u9526\u5dde\u5e02\"},{\"id\":210800,\"name\":\"\u8425\u53e3\u5e02\"},{\"id\":210900,\"name\":\"\u961c\u65b0\u5e02\"},{\"id\":211000,\"name\":\"\u8fbd\u9633\u5e02\"},{\"id\":211100,\"name\":\"\u76d8\u9526\u5e02\"},{\"id\":211200,\"name\":\"\u94c1\u5cad\u5e02\"},{\"id\":211300,\"name\":\"\u671d\u9633\u5e02\"},{\"id\":211400,\"name\":\"\u846b\u82a6\u5c9b\u5e02\"}]},{\"id\":22000,\"name\":\"\u5185\u8499\u53e4\",\"child\":[{\"id\":150100,\"name\":\"\u547c\u548c\u6d69\u7279\u5e02\"},{\"id\":150200,\"name\":\"\u5305\u5934\u5e02\"},{\"id\":150300,\"name\":\"\u4e4c\u6d77\u5e02\"},{\"id\":150400,\"name\":\"\u8d64\u5cf0\u5e02\"},{\"id\":150500,\"name\":\"\u901a\u8fbd\u5e02\"},{\"id\":150600,\"name\":\"\u9102\u5c14\u591a\u65af\u5e02\"},{\"id\":150700,\"name\":\"\u547c\u4f26\u8d1d\u5c14\u5e02\"},{\"id\":150800,\"name\":\"\u5df4\u5f66\u6dd6\u5c14\u5e02\"},{\"id\":150900,\"name\":\"\u4e4c\u5170\u5bdf\u5e03\u5e02\"},{\"id\":152200,\"name\":\"\u5174\u5b89\u76df\"},{\"id\":152500,\"name\":\"\u9521\u6797\u90ed\u52d2\u76df\"},{\"id\":152900,\"name\":\"\u963f\u62c9\u5584\u76df\"}]},{\"id\":23000,\"name\":\"\u5b81\u590f\",\"child\":[{\"id\":640100,\"name\":\"\u94f6\u5ddd\u5e02\"},{\"id\":640200,\"name\":\"\u77f3\u5634\u5c71\u5e02\"},{\"id\":640300,\"name\":\"\u5434\u5fe0\u5e02\"},{\"id\":640400,\"name\":\"\u56fa\u539f\u5e02\"},{\"id\":640500,\"name\":\"\u4e2d\u536b\u5e02\"}]},{\"id\":24000,\"name\":\"\u9752\u6d77\",\"child\":[{\"id\":630100,\"name\":\"\u897f\u5b81\u5e02\"},{\"id\":632100,\"name\":\"\u6d77\u4e1c\u5730\u533a\"},{\"id\":632200,\"name\":\"\u6d77\u5317\u85cf\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":632300,\"name\":\"\u9ec4\u5357\u85cf\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":632500,\"name\":\"\u6d77\u5357\u85cf\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":632600,\"name\":\"\u679c\u6d1b\u85cf\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":632700,\"name\":\"\u7389\u6811\u85cf\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":632800,\"name\":\"\u6d77\u897f\u8499\u53e4\u65cf\u85cf\u65cf\u81ea\u6cbb\u5dde\"}]},{\"id\":25000,\"name\":\"\u5c71\u4e1c\",\"child\":[{\"id\":370100,\"name\":\"\u6d4e\u5357\u5e02\"},{\"id\":370200,\"name\":\"\u9752\u5c9b\u5e02\"},{\"id\":370300,\"name\":\"\u6dc4\u535a\u5e02\"},{\"id\":370400,\"name\":\"\u67a3\u5e84\u5e02\"},{\"id\":370500,\"name\":\"\u4e1c\u8425\u5e02\"},{\"id\":370600,\"name\":\"\u70df\u53f0\u5e02\"},{\"id\":370700,\"name\":\"\u6f4d\u574a\u5e02\"},{\"id\":370800,\"name\":\"\u6d4e\u5b81\u5e02\"},{\"id\":370900,\"name\":\"\u6cf0\u5b89\u5e02\"},{\"id\":371000,\"name\":\"\u5a01\u6d77\u5e02\"},{\"id\":371100,\"name\":\"\u65e5\u7167\u5e02\"},{\"id\":371200,\"name\":\"\u83b1\u829c\u5e02\"},{\"id\":371300,\"name\":\"\u4e34\u6c82\u5e02\"},{\"id\":371400,\"name\":\"\u5fb7\u5dde\u5e02\"},{\"id\":371500,\"name\":\"\u804a\u57ce\u5e02\"},{\"id\":371600,\"name\":\"\u6ee8\u5dde\u5e02\"},{\"id\":371700,\"name\":\"\u8377\u6cfd\u5e02\"}]},{\"id\":26000,\"name\":\"\u5c71\u897f\",\"child\":[{\"id\":140100,\"name\":\"\u592a\u539f\u5e02\"},{\"id\":140200,\"name\":\"\u5927\u540c\u5e02\"},{\"id\":140300,\"name\":\"\u9633\u6cc9\u5e02\"},{\"id\":140400,\"name\":\"\u957f\u6cbb\u5e02\"},{\"id\":140500,\"name\":\"\u664b\u57ce\u5e02\"},{\"id\":140600,\"name\":\"\u6714\u5dde\u5e02\"},{\"id\":140700,\"name\":\"\u664b\u4e2d\u5e02\"},{\"id\":140800,\"name\":\"\u8fd0\u57ce\u5e02\"},{\"id\":140900,\"name\":\"\u5ffb\u5dde\u5e02\"},{\"id\":141000,\"name\":\"\u4e34\u6c7e\u5e02\"},{\"id\":141100,\"name\":\"\u5415\u6881\u5e02\"}]},{\"id\":27000,\"name\":\"\u9655\u897f\",\"child\":[{\"id\":610100,\"name\":\"\u897f\u5b89\u5e02\"},{\"id\":610200,\"name\":\"\u94dc\u5ddd\u5e02\"},{\"id\":610300,\"name\":\"\u5b9d\u9e21\u5e02\"},{\"id\":610400,\"name\":\"\u54b8\u9633\u5e02\"},{\"id\":610500,\"name\":\"\u6e2d\u5357\u5e02\"},{\"id\":610600,\"name\":\"\u5ef6\u5b89\u5e02\"},{\"id\":610700,\"name\":\"\u6c49\u4e2d\u5e02\"},{\"id\":610800,\"name\":\"\u6986\u6797\u5e02\"},{\"id\":610900,\"name\":\"\u5b89\u5eb7\u5e02\"},{\"id\":611000,\"name\":\"\u5546\u6d1b\u5e02\"}]},{\"id\":28000,\"name\":\"\u56db\u5ddd\",\"child\":[{\"id\":510100,\"name\":\"\u6210\u90fd\u5e02\"},{\"id\":510300,\"name\":\"\u81ea\u8d21\u5e02\"},{\"id\":510400,\"name\":\"\u6500\u679d\u82b1\u5e02\"},{\"id\":510500,\"name\":\"\u6cf8\u5dde\u5e02\"},{\"id\":510600,\"name\":\"\u5fb7\u9633\u5e02\"},{\"id\":510700,\"name\":\"\u7ef5\u9633\u5e02\"},{\"id\":510800,\"name\":\"\u5e7f\u5143\u5e02\"},{\"id\":510900,\"name\":\"\u9042\u5b81\u5e02\"},{\"id\":511000,\"name\":\"\u5185\u6c5f\u5e02\"},{\"id\":511100,\"name\":\"\u4e50\u5c71\u5e02\"},{\"id\":511300,\"name\":\"\u5357\u5145\u5e02\"},{\"id\":511400,\"name\":\"\u7709\u5c71\u5e02\"},{\"id\":511500,\"name\":\"\u5b9c\u5bbe\u5e02\"},{\"id\":511600,\"name\":\"\u5e7f\u5b89\u5e02\"},{\"id\":511700,\"name\":\"\u8fbe\u5dde\u5e02\"},{\"id\":511800,\"name\":\"\u96c5\u5b89\u5e02\"},{\"id\":511900,\"name\":\"\u5df4\u4e2d\u5e02\"},{\"id\":512000,\"name\":\"\u8d44\u9633\u5e02\"},{\"id\":513200,\"name\":\"\u963f\u575d\u85cf\u65cf\u7f8c\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":513300,\"name\":\"\u7518\u5b5c\u85cf\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":513400,\"name\":\"\u51c9\u5c71\u5f5d\u65cf\u81ea\u6cbb\u5dde\"}]},{\"id\":29000,\"name\":\"\u897f\u85cf\",\"child\":[{\"id\":540100,\"name\":\"\u62c9\u8428\u5e02\"},{\"id\":542100,\"name\":\"\u660c\u90fd\u5730\u533a\"},{\"id\":542200,\"name\":\"\u5c71\u5357\u5730\u533a\"},{\"id\":542300,\"name\":\"\u65e5\u5580\u5219\u5730\u533a\"},{\"id\":542400,\"name\":\"\u90a3\u66f2\u5730\u533a\"},{\"id\":542500,\"name\":\"\u963f\u91cc\u5730\u533a\"},{\"id\":542600,\"name\":\"\u6797\u829d\u5730\u533a\"}]},{\"id\":30000,\"name\":\"\u65b0\u7586\",\"child\":[{\"id\":650100,\"name\":\"\u4e4c\u9c81\u6728\u9f50\u5e02\"},{\"id\":650200,\"name\":\"\u514b\u62c9\u739b\u4f9d\u5e02\"},{\"id\":652100,\"name\":\"\u5410\u9c81\u756a\u5730\u533a\"},{\"id\":652200,\"name\":\"\u54c8\u5bc6\u5730\u533a\"},{\"id\":652300,\"name\":\"\u660c\u5409\u56de\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":652700,\"name\":\"\u535a\u5c14\u5854\u62c9\u8499\u53e4\u81ea\u6cbb\u5dde\"},{\"id\":652800,\"name\":\"\u5df4\u97f3\u90ed\u695e\u8499\u53e4\u81ea\u6cbb\u5dde\"},{\"id\":652900,\"name\":\"\u963f\u514b\u82cf\u5730\u533a\"},{\"id\":653000,\"name\":\"\u514b\u5b5c\u52d2\u82cf\u67ef\u5c14\u514b\u5b5c\u81ea\u6cbb\u5dde\"},{\"id\":653100,\"name\":\"\u5580\u4ec0\u5730\u533a\"},{\"id\":653200,\"name\":\"\u548c\u7530\u5730\u533a\"},{\"id\":654000,\"name\":\"\u4f0a\u7281\u54c8\u8428\u514b\u81ea\u6cbb\u5dde\"},{\"id\":654200,\"name\":\"\u5854\u57ce\u5730\u533a\"},{\"id\":654300,\"name\":\"\u963f\u52d2\u6cf0\u5730\u533a\"}]},{\"id\":31000,\"name\":\"\u4e91\u5357\",\"child\":[{\"id\":530100,\"name\":\"\u6606\u660e\u5e02\"},{\"id\":530300,\"name\":\"\u66f2\u9756\u5e02\"},{\"id\":530400,\"name\":\"\u7389\u6eaa\u5e02\"},{\"id\":530500,\"name\":\"\u4fdd\u5c71\u5e02\"},{\"id\":530600,\"name\":\"\u662d\u901a\u5e02\"},{\"id\":530700,\"name\":\"\u4e3d\u6c5f\u5e02\"},{\"id\":530800,\"name\":\"\u601d\u8305\u5e02\"},{\"id\":530900,\"name\":\"\u4e34\u6ca7\u5e02\"},{\"id\":532300,\"name\":\"\u695a\u96c4\u5f5d\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":532500,\"name\":\"\u7ea2\u6cb3\u54c8\u5c3c\u65cf\u5f5d\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":532600,\"name\":\"\u6587\u5c71\u58ee\u65cf\u82d7\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":532800,\"name\":\"\u897f\u53cc\u7248\u7eb3\u50a3\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":532900,\"name\":\"\u5927\u7406\u767d\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":533100,\"name\":\"\u5fb7\u5b8f\u50a3\u65cf\u666f\u9887\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":533300,\"name\":\"\u6012\u6c5f\u5088\u50f3\u65cf\u81ea\u6cbb\u5dde\"},{\"id\":533400,\"name\":\"\u8fea\u5e86\u85cf\u65cf\u81ea\u6cbb\u5dde\"}]},{\"id\":32000,\"name\":\"\u6d59\u6c5f\",\"child\":[{\"id\":330100,\"name\":\"\u676d\u5dde\u5e02\"},{\"id\":330200,\"name\":\"\u5b81\u6ce2\u5e02\"},{\"id\":330300,\"name\":\"\u6e29\u5dde\u5e02\"},{\"id\":330400,\"name\":\"\u5609\u5174\u5e02\"},{\"id\":330500,\"name\":\"\u6e56\u5dde\u5e02\"},{\"id\":330600,\"name\":\"\u7ecd\u5174\u5e02\"},{\"id\":330700,\"name\":\"\u91d1\u534e\u5e02\"},{\"id\":330800,\"name\":\"\u8862\u5dde\u5e02\"},{\"id\":330900,\"name\":\"\u821f\u5c71\u5e02\"},{\"id\":331000,\"name\":\"\u53f0\u5dde\u5e02\"},{\"id\":331100,\"name\":\"\u4e3d\u6c34\u5e02\"}]},{\"id\":33000,\"name\":\"\u91cd\u5e86\",\"child\":[{\"id\":500101,\"name\":\"\u4e07\u5dde\u533a\"},{\"id\":500102,\"name\":\"\u6daa\u9675\u533a\"},{\"id\":500103,\"name\":\"\u6e1d\u4e2d\u533a\"},{\"id\":500104,\"name\":\"\u5927\u6e21\u53e3\u533a\"},{\"id\":500105,\"name\":\"\u6c5f\u5317\u533a\"},{\"id\":500106,\"name\":\"\u6c99\u576a\u575d\u533a\"},{\"id\":500107,\"name\":\"\u4e5d\u9f99\u5761\u533a\"},{\"id\":500108,\"name\":\"\u5357\u5cb8\u533a\"},{\"id\":500109,\"name\":\"\u5317\u789a\u533a\"},{\"id\":500110,\"name\":\"\u4e07\u76db\u533a\"},{\"id\":500111,\"name\":\"\u53cc\u6865\u533a\"},{\"id\":500112,\"name\":\"\u6e1d\u5317\u533a\"},{\"id\":500113,\"name\":\"\u5df4\u5357\u533a\"},{\"id\":500114,\"name\":\"\u9ed4\u6c5f\u533a\"},{\"id\":500115,\"name\":\"\u957f\u5bff\u533a\"}]},{\"id\":34000,\"name\":\"\u9999\u6e2f\",\"child\":[{\"id\":811100,\"name\":\"\u6cb9\u5c16\u65fa\"},{\"id\":811200,\"name\":\"\u9ec4\u5927\u4ed9\"},{\"id\":811300,\"name\":\"\u6df1\u6c34\u57d7\"},{\"id\":811400,\"name\":\"\u89c2\u5858\"},{\"id\":811500,\"name\":\"\u4e5d\u9f99\u57ce\"},{\"id\":811600,\"name\":\"\u6e7e\u4ed4\"},{\"id\":811700,\"name\":\"\u8475\u9752\"},{\"id\":811800,\"name\":\"\u79bb\u5c9b\"},{\"id\":811900,\"name\":\"\u4e2d\u897f\"},{\"id\":812000,\"name\":\"\u5357\"},{\"id\":812100,\"name\":\"\u4e1c\"},{\"id\":812200,\"name\":\"\u8343\u6e7e\"},{\"id\":812300,\"name\":\"\u5143\u6717\"},{\"id\":812400,\"name\":\"\u6c99\u7530\"},{\"id\":812500,\"name\":\"\u897f\u8d21\"},{\"id\":812600,\"name\":\"\u5c6f\u95e8\"},{\"id\":812700,\"name\":\"\u5927\u57d4\"},{\"id\":812800,\"name\":\"\u5317\"}]},{\"id\":35000,\"name\":\"\u53f0\u6e7e\",\"child\":[{\"id\":710100,\"name\":\"\u53f0\u5317\u5e02\"},{\"id\":710200,\"name\":\"\u65b0\u5317\u5e02\"},{\"id\":710300,\"name\":\"\u53f0\u4e2d\u5e02\"},{\"id\":710400,\"name\":\"\u53f0\u5357\u5e02\"},{\"id\":710500,\"name\":\"\u9ad8\u96c4\u5e02\"},{\"id\":710600,\"name\":\"\u57fa\u9686\u5e02\"},{\"id\":710700,\"name\":\"\u65b0\u7af9\u5e02\"},{\"id\":710800,\"name\":\"\u5609\u4e49\u5e02\"},{\"id\":710900,\"name\":\"\u6843\u56ed\u53bf\"},{\"id\":711000,\"name\":\"\u65b0\u7af9\u53bf\"},{\"id\":711100,\"name\":\"\u82d7\u6817\u53bf\"},{\"id\":711200,\"name\":\"\u5f70\u5316\u53bf\"},{\"id\":711300,\"name\":\"\u5357\u6295\u53bf\"},{\"id\":711400,\"name\":\"\u4e91\u6797\u53bf\"},{\"id\":711500,\"name\":\"\u5609\u4e49\u53bf\"},{\"id\":711600,\"name\":\"\u5c4f\u4e1c\u53bf\"},{\"id\":711700,\"name\":\"\u5b9c\u5170\u53bf\"},{\"id\":711800,\"name\":\"\u82b1\u83b2\u53bf\"},{\"id\":711900,\"name\":\"\u53f0\u4e1c\u53bf\"},{\"id\":712000,\"name\":\"\u6f8e\u6e56\u53bf\"}]},{\"id\":36000,\"name\":\"\u6fb3\u95e8\",\"child\":[{\"id\":821100,\"name\":\"\u82b1\u5730\u739b\u5802\"},{\"id\":821200,\"name\":\"\u5723\u5b89\u591a\u5c3c\u5802\"},{\"id\":821300,\"name\":\"\u5927\u5802\"},{\"id\":821400,\"name\":\"\u671b\u5fb7\u5802\"},{\"id\":821500,\"name\":\"\u98ce\u987a\u5802\"},{\"id\":821600,\"name\":\"\u5609\u6a21\u5802\"},{\"id\":821700,\"name\":\"\u5723\u65b9\u6d4e\u5404\u5802\"}]}]";
    
    if (!_fullCityDictionary) {
        _fullCityDictionary = [[NSMutableDictionary alloc] init];
        NSArray *cityArray = (NSArray *)parseJsonString(strFullCityJson);
        for (NSDictionary *regionCities in cityArray) {
            NSNumber *regionID = [regionCities objectForKey:@"id"];
            NSArray *cities = [regionCities objectForKey:@"child"];
            [_fullCityDictionary setObject:cities forKey:regionID];
        }
    }
    
    return _fullCityDictionary;
}

// 返回指定省、直辖市的下辖市区数组
- (NSArray *)cityArrayWithRegionID:(NSInteger)regionID
{
    NSDictionary *fullCityDict = [self fullCityDictionary];
    NSArray *allKeys = [fullCityDict allKeys];
    for (NSNumber *key in allKeys) {
        if (regionID == [key integerValue]) {
            NSLog(@"secondColumn: for firstID: %ld, %@", (long)regionID, [fullCityDict objectForKey:key]);
            return [fullCityDict objectForKey:key];
        }
    }
    
    return nil;
}

- (void)updateUserRegion:(NSNumber *)regionID
{
    if (!regionID || regionID.integerValue <= 0) {
        return;
    }
    
    _userRegion = regionID.integerValue;
    [[NSUserDefaults standardUserDefaults] setObject:regionID forKey:USER_REGION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateUserCity:(NSNumber *)cityID andCityName:(NSString *)cityName
{
    if (!cityID || [cityID integerValue] <= 0) {
        return;
    }
    
    _userCity = cityID.integerValue;
    _userCityName = cityName;
    [[NSUserDefaults standardUserDefaults] setObject:cityID forKey:USER_CITY];
    [[NSUserDefaults standardUserDefaults] setObject:_userCityName forKey:USER_CITY_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber *)regionIDWithRegionName:(NSString *)regionName
{
    NSDictionary *regions = [self regionDictionaryForUser];
    NSArray *keys = regions.allKeys;
    for (NSString *key in keys) {
        if ([[regions objectForKey:key] isEqualToString:regionName]) {
            return [[NSNumber alloc] initWithInteger:key.integerValue];
        }
    }
    
    return [[NSNumber alloc] initWithInt:0];
}

- (NSString *)regionWithRegionID:(NSInteger)regionID
{
    NSDictionary *regions = [self regionDictionaryForUser];
    NSArray *keys = [regions allKeys];
    for (NSString *key in keys) {
        if (key.integerValue == regionID) {
            return [regions objectForKey:key];
        }
    }
    
    return @"";
}

- (JSONDecoder *)jsonDecoder
{
    if (!_jsonDecoder) {
        _jsonDecoder = [[JSONDecoder alloc] init];
    }
    
    return _jsonDecoder;
}

- (void)updateUnreadMsgCount
{
    if (!_canUpdateUnread) {
        return;
    }
    
    // 更新
    _canUpdateUnread = false;
    
    [self performSelectorInBackground:@selector(threadGetUnreadMsgCount) withObject:nil];
}

- (void)threadGetUnreadMsgCount
{
    @autoreleasepool {
        // 初始化首次使用信息
        NSNumber *hasFirstUsed = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_FIRST_USED];
        if (!hasFirstUsed || hasFirstUsed.integerValue != 1) {
            NSNumber *hasSentLocationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_SENT_LOCATIONINFO];
            // 开始定位并发送用户位置
            if (!hasSentLocationInfo || hasSentLocationInfo.integerValue != 1) {
                // 标记还未定位
                [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithInt:0] forKey:HAS_SENT_LOCATIONINFO];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //                // 开始定位
                //                [[CureMeUtils defaultCureMeUtil] startLocationing];
            }
            
            // 发送首次使用App请求
            // MCC  MNC  LAC  CID
            // 2013-11-22 获得一次基站信息
            
            NSString *post = [[NSString alloc] initWithFormat:@"action=jihuo&macaddr=%@", self.UDID];
            NSData *response = sendRequest(@"m.php", post);
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"action=jihuo resp: %@", strResp);
            
            NSDictionary *jsonData = parseJsonResponse(response);
            NSNumber *result = [jsonData objectForKey:@"result"];
            if (!result || result.integerValue != 1) {
                NSLog(@"action=jihuo req failed: %@", strResp);
            }
            else {
                NSString *uniqueID = [jsonData objectForKey:@"msg"];
                NSLog(@"uniqueID: %@", uniqueID);
                _uniID = uniqueID;
                [[NSUserDefaults standardUserDefaults] setObject:uniqueID forKey:USER_UNIQUE_ID];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:HAS_FIRST_USED];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // 如果已经获得设备Push Token则发送更新Token请求
                updateIOSPushInfo();
                
                //                // 提交用户位置信息
                //                [[CureMeUtils defaultCureMeUtil] sendUserLocationInfo];
            }
        }
        
        //登录对话服务
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [HiChat login:[NSString stringWithFormat:@"%ld",[CureMeUtils defaultCureMeUtil].userID] withPassword:@"" completion:^(NSError *error){
                if (error) {
                    NSLog(@"%@",error);
                }
                
                NSData *deviceToken = [NSData dataWithData:[[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN_NSDATA]];
                if (!deviceToken) {
                    NSLog(@"push token is nil fail to submit");
                }
                else{
                    [HiChat submitDeviceToken:deviceToken];
                }
                
            }];
            
            //            NSData *deviceToken = [NSData dataWithData:[[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN_NSDATA]];
            //            if (!deviceToken) {
            //                NSLog(@"push token is nil fail to submit");
            //            }
            //            else{
            //                [HiChat submitDeviceToken:deviceToken];
            //            }
        });
        
        // 如果未登录，则不获取
        if (!_hasLogin) {
            _canUpdateUnread = true;
            return;
        }
        
        NSString *post = [[NSString alloc] initWithFormat:@"action=unreadcount&userid=%ld", (long)_userID];
        NSData *response = sendRequest(@"m.php", post);
        
        //        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        //        NSLog(@"unreadCount: %@", strResp);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSLog(@"action=unreadcount result invalid %@", jsonData);
            _canUpdateUnread = true;
            return;
        }
        
        NSDictionary *unreadData = [jsonData objectForKey:@"msg"];
        if (unreadData && unreadData.count > 0) {
            NSNumber *unreadChatIDCount = [unreadData objectForKey:@"channelcount"];
            _unreadMessageCount = unreadChatIDCount.integerValue;
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NTF_UNREADMSGCOUNT_UPDATED object:nil]];
        }
        _canUpdateUnread = true;
    }
}

- (UIImage *)resizeImageWithConstraint:(UIImage *)oriImage andMaxSize:(float)maxSize
{
    @autoreleasepool {
        if (!oriImage)
            return nil;
        
        if (oriImage.size.width <= maxSize && oriImage.size.height <= maxSize) {
            UIImage *newImage = [[UIImage alloc] initWithData:UIImageJPEGRepresentation(oriImage, 1.0)];
            return newImage;
        }
        
        float scale = 0;
        if (oriImage.size.height > oriImage.size.width)
            scale = maxSize / oriImage.size.height;
        else
            scale = maxSize / oriImage.size.width;
        
        CGSize newSize = CGSizeMake(oriImage.size.width * scale, oriImage.size.height * scale);
        
        UIGraphicsBeginImageContext(newSize);
        [oriImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}

- (UIImage *)queryListSeparatorLineImage
{
    if (!_queryListSeparatorLineImage) {
        _queryListSeparatorLineImage = [UIImage imageNamed:@"xuxian_b.png"];
    }
    
    return _queryListSeparatorLineImage;
}


- (void)setCityCode:(NSInteger)cityCode
{
    _cityCode = cityCode;
}

- (NSInteger)cityCode
{
    if (_cityCode <= 0) {
        NSNumber *regionID = [self regionIDWithRegionName:_province];
        if (regionID)
            _cityCode = regionID.integerValue;
    }
    
    return _cityCode;
}

- (NSString *)getTimeSpanFromNow:(NSDate *)msgTime
{
    @autoreleasepool {
        //        NSDate *nowTime = [NSDate date];
        return nil;
    }
}

- (NSString *)getImageName:(NSString *)imageKey andSize:(NSString *)size
{
    if (!imageKey || !size)
        return nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *imageFolder = [pathDocumentDirectory() stringByAppendingPathComponent:@"/image"];
    
    BOOL *isDir = nil;
    if (![fileManager fileExistsAtPath:imageFolder isDirectory:isDir]) {
        NSError *error;
        if (![fileManager createDirectoryAtPath:imageFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"getImageByKey create image folder %@ failed: %@", imageFolder, error);
            return nil;
        }
    }
    
    return [imageFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@-%@.jpg", imageKey, size]];
}

- (bool)saveImage:(NSData *)image withKey:(NSString *)imageKey andSize:(NSString *)size
{
    if (!image || !imageKey || !size)
        return false;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *imageName = [self getImageName:imageKey andSize:size];
    
    if (!imageName) {
        NSLog(@"saveImage imagename invalid: %@ %@", imageKey, size);
        return false;
    }
    
    if (![fileManager createFileAtPath:imageName contents:image attributes:nil]) {
        NSLog(@"saveImage try to save image at: %@ failed", imageName);
        return false;
    }
    
    return true;
}

// 此函数应该在线程中使用
- (UIImage *)getImageByKey:(NSString *)key andSize:(NSString *)size
{
    @autoreleasepool {
        UIImage *image = nil;
        
        // 0. 确认是否存在Image目录
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *imageName = [self getImageName:key andSize:size];
        if (!imageName) {
            return nil;
        }
        
        // 1. 本地目录下查找带有key和size的图片文件，如果有，直接返回·
        BOOL *isDir = nil;
        if ([fileManager fileExistsAtPath:imageName isDirectory:isDir]) {
            image = [UIImage imageWithContentsOfFile:imageName];
            return image;
        }
        
        // 2. 如果没有找到本地图片，下载并保存图片，然后返回图片
        // http://medapp.ranknowcn.com/client/image.php?key=5047263e88bf9&type=s
        NSString *post = [NSString stringWithFormat:@"http://%@/client/image.php?key=%@&type=%@&version=2.2",DOMAIN_NAME, key, size];
        NSData *response = sendGETRequest(post);
        if (![fileManager createFileAtPath:imageName contents:response attributes:nil]) {
            NSLog(@"try to save image at: %@ failed", imageName);
            return nil;
        }
        
        image = [UIImage imageWithData:response];
        
        return image;
    }
}

// {"result":true,"msg":[{"id":75,"userid":"1000001","title":"ssssssss","dateadd":1347092681,"rcount":1,"replys":[{"id":81,"doctorid":3,"dname":"\u533b\u751f\u4e09","reply":"\u4f1a\u526f\u4e86\uff01\uff01\uff01","pic":"504ac04876937","dateadd":"2012-09-08 17:16:39"}]}]}
- (void)getReplyList:(NSInteger)questionID andQAInfo:(QuestionAnswers *)questionAnswer
{
    @autoreleasepool {
        if (questionID <= 0) {
            NSLog(@"getReplyList with questionID not set");
            return;
        }
        
        NSString *post = [NSString stringWithFormat:@"action=replylist&questionid=%ld", (long)questionID];
        NSLog(@"post: %@", post);
        
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"getReplyList resp: %@", strResp);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        if (!questionAnswer.question) {
            questionAnswer.question = [[Question alloc] init];
        }
        
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSString *errorMsg = [jsonData objectForKey:@"msg"];
            NSLog(@"replylist parse result failed msg: %@", errorMsg);
            return;
        }
        
        NSArray *msg = [jsonData objectForKey:@"msg"];
        if (!msg || msg.count <= 0) {
            NSLog(@"getreplylist reply empty %@ jsonData: %@", msg, jsonData);
            return;
        }
        
        NSDictionary *msgData = [msg objectAtIndex:0];
        
        if (msgData) {
            NSNumber *qID = [[NSNumber alloc] initWithInteger:[[msgData objectForKey:@"id"] integerValue]];
            [questionAnswer.question setIdentifier:qID];
            [questionAnswer.question setQuestion:[msgData objectForKey:@"title"]];
            [questionAnswer setReplyCount:[[msgData objectForKey:@"rcount"] integerValue]];
            [questionAnswer.question setUserid:[[msgData objectForKey:@"userid"] integerValue]];
            NSInteger unixTime = [[msgData objectForKey:@"dateadd"] integerValue];
            [questionAnswer.question setQuestionTime:[NSDate dateWithTimeIntervalSince1970:unixTime]];
            
            NSArray *replies = [msgData objectForKey:@"replys"];
            if (!replies || replies.count <= 0) {
                NSLog(@"with no reply");
                return;
            }
            
            for (NSDictionary *reply in replies) {
                NSLog(@"each reply: %@", reply);
                Answer *answer = [[Answer alloc] init];
                [answer setIdentifier:[reply objectForKey:@"id"]];
                [answer setDoctorID:[reply objectForKey:@"doctorid"]];
                [answer setDoctorName:[reply objectForKey:@"dname"]];
                [answer setAnswer:[reply objectForKey:@"reply"]];
                [answer setDoctorTitle:[reply objectForKey:@"dtitle"]];
                [answer setHospitalName:[reply objectForKey:@"hname"]];
                [answer setOfficeName:[reply objectForKey:@"oname"]];
                [answer setQuestionID:questionAnswer.question.identifier];
                [questionAnswer.answerArray addObject:answer];
            }
        }
    }
}

// {"id":1,"name":"\u533b\u751f\u4e00","title":"\u4e3b\u4efb\u533b\u5e08","pic":{"old":"\/uploadFile\/2012\/09\/5046fba67b665.jpg","L":"\/uploadFile\/2012\/09\/L-5046fba67b665.jpg","M":"\/uploadFile\/2012\/09\/M-5046fba67b665.jpg","S":"\/uploadFile\/2012\/09\/S-5046fba67b665.jpg"},"hid":1,"hname":"\u533b\u9662\u4e00","oid":1,"oname":"\u79d1\u5ba4\u4e00"}
- (Doctor *)parseDoctorInfoFromJson:(NSDictionary *)doctorJson andDoctor:(Doctor*)doctor
{
    @autoreleasepool {
        if (!doctor || !doctorJson) {
            return doctor;
        }
        
        NSLog(@"parseDoctorInfoFromJson: %@", doctorJson);
        
        NSNumber *dID = [doctorJson objectForKey:@"id"];
        if (!dID || dID.integerValue <= 0)
            return doctor;
        
        [doctor setDoctorID:dID.integerValue];
        [doctor setName:[doctorJson objectForKey:@"name"]];
        
        [doctor setTitle:[doctorJson objectForKey:@"title"]];
        
        NSNumber *isOnline = [doctorJson objectForKey:@"online"];
        if (isOnline && isOnline.integerValue == 1)
            doctor.isOnline = true;
        else
            doctor.isOnline = false;
        
        NSNumber *oID = [doctorJson objectForKey:@"oid"];
        [doctor setOfficeID:oID.integerValue];
        [doctor setOfficeName:[doctorJson objectForKey:@"oname"]];
        
        NSNumber *hID = [doctorJson objectForKey:@"hid"];
        [doctor setHospitalID:hID.integerValue];
        [doctor setHospitalName:[doctorJson objectForKey:@"hname"]];
        
        NSString *pics = [doctorJson objectForKey:@"pic"];
        [doctor setImageKey:pics];
        
        [doctor setIntroduction:[doctorJson objectForKey:@"intro"]];
        
        return doctor;
    }
}

// {"result":true,"msg":[{"id":90,"name":"\u5317\u4eac\u827e\u4e3d\u65af\u5987\u79d1\u533b\u9662","city":"1000","tel":"010-62800867 ","website":"http:\/\/www.fuke120.com","intro":"\u3000\u5317\u4eac\u827e\u4e3d\u65af\u5987\u79d1\u533b\u9662\uff0c\u662f\u4e00\u6240\u4e13\u6ce8\u5973\u6027\u5065\u5eb7\u3001\u7ef4\u517b\u5973\u6027\u9b45\u529b\u7684\u5927\u578b\u56fd\u9645\u5316\u533b\u9662\u3002\u533b\u9662\u4e0e\u56fd\u5916\u591a\u5bb6\u77e5\u540d\u533b\u9662\u8fdb\u884c\u56fd\u9645\u5408\u4f5c\uff0c\u6574\u5408\u56fd\u5185\u5916\u6743\u5a01\u4e13\u5bb6\u8d44\u6e90\u3001\u5148\u8fdb\u533b\u7597\u7ba1\u7406\u6a21\u5f0f\u548c\u670d\u52a1\u7406\u5ff5\uff0c\u878d\u8d2f\u5168\u7403\u524d\u6cbf\u533b\u7597\u8bbe\u5907\u6280\u672f\u7cbe\u9ad3\uff0c\u51ed\u501f\u72ec\u7279\u7684\u201c\u96c6\u6210\u5316\u56fd\u9645\u533b\u9662\u201d\u7406\u5ff5\u548c\u5353\u8d8a\u7684\u6743\u5a01\u533b\u7597\u4f53\u7cfb\uff0c\u6253\u9020\u4e2d\u56fd\u591a\u529f\u80fd\u9876\u7ea7\u5987\u79d1\u533b\u7597\u822a\u6bcd","pic1":"\/uploadFile\/2012\/09\/504710bd39ebf.jpg","pic2":{"old":"\/uploadFile\/2012\/09\/504710bd5832f.jpg","L":"\/uploadFile\/2012\/09\/L-504710bd5832f.jpg","M":"\/uploadFile\/2012\/09\/M-504710bd5832f.jpg","S":"\/uploadFile\/2012\/09\/S-504710bd5832f.jpg"},"geolocation":"0,0","types":"12","typeList":[{"id":"12","name":"\u5987\u4ea7"}],"jingdu":0,"weidu":0}]}

- (Hospital *)parseHospitalInfoFromJson:(NSDictionary *)hospitalJson andHospital:(Hospital *)hospital
{
    @autoreleasepool {
        if (!hospital || !hospitalJson) {
            return hospital;
        }
        
        NSLog(@"hospitalInfo json: %@", hospitalJson);
        
        NSNumber *hID = [hospitalJson objectForKey:@"id"];
        if (!hID || hID.integerValue <= 0) {
            NSLog(@"parseHospitalInfoFromJson hID wrong");
        }
        hospital.identifier = hID.integerValue;
        
        NSString *hName = [hospitalJson objectForKey:@"name"];
        hospital.name = hName;
        
        NSString *web = [hospitalJson objectForKey:@"website"];
        hospital.webSite = web;
        
        NSString *city = [hospitalJson objectForKey:@"cityname"];
        hospital.city = city;
        
        NSString *tel = [hospitalJson objectForKey:@"tel"];
        hospital.telephone = tel;
        
        NSString *intro = [hospitalJson objectForKey:@"intro"];
        hospital.introduction = intro;
        
        NSString *topImage = [hospitalJson objectForKey:@"pic1"];
        hospital.topImageKey = topImage;
        
        NSString *imageKey = [hospitalJson objectForKey:@"pic2"];
        hospital.imageKey = imageKey;
        
        NSNumber *longitude = [hospitalJson objectForKey:@"jingdu"];
        hospital.longitude = longitude.doubleValue;
        
        NSNumber *latitude = [hospitalJson objectForKey:@"weidu"];
        hospital.latitude = latitude.doubleValue;
        
        return hospital;
    }
}

- (Question *)parseQuestionInfoFromJson:(NSDictionary *)questionJson andQuestion:(Question *)question
{
    return question;
}

- (Answer *)parseAnswerInfoFromJson:(NSDictionary *)answerJson andAnswer:(Answer *)answer
{
    return answer;
}

- (Office *)parseOfficeInfoFromJson:(NSDictionary *)officeJson andOffice:(Office*)office
{
    return office;
}


#pragma mark LocateUtilsDelegate
- (void)localInfoLocationWillStartUpdate:(LocateUtils *)localInfo
{
    
}

- (void)localInfoLocationUpdateSuccess:(LocateUtils *)localInfo
{
    if (![localInfo isKindOfClass:[LocateUtils class]]) {
        NSLog(@"localInfoLocationUpdateSuccess localInfo invalid");
        return;
    }
    
    NSString *post = [[NSString alloc] initWithFormat:@"%@,%@,%@,%@,%@,%@,%@", localInfo.baiduLatitude,localInfo.baiduLongitude, localInfo.streetNumber, localInfo.streetName, localInfo.district, localInfo.city, localInfo.province];
    
    NSLog(@"BaiduMapAPI location: %@", post);
    
    // 生成地址详情
    _province = [localInfo.province substringToIndex:localInfo.province.length - 1];
    if ([_province isEqualToString:@"北京"] || [_province isEqualToString:@"上海"] || [_province isEqualToString:@"天津"] || [_province isEqualToString:@"重庆"]) {
        _cityOrDistrict = localInfo.district;
    }
    else {
        _cityOrDistrict = localInfo.city;
    }
    
    NSNumber *rID = [self regionIDWithRegionName:_province];
    if (rID) {
        // 本地保存省、直辖市
        [self updateUserRegion:rID];
        
        // 本地保存市区
        NSArray *cityArray = [[CureMeUtils defaultCureMeUtil] cityArrayWithRegionID:rID.integerValue];
        for (NSDictionary *data in cityArray) {
            if ([_cityOrDistrict isEqualToString:[data objectForKey:@"name"]]) {
                [self updateUserCity:[data objectForKey:@"id"] andCityName:_cityOrDistrict];
                break;
            }
        }
    }
    
    //新增虚拟定位
    NSString *addressStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"emulateLocationAddress"];
    if (!addressStr || addressStr.length <= 0) {
        _encodedLocateInfo = [post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else{
        _encodedLocateInfo = addressStr;
    }
    //_encodedLocateInfo = [post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 保存地址
    [locateUtils save];
    
    // 通知注册了通知的对象，地址已经获得
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NTF_LocationComfirmed object:nil]];
    
    [self sendUserLocationInfo];
}

- (void)sendUserLocationInfo
{
    // 如果还未发送地址信息，则发送至服务端更新
    NSNumber *hasSentLocationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_SENT_LOCATIONINFO];
    NSDate *lastSentTime = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_SEND_LOCATION_TIME];
    
    // 判断是否已经超过发送位置信息的间隔
    bool hasOverTime = false;
    if (!lastSentTime) {
        hasOverTime = true;
    }
    else if (fabs([lastSentTime timeIntervalSinceNow]) > 24 * 60 * 60) {
        hasOverTime = true;
    }
    
    //  此时满足发送地址信息的条件
    if (!hasSentLocationInfo || hasSentLocationInfo.integerValue != 1 || hasOverTime) {
        // 发送请求
        // 如果DeviceID为空，则不发送请求
        NSString *deviceID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID];
        if (!deviceID || deviceID.length <= 0) {
            NSLog(@"action=updaddrdetail abort deviceid empty");
            return;
        }
        
        NSString *post = [[NSString alloc] initWithFormat:@"action=updaddrdetail&addrdetail=%@", _encodedLocateInfo];
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"action=updaddrdetail resp: %@", strResp);
        
        // 标记为已发送
        [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithInt:1] forKey:HAS_SENT_LOCATIONINFO];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LAST_SEND_LOCATION_TIME];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)localInfoLocationUpdateFailed:(LocateUtils *)localInfo
{
    // 发送Notification告知特定页面，弹提示
    NSNotification *note = [NSNotification notificationWithName:NTF_LocateServiceNotAvailable object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

- (void)localInfoLocationLoadComplete:(LocateUtils *)localInfo
{
    if (!locateUtils.baiduLatitude || !locateUtils.baiduLongitude || !locateUtils.province) {
        _encodedLocateInfo = nil;
        _province = nil;
        return;
    }
    
    NSString *post = [[NSString alloc] initWithFormat:@"%@,%@,%@,%@,%@,%@,%@", localInfo.baiduLatitude,localInfo.baiduLongitude, localInfo.streetNumber, localInfo.streetName, localInfo.district, localInfo.city, localInfo.province];
    
    _province = localInfo.province;
    _encodedLocateInfo = [post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
}

@end

