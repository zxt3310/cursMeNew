//
//  CMCustomViews.m
//  私密健康医生
//
//  Created by Tim on 13-1-23.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMCustomViews.h"
#import <QuartzCore/QuartzCore.h>

@implementation CMCustomViews

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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


@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    
    return self;
}

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initialization];
    }
    
    return self;
}

- (void)initialization
{
    _loadingImage = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingImage.frame = CGRectMake(16, 1, 47, 47);
    [_loadingImage setBackgroundColor:[UIColor clearColor]];
    [_loadingImage startAnimating];
    [self addSubview:_loadingImage];

    _dscpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, 80, 20)];
    _dscpLabel.text = @"正在载入";
    [_dscpLabel setTextAlignment:UITextAlignmentCenter];
    [_dscpLabel setFont:[UIFont systemFontOfSize:14]];
    [_dscpLabel setBackgroundColor:[UIColor clearColor]];
    [_dscpLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:_dscpLabel];
    
    [self.layer setCornerRadius:10.0];
    [self setBackgroundColor:[UIColor blackColor]];
    self.alpha = 0.5;
}

@end


// 长宽：80 * 70
@implementation NoDataBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    
    return self;
}

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self initialization];
    }
    
    return self;
}

- (void)initialization
{
    _warningImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"警示.png"]];
    _warningImage.frame = CGRectMake(16, 1, 47, 47);
    [_warningImage setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_warningImage];
    
    _warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 80, 20)];
    _warningLabel.text = @"当前无数据";
    [_warningLabel setTextAlignment:UITextAlignmentCenter];
    [_warningLabel setFont:[UIFont systemFontOfSize:12]];
    [_warningLabel setBackgroundColor:[UIColor clearColor]];
    [_warningLabel setTextColor:[UIColor grayColor]];
    [self addSubview:_warningLabel];
}

@end
