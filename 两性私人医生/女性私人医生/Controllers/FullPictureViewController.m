//
//  FullPictureViewController.m
//  CureMe
//
//  Created by Tim on 12-9-13.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "FullPictureViewController.h"

@interface FullPictureViewController ()

@end

@implementation FullPictureViewController

@synthesize fullImageView;
@synthesize imageKey = _imageKey;
@synthesize fullImageScroll;

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
//    if (_image) {
//        fullImageView.image = _image;
//        [fullImageScroll setMinimumZoomScale:0.3];
//        [fullImageScroll setMaximumZoomScale:3];
//        [fullImageScroll setDelegate:self];
//    }
    
    // Do any additional setup after loading the view from its nib.
    [self performSelectorInBackground:@selector(threadGetFullSizeImage) withObject:nil];
}

- (void)viewDidUnload
{
    [self setFullImageView:nil];
    [self setFullImageScroll:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"FullPictureViewController didReceiveMemoryWarning");
    
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)refreshDisplay
{
    [fullImageView setImage:fullImage];
    [fullImageScroll setMinimumZoomScale:0.3];
    [fullImageScroll setMaximumZoomScale:3];
    [fullImageScroll setDelegate:self];
}

- (void)threadGetFullSizeImage
{
    @autoreleasepool {
        if (!_imageKey) {
            return;
        }
        
        fullImage = [[CureMeUtils defaultCureMeUtil] getImageByKey:_imageKey andSize:@"l"];
        
        if (!fullImage) {
            return;
        }
        
        [self performSelectorOnMainThread:@selector(refreshDisplay) withObject:nil waitUntilDone:NO];        
    }
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return fullImageView;
}

@end
