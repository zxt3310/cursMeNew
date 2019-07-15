//
//  BookDetailInfoViewController.m
//  CureMe
//
//  Created by Tim on 12-9-20.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "QueryViewController.h"
#import "BookDetailInfoViewController.h"

@interface BookDetailInfoViewController ()

@end

@implementation BookDetailInfoViewController

@synthesize hospitalLabel;
@synthesize officeLabel;
@synthesize bookTimeLabel;
@synthesize submitTimeLabel;
@synthesize nameLabel;
@synthesize genderLabel;
@synthesize telephoneLabel;
@synthesize ageLabel;
@synthesize memoLabel;
@synthesize hospitalReply;
@synthesize scrollView;

@synthesize bookingID = _bookingID;
@synthesize hospitalID = _hospitalID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _bookingID = 0;
        [scrollView setBackgroundColor:[UIColor clearColor]];
        _bgImageView.image = [UIImage imageNamed:@"bg_yyt.jpg"];
        hasPassedBookValidating = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 获取预约详细信息
    if (_bookingID <= 0)
        return;
    
    [self.navigationItem setTitle:@"预约详情"];
    
    // 设置NavigationBar的返回按钮效果
    UIImage *oriImage = [UIImage imageNamed:@"rightitem_button_alpha.png"];
    UIImage *stretchableImage = nil;
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 6.0) {
        stretchableImage = [oriImage imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    }
    else {
        stretchableImage = [oriImage stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
    }
    
//    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
//    
//    // Set the title to use the same font and shadow as the standard back button
//    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
//    button.titleLabel.textColor = [UIColor whiteColor];
//    button.titleLabel.shadowOffset = CGSizeMake(0,-1);
//    button.titleLabel.shadowColor = [UIColor darkGrayColor];
//    // Set the break mode to truncate at the end like the standard back button
//    button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
//    // Inset the title on the left and right
//    button.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
//    // Make the button as high as the passed in image
//    // Measure the width of the text
//    button.frame = CGRectMake(0, 0, 0, stretchableImage.size.height);;
//    NSString *t = [NSString stringWithFormat:@"修改"];
//    CGSize textSize = [t sizeWithFont:button.titleLabel.font];
//    // Change the button's frame. The width is either the width of the new text or the max width
//    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, (textSize.width + (14.0 * 1.5)) > MAX_BACK_BUTTON_WIDTH ? MAX_BACK_BUTTON_WIDTH : (textSize.width + (14.0 * 1.5)), button.frame.size.height);
//    
//    // Set the text on the button
//    [button setTitle:t forState:UIControlStateNormal];
//    
//    [button setBackgroundImage:stretchableImage forState:UIControlStateNormal];
//    // Add an action for going back
//    [button addTarget:self action:@selector(modifyBookInfo:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.rightBarButtonItem = barBtnItem;
}

- (void)viewDidUnload
{
    [self setHospitalLabel:nil];
    [self setOfficeLabel:nil];
    [self setBookTimeLabel:nil];
    [self setSubmitTimeLabel:nil];
    [self setNameLabel:nil];
    [self setGenderLabel:nil];
    [self setTelephoneLabel:nil];
    [self setAgeLabel:nil];
    [self setMemoLabel:nil];
    [self setScrollView:nil];
    [self setHospitalReply:nil];
    [self setBgImageView:nil];
    [self setPassStateBgImageView:nil];
    [self setSubmitStateBgImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initBookDetailInfo];

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSInteger unreadCount = [CureMeUtils defaultCureMeUtil].unreadMessageCount;
    if (unreadCount > 0) {
        [[super unreadMsgBtn] setTitle:[NSString stringWithFormat:@"%ld", (long)unreadCount] forState:UIControlStateNormal];
        [super unreadMsgBtn].hidden = NO;
    }
    else {
        [super unreadMsgBtn].hidden = YES;
    }
}

// sendRequest: action=bookinginfo&bookingid=558&version=2.2&deviceid=509b2acc9dc2a
// {"result":true,"msg":[{"id":558,"userid":1000001,"hospitalid":128,"officeid":57,"bday":"20131108","timerange":"","dateadd":1352352765,"username":"weee","usertel":"20","memo":"\u4e0d\u4ec5\u4ec5\u66f4\u597d","state":1,"oname":"\u533b\u7597\u6574\u5f62\u7f8e\u5bb9\u4e2d\u5fc3","hname":"\u6df1\u5733\u5929\u7f8e\u6574\u5f62\u7f8e\u5bb9\u533b\u9662","bookingSucc":0,"bookingSummary":"","doctormemo":"","usermemo":"","age":127,"no":""}]}
- (void)initBookDetailInfo
{
    if (_bookingID <= 0)
        return;
    
    NSString *post = [[NSString alloc] initWithFormat:@"action=bookinginfo&bookingid=%ld", (long)_bookingID];
    NSData *response = sendRequest(@"m.php", post);
    
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"initBookDetailInfo resp: %@", strResp);
    
    NSDictionary *jsonData = parseJsonResponse(response);
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!result || result.integerValue != 1) {
        NSLog(@"initBookDetailInfo result invalid");
        return;
    }
    
    NSArray *books = [jsonData objectForKey:@"msg"];
    if (!books || books.count != 1) {
        NSLog(@"initBookDetailInfo book info invalid");
        return;
    }

    NSDictionary *bookDetail = [books objectAtIndex:0];
    
    // 提交预约时间
    NSDate *addTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[bookDetail objectForKey:@"dateadd"] integerValue]];
    [submitTimeLabel setText:[[CureMeUtils defaultCureMeUtil].dateFormatter stringFromDate:addTime]];
    
    // 预约时间
    NSDate *bookTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[bookDetail objectForKey:@"bday"] integerValue]];
    [bookTimeLabel setText:[[CureMeUtils defaultCureMeUtil].dateFormatter stringFromDate:bookTime]];
    
    NSNumber *hospID = [bookDetail objectForKey:@"hospitalid"];
    if (hospID)
        _hospitalID = hospID.integerValue;

    // 医院名字
    hospitalLabel.text = [bookDetail objectForKey:@"hname"];
    
    // 科室名字
    officeLabel.text = [bookDetail objectForKey:@"oname"];
    
    // 个人姓名
    nameLabel.text = [bookDetail objectForKey:@"username"];
    
    // 电话
    telephoneLabel.text = [bookDetail objectForKey:@"usertel"];
    
    // 年龄
    NSNumber *age = [bookDetail objectForKey:@"age"];
    ageLabel.text = age.stringValue;
    
    // 约单号
    NSString *bookNumber = [bookDetail objectForKey:@"no"];
    
    // 预约是否成功
//    NSNumber *succeed = [bookDetail objectForKey:@"bookingSucc"];
//    if (!succeed || succeed.integerValue != 1) {
    bool hasExceed = dateHasExcedded(bookTime, [NSDate date]);
    if (hasExceed) {
        self.navigationItem.title = @"详情（已过期）";
        _submitStateBgImageView.image = [UIImage imageNamed:@"箭头红.png"];
    }
    else if (!bookNumber || ![bookNumber respondsToSelector:@selector(length)] || bookNumber.length <= 0) {
        [self.navigationItem setTitle:@"详情（待处理）"];
        _submitStateBgImageView.image = [UIImage imageNamed:@"箭头红.png"];
    }
    else {
        [self.navigationItem setTitle:[NSString stringWithFormat:@"详情（单号：%@）", bookNumber]];
        _passStateBgImageView.image = [UIImage imageNamed:@"箭头绿.png"];
    }
    
    // 备注
    memoLabel.text = [[NSString alloc] initWithFormat:@"我的备注：\t\t%@", [bookDetail objectForKey:@"memo"]];
    CGSize newSize = [memoLabel.text sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(266, 9999) lineBreakMode:UILineBreakModeWordWrap];

    CGRect frame = memoLabel.frame;
    frame.size.height = newSize.height;
    memoLabel.frame = frame;

    float replyOriginY = frame.origin.y + frame.size.height + 8;

    // 预约单审核备注
    NSString *summary = nil;
    if (bookNumber && bookNumber.length > 0) {
        summary = [[NSString alloc] initWithFormat:@"医院回复：\t%@", [bookDetail objectForKey:@"bookingSummary"]];
    }
    else {
        summary = [[NSString alloc] initWithFormat:@"医院回复：\t%@", [bookDetail objectForKey:@"bookingSummary"]];
    }

    // 医生留言（医生发起预约时说的话）
    NSString *doctorReply = [bookDetail objectForKey:@"usermemo"];
    if (doctorReply && doctorReply.length > 0) {
        summary = [[NSString alloc] initWithFormat:@"%@\n预约单审核备注：%@", summary, doctorReply];
    }
    
    hospitalReply.text = summary;
    newSize = [hospitalReply.text sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(266, 9999) lineBreakMode:UILineBreakModeWordWrap];
    CGRect replyFrame = CGRectMake(frame.origin.x, replyOriginY, frame.size.width, newSize.height);
    hospitalReply.frame = replyFrame;

    float totalHeight = hospitalReply.frame.origin.y + hospitalReply.frame.size.height;
    if (totalHeight > 400) {
        CGSize totalSize = CGSizeMake(320, totalHeight);
        [scrollView setContentSize:totalSize];
    }
}

- (IBAction)modifyBookInfo:(id)sender
{
    if (_bookingID <= 0) {
        return;
    }
    
    QueryViewController *queryVC = [[QueryViewController alloc] initWithNibName:@"QueryViewController" bundle:nil];
    [queryVC setHospitalID:_hospitalID];
    [queryVC setHospitalName:hospitalLabel.text];
    [queryVC setBookID:_bookingID];
    
    [self.navigationController pushViewController:queryVC animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
