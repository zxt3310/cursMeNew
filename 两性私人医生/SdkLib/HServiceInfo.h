//
//  HServiceInfo.h
//  HiChat
//
//  Created by xiaoshoucun on 15/12/21.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HServiceInfo @end

@interface HServiceInfo : NSObject

@property (nonatomic, strong)NSString *account;
@property (nonatomic, assign)int status;
@property (nonatomic, strong)NSString *nickName;

@end