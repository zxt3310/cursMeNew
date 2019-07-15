//
//  NetUtils.m
//  CureMe
//
//  Created by Tim on 12-8-15.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "JsonKit.h"
#import "NetUtils.h"
#import "Reachability.h"
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <AdSupport/AdSupport.h>

#define UD_IDFA_ID @"ud_idfaid"

/*
NSString* getUDID()
{
    //    return @"B39E2D1E_MP_REG";
    
    NSString *outstring = [[NSUserDefaults standardUserDefaults] stringForKey:UD_IDFA_ID];
    
    if (!outstring) {
        // 如果是iOS7之前的系统，获取MAC地址
        if (IOS_VERSION < 6.1) {
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
        
        [[NSUserDefaults standardUserDefaults] setObject:outstring forKey:UD_IDFA_ID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *resultString = [NSString stringWithFormat:@"%@_MP_REG", [outstring substringToIndex:8]];
    return resultString;
}*/

// 同步请求统一函数
// 默认所有调用此函数的请求，都发送至 medapp.ranknowcn.com/api/m.php
NSData *sendRequest(NSString *phpFile, NSString *post)
{
    NSString *finalPost = [[NSString alloc] initWithFormat:@"%@&deviceid=%@&appid=7&source=apple&imei=%@", post, [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID],[CureMeUtils defaultCureMeUtil].UDID];
    NSLog(@"sendRequest: %@", finalPost);
    
    NSDictionary *additionalHeader = nil;
    return sendRequestWithHeaderAndResponse(phpFile, finalPost, additionalHeader, true, false);
}

NSData *sendRequestWithFullURL(NSString *fullURL, NSString *post)
{
    NSString *finalPost = [NSString stringWithFormat:@"%@&version=3.0&deviceid=%@&appid=7&source=apple", post, [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID]];
    NSLog(@"sendRequestWithFullURL:%@ post:%@", fullURL, finalPost);
    
    return sendFullRequest(fullURL, finalPost, nil, true, false);
}
/*
 NSData *sendRequestWithFullURL22(NSString *fullURL, NSString *post)
 {
 NSString *finalPost = [NSString stringWithFormat:@"%@&version=2.2&deviceid=%@&appid=7&source=apple", post, [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID]];
 NSLog(@"sendRequestWithFullURL:%@ post:%@", fullURL, finalPost);
 
 return sendFullRequest(fullURL, finalPost, nil, true, false);
 }*/

NSData *sendRequestWithFullURLNAP(NSString *fullURL, NSMutableDictionary *respDict)
{
    NSLog(@"sendRequestWithFullURLNAP:%@", fullURL);
    NSDictionary *additionalHeader = nil;
    additionalHeader = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"appid", nil];
    
    return sendGetReqWithHeaderAndRespDict(fullURL, additionalHeader, respDict, false);
}

NSData *sendRequestWithCookie(NSString *phpFile, NSString *post, NSString *cookie, bool saveSetCookie) {
    
    NSDictionary *additionalHeader = nil;
    if (cookie && [cookie length] > 0) {
        additionalHeader = [NSDictionary dictionaryWithObjectsAndKeys:cookie, @"Cookie", nil];
    }
    NSData *respData = sendRequestAndNeedCookie(phpFile, post, additionalHeader, true, saveSetCookie);
    
    return respData;
}
/*
NSData *sendRequestWithFullURL(NSString *fullURL, NSString *post)
{
    NSString *finalPost = [[NSString alloc] initWithFormat:@"%@&version=2.2&deviceid=%@&source=apple", post, [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID]];
    //NSString *finalPost = [NSString stringWithFormat:@"%@&device=ios&version=%@&imei=%@", post, SERVER_VERSION, getUDID()];
    NSLog(@"sendRequestWithFullURL:%@ post:%@", fullURL, finalPost);
    
    return sendFullRequest(fullURL, finalPost, nil, true, false, false);
}*/

NSData *sendRequestWithData(NSString *url, NSData *data)
{
    if (!data || [data length] <= 0) {
        return nil;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *postLength = nil;
    NSURLResponse *response = nil;
    NSData *returnData = nil;
    NSHTTPURLResponse *httpResponse = nil;
    NSString *responseString = nil;
    
    @autoreleasepool {
        postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *fullURL = [NSString stringWithFormat:@"%@", url];
        [request setURL:[NSURL URLWithString:fullURL]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];
        returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        httpResponse = (NSHTTPURLResponse *) response;
        if ([httpResponse statusCode] != 200) {
            NSLog(@"Response error: http status %ld", (long)[httpResponse statusCode]);
            responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", responseString);
        }
        httpResponse = nil;
    }
    
    // show in the status bar that network activity is starting
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    return returnData;
}

NSData *sendFullRequest(NSString *fullURL, NSString *post, NSDictionary *additionalHeaders, bool needDispNetState, bool saveSetCookie/*, bool sendGZipContent*/)
{
    if (needDispNetState) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    
    NSData *data = nil;
    NSString *postLength = nil;
    NSURLResponse *response = nil;
    NSData *returnData = nil;
    NSHTTPURLResponse *httpResponse = nil;
    NSString *responseString = nil;
    
    @autoreleasepool {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        data = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSData *postData = nil;
        NSString *finalURL = nil;
        postData = data;
        finalURL = fullURL;
        /*if (sendGZipContent) {
            postData = [NSData gzipData:data];
            finalURL = [NSString stringWithFormat:@"%@&compressed", fullURL];
        }
        else {
            postData = data;
            finalURL = fullURL;
        }*/
        postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        [request setURL:[NSURL URLWithString:finalURL]];
        
        if (additionalHeaders) {
            NSArray *keys = additionalHeaders.allKeys;
            for (NSString *key in keys) {
                NSString *value = [additionalHeaders objectForKey:key];
                NSLog(@"POST add Header: %@ value: %@", key, value);
                [request addValue:value forHTTPHeaderField:key];
            }
        }
        [request setHTTPMethod:@"POST"];
        [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        httpResponse = (NSHTTPURLResponse *) response;
        if ([httpResponse statusCode] != 200) {
            NSLog(@"Response error: http status %ld", (long)[httpResponse statusCode]);
            responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", responseString);
        }
        
        if (saveSetCookie) {
            NSDictionary *headers = httpResponse.allHeaderFields;
            NSLog(@"setCookie resp: %@", headers);
            
            NSString *setCookie = [headers objectForKey:@"Set-Cookie"];
            if (setCookie && [setCookie length] > 0) {
                //                [CureMeUtils defaultCureMeUtil].loginCookie = setCookie;
            }
        }
        
        // show in the status bar that network activity is starting
        if (needDispNetState) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
    
    return returnData;
}

NSData * sendRequestWithHeaderAndResponse(NSString *phpFile, NSString *post, NSDictionary *additionalHeader, bool needDispNetState, bool saveSetCookie)
{
    Reachability *reachability = [Reachability reachabilityWithHostname:@"new.medapp.ranknowcn.com"];
    
    NSNotification *note = nil;
    switch ([reachability currentReachabilityStatus]) {
        case NotReachable:
            NSLog(@"new.medapp.ranknowcn.com host not reachable");
            note = [NSNotification notificationWithName:NTF_NetNotReachable object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:note];
            break;
        default:
            break;
    }
    
    // show in the status bar that network activity is starting
    if (needDispNetState) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    
    NSData *postData = nil;
    NSString *postLength = nil;
    NSURLResponse *response = nil;
    NSData *returnData = nil;
    NSHTTPURLResponse *httpResponse = nil;
    NSString *responseString = nil;
    
    @autoreleasepool {
        
        NSArray *postArray = [post componentsSeparatedByString:@"&"];
        NSString *actionStr;
        NSMutableString *exPost = [[NSMutableString alloc] init];
        for (NSString *action in postArray) {
            if ([action containsString:@"action="]) {
                actionStr = action;
                continue;
            }
            else{
                [exPost appendString:[NSString stringWithFormat:@"&%@",action]];
            }
        }
        [exPost replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
        NSString *finalPost = [exPost copy];
        
        postData = [finalPost dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *fullURL = [NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/api/%@?%@&version=3.0", phpFile,actionStr];
        [request setURL:[NSURL URLWithString:fullURL]];
        if (additionalHeader) {
            NSArray *keys = additionalHeader.allKeys;
            for (NSString *key in keys) {
                NSString *value = [additionalHeader objectForKey:key];
                NSLog(@"POST add Header: %@ value: %@", key, value);
                [request addValue:value forHTTPHeaderField:key];
            }
        }
        [request setHTTPMethod:@"POST"];
        [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        httpResponse = (NSHTTPURLResponse *) response;
        if ([httpResponse statusCode] != 200) {
            NSLog(@"Response error: http status %ld", (long)[httpResponse statusCode]);
            responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", responseString);
        }
        
        if (saveSetCookie) {
            NSDictionary *headers = httpResponse.allHeaderFields;
            NSLog(@"setCookie resp: %@", headers);
            
            NSString *setCookie = [headers objectForKey:@"Set-Cookie"];
            if (setCookie && [setCookie length] > 0) {
                [CureMeUtils defaultCureMeUtil].loginCookie = setCookie;
            }
        }
        
        // show in the status bar that network activity is starting
        if (needDispNetState) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
    
    NSString *strResp = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"sendRequestWithHeaderAndResponse reqp: %@", strResp);
    
    return returnData;
}


NSData *sendGETRequest(NSString *strUrl)
{
    return sendGetReqWithHeaderAndRespDict(strUrl, nil, nil, false);
}

NSData *sendGetReqWithHeaderAndRespDict(NSString *strUrl, NSDictionary *headers, NSMutableDictionary *respDict, bool needDispNetState)
{
    // show in the status bar that network activity is starting
    if (needDispNetState) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    NSData *data = nil;
    @autoreleasepool {
        @try {
            NSURL* url = [NSURL URLWithString:strUrl];
            NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
            [request setTimeoutInterval:30];
            [request setURL:url];
            [request setHTTPMethod:@"GET"];
            if (headers) {
                NSArray *keys = headers.allKeys;
                for (NSString *key in keys) {
                    NSString *value = [headers objectForKey:key];
                    NSLog(@"GET and header: %@ value: %@", key, value);
                    [request addValue:value forHTTPHeaderField:key];
                }
            }
            
            NSHTTPURLResponse *response = nil;
            NSError *error = nil;
            //            NSLog(@"sendGetReqWithHeaderAndRespDict request: %@", request);
            data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
            if (!data) {
                NSLog(@"sendSynchronousRequest fail with error: %@", error);
            }
            
            if (respDict) {
                NSArray *keys = response.allHeaderFields.allKeys;
                for (NSString *key in keys) {
                    [respDict setObject:[response.allHeaderFields objectForKey:key] forKey:key];
                }
            }
            
            response = nil;
            
            // show in the status bar that network activity is starting
            if (needDispNetState) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"sendGetReqWithHeaderAndRespDict exception: %@", exception);
        }
        @finally {
        }
    }
    
    return data;
}


NSData* loadRequestWithImg(NSDictionary *params,NSString *url)
{
    
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //要上传的图片
    UIImage *image=[params objectForKey:@"pic"];
    //得到图片的data
    NSData* data = UIImagePNGRepresentation(image);
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
    NSArray *keys= [params allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++)
    {
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        //如果key不是pic，说明value是字符类型，比如name：Boris
        if(![key isEqualToString:@"pic"] & ![key isEqualToString:@"token"])
        {
            //添加分界线，换行
            [body appendFormat:@"%@\r\n",MPboundary];
            //添加字段名称，换2行
            [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
            //添加字段的值
            [body appendFormat:@"%@\r\n",[params objectForKey:key]];
        }
        
    }
    
    
    if(image)
    {
        ////添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //声明pic字段，文件名为boris.png
        
        [body appendFormat:@"Content-Disposition: form-data; name=\"pic\"; filename=\"image.jpg\"\r\n"];
        //声明上传文件的格式
        [body appendFormat:@"Content-Type: image/jpeg\r\n\r\n"];
    }
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将image的data加入
    if(image)
    {
        [myRequestData appendData:data];
    }
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content;
    if(image)
    {
        content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    }
    
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    
    [request addValue:[params objectForKey:@"token"] forHTTPHeaderField:@"token"];
    //http method
    [request setHTTPMethod:@"POST"];
    
    NSData *returnData = nil;
    NSURLResponse *response = nil;
    returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    NSString *strResp = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",strResp);
    
    NSHTTPURLResponse *httpResponse = nil;
    httpResponse = (NSHTTPURLResponse *) response;
    if ([httpResponse statusCode] != 200) {
        NSLog(@"Response error: http status %ld", (long)[httpResponse statusCode]);
        NSString *responseString = nil;
        responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", responseString);
    }
    
    return returnData;
}



NSData* sendRequestAndNeedCookie(NSString *phpFile, NSString *post, NSDictionary *additionalHeader, bool needDispNetState, bool saveSetCookie)
{
    Reachability *reachability = [Reachability reachabilityWithHostname:@"new.medapp.ranknowcn.com"];
    
    NSNotification *note = nil;
    switch ([reachability currentReachabilityStatus]) {
        case NotReachable:
            NSLog(@"new.medapp.ranknowcn.com host not reachable");
            note = [NSNotification notificationWithName:NTF_NetNotReachable object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:note];
            break;
        default:
            break;
    }
    
    // show in the status bar that network activity is starting
    if (needDispNetState) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    
    NSData *postData = nil;
    NSString *postLength = nil;
    NSURLResponse *response = nil;
    NSData *returnData = nil;
    NSHTTPURLResponse *httpResponse = nil;
    NSString *responseString = nil;
    
    @autoreleasepool {
        postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setURL:[NSURL URLWithString:phpFile]];
        if (additionalHeader) {
            NSArray *keys = additionalHeader.allKeys;
            for (NSString *key in keys) {
                NSString *value = [additionalHeader objectForKey:key];
                NSLog(@"POST add Header: %@ value: %@", key, value);
                [request addValue:value forHTTPHeaderField:key];
            }
        }
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        httpResponse = (NSHTTPURLResponse *) response;
        if ([httpResponse statusCode] != 200) {
            NSLog(@"Response error: http status %ld", (long)[httpResponse statusCode]);
            responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", responseString);
        }
        
        if (saveSetCookie) {
            NSDictionary *headers = httpResponse.allHeaderFields;
            NSLog(@"setCookie resp: %@", headers);
            
            NSString *setCookie = [headers objectForKey:@"Set-Cookie"];
            if (setCookie && [setCookie length] > 0) {
                [CureMeUtils defaultCureMeUtil].loginCookie = setCookie;
            }
        }
        
        // show in the status bar that network activity is starting
        if (needDispNetState) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
    
    NSString *strResp = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"sendRequestWithHeaderAndResponse reqp: %@", strResp);
    
    return returnData;
}


#pragma mark Json parse methods
NSDictionary *parseJsonString(NSString *str)
{
    if (!str || str.length <= 0)
        return nil;
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
}

NSDictionary *parseJsonResponse(NSData *response)
{
    if (!response)
        return nil;
    
    if ([response length] <= 0) {
        return nil;
    }
    
    NSError *error = nil;
    return [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&error];
}
/*
NSDictionary *parseJsonString(NSString *str)
{
    if (!str || str.length <= 0)
        return nil;
    
    JSONDecoder *decoder = [CureMeUtils defaultCureMeUtil].jsonDecoder;
    
    NSMutableDictionary *parseResult = nil;
    
    NSError *error = nil;
    parseResult = [decoder objectWithUTF8String:(const unsigned char*)[str UTF8String] length:[str lengthOfBytesUsingEncoding:NSUTF8StringEncoding] error:&error];
    
    //    NSLog(@"JsonData %@ from string: %@", parseResult, str);
    
    return parseResult;
}

NSDictionary *parseJsonResponse(NSData *response)
{
    if (!response)
        return nil;
    
    JSONDecoder *decoder = [CureMeUtils defaultCureMeUtil].jsonDecoder;
    
    NSMutableDictionary *parseResult = nil;
    if ([response length] <= 0) {
        return parseResult;
    }
    
    parseResult = [decoder objectWithData:response];
    
    return parseResult;
}*/


void updateIOSPushInfo()
{
    NSString *pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN];
    NSString *uniID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID];
    /*UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:uniID
                          message:pushToken
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];*/
   
    if (!uniID || !pushToken)
        return;
    
    NSString *post = [[NSString alloc] initWithFormat:@"action=updiospush&userid=%ld&token=%@", (long)[[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] integerValue], pushToken];
    NSData *response = sendRequest(@"m.php", post);
    
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"action=updiospush resp: %@", strResp);
    
    NSDictionary *jsonData = parseJsonResponse(response);
    if (!jsonData || jsonData.count <= 0) {
        NSLog(@"action=updiospush json invalid: %@", strResp);
        return;
    }
    
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!result || result.integerValue != 1) {
        NSString *error = [jsonData objectForKey:@"msg"];
        NSLog(@"action=updiospush result invalid: %@", error);
        return;
    }
}

id JsonValue(id value, NSString *defaultClass)
{
    if (!value) {
        if (!defaultClass || [defaultClass length] <= 0)
            return nil;
        
        return [[NSClassFromString(defaultClass) alloc] init];
    }
    
    if ([value isKindOfClass:[NSNull class]])
        return [[NSClassFromString(defaultClass) alloc] init];
    
    return value;
}

NSDate* convertDateFromString(NSString *sdate, NSString *format)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:format];
    NSDate *date=[formatter dateFromString:sdate];
    return date;
}

NSString* convertStringFromDate(NSDate *date, NSString *format)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

NSString* removeHTML(NSString *html)
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    return html;
    /*
     NSArray *components = [html componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
     NSMutableArray *componentsToKeep = [NSMutableArray array];
     for (int i = 0; i < [components count]; i = i + 2) {
     [componentsToKeep addObject:[components objectAtIndex:i]];
     }
     NSString *plainText = [componentsToKeep componentsJoinedByString:@""];
     return plainText;*/
}

NSString* urlEncode(NSString *str)
{
    if (!str || str.length==0)
        return @"";
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[str UTF8String];
    NSInteger sourceLen = strlen((const char *)source);
    for (NSInteger i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

NSString* replaceUnicode(NSString *unicodeStr)
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    //NSLog(@"%@",returnStr);
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}
