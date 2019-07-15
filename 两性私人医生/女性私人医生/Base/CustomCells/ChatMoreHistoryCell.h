//
//  ChatMoreHistoryCell.h
//  CureMe
//
//  Created by Tim on 12-9-13.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BubbleViewController;

@interface ChatMoreHistoryCell : UITableViewCell

{
    UILabel *moreHistoryLabel;
}

@property (nonatomic, strong) BubbleViewController *chatViewController;

- (void)generateLayout;

@end
