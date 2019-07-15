//
//  CMDatePickerViewController.h
//  私密健康医生
//
//  Created by Tim on 13-2-4.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMDatePickerViewControllerDelegate <NSObject>

- (void)dateSelected:(NSDate *)date;

@end

@interface CMDatePickerViewController : UIViewController

{
    NSDate *selectedDate;
}

@property (nonatomic, assign) id<CMDatePickerViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIImageView *background;

- (IBAction)dateSelected:(id)sender;

@end
