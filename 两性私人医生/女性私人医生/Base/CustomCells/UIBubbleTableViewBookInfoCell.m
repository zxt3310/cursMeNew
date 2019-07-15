//
//  UIBubbleTableViewBookInfoCell.m
//  CureMe
//
//  Created by Tim on 12-11-2.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "UIBubbleTableViewBookInfoCell.h"

@implementation UIBubbleTableViewBookInfoCell

@synthesize dataInternal = _dataInternal;
@synthesize bubbleViewController = _bubbleViewController;
@synthesize bookInfoUnit = _bookInfoUnit;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setSelectionStyle:UITableViewCellEditingStyleNone];
        [self.contentView setBackgroundColor:[UIColor clearColor]];

        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 20)];
        [headerLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [headerLabel setTextColor:[UIColor darkGrayColor]];
        [headerLabel setTextAlignment:UITextAlignmentCenter];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setHidden:YES];
        [self.contentView addSubview:headerLabel];
        
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_ghd.png"]];
        [self.contentView addSubview:backgroundImage];

        // 他人预约，提示文字
        remindLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [remindLabel setFont:[UIFont systemFontOfSize:14]];
        [remindLabel setBackgroundColor:[UIColor clearColor]];
        [remindLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [remindLabel setShadowColor:[UIColor darkGrayColor]];
        [remindLabel setShadowOffset:CGSizeMake(1, 1)];
        [remindLabel setTextAlignment:UITextAlignmentCenter];
        [remindLabel setNumberOfLines:2];
        [remindLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.contentView addSubview:remindLabel];

        // “挂号单”
        bookTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        bookTitleLabel.text = @"挂号单";
        [bookTitleLabel setTextAlignment:UITextAlignmentCenter];
        [bookTitleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [bookTitleLabel setBackgroundColor:[UIColor clearColor]];
        [bookTitleLabel setTextColor:[UIColor darkGrayColor]];
        [self.contentView addSubview:bookTitleLabel];

        // “医院”
        hosLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        hosLabel.text = @"医院：";
        [hosLabel setFont:[UIFont systemFontOfSize:14]];
        [hosLabel setBackgroundColor:[UIColor clearColor]];
        [hosLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [self.contentView addSubview:hosLabel];
        
        // 医院名字
        hospitalName = [[UILabel alloc] initWithFrame:CGRectZero];
        [hospitalName setFont:[UIFont systemFontOfSize:14]];
        [hospitalName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:hospitalName];

        // "科室"
        officeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        officeLabel.text = @"科室：";
        [officeLabel setFont:[UIFont systemFontOfSize:14]];
        [officeLabel setBackgroundColor:[UIColor clearColor]];
        [officeLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [self.contentView addSubview:officeLabel];

        // 科室名字
        officeName = [[UILabel alloc] initWithFrame:CGRectZero];
        [officeName setFont:[UIFont systemFontOfSize:14]];
        [officeName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:officeName];
        
        // “日期”
        dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dateLabel.text = @"日期：";
        [dateLabel setFont:[UIFont systemFontOfSize:14]];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [dateLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [self.contentView addSubview:dateLabel];
        
        // 具体日期
        date = [[UILabel alloc] initWithFrame:CGRectZero];
        [date setFont:[UIFont systemFontOfSize:14]];
        [date setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:date];
        
        // 姓名
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.text = @"姓名：";
        [nameLabel setFont:[UIFont systemFontOfSize:14]];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [self.contentView addSubview:nameLabel];
        
        // 真实姓名
        name = [[UILabel alloc] initWithFrame:CGRectZero];
        [name setFont:[UIFont systemFontOfSize:14]];
        [name setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:name];
        
        // 年龄
        ageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        ageLabel.text = @"年龄：";
        [ageLabel setFont:[UIFont systemFontOfSize:14]];
        [ageLabel setBackgroundColor:[UIColor clearColor]];
        [ageLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [self.contentView addSubview:ageLabel];
        
        // 年龄数字
        age = [[UILabel alloc] initWithFrame:CGRectZero];
        [age setFont:[UIFont systemFontOfSize:14]];
        [age setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:age];
        
        // 电话
        telLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        telLabel.text = @"电话：";
        [telLabel setFont:[UIFont systemFontOfSize:14]];
        [telLabel setBackgroundColor:[UIColor clearColor]];
        [telLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [self.contentView addSubview:telLabel];
        
        // 真实电话
        telephone = [[UILabel alloc] initWithFrame:CGRectZero];
        [telephone setFont:[UIFont systemFontOfSize:14]];
        [telephone setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:telephone];
        
        // 备注
        memoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        memoLabel.text = @"医院回复：";
        [memoLabel setFont:[UIFont systemFontOfSize:14]];
        [memoLabel setBackgroundColor:[UIColor clearColor]];
        [memoLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [self.contentView addSubview:memoLabel];
        
        // 备注内容
        memory = [[UILabel alloc] initWithFrame:CGRectZero];
        [memory setFont:[UIFont systemFontOfSize:14]];
        [memory setBackgroundColor:[UIColor clearColor]];
        [memory setNumberOfLines:2];
        [memory setLineBreakMode:NSLineBreakByWordWrapping];
        [self.contentView addSubview:memory];
        
        // 预约按钮
        bookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bookBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateNormal];
        [bookBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateHighlighted];
        [bookBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateSelected];
        [bookBtn setImage:[UIImage imageNamed:@"yyjs_ljyy.png"] forState:UIControlStateNormal];
        [bookBtn setImage:[UIImage imageNamed:@"yyjs_down_ljyy.png"] forState:UIControlStateHighlighted];
        [bookBtn setImage:[UIImage imageNamed:@"yyjs_down_ljyy.png"] forState:UIControlStateSelected];
//        [bookBtn setTitle:@"预约挂号" forState:UIControlStateNormal];
//        [bookBtn setTitle:@"预约挂号" forState:UIControlStateHighlighted];
//        [bookBtn setTitle:@"预约挂号" forState:UIControlStateSelected];
//        [bookBtn setBackgroundImage:[UIImage imageNamed:@"an_tongyong.png"] forState:UIControlStateNormal];
//        [bookBtn setBackgroundImage:[UIImage imageNamed:@"an_down_tongyong.png"] forState:UIControlStateHighlighted];
//        [bookBtn setBackgroundImage:[UIImage imageNamed:@"an_down_tongyong.png"] forState:UIControlStateSelected];
        [bookBtn addTarget:self action:@selector(updateBookInfo:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:bookBtn];
    }
    return self;
}

- (void)dealloc
{
    _bubbleViewController = nil;
}

- (IBAction)updateBookInfo:(id)sender
{
    if (_bubbleViewController) {
        [_bubbleViewController showBookingPage];
    }
}

- (void)setBubbleViewController:(BubbleViewController *)bubbleViewController
{
    _bubbleViewController = bubbleViewController;
    
    if (_bubbleViewController)
        _bookInfoUnit = _bubbleViewController.bookInfoUnit;
    
    NSLog(@"BookInfoCell chatBookInfo: %@", _bookInfoUnit);

    [self generateLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)generateLayout
{
    if (!_bubbleViewController) {
        return;
    }
    
    if (self.dataInternal.header) {
        headerLabel.hidden = NO;
        headerLabel.text = self.dataInternal.header;
    }
    else {
        headerLabel.hidden = YES;
    }
    
    float timeHeader = 0;
    if (self.dataInternal.header) {
        NSLog(@"BookInfoCell header added");
        timeHeader = 30;
    }

    // 如果是别人的预约单，简化显示
    if (_dataInternal.data.talkerID != [CureMeUtils defaultCureMeUtil].userID) {
        [bookTitleLabel setHidden:YES];
        [backgroundImage setHidden:YES];
        [hosLabel setHidden:YES];
        [officeLabel setHidden:YES];
        [dateLabel setHidden:YES];
        [nameLabel setHidden:YES];
        [telLabel setHidden:YES];
        [ageLabel setHidden:YES];
        [memoLabel setHidden:YES];
        [hospitalName setHidden:YES];
        [officeName setHidden:YES];
        [date setHidden:YES];
        [name setHidden:YES];
        [age setHidden:YES];
        [telephone setHidden:YES];
        [memory setHidden:YES];
        [bookBtn setHidden:YES];

        [remindLabel setHidden:NO];
        [remindLabel setText:@"这是一条用户与医院的预约信息，由于隐私限制，您将不能查看详情。"];
        [remindLabel setFrame:CGRectMake(40, 4 + timeHeader, 240, 35)];
        return;
    }

    [remindLabel setHidden:YES];
    
    [backgroundImage setHidden:NO];
    [hosLabel setHidden:NO];
    [officeLabel setHidden:NO];
    [dateLabel setHidden:NO];
    [nameLabel setHidden:NO];
    [telLabel setHidden:NO];
    [ageLabel setHidden:NO];
    [memoLabel setHidden:NO];
    [hospitalName setHidden:NO];
    [officeName setHidden:NO];
    [date setHidden:NO];
    [name setHidden:NO];
    [age setHidden:NO];
    [telephone setHidden:NO];
    [memory setHidden:NO];
    [bookBtn setHidden:NO];

    bool hasExceed = dateHasExcedded(_bookInfoUnit.bookDate, [NSDate date]);
//    NSTimeInterval interval = [_chatBookInfo.date timeIntervalSinceNow];
//    if (interval < 0)
//        hasExceed = true;
//    else
//        hasExceed = false;
    
    if (hasExceed) {
        bookTitleLabel.text = @"挂号单（已过期）";
    }
    else if (_bookInfoUnit.bookNumber && _bookInfoUnit.bookNumber.length > 0) {
        bookTitleLabel.text = [NSString stringWithFormat:@"挂号单（单号：%@）", _bookInfoUnit.bookNumber];
    }
    else {
        bookTitleLabel.text = @"挂号单（待处理）";
    }
    
    CGRect imageRect = CGRectMake(0, timeHeader, 320, 236);
    [backgroundImage setFrame:imageRect];
    NSLog(@"bgImage origin Y: %.2f", backgroundImage.frame.origin.y);
    
    [bookTitleLabel setFrame:CGRectMake(90, 10 + timeHeader, 140, 20)];
    NSLog(@"bookTitleLabel origin Y: %.2f", bookTitleLabel.frame.origin.y);
    
    [hosLabel setFrame:CGRectMake(60, 32 + timeHeader, 50, 20)];
    [officeLabel setFrame:CGRectMake(60, 55 + timeHeader, 50, 20)];
    [dateLabel setFrame:CGRectMake(60, 78 + timeHeader, 50, 20)];
    
    [nameLabel setFrame:CGRectMake(60, 101 + timeHeader, 50, 20)];
    [ageLabel setFrame:CGRectMake(215, 101 + timeHeader, 50, 20)];
    
    [telLabel setFrame:CGRectMake(60, 124 + timeHeader, 50, 20)];
    [memoLabel setFrame:CGRectMake(60, 147 + timeHeader, 100, 20)];

    if (!_bookInfoUnit)
        return;

    [hospitalName setFrame:CGRectMake(110, 32 + timeHeader, 180, 20)];
    hospitalName.text = _bookInfoUnit.hospitalName;
    
    [officeName setFrame:CGRectMake(110, 55 + timeHeader, 180, 20)];
    officeName.text = _bookInfoUnit.officeName;
    NSLog(@"BookInfoCell generateLayout officeName: %@", officeName.text);
    
    [date setFrame:CGRectMake(110, 78 + timeHeader, 180, 20)];
    date.text = [[CureMeUtils defaultCureMeUtil].shortDateFormatter stringFromDate:_bookInfoUnit.bookDate];

    [name setFrame:CGRectMake(110, 101 + timeHeader, 150, 20)];
    name.text = _bookInfoUnit.userName;
    
    [age setFrame:CGRectMake(260, 101 + timeHeader, 50, 20)];
    age.text = [NSString stringWithFormat:@"%ld", (long)_bookInfoUnit.age];
    
    [telephone setFrame:CGRectMake(110, 124 + timeHeader, 200, 20)];
    telephone.text = _bookInfoUnit.telephone;
    
    [memory setFrame:CGRectMake(160, 147 + timeHeader, 130, 40)];
    memory.text = _bookInfoUnit.memory;
    
    [bookBtn setFrame:CGRectMake(103, 195 + timeHeader, 114, 34)];
//    CGRect frame = self.contentView.frame;
//    frame.size.width = 32;
//    frame.size.height = 236;
//    
//    self.contentView.frame = frame;
}

@end
