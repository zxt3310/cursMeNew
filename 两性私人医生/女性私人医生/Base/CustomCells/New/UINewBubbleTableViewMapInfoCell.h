//
//  UINewBubbleTableViewMapInfoCell.h
//  CureMe
//
//  Created by Tim on 12-11-2.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSBubbleDataInternal.h"
#import "CMNewQueryViewController.h"
#import "BMapKit.h"


@interface UINewBubbleTableViewMapInfoCell : UITableViewCell

{
    UIImageView *background;
    
    UIImageView *pinImage;
    UIImageView *mapImage;
    UILabel *addrInfoLabel;

    UILabel *headerLabel;
}

@property double latitude;
@property double longitude;
@property (nonatomic, strong) CMNewQueryViewController *bubbleViewController;
@property (nonatomic, strong) NSBubbleDataInternal *dataInternal;

- (void)threadGetMapImage;
- (void)mainThreadRefresh;

- (void)generateLayout;

@end
