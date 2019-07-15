//
//  CMDatePickerViewController.m
//  私密健康医生
//
//  Created by Tim on 13-2-4.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMDatePickerViewController.h"
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>

@interface CMDatePickerViewController ()

@end

@implementation CMDatePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_background.layer setCornerRadius:3.0];
    _background.clipsToBounds = YES;
    
    [_datePicker setDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dateSelected:(id)sender {
    NSLog(@"dateSelected");
    
    if (_delegate && [_delegate respondsToSelector:@selector(dateSelected:)]) {
        [_delegate dateSelected:_datePicker.date];
    }
    
    [[KGModal sharedInstance] hideAnimated:YES];
}

- (void)viewDidUnload {
    [self setDatePicker:nil];
    [self setBackground:nil];
    [super viewDidUnload];
}
@end
