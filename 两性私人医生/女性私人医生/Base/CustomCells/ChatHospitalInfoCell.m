//
//  ChatHospitalInfoCell.m
//  CureMe
//
//  Created by Tim on 12-10-31.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ChatHospitalInfoCell.h"
#import "BubbleViewController.h"


@implementation ChatMetaInfoData

@synthesize hasDoctorInfo = _hasDoctorInfo;

@synthesize identifier = _identifier;
@synthesize info = _info;
@synthesize name = _name;
@synthesize intro = _intro;
@synthesize imageKey = _imageKey;

@synthesize metaDataHeight = _metaDataHeight;

//@synthesize hospitalID = _hospitalID;
//@synthesize hospitalInfo = _hospitalInfo;
//@synthesize hospitalIntro = _hospitalIntro;
//@synthesize hospitalImageKey = _hospitalImageKey;
//
//@synthesize doctorID = _doctorID;
//@synthesize doctorInfo = _doctorInfo;
//@synthesize doctorIntro = _doctorIntro;
//@synthesize doctorImageKey = _doctorImageKey;

- (NSString *)description
{
    NSString *dscp = [NSString stringWithFormat:@"ChatMetaInfoData:\n identifier: %ld\nname: %@\ninfo: %@\nintro: %@\nimageKey: %@", (long)_identifier, _name, _info, _intro, _imageKey];
    
    return dscp;
}

- (void)dealloc
{
    _info = nil;
    _name = nil;
    _intro = nil;
    _imageKey = nil;
//    _hospitalInfo = nil;
//    _hospitalIntro = nil;
//    _hospitalImageKey = nil;
//    
//    _doctorInfo = nil;
//    _doctorIntro = nil;
//    _doctorImageKey = nil;
}

@end



@implementation ChatHospitalInfoCell

@synthesize bubbleViewController = _bubbleViewController;

@synthesize backgroundImage = _backgroundImage;
@synthesize headImage = _headImage;
@synthesize headImageFrame = _headImageFrame;
@synthesize nameLabel = _nameLabel;
@synthesize name = _name;
@synthesize infoLabel = _infoLabel;
@synthesize info = _info;
@synthesize intro = _intro;

@synthesize hospitalInfoBtn = _hospitalInfoBtn;
@synthesize officeInfoBtn = _officeInfoBtn;
@synthesize doctorInfoBtn = _doctorInfoBtn;
@synthesize bookBtn = _bookBtn;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setUserInteractionEnabled:YES];
        [self.contentView setUserInteractionEnabled:YES];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView setBackgroundColor:UIColorFromHex(0xfcfcfc, 1)];
        
        _backgroundImage = [[UIImageView alloc] initWithImage:nil];//[CMImageUtils defaultImageUtil].qaCellQuestionBgAllImage];
        _backgroundImage.hidden = YES;
        [self.contentView addSubview:_backgroundImage];
        
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(5.5, 4, 38, 38)];
        [_headImage setBackgroundColor:[UIColor clearColor]];
        
        _headImageFrame = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].doctorDefaultHeadImage];
        [_headImageFrame addSubview:_headImage];
        _headImageFrame.hidden = YES;
        [self.contentView addSubview:_headImageFrame];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        _nameLabel.text = @"医院：";
        [self.contentView addSubview:_nameLabel];
        
        _name = [[UILabel alloc] initWithFrame:CGRectZero];
        [_name setBackgroundColor:[UIColor clearColor]];
        [_name setTextColor:[UIColor grayColor]];
        [_name setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:_name];
        
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _infoLabel.text = @"姓名：";
        [_infoLabel setBackgroundColor:[UIColor clearColor]];
        [_infoLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [_infoLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:_infoLabel];
        
        _info = [[UILabel alloc] initWithFrame:CGRectZero];
        [_info setBackgroundColor:[UIColor clearColor]];
        [_info setTextColor:[UIColor grayColor]];
        [_info setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:_info];
        
        _intro = [[UILabel alloc] initWithFrame:CGRectZero];
        [_intro setBackgroundColor:[UIColor clearColor]];
        [_intro setTextColor:[UIColor grayColor]];
        [_intro setFont:[UIFont systemFontOfSize:14]];
        [_intro setNumberOfLines:4];
        [self.contentView addSubview:_intro];

//        _hospitalInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_hospitalInfoBtn setTitle:@"医院介绍" forState:UIControlStateNormal];
//        [_hospitalInfoBtn setTitle:@"医院介绍" forState:UIControlStateHighlighted];
//        [_hospitalInfoBtn setTitle:@"医院介绍" forState:UIControlStateSelected];
//        [_hospitalInfoBtn setBackgroundImage:[UIImage imageNamed:@"左_n.png"] forState:UIControlStateNormal];
//        [_hospitalInfoBtn setBackgroundImage:[UIImage imageNamed:@"左_p.png"] forState:UIControlStateSelected];
//        [_hospitalInfoBtn setBackgroundImage:[UIImage imageNamed:@"左_p.png"] forState:UIControlStateHighlighted];
//        _hospitalInfoBtn.frame = CGRectMake(0, 0, 75, 40);
//        [_hospitalInfoBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        [_hospitalInfoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_hospitalInfoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
//        [_hospitalInfoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
////        [_hospitalInfoBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateNormal];
////        [_hospitalInfoBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateHighlighted];
////        [_hospitalInfoBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateSelected];
//        [_hospitalInfoBtn setUserInteractionEnabled:YES];
//        [_hospitalInfoBtn addTarget:self action:@selector(hospitalInfoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_hospitalInfoBtn setHidden:YES];
//        [self.contentView addSubview:_hospitalInfoBtn];
//        
//        // 科室介绍按钮
//        _officeInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_officeInfoBtn setTitle:@"科室介绍" forState:UIControlStateNormal];
//        [_officeInfoBtn setBackgroundImage:[UIImage imageNamed:@"中_n.png"] forState:UIControlStateNormal];
//        [_officeInfoBtn setTitle:@"科室介绍" forState:UIControlStateSelected];
//        [_officeInfoBtn setBackgroundImage:[UIImage imageNamed:@"中_p.png"] forState:UIControlStateSelected];
//        [_officeInfoBtn setTitle:@"科室介绍" forState:UIControlStateHighlighted];
//        [_officeInfoBtn setBackgroundImage:[UIImage imageNamed:@"中_p.png"] forState:UIControlStateHighlighted];
//        [_officeInfoBtn setFrame:CGRectMake(0, 0, 75, 40)];
//        [_officeInfoBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        [_officeInfoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_officeInfoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
//        [_officeInfoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
////        [_officeInfoBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateNormal];
////        [_officeInfoBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateHighlighted];
////        [_officeInfoBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateSelected];
//        [_officeInfoBtn setUserInteractionEnabled:YES];
//        [_officeInfoBtn addTarget:self action:@selector(officeInfoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_officeInfoBtn setHidden:YES];
//        [self.contentView addSubview:_officeInfoBtn];
//        
//        // 专家介绍按钮
//        _doctorInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_doctorInfoBtn setTitle:@"专家介绍" forState:UIControlStateNormal];
//        [_doctorInfoBtn setBackgroundImage:[UIImage imageNamed:@"中_n.png"] forState:UIControlStateNormal];
//        [_doctorInfoBtn setTitle:@"专家介绍" forState:UIControlStateSelected];
//        [_doctorInfoBtn setBackgroundImage:[UIImage imageNamed:@"中_p.png"] forState:UIControlStateSelected];
//        [_doctorInfoBtn setTitle:@"专家介绍" forState:UIControlStateHighlighted];
//        [_doctorInfoBtn setBackgroundImage:[UIImage imageNamed:@"中_p.png"] forState:UIControlStateHighlighted];
//        [_doctorInfoBtn setFrame:CGRectMake(0, 0, 75, 40)];
//        [_doctorInfoBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        [_doctorInfoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_doctorInfoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
//        [_doctorInfoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
////        [_doctorInfoBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateNormal];
////        [_doctorInfoBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateHighlighted];
////        [_doctorInfoBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateSelected];
//        [_doctorInfoBtn setUserInteractionEnabled:YES];
//        [_doctorInfoBtn addTarget:self action:@selector(doctorInfoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_doctorInfoBtn setHidden:YES];
//        [self.contentView addSubview:_doctorInfoBtn];
//        
//        // 预约挂号按钮
//        _bookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_bookBtn setTitle:@"预约挂号" forState:UIControlStateNormal];
//        [_bookBtn setBackgroundImage:[UIImage imageNamed:@"右_n.png"] forState:UIControlStateNormal];
//        [_bookBtn setTitle:@"预约挂号" forState:UIControlStateSelected];
//        [_bookBtn setBackgroundImage:[UIImage imageNamed:@"右_p.png"] forState:UIControlStateSelected];
//        [_bookBtn setTitle:@"预约挂号" forState:UIControlStateHighlighted];
//        [_bookBtn setBackgroundImage:[UIImage imageNamed:@"右_p.png"] forState:UIControlStateHighlighted];
//        [_bookBtn setFrame:CGRectMake(0, 0, 75, 40)];
//        [_bookBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        [_bookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_bookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
//        [_bookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
////        [_bookBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateNormal];
////        [_bookBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateHighlighted];
////        [_bookBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateSelected];
//        [_bookBtn setUserInteractionEnabled:YES];
//        [_bookBtn setHidden:YES];
//        [_bookBtn addTarget:self action:@selector(bookBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_bookBtn];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)officeInfoBtnClick:(id)sender
{
    if (!_bubbleViewController) {
        return;
    }
    
    [_bubbleViewController showOfficeListPage];
}

- (IBAction)doctorInfoBtnClick:(id)sender
{
    if (!_bubbleViewController) {
        return;
    }
    
    [_bubbleViewController showDoctorDetailPage];
}

- (IBAction)bookBtnClick:(id)sender
{
    if (!_bubbleViewController) {
        return;
    }
    
    [_bubbleViewController showBookingPage];
}

- (IBAction)hospitalInfoBtnClick:(id)sender
{
    if (!_bubbleViewController) {
        return;
    }
    
    [_bubbleViewController showHospitalDetailPage];
}

- (void)generateLayout
{
    if (!metaInfoData) {
        NSLog(@"ChatHospitalInfoCell generateLayour failed, no metaInfoData");
        return;
    }

    NSLog(@"ChatHospitalInfoCell generateLayout metaData: %@", metaInfoData);
    float inset = 4.0;
    
    _backgroundImage.frame = CGRectMake(0, 0, SCREEN_WIDTH, metaInfoData.metaDataHeight);
    _backgroundImage.hidden = NO;
    
    // 医生头像
    UIImage *image = nil;
    if (_bubbleViewController) {
        image = [_bubbleViewController metaDataImageWithImageKey:metaInfoData.imageKey];
        if (image) {
            _headImage.image = image;
        }
        else {
            _headImage.image = [CMImageUtils defaultImageUtil].doctorDefaultHeadMImage;
        }
    }
    _headImageFrame.frame = CGRectMake(10, 10, 48, 48);
    _headImageFrame.image = nil;
    _headImageFrame.hidden = NO;
    
    // 医院信息
    _nameLabel.frame = CGRectMake(10 + 48 + inset, 10, 50, 20);
    _name.text = metaInfoData.name;
    _name.frame = CGRectMake(10 + 94 + inset * 2, 10, 194, 20);

    // 医生信息
    if (metaInfoData.hasDoctorInfo) {
        [_infoLabel setHidden:NO];
        _infoLabel.frame = CGRectMake(10 + 48 + inset, 30 + inset, 50, 20);
        [_info setHidden:NO];
        _info.text = metaInfoData.info;
        _info.frame = CGRectMake(10 + 94 + inset * 2, 30 + inset, 194, 20);
    }
    else {
        [_infoLabel setHidden:NO];
        [_info setHidden:NO];
    }

    // 简介Label
    _intro.text = metaInfoData.intro;
    CGSize textSize = [_intro.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(292, 100) lineBreakMode:NSLineBreakByTruncatingTail];
    _intro.frame = CGRectMake(10 + inset, 10 + 46 + inset, 292, textSize.height);

//    // 1. 医院介绍按钮
//    _hospitalInfoBtn.hidden = NO;
//    _hospitalInfoBtn.frame = CGRectMake(10, 56 + inset * 2 + textSize.height, 88.75, 40);
//    // 2. 科室介绍按钮
//    _officeInfoBtn.hidden = NO;
//    _officeInfoBtn.frame = CGRectMake(10 + 88.75, 56 + inset * 2 + textSize.height, 88.75, 40);
//    // 3. 专家介绍按钮
//    _doctorInfoBtn.hidden = NO;
//    _doctorInfoBtn.frame = CGRectMake(10 + 177.5, 56 + inset * 2 + textSize.height, 88.75, 40);
//    // 4. 预约挂号按钮
//    _bookBtn.hidden = NO;
//    _bookBtn.frame = CGRectMake(10 + 266.25, 56 + inset * 2 + textSize.height, 88.75, 40);
}

- (void)setChatMetaInfoData:(ChatMetaInfoData *)metaData
{
    metaInfoData = metaData;

    [self generateLayout];
}

@end
