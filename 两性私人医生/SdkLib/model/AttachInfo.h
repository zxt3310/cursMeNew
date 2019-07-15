//
//  AttachInfo.h
//  HiChat
//
//  Created by xiaoshoucun on 15/10/29.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import "JSONModel.h"

@protocol AttachInfo @end

@interface AttachInfo : JSONModel

@property (nonatomic, assign)int type;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, assign)long size;

@property (nonatomic, strong)NSString *url;
@property (nonatomic, strong)NSString *path;
@property (nonatomic, strong)NSString *md5;
@property (nonatomic, strong)NSString<JMText> *attachment;

@property (nonatomic, strong)NSString<JMPrimaryKey> *msgId;

+(NSString*) getAttachPath:(int) attachType withName:(NSString*) name;
+(NSString*) getAttachThumbnailPath:(NSString*) name;

@end

