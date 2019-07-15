//
//  MessageInfo.h
//
//  Created by xiaoshoucun on 15/10/30.
//  Copyright (c) 2015年 Hesine. All rights reserved.
//

#import "HAttachInfo.h"

@protocol HMessageInfo @end
@class MessageInfo;

@interface HMessageInfo : NSObject

@property (nonatomic, strong)NSString *msgId;
@property (nonatomic, assign)long time;
@property (nonatomic, strong)NSString *from;
@property (nonatomic, strong)NSString *to;
@property (nonatomic, strong)NSString *body;
@property (nonatomic, assign)int status;
@property (nonatomic, assign)int type;
@property (nonatomic, strong)NSString *subject;
@property (nonatomic, strong)HAttachInfo *attachInfo;

-(void) updateToDB; // if you modify any feild that
                    // need update to DB, call this.

-(id) initWithMessageInfo:(MessageInfo*) msg;

@end
