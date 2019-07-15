//
//  CMChatHeaderBtnView.h
//  私密健康医生
//
//  Created by Tim on 13-1-16.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "BubbleViewController.h"
#import <UIKit/UIKit.h>

@interface CMChatHeaderBtnView : UIView

@property NSString *headImageKey;
@property UIImageView *backgroundImage;
@property UIImageView *headImage;
@property UIImageView *headImageFrame;
@property UILabel *name;
@property UILabel *info;
@property UIButton *bookBtn;

@property UIBubbleTableView *tableView;
@property BubbleViewController *bubbleViewController;

- (id)initWithBubbleViewController:(BubbleViewController *)viewController andInView:(UIBubbleTableView *)tableView;

- (IBAction)bookBtnClick:(id)sender;

- (void)updateData;

- (void)show:(BOOL)animated;
- (void)fadeIn;
- (void)hide;
- (void)fadeOut;

@end
