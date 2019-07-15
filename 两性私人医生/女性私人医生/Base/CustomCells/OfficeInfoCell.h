//
//  OfficeInfoCell.h
//  CureMe
//
//  Created by Tim on 12-9-6.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OfficeInfoUnit : NSObject

@property NSInteger officeID;
@property (nonatomic, strong) NSString *officeName;
@property (nonatomic, strong) NSString *officeIntro;
@property NSInteger hospitalID;
@property (nonatomic, strong) NSString *hospitalName;

@end


@interface OfficeInfoCell : UITableViewCell

{
    UILabel *nameLabel;
    UILabel *introLabel;
}

@property (nonatomic, strong) OfficeInfoUnit *infoUnit;

- (void)generateLayout;

@end
