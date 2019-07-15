//
//  UIBubbleTableViewTelephoneCell.m
//  CureMe
//
//  Created by Tim on 12-11-2.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "NSBubbleData.h"
#import "UIBubbleTableViewTelephoneCell.h"

@implementation UIBubbleTableViewTelephoneCell

@synthesize dataInternal = _dataInternal;
@synthesize bubbleViewController = _bubbleViewController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        background = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].chatNotifyBubbleImage];
        [background setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:background];
        
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 20)];
        [headerLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [headerLabel setTextColor:[UIColor darkGrayColor]];
        [headerLabel setTextAlignment:UITextAlignmentCenter];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setHidden:YES];
        [self.contentView addSubview:headerLabel];

        dscpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [dscpLabel setFont:[UIFont systemFontOfSize:13]];
        [dscpLabel setBackgroundColor:[UIColor clearColor]];
        [dscpLabel setTextColor:[UIColor whiteColor]];
//        [dscpLabel setTextColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1]];
        [dscpLabel setShadowColor:[UIColor darkGrayColor]];
        [dscpLabel setShadowOffset:CGSizeMake(1, 1)];
        [dscpLabel setTextAlignment:UITextAlignmentCenter];
        [dscpLabel setNumberOfLines:3];
        [dscpLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.contentView addSubview:dscpLabel];
        
        callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [callBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [callBtn setImage:[UIImage imageNamed:@"tel_s.png"] forState:UIControlStateNormal];
        [callBtn setImage:[UIImage imageNamed:@"tel_s.png"] forState:UIControlStateHighlighted];
        [callBtn setImage:[UIImage imageNamed:@"tel_s.png"] forState:UIControlStateSelected];
//        [callBtn setBackgroundImage:[UIImage imageNamed:@"an_tongyong.png"] forState:UIControlStateNormal];
//        [callBtn setBackgroundImage:[UIImage imageNamed:@"an_down_tongyong.png"] forState:UIControlStateHighlighted];
//        [callBtn setBackgroundImage:[UIImage imageNamed:@"an_down_tongyong.png"] forState:UIControlStateSelected];
//        [callBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateNormal];
//        [callBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateNormal];
//        [callBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateNormal];
//        [callBtn setTitle:@"来聊聊热线" forState:UIControlStateNormal];
//        [callBtn setTitle:@"来聊聊热线" forState:UIControlStateSelected];
//        [callBtn setTitle:@"来聊聊热线" forState:UIControlStateHighlighted];
        [callBtn addTarget:self action:@selector(callTel:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:callBtn];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self callTelephone];
}

- (IBAction)callTel:(id)sender
{
}

- (void)callTelephone
{
    if (!_bubbleViewController || !_dataInternal)
    return;
    
    // 聊天窗口呼叫电话
    NSString *strTel = [_dataInternal.data.telephone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *strFinal = [strTel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *telephone = [[NSString alloc] initWithFormat:@"tel://%@", strFinal];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telephone]];
}

- (void)setDataInternal:(NSBubbleDataInternal *)dataInternal
{
    _dataInternal = dataInternal;
}

- (void)setBubbleViewController:(BubbleViewController *)bubbleViewController
{
    _bubbleViewController = bubbleViewController;
    
    [self generateLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)generateLayout
{
    float inset = 4.0;

    float startHeight = 0;
    if (self.dataInternal.header)
    {
        headerLabel.hidden = NO;
        headerLabel.text = self.dataInternal.header;
        startHeight += 30;
    }
    else
    {
        headerLabel.hidden = YES;
    }

//    if (_dataInternal)
//        dscpLabel.text = _dataInternal.data.text;
//    else
//        dscpLabel.text = @"想了解一下吗？现在就打个电话聊聊。";
    dscpLabel.text = [NSString stringWithFormat:@"%@%@", _dataInternal.data.text, _dataInternal.data.telephone];
    CGSize textSize = [dscpLabel.text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(160, 60) lineBreakMode:NSLineBreakByTruncatingTail];
    [dscpLabel setFrame:CGRectMake(60 + 35, startHeight + inset, 160, textSize.height)];
    
    background.frame = CGRectMake(60, startHeight, 200, textSize.height + 10);
    NSLog(@"dscpLabel: %@", dscpLabel);
    NSLog(@"bGimage: %@", background);
//    if (_dataInternal) {
//        [callBtn setTitle:[NSString stringWithFormat:@"拨打：%@", _dataInternal.data.telephone] forState:UIControlStateNormal];
//        [callBtn setTitle:[NSString stringWithFormat:@"拨打：%@", _dataInternal.data.telephone] forState:UIControlStateSelected];
//        [callBtn setTitle:[NSString stringWithFormat:@"拨打：%@", _dataInternal.data.telephone] forState:UIControlStateHighlighted];
//    }
    [callBtn setFrame:CGRectMake(60 + inset * 2, startHeight + inset + 1, 25, 25)];
}

@end
