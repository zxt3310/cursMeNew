//
//  UIBubbleTableViewTextRemindCell.m
//  CureMe
//
//  Created by Tim on 12-12-20.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "UIBubbleTableViewTextRemindCell.h"

@implementation UIBubbleTableViewTextRemindCell

@synthesize remind = _remind;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        textRemind = [[UILabel alloc] initWithFrame:CGRectZero];
        [textRemind setBackgroundColor:[UIColor clearColor]];
        [textRemind setTextColor:[UIColor darkGrayColor]];
        [textRemind setLineBreakMode:NSLineBreakByTruncatingTail];
        [textRemind setFont:[UIFont boldSystemFontOfSize:14]];
        [textRemind setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:textRemind];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDataInternal:(NSBubbleDataInternal *)dataInternal
{
    _dataInternal = dataInternal;
    
    [self generateLayout];
}

- (void)setRemind:(NSString *)remind
{
    _remind = remind;
}

- (void)generateLayout
{
    if (!_dataInternal) {
        [textRemind setHidden:YES];
    }
//    CGSize textSize = [_remind sizeWithFont:[UIFont fontWithName:@"Copperplate" size:14] constrainedToSize:CGSizeMake(280, 100) lineBreakMode:NSLineBreakByTruncatingTail];
    textRemind.text = _dataInternal.data.text;
    [textRemind setFrame:CGRectMake(20, 15, 280, 20)];
}

@end
