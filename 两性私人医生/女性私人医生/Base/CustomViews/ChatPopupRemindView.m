//
//  ChatPopupRemindView.m
//  CureMe
//
//  Created by Tim on 12-12-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "ChatPopupRemindView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ChatPopupRemindView

@synthesize remindText = _remindText;
@synthesize isShowing = _isShowing;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.alpha = 0.0;
        [self setClipsToBounds:YES];
        [self.layer setCornerRadius:3.0];
        [self setBackgroundColor:[UIColor blackColor]];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        [textLabel setNumberOfLines:2];
        [self addSubview:textLabel];
    }
    return self;
}

- (void)setRemindText:(NSString *)remindText
{
    _remindText = remindText;
    textLabel.text = _remindText;
}

- (void)fadeIn
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1];
    [self setAlpha:0.7f];
    [UIView commitAnimations];

    _isShowing = true;
    [self setNeedsDisplay];
    
    // 启动显示Timer
    [NSTimer scheduledTimerWithTimeInterval:3.0f
                                     target:self
                                   selector:@selector(fadeOut)
                                   userInfo:nil
                                    repeats:NO];

//    self.navigationItem.rightBarButtonItem = BARBUTTON(@”Fade Out”,@selector(fadeOut:));
}

- (void)fadeOut
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    [self setAlpha:0.0f];
    [UIView commitAnimations];
    
    _isShowing = false;
    [self setNeedsDisplay];
//    self.navigationItem.rightBarButtonItem = BARBUTTON(@”Fade In”,@selector(fadeIn:));
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    CGSize textSize = [_remindText sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByTruncatingTail];
    [textLabel setFrame:CGRectMake(10, 5, textSize.width, textSize.height)];
}

@end
