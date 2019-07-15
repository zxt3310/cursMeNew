//
//  QueryViewController.m
//  CureMe
//
//  Created by Tim on 12-8-27.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "QueryViewController.h"
#import "LoginViewController.h"
#import "BubbleViewController.h"
//#import "QuerySubPickDateViewController.h"
//#import "QuerySubPickOfficeViewController.h"
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>

/*
@implementation UIScrollView (my)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.dragging)
    {
        [[self nextResponder] touchesBegan:touches withEvent:event];
    }
    [super touchesBegan:touches withEvent:event];
    //NSLog(@"MyScrollView touch Began");
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.dragging)
    {
        [[self nextResponder] touchesMoved:touches withEvent:event];
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.dragging)
    {
        [[self nextResponder] touchesEnded:touches withEvent:event];
    }
    [super touchesEnded:touches withEvent:event];
}

@end*/

@interface QueryViewController ()

- (void)threadGetOfficeListData;

@end


@implementation QueryViewController

@synthesize hospitalName = _hospitalName;
@synthesize hospitalID = _hospitalID;
@synthesize officeID = _officeID;
@synthesize chatID = _chatID;

@synthesize bookID = _bookID;
@synthesize bookDetail = _bookDetail;

@synthesize hospitalNameLabel;

@synthesize officeLabel;
@synthesize pickDateLabel;
@synthesize nameField;
@synthesize ageField;
@synthesize telField;
@synthesize remarksField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_yyt.jpg"]]];        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfDatePicked:) name:NTF_BookDatePicked object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfOfficePicked:) name:NTF_BookOfficePicked object:nil];
    
    self.navigationItem.title = @"预约挂号";
// Do any additional setup after loading the view from its nib.
    
//    _bookID = 0;
//    _bookDetail = nil;
//    _officeID = -1;
//    _chatID = 0;
    UIButton *BGButton = [UIButton buttonWithType:UIButtonTypeCustom];
    BGButton.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, SCREEN_HEIGHT);
    [BGButton setBackgroundColor:[UIColor clearColor]];
    [BGButton addTarget:self action:@selector(closeKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    [self.contentScrollView insertSubview:BGButton atIndex:0];
}
-(void)closeKeyBoard{
    [ageField resignFirstResponder];
    [nameField resignFirstResponder];
    [telField resignFirstResponder];
    [remarksField resignFirstResponder];
}
- (void)viewDidUnload
{
    [self setNameField:nil];
    [self setAgeField:nil];
    [self setTelField:nil];
    [self setRemarksField:nil];
    [self setOfficeLabel:nil];
    [self setPickDateLabel:nil];
    [self setHospitalNameLabel:nil];
    [self setBookBtn:nil];
    [self setSubmitStateBgImageView:nil];
    [self setPassStateBgImageView:nil];
    [self setSelectOfficeBgImageView:nil];
    [self setSelectDateBgImageView:nil];
    [self setContentScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [hospitalNameLabel setText:_hospitalName];

    // 如果是现有预约修改
    if (_bookID > 0) {
        CGRect frame = _bookBtn.frame;
        frame.origin.x = 72;
        frame.size.width = 175;
        _bookBtn.frame = frame;
        [_bookBtn setImage:[UIImage imageNamed:@"an_xgyyxx.png"] forState:UIControlStateNormal];
        [_bookBtn setImage:[UIImage imageNamed:@"an_down_xgyyxx.png"] forState:UIControlStateSelected];
        [_bookBtn setImage:[UIImage imageNamed:@"an_down_xgyyxx.png"] forState:UIControlStateHighlighted];

        // 如果是页面首次显示，更新内容
        if (!_bookDetail) {
            [self performSelectorInBackground:@selector(threadGetBookInfo) withObject:nil];
        }
    }
    // 如果是新建预约
    else {
        CGRect frame = _bookBtn.frame;
        frame.origin.x = 90;
        frame.size.width = 140;
        _bookBtn.frame = frame;
        [_bookBtn setImage:[UIImage imageNamed:@"an_xgyyxx.png"] forState:UIControlStateNormal];
        [_bookBtn setImage:[UIImage imageNamed:@"an_down_xgyyxx.png"] forState:UIControlStateSelected];
        [_bookBtn setImage:[UIImage imageNamed:@"an_down_xgyyxx.png"] forState:UIControlStateHighlighted];
        
        [nameField setText:[[NSUserDefaults standardUserDefaults] objectForKey:USER_PERSONALNAME]];
        NSNumber *age = [[NSUserDefaults standardUserDefaults] objectForKey:USER_AGE];
        if (age) {
            [ageField setText:[NSString stringWithFormat:@"%ld", (long)age.integerValue]];
        }
        [telField setText:[[NSUserDefaults standardUserDefaults] objectForKey:USER_PHONENO]];
    }

    CGSize contentS = _contentScrollView.contentSize;
    contentS.height = _contentScrollView.frame.size.height;
    contentS.height += 250;
    _contentScrollView.contentSize = contentS;
    NSLog(@"contentScroll: %@ contentSize: %.2f %.2f", _contentScrollView, _contentScrollView.contentSize.width, _contentScrollView.contentSize.height);
    
    // 获取OfficeList
    [activityIndicator startAnimating];
    [self performSelectorInBackground:@selector(threadGetOfficeListData) withObject:nil];
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

- (void)didReceiveMemoryWarning
{
    NSLog(@"QueryViewController didReceiveMemoryWarning");
    
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)threadGetOfficeListData
{
    if (!officeList) {
        officeList = [[NSMutableArray alloc] init];
    }
    
    NSString *post = [NSString stringWithFormat:@"action=getofficelist&hospitalid=%ld", (long)_hospitalID];
    NSData *response = sendRequest(@"m.php", post);

    // {"result":true,"msg":[{"id":117,"city":29000,"name":"\u79d1\u5ba4\u4e00","intro":"\u79d1\u5ba4\u4e00\u79d1\u5ba4\u4e00\u79d1\u5ba4\u4e00\u79d1\u5ba4\u4e00"},{"id":118,"city":29000,"name":"\u79d1\u5ba4\u4e8c","intro":"\u79d1\u5ba4\u4e8c\u79d1\u5ba4\u4e8c\u79d1\u5ba4\u4e8c"}],"city":29000}
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"getOfficeList: %@", strResp);
    
    NSDictionary *jsonData = parseJsonResponse(response);
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!response || result.integerValue != 1) {
        NSLog(@"getofficelist req result failed");
        return;
    }
    
    bookHospRegion = [jsonData objectForKey:@"city"];

    NSArray *offices = [jsonData objectForKey:@"msg"];
    for (NSDictionary *office in offices) {
        NSNumber *officeID = [office objectForKey:@"id"];
        NSString *officeName = [office objectForKey:@"name"];
        [officeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:officeName, @"name", officeID, @"id", nil]];
    }
    
    NSString *strRegion = [CureMeUtils defaultCureMeUtil].province;
    if (strRegion && [strRegion length] > 0) {
        NSNumber *regionID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
        if (!bookHospRegion || !regionID || [bookHospRegion integerValue] != regionID.integerValue) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"预约" message:@"您打算预约的医院与您的所在地区不符，或将不被医院受理" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    }
    
    [activityIndicator stopAnimating];
}

#pragma mark CMDatePickerViewControllerDelegate
- (void)dateSelected:(NSDate *)date
{
    if (!date) {
        return;
    }
    
    pickedDate = date;
    pickDateLabel.text = [[CureMeUtils defaultCureMeUtil].shortDateFormatter stringFromDate:pickedDate];
}

#pragma mark CMPickerViewControllerDelegate
- (void)didSelectOK:(NSDictionary *)firstUnit andSecondColumn:(NSDictionary *)secondUnit andThirdColumn:(NSDictionary *)thirdUnit
{
    if (!firstUnit) {
        return;
    }
    
    _officeID = [((NSNumber *)[firstUnit objectForKey:@"id"]) integerValue];
    officeLabel.text = [firstUnit objectForKey:@"name"];
}

#pragma mark events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *setTouches = [event allTouches];
    UITouch *touch = [setTouches anyObject];
    
    switch ([setTouches count]) {
        case 1:
            if (![touch.view isKindOfClass:[UITextField class]]) {
                [ageField resignFirstResponder];
                [nameField resignFirstResponder];
                [telField resignFirstResponder];
                [remarksField resignFirstResponder];
            }
            break;
            
        default:
            break;
    }

    if ([touch.view isEqual:_selectDateBgImageView]) {
        NSLog(@"change date clicked");
        [self showDateSelectionView];
    }

    if ([touch.view isEqual:_selectOfficeBgImageView]) {
        NSLog(@"change office clicked");
        [self showOfficeSelectionView];
    }
}

- (void)showDateSelectionView
{
    if (!datePickerViewController) {
        datePickerViewController = [[CMDatePickerViewController alloc] initWithNibName:@"CMDatePickerViewController" bundle:nil];
        datePickerViewController.delegate = self;
    }
    
    [[KGModal sharedInstance] setModalBackgroundColor:[UIColor clearColor]];
    [[KGModal sharedInstance] setYUpOffset:0];
    [[KGModal sharedInstance] showWithContentView:datePickerViewController.view andAnimated:YES];
}

- (void)showOfficeSelectionView
{
    if (!officePickerViewController) {
        officePickerViewController = [[CMPickerViewController alloc] initWithNibName:@"CMPickerViewController" bundle:nil];
        [officePickerViewController setPickerDelegate:self];
        [officePickerViewController setPickerTitle:[NSString stringWithFormat:@"请选择您要预约的科室"]];
        [officePickerViewController setPickerColumnCount:1];
        [officePickerViewController.view setBackgroundColor:[UIColor whiteColor]];
    }

    if (!officeList || officeList.count <= 0) {
        [activityIndicator startAnimating];
        [self threadGetOfficeListData];
    }
    
    [officePickerViewController setFirstColumnData:officeList];
//    [officePickerViewController setData:officeList];
    
    [[KGModal sharedInstance] setModalBackgroundColor:[UIColor clearColor]];
    [[KGModal sharedInstance] setYUpOffset:0];
    [[KGModal sharedInstance] showWithContentView:officePickerViewController.view andAnimated:YES];
}

- (IBAction)pickDateBtn:(id)sender
{
    [self showDateSelectionView];
//    QuerySubPickDateViewController *pickDateVC = [[QuerySubPickDateViewController alloc] initWithNibName:@"QuerySubPickDateViewController" bundle:nil];
//    if (!pickDateVC)
//        return;
//    
//    [[pickDateVC datePicker] setDate:[[NSDate alloc] init]];
//    [[self navigationController] pushViewController:pickDateVC animated:YES];
}

- (IBAction)pickOfficeBtn:(id)sender
{
    [self showOfficeSelectionView];
//    QuerySubPickOfficeViewController *pickOfficeVC = [[QuerySubPickOfficeViewController alloc] initWithNibName:@"QuerySubPickOfficeViewController" bundle:nil];
//    if (!pickOfficeVC)
//        return;
//    
//    [pickOfficeVC setHospitalID:_hospitalID];
//    [[self navigationController] pushViewController:pickOfficeVC animated:YES];
}

- (IBAction)bookBtnClick:(id)sender
{
    if (![[CureMeUtils defaultCureMeUtil] hasLogin]) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        if (!loginVC) {
            NSLog(@"bookBtnClick create LoginViewController failed");
            return;
        }
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }

    if (_hospitalID <= 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"预约"
                              message:@"医生信息初始化异常"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (_officeID < 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"预约"
                              message:@"请选择要预约的科室"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;        
    }
    
    // 如果个人信息输入不够完整
    if ([nameField.text length] <= 0 ||
        [ageField.text length] <= 0 ||
        [telField.text length] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"预约"
                              message:@"请输入个人信息"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // 如果输入的手机格式不正确
    if (![[CureMeUtils defaultCureMeUtil] isPureInt:telField.text] || telField.text.length != 11) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"预约"
                                                        message:@"您输入的手机格式不正确，请输入11位数字"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // 如果未选择预约科室
    if (!officeLabel.text || [officeLabel.text length] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"预约" message:@"请选择需要预约的科室" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    // 如果未选择预约日期
    if (!pickDateLabel.text || [pickDateLabel.text length] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"预约" message:@"请选择到诊日期，或者在备注中说明情况。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    // 如果备注信息输入的不够多
    if (!remarksField.text || [remarksField.text length] <= 10) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"预约" message:@"请输入至少10个字的备注信息，以便我们更好的提供服务，谢谢。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // 以下，发送预约请求，请求成功、失败做提示
    // action=booking&userid=xxx&hospitalid=xxx&truename=xxx&tel=xxx&bookingday= xxx&bookingtime=xxx&officeid=xxxx&memo=xxxxx
    // response: {"result":false,"msg":"\u4e00\u4eba\u4e00\u5929\u53ea\u80fd\u9884\u7ea6\u4e00\u4e2a\u53f7\uff0c\u660e\u5929\u518d\u8bd5\u8bd5\u5427\u3002"}
    NSInteger unixTime = [pickedDate timeIntervalSince1970];
    NSString *post = nil;
    NSString *encodeName = [nameField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodeMemory = [remarksField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (_bookID > 0) {
        post = [NSString stringWithFormat:@"action=updbooking&bookingid=%ld&truename=%@&tel=%@&age=%@&officeid=%ld&bookingday=%ld&memo=%@", (long)_bookID, encodeName, telField.text, ageField.text, (long)_officeID, (long)unixTime, encodeMemory];
    }
    else {
        post = [NSString stringWithFormat:@"action=booking&userid=%ld&hospitalid=%ld&truename=%@&tel=%@&bookingday=%ld&bookingtime=%ld&officeid=%ld&memo=%@&age=%@&chatid=%ld", (long)[CureMeUtils defaultCureMeUtil].userID, (long)_hospitalID, encodeName, telField.text, (long)unixTime, (long)unixTime, (long)_officeID, encodeMemory, ageField.text, (long)_chatID];
        
        // 如果是新预约，创建新的bookDetail
        if (!_bookDetail)
            _bookDetail = [[BookDetail alloc] init];
        
        _bookDetail.hospitalID = _hospitalID;
        _bookDetail.hospitalName = _hospitalName;
        _bookDetail.officeID = _officeID;
        _bookDetail.officeName = officeLabel.text;
        _bookDetail.name = nameField.text;
        _bookDetail.age = ageField.text.integerValue;
        _bookDetail.telephone = telField.text;
        _bookDetail.bookTime = pickedDate;
        _bookDetail.memory = remarksField.text;
    }
    NSLog(@"bookBtnClick bookID: %ld post: %@", (long)_bookID, post);

    NSData *response = sendRequest(@"m.php", post);
    
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"resp: %@", strResp);
    
    NSDictionary *jsonData = parseJsonResponse(response);
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!result || result.integerValue != 1) {
        NSLog(@"bookBtnClick req failed.");
        NSString *message = [jsonData objectForKey:@"msg"];
        if (message.length > 0) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"预约"
                                  message:message
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
        return;
    }
    
    NSInteger count = self.navigationController.viewControllers.count;
    UIViewController *VC = [self.navigationController.viewControllers objectAtIndex:count - 2];
    if ([VC isKindOfClass:[BubbleViewController class]]) {
        BubbleViewController *bubbleVC = ((BubbleViewController *)VC);
        BookInfoUnit *bookInfo = [[BookInfoUnit alloc] init];
        NSString *strBookid = [jsonData objectForKey:@"msg"];
        if (_bookID <= 0 && strBookid && [strBookid respondsToSelector:@selector(integerValue)]) {
            bookInfo.bookID = [strBookid integerValue];
        }
        else
            bookInfo.bookID = _bookID;

        bookInfo.officeID = _officeID;
        bookInfo.officeName = officeLabel.text;
        bookInfo.hospitalID = _hospitalID;
        bookInfo.hospitalName = _hospitalName;
        bookInfo.userName = nameField.text;
        bookInfo.age = ageField.text.integerValue;
//        bookInfo.memory = _bookDetail.memory;
        bookInfo.telephone = telField.text;
        bookInfo.bookDate = pickedDate;
        NSLog(@"QVC bookBtnClick bookInfo: %@", bookInfo);
        [bubbleVC setBookInfoUnit:bookInfo];

        if (_bookID > 0) {
            [bubbleVC sendBookActionResponse:@"upt" andBookID:_bookID];
        }
        else {
            _bookID = bookInfo.bookID;
            [bubbleVC sendBookActionResponse:@"new" andBookID:_bookID];
        }
    }

//    // 新预约，获得BookID，在给聊天窗口添加消息之后，再对_bookID赋值
//    if (_bookID <= 0) {
//        NSString *strBookID = [jsonData objectForKey:@"msg"];
//        _bookID = strBookID.integerValue;
//    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"预约"
                          message:@"预约成功，请牢记时间，准时就诊，谢谢。"
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)ntfDatePicked:(NSNotification *)note
{
    if (!note.userInfo)
        return;
    
    NSDate *date = [note.userInfo objectForKey:@"pickTime"];
    if (!date)
        return;
    
    pickedDate = date;

    pickDateLabel.text = [NSString stringWithFormat:@"%@", [[CureMeUtils defaultCureMeUtil].shortDateFormatter stringFromDate:date]];
}

- (void)ntfOfficePicked:(NSNotification *)note
{
    if (!note.userInfo)
        return;
    
    NSNumber *office = [note.userInfo objectForKey:@"officeID"];
    NSString *officeName = [note.userInfo objectForKey:@"officeName"];
    if (!office || office.integerValue < 0 || !officeName)
        return;
    
    _officeID = office.integerValue;
    officeLabel.text = officeName;
}

- (void)threadGetBookInfo
{
    @autoreleasepool {
        NSString *post = [[NSString alloc] initWithFormat:@"action=bookinginfo&bookingid=%ld", (long)_bookID];
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"bookinginfo post: %@ resp: %@", post, strResp);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        if (!jsonData || jsonData.count <= 0)
            return;
        
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSString *error = [jsonData objectForKey:@"msg"];
            NSLog(@"action=bookinginfo result invalid: %@", error);
            return;
        }
        
        if (!_bookDetail)
            _bookDetail = [[BookDetail alloc] init];

        NSArray *msg = [jsonData objectForKey:@"msg"];
        if (!msg || ![msg isKindOfClass:[NSArray class]])
            return;
        
        // {"result":true,"msg":[{"id":481,"userid":1000001,"hospitalid":169,"officeid":117,"bday":"1352196317","timerange":"","dateadd":1352196148,"username":"111","usertel":"11","memo":"11","state":1,"oname":"\u79d1\u5ba4\u4e00","hname":"\u6d4b\u8bd5\u533b\u9662\u4e00","bookingSucc":0,"bookingSummary":"","doctormemo":"111","age":11}]}
        NSDictionary *bookData = [msg objectAtIndex:0];
        
        NSString *bday = [bookData objectForKey:@"bday"];
        NSLog(@"action=bookinginfo bday: %@", bday);
        if (bday) {
            _bookDetail.bookTime = [[NSDate alloc] initWithTimeIntervalSince1970:bday.integerValue];
            pickedDate = _bookDetail.bookTime;
        }

        // 判断预约是否已经过期
        bool hasExceeded = dateHasExcedded(_bookDetail.bookTime, [NSDate date]);
//        if (!_bookDetail.bookTime || ![_bookDetail.bookTime isKindOfClass:[NSData class]]) {
//            hasExceeded = true;
//        }
//        else {
//            NSTimeInterval interval = [_bookDetail.bookTime timeIntervalSinceNow];
//            NSLog(@"internal: %.2f", interval);
//            if (interval < 0)
//                hasExceeded = true;
//            else
//                hasExceeded = false;
//        }
        
        NSString *bookNumber = [bookData objectForKey:@"no"];
        if (hasExceeded) {
            self.navigationItem.title = @"预约挂号（已过期）";
        }
        else if (!bookNumber || bookNumber.length <= 0) {
            self.navigationItem.title = @"预约挂号（待处理）";
        }
        else {
            self.navigationItem.title = [[NSString alloc] initWithFormat:@"预约挂号（单号：%@）", bookNumber];
        }

        NSNumber *hosID = [bookData objectForKey:@"hospitalid"];
        if (hosID)
            _bookDetail.hospitalID = hosID.integerValue;
        
        NSString *hosName = [bookData objectForKey:@"hname"];
        _bookDetail.hospitalName = hosName;
        
        NSNumber *offID = [bookData objectForKey:@"officeid"];
        if (offID)
            _bookDetail.officeID = offID.integerValue;
        
        NSString *offName = [bookData objectForKey:@"oname"];
        _bookDetail.officeName = offName;
                
        NSString *addDay = [bookData objectForKey:@"dateadd"];
        if (addDay)
            _bookDetail.submitTime = [[NSDate alloc] initWithTimeIntervalSince1970:addDay.integerValue];
        
        NSString *name = [bookData objectForKey:@"username"];
        _bookDetail.name = name;
        
        NSString *tel = [bookData objectForKey:@"usertel"];
        _bookDetail.telephone = tel;
        
        NSString *memo = [bookData objectForKey:@"memo"];
        _bookDetail.memory = memo;
        
        NSString *docMemo = [bookData objectForKey:@"doctormemo"];
        _bookDetail.hospitalReply = docMemo;
        
        NSNumber *succeed = [bookData objectForKey:@"bookingSucc"];
        if (succeed)
            _bookDetail.succeed = succeed.integerValue;

        NSNumber *age = [bookData objectForKey:@"age"];
        if (age)
            _bookDetail.age = age.integerValue;

        [self performSelectorOnMainThread:@selector(mainThreadRefreshDisplay) withObject:nil waitUntilDone:NO];
    }
}

- (void)mainThreadRefreshDisplay
{
    if (!_bookDetail)
        return;
    
    hospitalNameLabel.text = _bookDetail.hospitalName;
    
    officeLabel.text = _bookDetail.officeName;
    
    pickDateLabel.text = [[CureMeUtils defaultCureMeUtil].shortDateFormatter stringFromDate:_bookDetail.bookTime];
    
    nameField.text = _bookDetail.name;
    
    ageField.text = [[NSString alloc] initWithFormat:@"%ld", (long)_bookDetail.age];
    
    telField.text = _bookDetail.telephone;
    
    remarksField.text = _bookDetail.memory;
    
    _officeID = _bookDetail.officeID;
}

@end
