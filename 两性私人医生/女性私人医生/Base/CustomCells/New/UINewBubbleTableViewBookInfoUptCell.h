//
//  UINewBubbleTableViewBookInfoUptCell.h
//  CureMe
//
//  Created by Tim on 12-11-7.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "NSBubbleDataInternal.h"
#import "CMNewQueryViewController.h"
#import <UIKit/UIKit.h>

@interface UINewBubbleTableViewBookInfoUptCell : UITableViewCell

{
    UIImageView *background;
    
    UILabel *dscpLabel;
    UIButton *updateBookBtn;
    
    UILabel *headerLabel;
}

@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSBubbleDataInternal *dataInternal;
@property (nonatomic, strong) CMNewQueryViewController *bubbleViewController;

- (void)showBookDetailPage;

- (void)generateLayout;

@end
