//
//  HiChatServerInfo.h
//
//  Created by xiaoshoucun on 15/10/30.
//  Copyright (c) 2015年 Hesine. All rights reserved.
//

#import "JSONModel.h"

@interface HiChatServerInfo : JSONModel

@property (nonatomic, strong)NSString *serverIp;
@property (nonatomic, strong)NSString *serverPort;

@end
