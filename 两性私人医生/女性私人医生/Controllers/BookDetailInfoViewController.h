//
//  BookDetailInfoViewController.h
//  CureMe
//
//  Created by Tim on 12-9-20.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "CustomBaseViewController.h"
#import <UIKit/UIKit.h>

@interface BookDetailInfoViewController : CustomBaseViewController

{
    bool hasPassedBookValidating;
}

@property NSInteger bookingID;
@property NSInteger hospitalID;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *hospitalLabel;
@property (strong, nonatomic) IBOutlet UILabel *officeLabel;
@property (strong, nonatomic) IBOutlet UILabel *bookTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *submitTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *genderLabel;
@property (strong, nonatomic) IBOutlet UILabel *telephoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *memoLabel;
@property (strong, nonatomic) IBOutlet UILabel *hospitalReply;
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) IBOutlet UIImageView *passStateBgImageView;
@property (strong, nonatomic) IBOutlet UIImageView *submitStateBgImageView;

- (IBAction)modifyBookInfo:(id)sender;

- (void)initBookDetailInfo;

@end
