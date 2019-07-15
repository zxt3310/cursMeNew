//
//  InfoListTableViewController.h
//  CureMe
//
//  Created by Tim on 12-8-30.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "ImageDownloadHelper.h"
#import "CustomTableBaseViewController.h"


@class XYLoadingView;

@interface InfoListTableViewController : CustomTableBaseViewController<ImageDownloadHelperDelegate>

{
    NSMutableArray *dataList;
    XYLoadingView *loadingView;
    
    NSMutableDictionary *headImageDict;
    ImageDownloadHelper *imageDownloadHelper;
}

@property NSInteger officeType;
@property NSInteger listType;
@property NSInteger hospitalID;

- (void)startImageDownload;
- (UIImage *)getHeadImage:(NSString *)imageKey;

- (void)threadInitInfoData;
- (void)initDoctorInfoData:(int)officeType;
- (void)initHospitalInfoData:(int)officeType;
- (void)initMyBookInfoData;

- (void)showHospitalInfoPage:(NSInteger)hospID;
- (void)showDoctorInfoPage:(NSInteger)doctorID;
- (void)showBookDetailInfoPage:(NSInteger)bookingID andHospitalID:(NSInteger)hID;

@end
