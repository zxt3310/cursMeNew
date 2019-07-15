//
//  ImageDownloadHelper.m
//  CureMe
//
//  Created by Tim on 12-9-13.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "ImageDownloadHelper.h"

@implementation ImageDownloadHelper

@synthesize endlessMode = _endlessMode;
@synthesize shouldEnd = _shouldEnd;
@synthesize isRunning = _isRunning;

- (id)init
{
    self = [super init];
    if (self) {
        _endlessMode = false;
        _shouldEnd = false;
    }
    
    return self;
}

- (void)addImageKey:(NSString *)imageKey andSizeType:(NSString *)type
{
    if (!imageKeyDict) {
        imageKeyDict = [[NSMutableDictionary alloc] init];
    }
    
    if (!imageKey || imageKey.length <= 0 || !type || type.length <= 0) {
        NSLog(@"ImageDownloadHelper addImageKey invalid info: %@ %@", imageKey, type);
//        NSLog(@"addImageKey call stack: %@", [NSThread callStackSymbols]);
        return;
    }

    imageKey = [[NSString alloc] initWithFormat:@"%@-%@", imageKey, type];
//    // 去重，不重复下载相同文件（此处假设一个downloadhelper里下载同一尺寸类型图片）
    NSArray *keys = [imageKeyDict allKeys];
    for (NSString *key in keys) {
        if ([key isEqualToString:imageKey])
            return;
    }

//    NSLog(@"typedImageKey: %@", imageKey);

    [imageKeyDict setObject:type forKey:imageKey];
}

- (void)startDownload
{
    if (!_isRunning) {
        [NSThread detachNewThreadSelector:@selector(threadDownloadImages) toTarget:self withObject:nil];
    }
}

- (void)threadDownloadImages
{
    @autoreleasepool {
        _isRunning = true;
        do {
            if (!_endlessMode && (!imageKeyDict || imageKeyDict.count <= 0)) {
                break;
            }
            
            if (!self.delegate) {
                NSLog(@"ImageDownloadHelper delegate invalid");
                break;
            }
            
            if (_shouldEnd)
                break;
            
            // 逐一取出数据，获取图片，并通知Delegate
            NSArray *keys = [imageKeyDict allKeys];
            
            // 如果无尽模式下，无图片，则等待十秒后重试
            if (_endlessMode && (!keys || keys.count <= 0)) {
                sleep(5);
                continue;
            }
            
            for (NSString *key in keys) {
                NSArray *strs = [key componentsSeparatedByString:@"-"];
                NSString *realKey = [strs objectAtIndex:0];
//                NSLog(@"RealKey: %@", realKey);

                UIImage *image = [[CureMeUtils defaultCureMeUtil] getImageByKey:realKey andSize:[imageKeyDict objectForKey:key]];
                
                if (self.delegate && image) {
                    [self.delegate imageDownloadComplete:realKey andType:[imageKeyDict objectForKey:key] andImage:image];
                }
                
                [imageKeyDict removeObjectForKey:key];
                
                if (_shouldEnd)
                    break;
            }
            
            if (self.delegate) {
                [self.delegate allImageComplete];
            }
            
            if (_shouldEnd)
                break;
        } while (_endlessMode);
        
        _isRunning = false;
    }
}

@end
