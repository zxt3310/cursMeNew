//
//  CMNewQueryViewController.h
//  私密健康医生
//
//  Created by jongs zhong on 16/2/29.
//  Copyright © 2016年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMCustomViews.h"
#import "CustomBaseViewController.h"
#import "UINewBubbleTableViewDataSource.h"
#import "Doctor.h"
#import "ImageDownloadHelper.h"
#import "HiChat.h"

enum NewScrollAdjustType {
    NSCROLLTOEND = 0,
    NSCROLLNONE
};

static bool needStopDetectReplies;

@class Doctor;
@class UINewBubbleTableView;
@class LoadingView;

@interface CMNewQueryViewController : CustomBaseViewController<UINewBubbleTableViewDataSource, ImageDownloadHelperDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    LoadingView *loadingView;
    // 聊天过程中，生成的
    NSInteger chatBookID;
    
    NSMutableDictionary *doctorImages;
    NSMutableDictionary *doctorNames;
    NSMutableDictionary *doctorIDImageKeys;

    ImageDownloadHelper *imageDownloader;
}

@property (nonatomic) NSInteger officeType;
@property (nonatomic) NSInteger subOfficeType;

@property (nonatomic, strong) UINewBubbleTableView *bubbleTable;
@property (nonatomic,retain) NSMutableArray *bubbleData;

@property (nonatomic, strong) Doctor *doctor;
@property (nonatomic, strong) BookInfoUnit *bookInfoUnit;
@property double hospitalLongitude;
@property double hospitalLatitude;

@property NSNumber *questionID;
@property NSInteger chatID;
@property NSInteger chatSWTID;
@property NSInteger chatUserID;
@property NSInteger doctorID;
@property NSInteger swtUserID;
/**
 *  @author Zxt, 17-03-27 10:03:16
 *
 *  是否允许分配到医爱淘
 */
@property BOOL isAllowToiatao;
@property NSString *chatHistoryType;

- (NSMutableDictionary *)doctorNames;
- (NSString *)doctorNameWithDoctorID:(NSInteger)doctorID;

- (UIImage *)doctorHeadImageWithImageKey:(NSString *)imageKey;

- (void)reloadData:(NSNumber *)newScrollAdjustType;

- (void)showBookingPage;
- (void)showHospitalMapPage;

- (void)closeKeyboard;

@end
