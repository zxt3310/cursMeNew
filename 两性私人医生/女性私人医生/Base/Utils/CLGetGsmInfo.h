//
//  CLGetGsmInfo.h
//  cutelocation
//
//  Created by Tim on 13-8-23.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
//#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <stdio.h>
#import <string.h>


struct __CTServerConnection {
    int a;
    int b;
    CFMachPortRef myport;
    int c;
    int d;
    int e;
    int f;
    int g;
    int h;
    int i;
};
typedef struct __CTServerConnection CTServerConnection;
typedef CTServerConnection* CTServerConnectionRef;


struct __CellInfo {
    int servingmnc;
    int network;
    int location;
    int cellid;
    int station;
    int freq;
    int rxlevel;
    int c1;
    int c2;
};
typedef struct __CellInfo CellInfo;
typedef CellInfo* CellInfoRef;



static CTServerConnectionRef connection;
static CFMachPortRef ref;
static mach_port_t tl;
static mach_port_t tx;

static int  callback(void *connection, CFStringRef string, CFDictionaryRef dictionary, void *data);
static void sourcecallback ( CFMachPortRef port, void *msg, CFIndex size, void *info);


@interface GSMInfoData : NSObject

@property (nonatomic) NSInteger cellID;
@property (nonatomic) NSInteger lac;
@property (nonatomic, strong) NSString *mcc;
@property (nonatomic, strong) NSString *mnc;

@end


@interface CLGetGsmInfo : NSObject

{
    CellInfo cellinfo;
    struct CTServerConnection * (*_CTServerConnectionCreate)();
    int (*_CTServerConnectionGetPort)();
    void (*_CTServerConnectionCellMonitorStart)();
    int* (*_CTServerConnectionCellMonitorGetCellCount)();
    void (*_CTServerConnectionCellMonitorGetCellInfo)();
    int (*_CTServerConnectionRegisterForNotification)();
    
    void (*_CTServerConnectionGetCellID)();
    void (*_CTServerConnectionGetLocationAreaCode)();
    int (*CTGetSignalStrength)();
}

- (int) getSignalStrength;
- (GSMInfoData *) getCellInfo2;

- (void) cellConnect;
- (void) getCellInfo:(int) cell;
- (int) getCellCount;
- (void)showLocationInfo;
- (void) showLocationWithMNC:(int) MNC andMCC:(int) MCC andCID:(int) CID andLAC:(int) LAC;

@end
