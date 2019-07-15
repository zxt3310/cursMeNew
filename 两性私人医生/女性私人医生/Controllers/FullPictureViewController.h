//
//  FullPictureViewController.h
//  CureMe
//
//  Created by Tim on 12-9-13.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "CustomBaseViewController.h"
#import <UIKit/UIKit.h>

@interface FullPictureViewController : CustomBaseViewController <UIScrollViewDelegate>

{
    UIImage *fullImage;
}

@property (nonatomic, strong) NSString *imageKey;
@property (strong, nonatomic) IBOutlet UIScrollView *fullImageScroll;
@property (strong, nonatomic) IBOutlet UIImageView *fullImageView;

// main thread method
- (void)refreshDisplay;
// background thread method
- (void)threadGetFullSizeImage;

@end
