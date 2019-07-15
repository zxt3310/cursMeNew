//
//  CMViews.m
//  私密健康医生
//
//  Created by Tim on 13-2-4.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMViews.h"


@implementation CMViews

@end


#pragma mark UIView Category
@implementation UIView (FirstResponder)
- (UIView *) findFirstResponder
{
	if ([self isFirstResponder]) return self;
    
	for (UIView *view in self.subviews)
	{
		UIView *responder = [view findFirstResponder];
        if (!responder) continue;
        return responder;
	}
    
	return nil;
}

+ (UIView *) currentResponder
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	return [keyWindow findFirstResponder];
}
@end
