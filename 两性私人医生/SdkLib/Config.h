//
//  Config.h
//  HiChat
//
//  Created by xiaoshoucun on 15/11/3.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

+(void)saveUserAccount:(NSString*)account;
+(NSString*)getUserAccount;
+(void)savePassword:(NSString*)password;
+(NSString*)getPassword;
+(void)saveFormerUser:(NSString*)account;
+(NSString*)getFormerUser;
+(void)saveAppKey:(NSString*)appKey;
+(NSString*)getAppKey;
+(void)saveServerIp:(NSString*)serverIpKey;
+(NSString*)getServerIp;
+(void)saveServerPort:(NSString*)serverPort;
+(NSString*)getServerPort;
+(void)savePnToken:(NSString*)pnToken;
+(NSString*)getPnToken;
+(void)saveApnsToken:(NSString*)pnToken;
+(NSString*)getApnsToken;
+(void)saveUploadPNTokenFlag:(BOOL)uploadPNTokenFlag;
+(BOOL)getUploadPNTokenFlag;
+(void)saveLoginStatus:(int)loginStatus;
+(int)getLoginStatus;
+(void)saveCurServiceAccount:(NSString*)CurServiceAccount;
+(NSString*)getCurServiceAccount;
+(void)saveDevId:(NSString*)devId;
+(NSString*)getDevId;

+ (NSString *)stringForKey:(NSString *)defaultName withDefaultValue:(NSString*) defaultValue;
+ (NSInteger)integerForKey:(NSString *)defaultName withDefaultValue:(int) defaultValue;
+ (BOOL)boolForKey:(NSString *)defaultName withDefaultValue:(bool) defaultValue;
+ (NSData*)dataForKey:(NSString *)defaultName withDefaultValue:(NSData*) defaultValue;

@end
