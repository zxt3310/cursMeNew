//
//  CMLogUtils.h
//  私密健康医生
//
//  Created by Tim on 13-1-9.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

bool WriteLog(NSString *format, ...);

@interface CMLogUtils : NSObject

+ (CMLogUtils *)defaultLogUtils;

@end
