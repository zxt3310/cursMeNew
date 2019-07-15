//
//  NetUtils.h
//  CureMe
//
//  Created by Tim on 12-8-15.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

id JsonValue(id value, NSString *defaultClass);

void updateIOSPushInfo();

NSDate* convertDateFromString(NSString *sdate, NSString *format);

NSString* convertStringFromDate(NSDate *date, NSString *format);

NSString* removeHTML(NSString *html);

NSString* urlEncode(NSString *str);

NSString* replaceUnicode(NSString *unicodeStr);

#pragma mark POST methods:

//NSString* getUDID();

NSData *sendRequestWithFullURL(NSString *fullURL, NSString *post);
//NSData *sendRequestWithFullURL22(NSString *fullURL, NSString *post);
NSData *sendRequestWithFullURLNAP(NSString *fullURL, NSMutableDictionary *respDict);
NSData *sendFullRequest(NSString *fullURL, NSString *post, NSDictionary *additionalHeaders, bool needDispNetState, bool saveSetCookie);

// Send synchronous request
NSData *sendRequest(NSString *phpFile, NSString *post);
NSData *sendRequestWithCookie(NSString *phpFile, NSString *post, NSString *cookie, bool saveSetCookie);
//NSData *sendRequestWithFullURL(NSString *fullURL, NSString *post);

NSData *sendRequestWithData(NSString *url, NSData *data);

NSData *sendRequestWithHeaderAndResponse(NSString *phpFile, NSString *post, NSDictionary *additionalHeaders, bool needDispNetState, bool saveSetCookie);

NSData* sendRequestAndNeedCookie(NSString *phpFile, NSString *post, NSDictionary *additionalHeader, bool needDispNetState, bool saveSetCookie);
//NSData *sendFullRequest(NSString *fullURL, NSString *post, NSDictionary *additionalHeaders, bool needDispNetState, bool saveSetCookie, bool sendGZipContent);

NSData* loadRequestWithImg(NSDictionary *params,NSString *url);
#pragma mark GET methods:
// Send synchronous GET request
NSData *sendGETRequest(NSString *url);

NSData *sendGetReqWithHeaderAndRespDict(NSString *strUrl, NSDictionary *headers, NSMutableDictionary *respDict, bool needDispNetState);

#pragma mark Json parse methods:
// Parse response string to JSon dictionary
NSDictionary *parseJsonResponse(NSData *response);

NSDictionary *parseJsonString(NSString *str);


