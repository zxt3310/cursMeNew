//
//  UINewBubbleTableViewTelephoneCell.h
//  CureMe
//
//  Created by Tim on 12-11-2.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMNewQueryViewController.h"
#import "NSBubbleDataInternal.h"


@interface UINewBubbleTableViewTelephoneCell : UITableViewCell

{
    UIImageView *background;
    
    UILabel *headerLabel;
    UILabel *dscpLabel;
    UIButton *callBtn;
}

@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *telephone;
@property (nonatomic, strong) NSBubbleDataInternal *dataInternal;
@property (nonatomic, strong) CMNewQueryViewController *bubbleViewController;

- (IBAction)callTel:(id)sender;
- (void)callTelephone;

- (void)generateLayout;

@end
