//
//  AttachInfo.h
//  HiChat
//
//  Created by xiaoshoucun on 15/10/29.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^callBackGetAttachment)(NSData* data, NSError* error);

@protocol HAttachInfo @end

@interface HAttachInfo : NSObject

@property (nonatomic, assign)int type;        // attachment type, value of
                                              // ATTACHMENT_TYPE defined in HiChat.h.
@property (nonatomic, strong)NSString *name;  // display name.
@property (nonatomic, assign)long size;       // attachment size.

@property (nonatomic, strong)NSString *url;    // remote path for the attachment.
@property (nonatomic, strong)NSString *path;    // local path for the attachment.
@property (nonatomic, strong)NSData *thumbnail; // If not exist, will be nil.

-(bool) getAttachment:(callBackGetAttachment) block; // if not exist, return false, or else will
                                                     // aync return attachment data by callback.

@end

