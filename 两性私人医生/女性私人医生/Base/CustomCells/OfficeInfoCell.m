//
//  OfficeInfoCell.m
//  CureMe
//
//  Created by Tim on 12-9-6.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "OfficeInfoCell.h"


@implementation OfficeInfoUnit

@synthesize officeID = _officeID;
@synthesize officeName = _officeName;
@synthesize officeIntro = _officeIntro;
@synthesize hospitalID = _hospitalID;
@synthesize hospitalName = _hospitalName;

- (void)dealloc
{
    _officeName = nil;
    _officeIntro = nil;
}

@end


@implementation OfficeInfoCell

@synthesize infoUnit = _infoUnit;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [nameLabel setFont:[UIFont fontWithName:@"Arial" size:18]];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:nameLabel];
        
        introLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [introLabel setFont:[UIFont systemFontOfSize:12]];
        [introLabel setBackgroundColor:[UIColor clearColor]];
        [introLabel setLineBreakMode:UILineBreakModeWordWrap];
        [introLabel setNumberOfLines:2];
        [self.contentView addSubview:introLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfoUnit:(OfficeInfoUnit *)infoUnit
{
    if (!infoUnit)
        return;
    
    _infoUnit = infoUnit;
    
    [self generateLayout];
}

- (void)generateLayout
{
    float inset = 4.0;
    [nameLabel setFrame:CGRectMake(inset, inset, 200, 20)];
    nameLabel.text = _infoUnit.officeName;
    
    [introLabel setFrame:CGRectMake(inset, 20 + inset, 310, 40)];
    introLabel.text = _infoUnit.officeIntro;
}

@end




