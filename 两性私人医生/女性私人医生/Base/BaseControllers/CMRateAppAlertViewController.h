//
//  CMRateAppAlertViewController.h
//  私密健康医生
//
//  Created by Tim on 13-1-23.
//  Copyright (c) 2013年 Tim. All rights reserved.
//


#import <UIKit/UIKit.h>


@protocol CMRateAppAlertViewControllerDelegate <NSObject>

@required
- (void)confirmBtnClickForDelegate;
- (void)cancelBtnClickForDelegate;

@end



@interface CMRateAppAlertViewController : UIViewController

@property (nonatomic, strong) NSString *msgTitle;
@property (nonatomic, strong) NSString *msgContent;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic, strong) id<CMRateAppAlertViewControllerDelegate> delegate;

- (IBAction)confirmBtnClicked:(id)sender;
- (IBAction)cancelBtnClick:(id)sender;

@end
