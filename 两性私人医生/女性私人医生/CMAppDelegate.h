//
//  CMAppDelegate.h
//  私密健康医生
//
//  Created by Tim on 13-1-9.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CureMeNavigationController.h"
#import "Mixpanel.h"

NSString *getCrashFilePathName();

@class CMMainTabViewController;

@interface CMAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

{
    CMMainTabViewController* mainTabViewController;
    
    NSDictionary *alertJsonData;
    NSDictionary *pushJsonData;
}

@property (nonatomic, strong) CureMeNavigationController *navigationController;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CMAppDelegate *)Delegate;

//- (void)saveContext;

// 告知服务端push已读
- (void)sendPushMsgReadRequest;

- (UIViewController *)processBackgroundPush;

- (UIViewController *)processChatPush;
- (UIViewController *)processChatListPush;
- (UIViewController *)processBookingPush;
- (UIViewController *)processBookingListPush;
- (UIViewController *)processHuodongPush;
- (UIViewController *)processHuodongListPush;
- (UIViewController *)processOpenURLPush;
- (UIViewController *)processNewAppPush;

- (NSURL *)applicationDocumentsDirectory;

//- (void)threadUploadCrashDataWithFileHandle;

@end
