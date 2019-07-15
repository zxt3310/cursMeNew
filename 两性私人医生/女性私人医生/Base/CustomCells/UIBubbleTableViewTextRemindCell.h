//
//  UIBubbleTableViewTextRemindCell.h
//  CureMe
//
//  Created by Tim on 12-12-20.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "BubbleViewController.h"
#import "NSBubbleData.h"
#import "NSBubbleDataInternal.h"
#import <UIKit/UIKit.h>

@interface UIBubbleTableViewTextRemindCell : UITableViewCell

{
    UILabel *textRemind;
}

@property (nonatomic, strong) NSString *remind;
@property (nonatomic, strong) NSBubbleDataInternal *dataInternal;
@property (nonatomic, strong) BubbleViewController *bubbleViewController;

- (void)generateLayout;

@end
