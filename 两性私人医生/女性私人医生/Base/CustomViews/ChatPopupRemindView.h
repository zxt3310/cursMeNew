//
//  ChatPopupRemindView.h
//  CureMe
//
//  Created by Tim on 12-12-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatPopupRemindView : UIView

{
    UILabel *textLabel;
}

@property (readonly) bool isShowing;
@property (nonatomic, strong) NSString *remindText;

- (void)fadeIn;
- (void)fadeOut;

@end
