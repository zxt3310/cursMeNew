//
//  ChatHospitalInfoCell.h
//  CureMe
//
//  Created by Tim on 12-10-31.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BubbleViewController;


@interface ChatMetaInfoData : NSObject

// 信息里是否含有Doctor信息
@property bool hasDoctorInfo;

@property NSInteger identifier;
@property NSString *info;
@property NSString *name;
@property NSString *intro;
@property NSString *imageKey;

@property float metaDataHeight;

//@property NSInteger hospitalID;
//@property NSString *hospitalInfo;
//@property NSString *hospitalIntro;
//@property NSString *hospitalImageKey;
//
//@property NSInteger doctorID;
//@property NSString *doctorInfo;
//@property NSString *doctorIntro;
//@property NSString *doctorImageKey;

@end


@interface ChatHospitalInfoCell : UITableViewCell

{
    ChatMetaInfoData *metaInfoData;
}

@property BubbleViewController *bubbleViewController;

@property UIImageView *backgroundImage;
// 头像
@property UIImageView *headImage;
// 头像边框
@property UIImageView *headImageFrame;
@property UILabel *nameLabel;
// 医院名字
@property UILabel *name;
@property UILabel *infoLabel;
// 如果有医生信息，则为医生名字与职位；如果没有医生信息，则不显示
@property UILabel *info;
@property UILabel *intro;

@property UIButton *hospitalInfoBtn;
@property UIButton *officeInfoBtn;
@property UIButton *doctorInfoBtn;
@property UIButton *bookBtn;

- (IBAction)hospitalInfoBtnClick:(id)sender;
- (IBAction)officeInfoBtnClick:(id)sender;
- (IBAction)doctorInfoBtnClick:(id)sender;
- (IBAction)bookBtnClick:(id)sender;

- (void)generateLayout;
- (void)setChatMetaInfoData:(ChatMetaInfoData *)metaoData;

@end
