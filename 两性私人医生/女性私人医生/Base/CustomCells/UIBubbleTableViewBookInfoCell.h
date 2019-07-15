//
//  UIBubbleTableViewBookInfoCell.h
//  CureMe
//
//  Created by Tim on 12-11-2.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSBubbleData.h"
#import "NSBubbleDataInternal.h"
#import "BubbleViewController.h"

@interface UIBubbleTableViewBookInfoCell : UITableViewCell

{
    UILabel *remindLabel;
    UILabel *bookTitleLabel;
    UILabel *hosLabel;
    UILabel *officeLabel;
    UILabel *dateLabel;
    UILabel *nameLabel;
    UILabel *telLabel;
    UILabel *ageLabel;
    UILabel *memoLabel;
    
    UILabel *hospitalName;
    UILabel *officeName;
    UILabel *date;
    UILabel *name;
    UILabel *age;
    UILabel *telephone;
    UILabel *memory;
    
    UILabel *headerLabel;
    UIImageView *backgroundImage;
    UIButton *bookBtn;
}

@property (nonatomic, strong) BookInfoUnit *bookInfoUnit;
@property (nonatomic, strong) BubbleViewController *bubbleViewController;
@property (nonatomic, strong) NSBubbleDataInternal *dataInternal;

- (IBAction)updateBookInfo:(id)sender;

- (void)generateLayout;

@end
