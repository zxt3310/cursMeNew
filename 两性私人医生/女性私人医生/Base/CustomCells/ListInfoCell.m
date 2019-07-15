//
//  ListInfoCell.m
//  CureMe
//
//  Created by Tim on 12-8-28.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "ListInfoCell.h"
#import "InfoListTableViewController.h"



@interface InfoUnit ()

@end

@implementation InfoUnit

@synthesize name = _name;
@synthesize info = _info;
@synthesize introduction = _introduction;
@synthesize identifier = _identifier;
@synthesize dataListType = _dataListType;
@synthesize imageKey = _imageKey;
@synthesize hospitalID = _hospitalID;


-(void)dealloc
{
    _name = nil;
    _info = nil;
    _introduction = nil;
    _imageKey = nil;
}

@end



@implementation ListInfoCell

@synthesize viewController = _viewController;
@synthesize infoUnit = _infoUnit;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        headImage = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].doctorDefaultHeadMImage];
        [headImage setFrame:CGRectMake(5, 4.5, 45, 45)];
        [headImage.layer setCornerRadius:3.0];
        [headImage setClipsToBounds:YES];
        
        headImageFrame = [[UIImageView alloc] initWithFrame:CGRectZero];
        [headImageFrame setBackgroundColor:[UIColor colorWithPatternImage:[CMImageUtils defaultImageUtil].doctorDefaultBGMImage]];
        headImageFrame.image = [CMImageUtils defaultImageUtil].doctorDefaultBGMImage;
        [headImageFrame addSubview:headImage];
        [[self contentView] addSubview:headImageFrame];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [nameLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [nameLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:nameLabel];
        
        infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [infoLabel setBackgroundColor:[UIColor clearColor]];
        [infoLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:infoLabel];
        
        introLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [introLabel setFont:[UIFont systemFontOfSize:14]];
        [introLabel  setBackgroundColor:[UIColor clearColor]];
        [introLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [introLabel setNumberOfLines:2];
        [self.contentView addSubview:introLabel];
        
        self.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bg_wddh_n.jpg"] stretchableImageWithLeftCapWidth:3 topCapHeight:3]];
        
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bg_wddh_h.jpg"] stretchableImageWithLeftCapWidth:3 topCapHeight:3]];        
//        self.backgroundView = bgView;
//        self.selectedBackgroundView = selectedBgView;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfoUnit:(InfoUnit *)infoUnit
{
    _infoUnit = infoUnit;
    
    [self generateLayout];
}

- (void)layoutSubviews
{
    [self generateLayout];

    [super layoutSubviews];
}

- (void)generateLayout
{
    if (!_infoUnit)
        return;
    
    float inset = 4.0;
    float addx = 0.0;
    float addy = 0.0;
    if (_infoUnit.dataListType == LIST_BOOK) {
        addx = 25;
        addy = 4;
    }
    
    if (_infoUnit.dataListType == LIST_BOOK) {
        [self.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_yys.png"]]];
    }
    
    float x = _infoUnit.dataListType == LIST_DOCTOR ? 66 : inset * 2;
    float width = 254;
    if (_infoUnit.dataListType == LIST_DOCTOR) {
        width = 254;
    }
    else if (_infoUnit.dataListType == LIST_BOOK) {
        width = 260;
    }
    else {
        width = 300;
    }
    // 放置头像
    if (_infoUnit.dataListType == LIST_DOCTOR) {
        [headImageFrame setHidden:NO];
        [headImage setHidden:NO];
        UIImage *hImage = [_viewController getHeadImage:_infoUnit.imageKey];
        headImageFrame.frame = CGRectMake(inset, inset * 7, 55, 58);
        if (!hImage) {
            if (_infoUnit.dataListType == LIST_DOCTOR) {
                [headImage setImage:[CMImageUtils defaultImageUtil].doctorDefaultHeadMImage];
            }
            else if (_infoUnit.dataListType == LIST_HOSPITAL ||
                     _infoUnit.dataListType == LIST_BOOK) {
//                [headImage setImage:[CureMeUtils defaultCureMeUtil].hospitalDefaultHeadMImage];
            }
        }
        else {
            [headImage setImage:hImage];
        }
    }
    else {
        [headImageFrame setHidden:YES];
        [headImage setHidden:YES];
    }
    

    // 放置名字
    nameLabel.frame = CGRectMake(x + addx, inset * 2 + addy, 256, 20);
    [nameLabel setText:[NSString stringWithFormat:@"%@", _infoUnit.name]];
    
    // 放置其他信息描述
    infoLabel.frame = CGRectMake(x + addx, 28 + addy, width, 18);
    [infoLabel setText:[NSString stringWithFormat:@"%@", _infoUnit.info]];
    
    introLabel.frame = CGRectMake(x + addx, 46 + addy, width, 42);
    [introLabel setText:[NSString stringWithFormat:@"%@", _infoUnit.introduction]];
    
//    CGRect f = self.frame;
//    f.size.height = INFOCELL_HEIGHT;
//    self.frame = f;
}

#pragma mark events
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (!_viewController) {
        NSLog(@"ListInfoCell viewController not set");
        return;
    }

    if (_infoUnit.dataListType == LIST_DOCTOR) {
        [_viewController showDoctorInfoPage:_infoUnit.identifier];
    }
    else if (_infoUnit.dataListType == LIST_HOSPITAL) {
        [_viewController showHospitalInfoPage:_infoUnit.identifier];
    }
    else if (_infoUnit.dataListType == LIST_BOOK) {
        // 此处为预约列表被点击，展开预约详细页面
        [_viewController showBookDetailInfoPage:_infoUnit.identifier andHospitalID:_infoUnit.hospitalID];
        
    }
}

- (void)dealloc
{
    _viewController = nil;
}

@end
