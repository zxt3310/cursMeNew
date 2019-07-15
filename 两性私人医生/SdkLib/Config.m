//
//  Config.m
//  HiChat
//
//  Created by xiaoshoucun on 15/11/3.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import "Config.h"
#import "Gloabal.h"
#import "EncryptAndDecrypt.h"

@implementation Config

+(void)saveUserAccount:(NSString*)account {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:account forKey:@"userAccount"];
    [defaults synchronize];
}

+(NSString*)getUserAccount {
    return [Config stringForKey:@"userAccount" withDefaultValue:nil];
}

#define SESSIONKEYDATA [@"0B41883A7B4599F51C1462CF9606CE3C" dataUsingEncoding:NSUTF8StringEncoding]

+(void)savePassword:(NSString*)password {
    NSData *cipherData = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (nil != password) {
        NSData *rawData = [password dataUsingEncoding:NSUTF8StringEncoding];
        cipherData = [rawData AES256EncryptWithKey:SESSIONKEYDATA];
    }
    [defaults setObject:cipherData forKey:@"password"];
    [defaults synchronize];
}

+(NSString*)getPassword {
    NSData* rawData = [Config dataForKey:@"password" withDefaultValue:nil];
    if (nil == rawData) {
        return nil;
    }
    NSData *cipherData = [rawData AES256DecryptWithKey:SESSIONKEYDATA];
    return [[NSString alloc] initWithData:cipherData encoding:NSUTF8StringEncoding];
}

+(void)saveFormerUser:(NSString*)account {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:account forKey:@"formerUser"];
    [defaults synchronize];
}

+(NSString*)getFormerUser {
    return [Config stringForKey:@"formerUser" withDefaultValue:nil];
}

+(void)saveAppKey:(NSString*)appKey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:appKey forKey:@"appKey"];
    [defaults synchronize];
}

+(NSString*)getAppKey {
    return [Config stringForKey:@"appKey" withDefaultValue:nil];
}

+(void)saveServerIp:(NSString*)serverIpKey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:serverIpKey forKey:@"serverIpKey"];
    [defaults synchronize];
}

+(NSString*)getServerIp {
    return [Config stringForKey:@"serverIpKey" withDefaultValue:nil];
}

+(void)saveServerPort:(NSString*)serverPort {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:serverPort forKey:@"serverPort"];
    [defaults synchronize];
}

+(NSString*)getServerPort {
    return [Config stringForKey:@"serverPort" withDefaultValue:nil];
}

+(void)savePnToken:(NSString*)pnToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:pnToken forKey:@"pnToken"];
    [defaults synchronize];
}

+(NSString*)getPnToken {
    return [Config stringForKey:@"pnToken" withDefaultValue:nil];
}

+(void)saveApnsToken:(NSString*)pnToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:pnToken forKey:@"apnsToken"];
    [defaults synchronize];
}

+(NSString*)getApnsToken {
    return [Config stringForKey:@"apnsToken" withDefaultValue:nil];
}

+(void)saveUploadPNTokenFlag:(BOOL)uploadPNTokenFlag {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:uploadPNTokenFlag forKey:@"uploadPNTokenFlag"];
    [defaults synchronize];
}

+(BOOL)getUploadPNTokenFlag {
    return [Config boolForKey:@"uploadPNTokenFlag" withDefaultValue:false];
}

+(void)saveLoginStatus:(int)loginStatus {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:loginStatus forKey:@"loginStatus"];
    [defaults synchronize];
}

+(int)getLoginStatus {
    return [Config integerForKey:@"loginStatus" withDefaultValue:HICHAT_OFFLINE];
}

+(void)saveCurServiceAccount:(NSString*)CurServiceAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:CurServiceAccount forKey:@"CurServiceAccount"];
    [defaults synchronize];
}

+(NSString*)getCurServiceAccount {
    return [Config stringForKey:@"CurServiceAccount" withDefaultValue:nil];
}

+(void)saveDevId:(NSString*)devId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:devId forKey:@"devId"];
    [defaults synchronize];
}

+(NSString*)getDevId {
    return [Config stringForKey:@"devId" withDefaultValue:nil];
}

+ (NSString *)stringForKey:(NSString *)defaultName withDefaultValue:(NSString*) defaultValue {
    NSUserDefaults *defualts = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 defaultValue, defaultName, nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    return [defualts stringForKey:defaultName];
}

+ (NSInteger)integerForKey:(NSString *)defaultName withDefaultValue:(int) defaultValue {
    NSUserDefaults *defualts = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:defaultValue], defaultName, nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    return [defualts integerForKey:defaultName];
}

+ (BOOL)boolForKey:(NSString *)defaultName withDefaultValue:(bool) defaultValue {
    NSUserDefaults *defualts = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:defaultValue], defaultName, nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    return [defualts integerForKey:defaultName];
}

+ (NSData*)dataForKey:(NSString *)defaultName withDefaultValue:(NSData*) defaultValue {
    NSUserDefaults *defualts = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 defaultValue, defaultName, nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    return [defualts dataForKey:defaultName];
}


@end