//
//  CMQAViewControllerTitleView.m
//  私密健康医生
//
//  Created by Tim on 13-1-13.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMQAViewControllerTitleView.h"
#import "CMQAViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation CMQAViewControllerTitleView

@synthesize officeID = _officeID;
@synthesize qaViewController = _qaViewController;
@synthesize titleIconView = _titleIconView;
@synthesize titleLabel = _titleLabel;
@synthesize titleTriangleView = _titleTriangleView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        isTypesExpanded = false;

        _titleIconView = [[UIImageView alloc] initWithImage:[[CMImageUtils defaultImageUtil] officeIconWithID:_officeID]];
        [_titleIconView setBackgroundColor:[UIColor clearColor]];
        _titleIconView.frame = CGRectMake(4.0, 7.0, 20, 30);
        [self addSubview:_titleIconView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7.0, 80, 30)];
        _titleLabel.text = officeStringWithType(_officeID);
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
            [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        else
            [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setMinimumFontSize:12];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [self addSubview:_titleLabel];
        
        _titleTriangleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"triang.png"]];
        [_titleTriangleView setFrame:CGRectMake(100, 17, 10, 10)];
        [self addSubview:_titleTriangleView];
    }
    return self;
}

- (void)setOfficeID:(NSInteger)officeID
{
    _officeID = officeID;
    
    _titleIconView.image = [[CMImageUtils defaultImageUtil] officeIconWithID:_officeID];
    
    _titleLabel.text = officeStringWithType(_officeID);
    
    _titleTriangleView.image = [UIImage imageNamed:@"triang.png"];
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//        
//    if (_qaViewController) {
//        if (isTypesExpanded) {
//            [_qaViewController dismissLeveyPopListView];
//        }
//        else {
//            [_qaViewController showAllOfficeTypeView];
//            [self rotateTitleTriangle];
//        }
//    }
//}

- (void)rotateTitleTriangle
{
    [CATransaction setValue:[NSNumber numberWithFloat:0.7] forKey:kCATransactionAnimationDuration];
    CABasicAnimation *FlipAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    FlipAnimation.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    FlipAnimation.toValue= [NSNumber numberWithFloat:M_PI];
    FlipAnimation.duration=0.7;
    FlipAnimation.fillMode=kCAFillModeForwards;
    FlipAnimation.removedOnCompletion=NO;
    [_titleTriangleView.layer addAnimation:FlipAnimation forKey:@"flip"];
    [CATransaction commit];

    if (!isTypesExpanded) {
        _titleTriangleView.image = [UIImage imageNamed:@"triang.png"];
    }
    else {
        _titleTriangleView.image = [UIImage imageNamed:@"triang_up.png"];
    }
    
    isTypesExpanded = !isTypesExpanded;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
