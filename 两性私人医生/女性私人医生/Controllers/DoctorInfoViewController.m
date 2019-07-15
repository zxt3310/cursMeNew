//
//  DoctorInfoViewController.m
//  CureMe
//
//  Created by Tim on 12-8-27.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "Doctor.h"
//#import "BookingViewController.h"
#import "BubbleViewController.h"
#import "LoginViewController.h"
#import "QueryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DoctorInfoViewController.h"

@interface DoctorInfoViewController ()

@end

@implementation DoctorInfoViewController

@synthesize doctorHeadImageView = _doctorHeadImageView;
@synthesize nameLabel = _nameLabel;
@synthesize titleLabel = _titleLabel;
@synthesize officeLabel = _officeLabel;
@synthesize hospitalLabel = _hospitalLabel;
@synthesize introLabel = _introLabel;
@synthesize doctorID = _doctorID;
@synthesize infoScroll = _infoScroll;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization        
        doctor = nil;
        _doctorID = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_doctorID <= 0) {
        return;
    }
    
    [[_doctorHeadImageView layer] setCornerRadius:5.0];
//    [[_doctorHeadImageView layer] setBorderWidth:3.0];
//    [[_doctorHeadImageView layer] setBorderColor:[UIColor colorWithRed:249.0/255 green:208.0/255 blue:214.0/255 alpha:1.0].CGColor];
    [_doctorHeadImageView setBackgroundColor:[UIColor clearColor]];
//    [_doctorHeadImageView setContentMode:UIViewContentModeScaleAspectFit];
    [_doctorHeadImageView setClipsToBounds:YES];

    [_introLabel setFont:[UIFont systemFontOfSize:16]];
    [_introLabel setNumberOfLines:50];
    
    [_infoScroll setFrame:CGRectMake(0, 0, 320, 328)];
    [_infoScroll setContentSize:CGSizeMake(320, 328)];
    
    headImage = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect frame = _doctorHeadImageView.frame;
    frame.origin.x -= 0.5;
    _doctorHeadImageView.frame = frame;

    [self threadInitDoctorInfo];
//    [NSThread detachNewThreadSelector:@selector(threadInitDoctorInfo) toTarget:self withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"DoctorInfoViewController didReceiveMemoryWarning");
    
    [super didReceiveMemoryWarning];
}

- (void)threadInitDoctorInfo
{
    @autoreleasepool {
        NSString *post = [NSString stringWithFormat:@"action=doctorinfo&doctorid=%ld", (long)_doctorID];
        NSData *response = sendRequest(@"m.php", post);
        NSDictionary *jsonData = parseJsonResponse(response);
        
//        NSString *respString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
//        NSLog(@"Doctorinfo resp: %@", respString);
        
        // {"result":false,"msg":{"id":"1","name":"\u533b\u751f\u4e00","title":"\u4e3b\u4efb\u533b\u5e08","pic":"","hid":"1","hname":"\u533b\u9662\u4e00","oid":"1","oname":"\u79d1\u5ba4\u4e00"}}
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (result.intValue != 1) {
            NSString *msg = [jsonData objectForKey:@"msg"];
            NSLog(@"Getdoc %ld info failed %@", (long)_doctorID, msg);
        }
        
        NSDictionary *doctorInfo = [jsonData objectForKey:@"msg"];
        doctor = [[Doctor alloc] init];
        
        [[CureMeUtils defaultCureMeUtil] parseDoctorInfoFromJson:doctorInfo andDoctor:doctor];
        
        [self updateDisplay];
//        [self performSelectorOnMainThread:@selector(updateDisplay) withObject:nil waitUntilDone:NO];
        
        [self startImageDownload];
    }
}

- (void)startImageDownload
{
    if (!imageDownloadHelper) {
        imageDownloadHelper = [[ImageDownloadHelper alloc] init];
        [imageDownloadHelper setDelegate:self];
    }
    
    [imageDownloadHelper addImageKey:doctor.imageKey andSizeType:@"150"];
    
    [imageDownloadHelper startDownload];
}

- (void)updateDisplay
{
    [_nameLabel setText:doctor.name];
    [_titleLabel setText:doctor.title];
    [_officeLabel setText:doctor.officeName];
    [_hospitalLabel setText:doctor.hospitalName];
    [_introLabel setText:doctor.introduction];
    NSLog(@"doctor intro text: %@", _introLabel.text);
    
    CGSize introSize = [_introLabel.text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(290, 9999) lineBreakMode:UILineBreakModeWordWrap];
    float additionalHeight = 0;
    if (introSize.height > 180) {
        additionalHeight = introSize.height - 180;
    }
    
    CGRect introFrame = _introLabel.frame;
    introFrame.size.height = introSize.height;
    [_introLabel setFrame:introFrame];
    CGSize scrollSize = _infoScroll.contentSize;
    scrollSize.height += additionalHeight;
    [_infoScroll setContentSize:scrollSize];
    
    [self.navigationItem setTitle:[[NSString alloc] initWithFormat:@"%@ 医生", doctor.name]];
    
    if (headImage) {
        [_doctorHeadImageView setImage:headImage];
    }
}

- (void)imageDownloadComplete:(NSString *)imageKey andType:(NSString *)type andImage:(UIImage *)image
{
    headImage = image;
}

- (void)allImageComplete
{
    [self performSelectorOnMainThread:@selector(updateDisplay) withObject:nil waitUntilDone:NO];
}


- (void)viewDidUnload
{
    [self setDoctorHeadImageView:nil];
    [self setNameLabel:nil];
    [self setTitleLabel:nil];
    [self setOfficeLabel:nil];
    [self setHospitalLabel:nil];
    [self setIntroLabel:nil];
    
    imageDownloadHelper = nil;

    [self setInfoScroll:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    _doctorHeadImageView = nil;
    _nameLabel = nil;
    _titleLabel = nil;
    _officeLabel = nil;
    _hospitalLabel = nil;
    _introLabel = nil;
    doctor = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)startTalk:(id)sender
{
    if (![[CureMeUtils defaultCureMeUtil] hasLogin]) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        if (!loginVC) {
            NSLog(@"Create LoginVC failed.");
            return;
        }
        [[self navigationController] pushViewController:loginVC animated:YES];
    }
    else {
        // 此处开始聊天
        BubbleViewController *talkView = [[BubbleViewController alloc] initWithNibName:@"BubbleViewController" bundle:nil];
        if (!talkView) {
            NSLog(@"startTalk create BubbleViewController failed");
            return;
        }
        
        [talkView setChatOpenType:@"mylist"];
        [talkView setTalkerID:doctor.doctorID];
        [talkView setTalkerName:doctor.name];
        [talkView setSourceType:[NSString stringWithFormat:@"DOCTOR"]];
        [talkView setSourceID:doctor.doctorID];
        
        [self.navigationController pushViewController:talkView animated:YES];
    }
}

-(IBAction)startBook:(id)sender
{
    if (![[CureMeUtils defaultCureMeUtil] hasLogin]) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        if (!loginVC) {
            NSLog(@"Create LoginVC failed.");
            return;
        }
        [[self navigationController] pushViewController:loginVC animated:YES];
    }
    else {
        // 此处开始预约
        QueryViewController *bookVC = [[QueryViewController alloc] initWithNibName:@"QueryViewController" bundle:nil];
        if (!bookVC) {
            NSLog(@"startBook craete BookingVC failed.");
            return;
        }

        [bookVC setHospitalID:doctor.hospitalID];
        [bookVC setHospitalName:doctor.hospitalName];
        
        [self.navigationController pushViewController:bookVC animated:YES];
    }
}

@end
