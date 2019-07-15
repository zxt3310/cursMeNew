//
//  CMQAProtocolView.h
//  私密健康医生
//
//  Created by 张信涛 on 2017/4/12.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMQuickAskLocationDeletage <NSObject>

@optional
- (void)chooseOfficeToQuery;
- (void)pushNewQuary:(NSInteger) office1 and:(NSInteger) office2;
@end

@interface CMQAProtocolView : UIView

@property id <CMQuickAskLocationDeletage> CmLocationDelegate;
@property NSInteger office1;
@property NSInteger office2;
@property (nonatomic) CGRect protcolViewFrame;

@end
