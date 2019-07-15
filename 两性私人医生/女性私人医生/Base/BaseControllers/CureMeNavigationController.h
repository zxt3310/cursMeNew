//
//  CureMeNavigationController.h
//  CureMe
//
//  Created by Tim on 12-8-10.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CureMeNavigationController : UINavigationController

{
    UIViewController* rootViewController;
}

@property (nonatomic, strong) UIButton *unreadMsgBtn;

- (void)setUnreadMsgCount:(NSInteger)unreadCount;

- (void)SetNavRootViewController:(UIViewController *)controller;

@end
