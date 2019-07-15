//
//  MessageInfo.m
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#import "HMessageInfo.h"
#import "MessageInfo.h"

@implementation HMessageInfo

- (void)dealloc
{
    self.to = nil;
    self.from = nil;
    self.msgId = nil;
    self.body = nil;
    self.attachInfo = nil;
    _subject = nil;
}

-(void) updateToDB {
    MessageInfo* msg = [MessageInfo JM_find:[self msgId]];
    if (nil == msg) {
        msg = [[MessageInfo alloc] init];
    }
    [msg setMsgId:[self msgId]];
    [msg setTime:[self time]];
    [msg setFrom:[self from]];
    [msg setTo:[self to]];
    [msg setBody:[self body]];
    [msg setStatus:[self status]];
    [msg setType:[self type]];
    [msg setSubject:[self subject]];

    HAttachInfo* hai = [self attachInfo];
    if (nil != hai) {
        AttachInfo* ai = [msg attachInfo];
        if (nil == ai) {
            ai = [[AttachInfo alloc] init];
        }
        [ai setType:[hai type]];
        [ai setName:[hai name]];
        [ai setSize:[hai size]];
        [ai setUrl:[hai url]];
        [ai setPath:[hai path]];
        if (nil != [hai thumbnail]) {
            [ai setAttachment:nil];
        }
    }
    
    [msg save];
}

-(id) initWithMessageInfo:(MessageInfo*) msg
{
    self = [super init];
    
    if (self && msg) {
        [self setMsgId:[msg msgId]];
        [self setTime:[msg time]];
        [self setFrom:[msg from]];
        [self setTo: [msg to]];
        [self setBody:[msg body]];
        [self setStatus:[msg status]];
        [self setType:[msg type]];
        [self setSubject:[msg subject]];
        AttachInfo* ai = [msg attachInfo];
        if (nil != ai) {
            HAttachInfo* hai = [[HAttachInfo alloc] init];
            [hai setType:[ai type]];
            [hai setName:[ai name]];
            [hai setSize:[ai size]];
            [hai setUrl:[ai url]];
            
            [hai setPath:[AttachInfo getAttachPath:[ai type] withName:[ai name]]];
            [hai setThumbnail:[NSData dataWithContentsOfFile:[AttachInfo getAttachThumbnailPath:[ai name]]]];

            [self setAttachInfo:hai];
        }
    }
    return self;
}

@end