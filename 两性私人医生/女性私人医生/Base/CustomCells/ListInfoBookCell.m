//
//  ListInfoBookCell.m
//  CureMe
//
//  Created by Tim on 12-11-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ListInfoBookCell.h"

@implementation ListInfoBookCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_yys.png"]]];
        
        hospitalImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [hospitalImageView.layer setCornerRadius:4.0];
        [hospitalImageView.layer setBorderWidth:2.0];
        [hospitalImageView.layer setBorderColor:[UIColor colorWithRed:249.0/255 green:208.0/255 blue:214.0/255 alpha:1.0].CGColor];
        [hospitalImageView setClipsToBounds:YES];
        [hospitalImageView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:hospitalImageView];
        
        statusImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [statusImageView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:statusImageView];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [dateLabel setFont:[UIFont systemFontOfSize:15]];
        [dateLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        dateLabel.text = @"日期";
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:dateLabel];
        
        date = [[UILabel alloc] initWithFrame:CGRectZero];
        [date setFont:[UIFont systemFontOfSize:15]];
        [date setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:date];
        
        bookNoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        bookNoLabel.text = @"预约号";
        [bookNoLabel setFont:[UIFont systemFontOfSize:15]];
        [bookNoLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [bookNoLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:bookNoLabel];
        
        bookNo = [[UILabel alloc] initWithFrame:CGRectZero];
        [bookNo setFont:[UIFont systemFontOfSize:15]];
        [bookNo setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:bookNo];
        
        hospNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        hospNameLabel.text = @"医院";
        [hospNameLabel setFont:[UIFont systemFontOfSize:15]];
        [hospNameLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [hospNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:hospNameLabel];
        
        hospName = [[UILabel alloc] initWithFrame:CGRectZero];
        [hospName setFont:[UIFont systemFontOfSize:15]];
        [hospName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:hospName];
        
        offNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        offNameLabel.text = @"科室";
        [offNameLabel setFont:[UIFont systemFontOfSize:15]];
        [offNameLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [offNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:offNameLabel];
        
        offName = [[UILabel alloc] initWithFrame:CGRectZero];
        [offName setFont:[UIFont systemFontOfSize:15]];
        [offName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:offName];
        
        hospReplyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        hospReplyLabel.text = @"医院回复";
        [hospReplyLabel setFont:[UIFont systemFontOfSize:15]];
        [hospReplyLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [hospReplyLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:hospReplyLabel];
        
        hospReply = [[UILabel alloc] initWithFrame:CGRectZero];
        [hospReply setFont:[UIFont systemFontOfSize:15]];
        [hospReply setBackgroundColor:[UIColor clearColor]];
        [hospReply setNumberOfLines:2];
        [self.contentView addSubview:hospReply];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBookListViewController:(MyBookListViewController *)bookListViewController
{
    _bookListViewController = bookListViewController;
}

- (void)setBookDetail:(BookDetail *)bookDetail
{
    _bookDetail = bookDetail;
    
    [self generateLayout];
}

- (void)generateLayout
{
    if (!_bookDetail || !_bookListViewController) {
        NSLog(@"ListInfoBookCell generate bookdetail invalid");
        return;
    }

    float inset = 5.0;
    
    UIImage *hospImage = [_bookListViewController hospitalImageWithKey:_bookDetail.hospitalImage andSize:@"90"];
    if (hospImage)
        hospitalImageView.image = hospImage;
    else
        hospitalImageView.image = [CMImageUtils defaultImageUtil].hospitalDefaultHeadMImage;
    hospitalImageView.frame = CGRectMake(25, 20, 45, 45);
    
    statusImageView.frame = CGRectMake(18, 75, 58, 25);
    bool hasExceed = dateHasExcedded(_bookDetail.bookTime, [NSDate date]);
    if (hasExceed) {
        statusImageView.image = [UIImage imageNamed:@"ico_gq.png"];
        if (_bookDetail.hospitalReply && _bookDetail.hospitalReply.length > 0)
            hospReply.text = _bookDetail.hospitalReply;
        else
            hospReply.text = @"该预约已过期，您可以重新预约或者直接与医院联系。";
    }
    else {
        if (_bookDetail.succeed > 0) {
            statusImageView.image = [UIImage imageNamed:@"ico_yywc.png"];
            if (_bookDetail.hospitalReply && _bookDetail.hospitalReply.length > 0)
                hospReply.text = _bookDetail.hospitalReply;
            else
                hospReply.text = @"预约已成功，请您按时就诊。";
        }
        else {
            statusImageView.image = [UIImage imageNamed:@"ico_yyz.png"];
            if (_bookDetail.hospitalReply && _bookDetail.hospitalReply.length > 0) {
                hospReply.text = _bookDetail.hospitalReply;
            }
            else {
                hospReply.text = @"等待医院处理，暂无医院回复信息。";
            }
        }
    }
    
    dateLabel.frame = CGRectMake(75 + inset, 20, 30, 20);

    date.text = [[CureMeUtils defaultCureMeUtil].shortDateFormatter stringFromDate:_bookDetail.bookTime];
    date.frame = CGRectMake(110 + inset, 20, 90, 20);
    
    bookNoLabel.frame = CGRectMake(198, 20, 45, 20);
    
    bookNo.text = _bookDetail.bookNumber;
    bookNo.frame = CGRectMake(248, 20, 60, 20);
    
    hospNameLabel.frame = CGRectMake(75 + inset, 42 + inset, 30, 20);

    hospName.text = _bookDetail.hospitalName;
    hospName.frame = CGRectMake(110 + inset, 42 + inset, 195, 20);
    
    offNameLabel.frame = CGRectMake(75 + inset, 64 + inset * 2, 30, 20);
    
    offName.text = _bookDetail.officeName;
    offName.frame = CGRectMake(110 + inset, 64 + inset * 2, 195, 20);
    
    hospReplyLabel.frame = CGRectMake(16, 90 + inset * 3, 60, 19);

    CGSize replySize = [hospReply.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(230, 50) lineBreakMode:NSLineBreakByTruncatingTail];
    hospReply.frame = CGRectMake(75 + inset, 90 + inset * 3, replySize.width, replySize.height);
}

@end
