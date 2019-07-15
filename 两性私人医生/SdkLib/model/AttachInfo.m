//
//  AttachInfo.m
//  HiChat
//
//  Created by xiaoshoucun on 15/10/29.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import "AttachInfo.h"

@implementation AttachInfo

+ (NSString *)__documentsDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+(NSString*) getAttachPath:(int) attachType withName:(NSString*) name {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *dir = [[AttachInfo __documentsDir] stringByAppendingPathComponent:@"attachment"];
    NSString* nextDir = nil;
    NSError *error;
    if (![fileMgr fileExistsAtPath:dir]) {
        if (![fileMgr createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"create file path fail dir:%@,error:%@",dir,error);
        }
        
    }
    switch (attachType) {
        case 0:
            return nil;
        case 1:
            nextDir = [dir stringByAppendingPathComponent:@"image"];
            break;
        case 2:
            nextDir = [dir stringByAppendingPathComponent:@"video"];
            break;
        case 3:
            nextDir = [dir stringByAppendingPathComponent:@"audio"];
            break;
        default:
            nextDir = [dir stringByAppendingPathComponent:@"file"];
            break;
    }
    
    if (![fileMgr fileExistsAtPath:nextDir]) {
        if (![fileMgr createDirectoryAtPath:nextDir withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"create file path fail nextDir:%@,error:%@",nextDir,error);
        }
    }
    return [nextDir stringByAppendingPathComponent:name];
}

+(NSString*) getAttachThumbnailPath:(NSString*) name {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *dir = [[AttachInfo __documentsDir] stringByAppendingPathComponent:@"attachment"];
    NSString* nextDir = [dir stringByAppendingPathComponent:@"thumbnail"];
    NSError *error;
    if (![fileMgr fileExistsAtPath:dir]) {
        if (![fileMgr createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"create file path fail dir:%@,error:%@",dir,error);
        }
        
    }
    
    if (![fileMgr fileExistsAtPath:nextDir]) {
        if (![fileMgr createDirectoryAtPath:nextDir withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"create file path fail nextDir:%@,error:%@",nextDir,error);
        }
    }
    return [nextDir stringByAppendingPathComponent:name];
}

@end