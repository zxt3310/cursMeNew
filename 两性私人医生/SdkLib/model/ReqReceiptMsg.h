//
//  ReqReceiptMsg.h
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Hesine. All rights reserved.
//

#import "ReqBase.h"

@protocol NSString @end

@interface ReqReceiptMsg : ReqBase

@property (nonatomic, strong) NSArray<NSString> *recvMsgList;

@end