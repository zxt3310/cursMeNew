//
//  CLGetGsmInfo.m
//  cutelocation
//
//  Created by Tim on 13-8-23.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CLGetGsmInfo.h"


//.m
//#import "GLGetGsmInfo.h"
//#import "CoreTelephony.h"
//#import <CoreTelephony/CoreTelephony.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>



@implementation GSMInfoData

- (NSString *)description
{
    return [NSString stringWithFormat:@"GSMInfo cellID: %ld lac: %ld mcc: %@ mnc: %@", (long)_cellID, (long)_lac, _mcc, _mnc];
}

@end


@implementation CLGetGsmInfo

- (id)init
{
    self = [super init];
    if (self) {
        char* sdk_path = "/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony";
        
        // void * dlopen( const char * pathname, int mode );
        // 功能：以指定模式打开指定的动态连接库文件，并返回一个句柄给调用进程。 打开错误返回NULL,成功，返回库引用
        // RTLD_LAZY 暂缓决定，等有需要时再解出符号。这个参数使得未解析的symbol将在使用时去解析
        int* handle =dlopen(sdk_path, RTLD_LAZY);
        if (handle == NULL) {
            return self;
        }

        // void* dlsym(void* handle,const char* symbol) 该函数在<dlfcn.h>文件中。将库中的一个函数绑定到预定义的函数地址(即获取到函数的指针)。handle是由dlopen打开动态链接库后返回的指针，symbol就是要求获取的函数的名称，函数返回值是void*,指向函数的地址，供调用使用。
        _CTServerConnectionCreate = dlsym(handle, "_CTServerConnectionCreate");
        
        _CTServerConnectionGetPort = dlsym(handle, "_CTServerConnectionGetPort");
        //    port=CFMachPortCreateWithPort(kCFAllocatorDefault, _CTServerConnectionGetPort(sc), NULL, NULL, NULL);
        
        _CTServerConnectionCellMonitorStart = dlsym(handle, "_CTServerConnectionCellMonitorStart");
        
        _CTServerConnectionCellMonitorGetCellCount = dlsym(handle, "_CTServerConnectionCellMonitorGetCellCount");
        
        _CTServerConnectionCellMonitorGetCellInfo = dlsym(handle, "_CTServerConnectionCellMonitorGetCellInfo");
        
        _CTServerConnectionGetCellID = dlsym(handle, "_CTServerConnectionGetCellID");
        _CTServerConnectionGetLocationAreaCode = dlsym(handle, "_CTServerConnectionGetLocationAreaCode");

        CTGetSignalStrength = dlsym(handle, "CTGetSignalStrength");

//        void *kCTCellMonitorUpdateNotification = dlsym(handle, "kCTIndicatorsSignalStrengthNotification");
//        
//        if( kCTCellMonitorUpdateNotification== NULL)
//            NSLog(@"Could not find kCTCellMonitorUpdateNotification");
//        
//        int x = 0; //placehoder for callback
//        _CTServerConnectionRegisterForNotification = dlsym(handle, "_CTServerConnectionRegisterForNotification");
//        _CTServerConnectionRegisterForNotification(connection,kCTCellMonitorUpdateNotification,&x);
    }
    return self;
}

static int callback(void *connection, CFStringRef string, CFDictionaryRef dictionary, void *data) {
    NSLog(@"callback (but it never calls me back :( ))\n");
    return 0;
}

static void sourcecallback ( CFMachPortRef port, void *msg, CFIndex size, void *info)
{
    NSLog(@"Source called back\n");
}

- (void)showLocationInfo
{
    [self showLocationWithMNC: cellinfo.network
                          andMCC: cellinfo.servingmnc
                          andCID: cellinfo.cellid
                          andLAC: cellinfo.location
     ];
}

-(void)showLocationWithMNC:(int) MNC andMCC:(int) MCC andCID:(int) CID andLAC:(int) LAC
{
    char pd[] = {
        0x00, 0x0e,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00,
        0x00, 0x00,
        0x00, 0x00,
        
        0x1b,
        0x00, 0x00, 0x00, 0x00, // Offset 0x11
        0x00, 0x00, 0x00, 0x00, // Offset 0x15
        0x00, 0x00, 0x00, 0x00, // Offset 0x19
        0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, // Offset 0x1f
        0x00, 0x00, 0x00, 0x00, // Offset 0x23
        0x00, 0x00, 0x00, 0x00, // Offset 0x27
        0x00, 0x00, 0x00, 0x00, // Offset 0x2b
        0xff, 0xff, 0xff, 0xff,
        0x00, 0x00, 0x00, 0x00
    };
    
    if (CID > 65535)
        pd[0x1c] = 5;
    else {
        pd[0x1c] = 3;
        CID &= 0xffff;
    }
    
    pd[0x11] = (unsigned char)((MNC >> 24) & 0xFF);
    pd[0x12] = (unsigned char)((MNC >> 16) & 0xFF);
    pd[0x13] = (unsigned char)((MNC >> 8) & 0xFF);
    pd[0x14] = (unsigned char)((MNC >> 0) & 0xFF);
    
    pd[0x15] = (unsigned char)((MCC >> 24) & 0xFF);
    pd[0x16] = (unsigned char)((MCC >> 16) & 0xFF);
    pd[0x17] = (unsigned char)((MCC >> 8) & 0xFF);
    pd[0x18] = (unsigned char)((MCC >> 0) & 0xFF);
    
    pd[0x27] = (unsigned char)((MNC >> 24) & 0xFF);
    pd[0x28] = (unsigned char)((MNC >> 16) & 0xFF);
    pd[0x29] = (unsigned char)((MNC >> 8) & 0xFF);
    pd[0x2a] = (unsigned char)((MNC >> 0) & 0xFF);
    
    pd[0x2b] = (unsigned char)((MCC >> 24) & 0xFF);
    pd[0x2c] = (unsigned char)((MCC >> 16) & 0xFF);
    pd[0x2d] = (unsigned char)((MCC >> 8) & 0xFF);
    pd[0x2e] = (unsigned char)((MCC >> 0) & 0xFF);
    
    pd[0x1f] = (unsigned char)((CID >> 24) & 0xFF);
    pd[0x20] = (unsigned char)((CID >> 16) & 0xFF);
    pd[0x21] = (unsigned char)((CID >> 8) & 0xFF);
    pd[0x22] = (unsigned char)((CID >> 0) & 0xFF);
    
    pd[0x23] = (unsigned char)((LAC >> 24) & 0xFF);
    pd[0x24] = (unsigned char)((LAC >> 16) & 0xFF);
    pd[0x25] = (unsigned char)((LAC >> 8) & 0xFF);
    pd[0x26] = (unsigned char)((LAC >> 0) & 0xFF);
    
    NSString *url = [NSString stringWithFormat:@"http://google.com/glm/mmap"];
    
    NSLog(@"String is (%@) req len %lu", url, sizeof(pd));
    
    NSURL *theURL = [NSURL URLWithString:url];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1000.0f];
    [theRequest setHTTPMethod:@"POST"];
    
    NSData *body = [[NSData alloc] initWithBytes:pd length:sizeof(pd)];
    
    //    NSString *contentLen = [NSString stringWithFormat:@"%d", [body length]];
    //    [theRequest addValue:contentLen  forHTTPHeaderField:@"Content-Length"];
    NSString *contentType = [NSString stringWithFormat:@"application/binary"];
    [theRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    [theRequest setHTTPBody: body];
    
    NSURLResponse *theResponse = NULL;
    NSError *theError = NULL;
    NSData *theResponseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&theError];
    NSLog(@"response len %lu", (unsigned long)[theResponseData length]);
    
    unsigned char *ps = [theResponseData bytes];
    short opcode1 = (short)(ps[0] << 8 | ps[1]);
    unsigned char opcode2 = ps[2];
    int ret_code = (int)((ps[3] << 24) | (ps[4] << 16) | (ps[5] << 8) | (ps[6]));
    if ((opcode1 == 0x0e) &&
        (opcode2 == 0x1b) &&
        (ret_code == 0)) {
        double lat = ((double)((ps[7] << 24) | (ps[8] << 16) | (ps[9] << 8) | (ps[10]))) / 1000000;
        double lon = ((double)((ps[11] << 24) | (ps[12] << 16) | (ps[13] << 8) | (ps[14]))) / 1000000;
        NSLog(@"Latitude %f, Longtitude %f\n", lat, lon);
    } else {
        NSLog(@"opcode1=%04X", opcode1);
        NSLog(@"opcode2=%02X", opcode1);
        NSLog(@"ret_cod=%d", ret_code);
        NSLog(@"Can't get GPS data");
    }
}

-(void)cellConnect
{
    connection = _CTServerConnectionCreate(kCFAllocatorDefault, callback, NULL);
    
    CFMachPortContext  context = { 0, 0, NULL, NULL, NULL };
    
    ref = CFMachPortCreateWithPort(kCFAllocatorDefault, _CTServerConnectionGetPort(connection), sourcecallback, &context, NULL);
    
    _CTServerConnectionCellMonitorStart(&tx, connection);
    
//    ref = CFMachPortCreateWithPort(kCFAllocatorDefault,port,NULL,NULL, NULL);
//    NSLog(@"mach_port=%x",CFMachPortGetPort(ref));
//    CFRunLoopSourceRef source = CFMachPortCreateRunLoopSource ( kCFAllocatorDefault, ref, 0);
//    CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop], source, kCFRunLoopCommonModes);
//    _CTServerConnectionCellMonitorStart(ref,connection);

    NSLog(@"Connected\n");
}

void register_notification(){
    
    
}


-(int)getCellCount
{
    int cellcount;
    
    _CTServerConnectionCellMonitorGetCellCount(&tl, connection, &cellcount);
    
    return cellcount;
}

- (int)getSignalStrength
{
    if( CTGetSignalStrength == NULL) {
        NSLog(@"Could not find CTGetSignalStrength");
    }
    
	int result = CTGetSignalStrength();
    NSLog(@"signalStrength:%d", result);

	return result;
}

int t1;
CellInfo cellinfo;

- (GSMInfoData *)getCellInfo2
{
    int cellId = 0, cellLac = 0;
    _CTServerConnectionGetCellID(&t1,connection,&cellId);
    _CTServerConnectionGetLocationAreaCode(&t1,connection,&cellLac);
    NSLog(@"cellId:%d",cellId);
    NSLog(@"cellLAC:%d", cellLac);
    
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    // Get mobile country code
    NSString *mcc = [carrier mobileCountryCode];
    if (mcc != nil)
        NSLog(@"Mobile Country Code (MCC): %@", mcc);
    
    // Get mobile network code
    NSString *mnc = [carrier mobileNetworkCode];
    if (mnc != nil)
        NSLog(@"Mobile Network Code (MNC): %@", mnc);

//    int sigStrength = [self getSignalStrength];
    
    GSMInfoData *data = [[GSMInfoData alloc] init];
    data.cellID = cellId;
    data.lac = cellLac;
    data.mcc = mcc;
    data.mnc = mnc;
    
    return data;
    
    
    
//    int cellcount;
//    _CTServerConnectionCellMonitorGetCellCount(&t1,connection,&cellcount);
//    
//    printf("Cell count: %x\n",cellcount);
//    
//    printf("Size = %lx\n", sizeof(CellInfo));
//    
//    unsigned char *a=malloc(sizeof(CellInfo));
//    
//    for(int b=0;b<cellcount;b++)
//    {
//        //OMG the toolchain is broken, &cellinfo doesn't work
//        _CTServerConnectionCellMonitorGetCellInfo(&t1,connection,b,a); memcpy(&cellinfo,a,sizeof(CellInfo));
//        //OMG the toolchain is more broken, these printfs don't work on one line
//        printf("Cell Site: %d, MNC: %d, ",b,cellinfo.servingmnc);
//        printf("Location: %d, Cell ID: %d, Station: %d, ",cellinfo.location, cellinfo.cellid, cellinfo.station);
//        printf("Freq: %d, RxLevel: %d, ", cellinfo.freq, cellinfo.rxlevel);
//        printf("C1: %d, C2: %d\n", cellinfo.c1, cellinfo.c2);
//    }
//    if(a) free(a);
}

-(void)getCellInfo:(int) cell
{
    char *a = malloc(sizeof(CellInfo));
    
    _CTServerConnectionCellMonitorGetCellInfo(&tl, connection, cell, a);
    
    memcpy(&cellinfo, a, sizeof(CellInfo));
    
    NSLog(@"Cell Site: %d, MCC: %d, ", cell, cellinfo.servingmnc);
    NSLog(@"MNC: %d ", cellinfo.network);
    NSLog(@"Location: %d, Cell ID: %d, Station: %d, ", cellinfo.location, cellinfo.cellid, cellinfo.station);
    NSLog(@"Freq: %d, RxLevel: %d, ", cellinfo.freq, cellinfo.rxlevel);
    NSLog(@"C1: %d, C2: %d\n", cellinfo.c1, cellinfo.c2);
    
    free(a);
#if 0
    int i;
    int cellcount;
    
    _CTServerConnectionCellMonitorGetCellCount(&tl, connection, &cellcount);
    NSLog(@"Cell count: %d (%d)\n", cellcount, tl);
    char *a = malloc(sizeof(CellInfo));
    for(i = 0; i < cellcount; i++) {
        _CTServerConnectionCellMonitorGetCellInfo(&tl, connection, i, a);
        memcpy(&cellinfo, a, sizeof(CellInfo));
        NSLog(@"Cell Site: %d, MCC: %d, ", i, cellinfo.servingmnc);
        NSLog(@"MNC: %d ", cellinfo.network);
        NSLog(@"Location: %d, Cell ID: %d, Station: %d, ", cellinfo.location, cellinfo.cellid, cellinfo.station);
        NSLog(@"Freq: %d, RxLevel: %d, ", cellinfo.freq, cellinfo.rxlevel);
        NSLog(@"C1: %d, C2: %d\n", cellinfo.c1, cellinfo.c2);
    }
    
    _CTServerConnectionCellMonitorGetCellInfo(&tl, connection, 0, a);
    
    memcpy(&cellinfo, a, sizeof(CellInfo));
    
    if (a)
        free(a);
#endif
}

@end
