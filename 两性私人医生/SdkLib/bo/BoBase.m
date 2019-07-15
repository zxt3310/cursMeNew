//
//  BoBase.m
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#import "BoBase.h"

#import "RespBase.h"
#import "Gloabal.h"
//#import "EncryptAndDecrypt.h"

@interface BoBase ()
{
    complete mCallback;
}

@end

@implementation BoBase

#define BASE_URL @"http://180.76.137.158:8080"
//#define SESSIONKEY @"0B41883A7B4599F51C1462CF9606CE3C"

- (void)request:(JSONModel*)reqObj Completed:(complete) callback {
    [self request:reqObj withBaseUrl:BASE_URL Completed:callback];
}

- (void)request:(JSONModel*)reqObj withBaseUrl:(NSString*) url Completed:(complete) callback {
    mCallback = callback;
    [JSONHTTPClient postJSONFromURLWithString:url bodyString: [reqObj toJSONString] completion:^(NSDictionary *json, JSONModelError *err) {
        if (err) {
            if(mCallback != nil) {
                mCallback(self, nil, NET_FAIL);
            }
        } else {
            int code = NET_FAIL;
            NSObject* responseObj = nil;
            responseObj = [[_responseCls alloc ] initWithDictionary: json error:nil];
            if (nil != responseObj) {
                RespBase* respObj = (RespBase*) responseObj;
                if (respObj.code != 0) {
                    code = SERVER_ERROR;
                } else {
                    code = NET_SUCCESS;
                }
            } else {
                code = PARSE_FAIL;
            }
            if(mCallback != nil) {
                mCallback(self, responseObj, code);
            }
        }
    }];
}

@end
