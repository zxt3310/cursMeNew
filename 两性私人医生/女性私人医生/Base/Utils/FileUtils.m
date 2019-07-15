//
//  FileUtils.m
//  CureMe
//
//  Created by Tim on 12-8-15.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "FileUtils.h"

bool dateHasExcedded(NSDate *date, NSDate *nowDate)
{
    if (!date)
        return true;
    
    if (!nowDate)
        return false;

    if ([[[CureMeUtils defaultCureMeUtil].shortDateFormatter stringFromDate:date] isEqualToString:[[CureMeUtils defaultCureMeUtil].shortDateFormatter stringFromDate:nowDate]]) {
        return false;
    }
    
    NSTimeInterval interval = [date timeIntervalSinceDate:nowDate];
    if (interval < 0)
        return true;
    
    return false;
}

NSString *pathDocumentDirectory()
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [documentDirectories objectAtIndex:0];
}

NSString *pathInDocumentDirectory(NSString *fileName)
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:fileName];
}