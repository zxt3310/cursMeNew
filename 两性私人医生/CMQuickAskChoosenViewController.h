//
//  CMQuickAskChoosenViewController.h
//  私密健康医生
//
//  Created by 张信涛 on 2017/4/10.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "CustomBaseViewController.h"
#import "CMNewQueryViewController.h"
#import "CMQAProtocolView.h"

@protocol chooseLocationDelegate <NSObject>
@optional
- (void)refreshChosedLocation:(NSString *) province City:(NSString *) city Province:(NSInteger) city1 userCity:(NSInteger) city2;
@end

@interface CMQuickAskChoosenAndLocationViewController : CustomBaseViewController <UITableViewDelegate,UITableViewDataSource,CMQuickAskLocationDeletage>
@property  BOOL isQuickAskView;

@property id <chooseLocationDelegate> chooseDelegate;
@property (nonatomic, copy) NSString *currentLocation;

@end
