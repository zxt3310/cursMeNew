//
//  CMAlertViewController.m
//  私密健康医生
//
//  Created by Tim on 13-1-23.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMAlertViewController.h"
#import "KGModal.h"


@interface CMAlertViewController ()

@end

@implementation CMAlertViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setMessageLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    _titleLabel.text = _msgTitle;
    _messageLabel.text = _msgContent;
    
    [super viewWillAppear:animated];
}

- (IBAction)confirmBtnClicked:(id)sender {
    [[KGModal sharedInstance] hideAnimated:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(confirmBtnClickForDelegate)]) {
        [_delegate confirmBtnClickForDelegate];
    }
}
@end
