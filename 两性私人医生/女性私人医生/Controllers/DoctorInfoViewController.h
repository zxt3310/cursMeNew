//
//  DoctorInfoViewController.h
//  CureMe
//
//  Created by Tim on 12-8-27.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "ImageDownloadHelper.h"
#import "CustomBaseViewController.h"
#import <UIKit/UIKit.h>

@class Doctor;

@interface DoctorInfoViewController : CustomBaseViewController<ImageDownloadHelperDelegate>

{
    Doctor *doctor;
    
    UIImage *headImage;
    ImageDownloadHelper *imageDownloadHelper;
}

@property NSInteger doctorID;
@property (strong, nonatomic) IBOutlet UIScrollView *infoScroll;
@property (strong, nonatomic) IBOutlet UIImageView *doctorHeadImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *officeLabel;
@property (strong, nonatomic) IBOutlet UILabel *hospitalLabel;
@property (strong, nonatomic) IBOutlet UILabel *introLabel;

-(IBAction)startTalk:(id)sender;
-(IBAction)startBook:(id)sender;

- (void)threadInitDoctorInfo;
- (void)startImageDownload;
- (void)updateDisplay;

@end
