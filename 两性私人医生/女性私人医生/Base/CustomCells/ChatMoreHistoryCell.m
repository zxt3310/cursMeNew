//
//  ChatMoreHistoryCell.m
//  CureMe
//
//  Created by Tim on 12-9-13.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "BubbleViewController.h"
#import "ChatMoreHistoryCell.h"


@implementation ChatMoreHistoryCell

@synthesize chatViewController = _chatViewController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        moreHistoryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [moreHistoryLabel setFont:[UIFont systemFontOfSize:14]];
        [moreHistoryLabel setTextAlignment:NSTextAlignmentCenter];
        [moreHistoryLabel setText:@"获得更早聊天消息"];
        [moreHistoryLabel setBackgroundColor:[UIColor whiteColor]];
        
        [self.contentView addSubview:moreHistoryLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (event.allTouches.count > 1)
        return;

    if (_chatViewController) {
        [_chatViewController loadNextPageHistory];
    }
}

- (void)generateLayout
{
    [moreHistoryLabel setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
}

@end
