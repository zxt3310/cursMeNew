//
//  ImageDownloadHelper.h
//  CureMe
//
//  Created by Tim on 12-9-13.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageDownloadHelperDelegate <NSObject>

@optional

@required

- (void)imageDownloadComplete:(NSString *)imageKey andType:(NSString *)type andImage:(UIImage*)image;

- (void)allImageComplete;

@end



@interface ImageDownloadHelper : NSObject

{
    NSMutableDictionary *imageKeyDict;
}

// 无尽模式
@property bool endlessMode;
@property bool shouldEnd;
@property bool isRunning;

@property (nonatomic, assign) id<ImageDownloadHelperDelegate> delegate;

- (void)addImageKey:(NSString *)imageKey andSizeType:(NSString *)type;

- (void)startDownload;
- (void)threadDownloadImages;

@end
