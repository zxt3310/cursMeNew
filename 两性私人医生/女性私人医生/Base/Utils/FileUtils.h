//
//  FileUtils.h
//  CureMe
//
//  Created by Tim on 12-8-15.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

// 获得Document目录
NSString *pathDocumentDirectory();

// 获得Document目录下某文件的全路径
NSString *pathInDocumentDirectory(NSString *fileName);

// 判断时间是否已过期，当天日期内有效
bool dateHasExcedded(NSDate *date, NSDate *nowDate);
