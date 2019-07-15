//
//  AttachInfo.m
//  HiChat
//
//  Created by xiaoshoucun on 15/10/29.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import "HAttachInfo.h"

@implementation HAttachInfo

-(void) dataFromUrl:(NSString*) url completion: (callBackGetAttachment) block
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void)
                   {
                       NSString* webStringURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                       NSURL* uRL = [NSURL URLWithString:webStringURL];
                       NSData * data = [[NSData alloc] initWithContentsOfURL:uRL];
                       [data writeToFile:[self path] atomically:YES];
                       dispatch_async( dispatch_get_main_queue(), ^(void){
                           if( data != nil )
                           {
                               if (nil != block) {
                                   block(data, nil);
                                   //[data release];
                               }
                           } else {
                               NSError *err =  [NSError errorWithDomain:@"get attachment fail"
                                                                   code:1
                                                               userInfo:nil];
                               if (nil != block) {
                                   block(nil, err);
                               }
                           }
                       });
                   });
}

-(bool) getAttachment:(callBackGetAttachment) block {
    if (nil != [self path]) {
        NSData * data = [[NSData alloc] initWithContentsOfFile:[self path]];
        if (nil != data) {
            if (nil != block) {
                block(data, nil);
                //[data release];
            }
            return true;
        }
    }
    if (nil != [self url]) {
        [self  dataFromUrl:[self url] completion:block];
        return true;
    }
    
    return false;
}

@end
