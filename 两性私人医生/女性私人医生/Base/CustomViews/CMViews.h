//
//  CMViews.h
//  私密健康医生
//
//  Created by Tim on 13-2-4.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CMViews : NSObject

@end


#pragma mark UIView Category
@interface UIView (FirstResponder)

+ (UIView *) currentResponder;

@end
