//
//  CMException.h
//  私密健康医生
//
//  Created by jongs zhong on 14-8-14.
//  Copyright (c) 2014年 Jongs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UncaughtExceptionHandler : NSObject

{
    BOOL dismissed;
}

- (void)handleException:(NSException *)exception;

@end

//NSString* getAppInfo();
void MySignalHandler(int signal);
void InstallUncaughtExceptionHandler();

@interface CMException : NSObject

@end
