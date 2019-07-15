//
//  CMMarkDoctorViewController.h
//  私密健康医生
//
//  Created by Tim on 13-1-21.
//  Copyright (c) 2013年 Tim. All rights reserved.
//


#import "CustomBaseViewController.h"


@protocol CMMarkDoctorViewControllerDelegate <NSObject>

@required
- (void)pointMarked:(NSInteger)point withComment:(NSString *)comment;

@end


@interface CMMarkDoctorViewController : UIViewController<UIAlertViewDelegate>
{
    bool hasComment;
    NSString *lastCommentString;
}

@property NSInteger chatID;
// 1、差 6、中 10、好
@property (nonatomic) NSInteger markPoint;
@property (nonatomic, strong) NSString *markComment;

@property (nonatomic, assign) id<CMMarkDoctorViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *background;
@property (strong, nonatomic) IBOutlet UIButton *markGoodBtn;
@property (strong, nonatomic) IBOutlet UIButton *markNormalBtn;
@property (strong, nonatomic) IBOutlet UIButton *markBadBtn;
@property (strong, nonatomic) IBOutlet UITextField *commentField;

- (void)updateMarkBtnDisplay;

- (IBAction)markBtnClicked:(id)sender;

- (IBAction)submitBtnClicked:(id)sender;
- (IBAction)cancelBtnClicked:(id)sender;

@end
