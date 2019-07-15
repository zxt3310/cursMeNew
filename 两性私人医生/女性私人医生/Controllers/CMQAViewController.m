//
//  CMQAViewController.m
//  私密健康医生
//
//  Created by Tim on 13-1-10.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMQAViewController.h"
#import "LoginViewController.h"
#import "CMQAViewControllerTitleView.h"
#import "CMQAOfficeSubTypeView.h"
#import "DoctorInfoViewController.h"
#import "BubbleViewController.h"
#import "CMMainTabViewController.h"
#import "CureMeNavigationController.h"
#import "KGModal.h"
#import "WebViewController.h"
#import "CMNewQueryViewController.h"


#define FF_HEADER_BGCOLOR [UIColor colorWithRed:208.0/255 green:2.0/255 blue:27.0/255 alpha:1.0]
#define FF_TEXTCOLOR_BLACK [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1.0]
@interface CMQAViewController ()
{
    UIScrollView *navView;
    UIButton *currentNavBtn;
    CGFloat split_width;
    NSDictionary *typeDataQA;
    
    UIView *qa_selectNavView;
    CGPoint qa_navViewStartPosPoint;
    CMQAProtocolView *protcolView;

}
@end

@implementation CMQAViewController

@synthesize isMainTabQAPage = _isMainTabQAPage;
@synthesize officeType = _officeType;
@synthesize officeSubType = _officeSubType;
@synthesize userID = _userID;
//@synthesize pageNo = _pageNo;
@synthesize leveyPopListView = _leveyPopListView;

UIView *protocolView1;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isMainTabQAPage = false;
//        _pageNo = 0;
        _userID = 0;
        _officeSubType = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    // Custom initialization
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [self.tabBarController.navigationController setNavigationBarHidden:NO];
    [self.view setUserInteractionEnabled:YES];
    // Do any additional setup after loading the view from its nib.
    _qaTable.qaViewController = self;
    [_qaTable setOfficeType:_officeType];
    [_qaTable refreshOfficeSubTypes];
    
    // 创建NavigationBar的显示View
    titleView = [[CMQAViewControllerTitleView alloc] initWithFrame:CGRectMake(0, 2, 120, 40)];
    [titleView setOfficeID:_officeType];
    [titleView setQaViewController:self];
    NSLog(@"titleView: %@", titleView);
    NSLog(@"titleView's titleIconView: %@", titleView.titleIconView);
    NSLog(@"titleView's titleLabel: %@", titleView.titleLabel);

    // 界面调整
    // 此时是“我的咨询”页面
    if (_isMainTabQAPage) {
        self.tabBarController.navigationItem.leftBarButtonItem = nil;
        self.tabBarController.navigationItem.leftBarButtonItems = nil;
        
        _startQueryView.hidden = YES;
        _qaTable.frame = CGRectMake(0, 0, 320, 367);
        
        self.tabBarController.navigationItem.title = @"我的咨询";
    }
    // 此时是“科室咨询”页面
    else {
        // 1. 更新QAViewController的控件高度
        CGRect frame = _qaTable.frame;
        if (IOS_VERSION >= 7.0) {
            frame.size.height += 14;
        }
        else {
            frame.size.height += 4;
        }

        _qaTable.frame = frame;
        NSLog(@"qaTable init: %@", _qaTable);

//        float sendAreaOriginY = [UIScreen mainScreen].applicationFrame.size.height - 44 - 44;
        _startQueryView.hidden = NO;
        NSLog(@"startQueryView init: %@", _startQueryView);
        
        self.navigationItem.titleView = titleView;
    }
    
    [super viewDidLoad];
    
    // 如果不是“我的咨询”页面，或者已登录未登录
    if (!_isMainTabQAPage || [CureMeUtils defaultCureMeUtil].hasLogin) {
        [self refreshData];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfUnreadMsgCountUpdated:) name:NTF_UNREADMSGCOUNT_UPDATED object:nil];
    
    NSNumber *hasMarkApp = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_AGREEPROTOCOL];
    if (!hasMarkApp || hasMarkApp.integerValue == 0) {
        protcolView = [[CMQAProtocolView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        protcolView.CmLocationDelegate = self;
    }    
    
    split_width = 15;
    
    navView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    navView.showsHorizontalScrollIndicator = NO;
    navView.showsVerticalScrollIndicator = NO;
    navView.panGestureRecognizer.delaysTouchesBegan = YES;//按钮滑动流畅
    navView.backgroundColor = [UIColor whiteColor];
    navView.layer.shadowColor = [UIColor blackColor].CGColor;
    navView.layer.shadowOffset = CGSizeMake(0, 1);
    navView.layer.shadowOpacity = 0.3;
    navView.clipsToBounds = NO;
    
    CGFloat navStartPos = split_width;
    currentNavBtn = [self createNavButton:@"全部" index:0 startPos:navStartPos width:2*14+2];
    [currentNavBtn setTitleColor:FF_HEADER_BGCOLOR forState:UIControlStateNormal];
    [navView addSubview:currentNavBtn];
    navStartPos += 2*14+2 + split_width*2;
    
    typeDataQA = [[CMDataUtils defaultDataUtil].officeTypeDict objectForKey:[NSNumber numberWithInteger:_officeType]];
    
    if (typeDataQA) {

        for (NSString *key in typeDataQA) {
            NSString *btnName = [typeDataQA objectForKey:key];
            int length = [self countAsciiLength:btnName];
            CGFloat btnWidth = length*14+2;
            [navView addSubview:[self createNavButton:btnName index:[key integerValue] startPos:navStartPos width:btnWidth]];
            navStartPos += btnWidth + split_width*2;            
        }
    }
    qa_selectNavView = [[UIView alloc] initWithFrame:CGRectMake(split_width, 35, 2*14+2, 3)];
    qa_selectNavView.backgroundColor = FF_HEADER_BGCOLOR;//[UIColor colorWithRed:255.0/255 green:205.0/255 blue:206.0/255 alpha:1.0];
    [navView addSubview:qa_selectNavView];
    CGSize contentSize = CGSizeMake(navStartPos, 40);
    navView.contentSize = contentSize;
    
    [self.view addSubview:navView];
}

-(void)navBtnClicked:(UIButton *)sender{
    [currentNavBtn setTitleColor:FF_TEXTCOLOR_BLACK forState:UIControlStateNormal];
    currentNavBtn = sender;
    [currentNavBtn setTitleColor:FF_HEADER_BGCOLOR forState:UIControlStateNormal];
    
    [self moveSelectView:sender.tag];
    //self.navigationItem.title = sender.titleLabel.text;
    if (sender.tag == 0) {
        [self officeSubTypeSelected:0];
    }else{
        [self officeSubTypeSelected:sender.tag];
    }
}

-(void)moveSelectView:(NSInteger)index{
    CGFloat spos = split_width;
    CGFloat swidth = 14*2+2;
    if (typeDataQA && index !=0) {
        
        for (NSString *key in typeDataQA) {
            NSString *btnName = [typeDataQA objectForKey:key];
            int length = [self countAsciiLength:btnName];
            spos += swidth + split_width*2;
            swidth = length*14+2;
            
            if ([key integerValue] == index)
                break;
        }
    }
    
    CGRect frame = CGRectMake(spos, 35, swidth, 3);
    qa_selectNavView.frame = frame;
}

-(UIButton *)createNavButton:(NSString *)title index:(NSInteger)index startPos:(CGFloat)startPos width:(CGFloat)width{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(startPos, 0+6, width, 28);
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button setTitle:title forState:UIControlStateNormal];
    //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:FF_TEXTCOLOR_BLACK forState:UIControlStateNormal];
    [button addTarget:self action:@selector(navBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = index;
    return button;
}

- (int)countAsciiLength:(NSString*)strtemp {
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
}

//-------------------------------------------------------------------------------

-(void)yesBtnClicked:(UIButton *)sender{
    protocolView1.hidden = YES;
    NSNumber *hasAgreeProtocol = [NSNumber numberWithInt:1];
    [[NSUserDefaults standardUserDefaults] setObject:hasAgreeProtocol forKey:HAS_AGREEPROTOCOL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)noBtnClicked:(UIButton *)sender{
    protocolView1.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"CMQAViewController didReceivememoryWaring");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setQaTable:nil];
    [self setStartQueryView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // 如果当前是科室咨询列表页，监听键盘输入事件
   /* [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 键盘高度变化通知，ios5.0新增的
    //#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }*/
    //#endif

//    // 更新是否有未读消息
//    [self ntfUnreadMsgCountUpdated:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 如果是“我的咨询”页面，并且未登录
    if (!hasShownLoginPage && _isMainTabQAPage && ![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.tabBarController.navigationController pushViewController:loginVC animated:YES];
        hasShownLoginPage = true;
        return;
    }
    
    rightBarItem = self.navigationItem.rightBarButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (imageDownloadHelper) {
        [imageDownloadHelper setShouldEnd:true];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setOfficeSubType:(NSInteger)officeSubType
{
    _officeSubType = officeSubType;
}

- (NSInteger)officeSubType
{
    return _officeSubType;
}

- (void)initQueryRightBarItem
{
    if (!confirmRightBarItem) {
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmBtn.frame = CGRectMake(0, 0, 41, 43);
        [confirmBtn setImage:[UIImage imageNamed:@"消息_n.png"] forState:UIControlStateNormal];
        [confirmBtn setImage:[UIImage imageNamed:@"消息_p.png"] forState:UIControlStateHighlighted];
        [confirmBtn setImage:[UIImage imageNamed:@"消息_p.png"] forState:UIControlStateSelected];
        [confirmBtn addTarget:self action:@selector(sendQueryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        confirmRightBarItem = [[UIBarButtonItem alloc] initWithCustomView:confirmBtn];
    }
}

- (void)ntfUnreadMsgCountUpdated:(NSNotification *)note
{
    NSInteger unreadCount = [CureMeUtils defaultCureMeUtil].unreadMessageCount;

    if (unreadCount > 0) {
        [[super unreadMsgBtn] setTitle:[NSString stringWithFormat:@"%ld", (long)unreadCount] forState:UIControlStateNormal];
        [super unreadMsgBtn].hidden = NO;
    }
    else {
        [super unreadMsgBtn].hidden = YES;
    }
}

- (IBAction)back:(id)sender
{
    [super back:sender];
}

#pragma mark -
#pragma mark events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [event allTouches].anyObject;
    if ([touch.view isEqual:querySubTypeView] || [querySubTypeView.subviews containsObject:touch.view]) {
        [super touchesBegan:touches withEvent:event];
    }

    [self.view becomeFirstResponder];
}

//- (void)keyboardWillShow:(NSNotification *)notification {
//    
//    /*
//     Reduce the size of the text view so that it's not obscured by the keyboard.
//     Animate the resize so that it's in sync with the appearance of the keyboard.
//     */
//    
//    NSDictionary *userInfo = [notification userInfo];
//    
//    // Get the origin of the keyboard when it's displayed.
//    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    
//    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
//    CGRect keyboardRect = [aValue CGRectValue];
//    
//    // Get the duration of the animation.
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    
//    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
//    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
//}
//
//
//- (void)keyboardWillHide:(NSNotification *)notification {
//    
//    NSDictionary* userInfo = [notification userInfo];
//    
//    /*
//     Restore the size of the text view (fill self's view).
//     Animate the resize so that it's in sync with the disappearance of the keyboard.
//     */
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    
//    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
//}
//
//- (void)moveInputBarWithKeyboardHeight:(float)height withDuration:(NSTimeInterval)duration
//{
//    // 如果是键盘还原
//    if (height < 0.0001 && height > -0.0001) {
//        // 1. 还原键盘
////        float originY = [[UIScreen mainScreen] applicationFrame].size.height;
////        _sendAreaView.frame = CGRectMake(0, originY - 44 - 44, 320, 44);
////        [_sendAreaView setHidden:YES];
//
//        // 2. 隐藏咨询子分类View
//        [querySubTypeView setHidden:YES];
//        
//        // 3.
//        [_startQueryView setHidden:NO];
//        
//        // 4. 调整Nav元素显示
//        self.navigationItem.title = nil;
//        self.navigationItem.titleView = titleView;
//        self.navigationItem.rightBarButtonItem = rightBarItem;
//    }
//    // 如果是键盘出现
//    else if (height > 0.0001) {
//        CGRect frame;
//        
//        // 1. 显示子分类View，保证从0高度开始覆盖
//        if (!querySubTypeView || querySubTypeView.officeType != _officeType) {
//            [querySubTypeView removeFromSuperview];
//
//            querySubTypeView = [[CMQAOfficeSubTypeView alloc] initWithFrame:CGRectZero];
//            [querySubTypeView setOfficeType:_officeType];
//            [querySubTypeView clearAllSubTypeBtns];
//            [querySubTypeView initSubTypeButtons];
//            querySubTypeView.delegate = self;
////            [querySubTypeView setQaViewController:self];
//            // 设置科室的子分类
//            [querySubTypeView switchViewTypeToQuery];
//            [querySubTypeView updateBackgroundImage:[UIImage imageNamed:@"layout_bg.png"]];
//            [querySubTypeView setHidden:NO];
//            frame = querySubTypeView.frame;
//            frame.origin.y = 0;
//            querySubTypeView.frame = frame;
//            [self.view addSubview:querySubTypeView];
//        }
//        
//        // 调整Nav元素显示
//        [self initQueryRightBarItem];
//        self.navigationItem.rightBarButtonItem = confirmRightBarItem;
//        self.navigationItem.titleView = nil;
//        self.navigationItem.title = @"咨询";
//        
//        _queryOfficeSubType = _officeSubType;
//        [querySubTypeView setOfficeSubType:_queryOfficeSubType];
//        NSLog(@"querySubTypeView: %@", querySubTypeView);
//
////        // 1. 显示键盘
////        float screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
////        float sendAreaHeight = screenHeight - height - 44 - querySubTypeView.frame.size.height;
////        _sendAreaView.hidden = NO;
////        _sendAreaView.frame = CGRectMake(0, querySubTypeView.frame.size.height, 320, sendAreaHeight);
////        frame = _sendAreaView.frame;
////        _sendAreaSendBtn.frame = CGRectMake(255, frame.size.height - 38, 60, 36);
////        _sendAreaInputField.frame = CGRectMake(5, 5, 310, frame.size.height - 44);
////        NSLog(@"sendAreaView: %@ querySubTypeView: %@", _sendAreaView, querySubTypeView);
//    }
//}

#pragma mark CMQOfficeSubTypeViewDelegate
- (void)officeSubTypeSelected:(NSInteger)officeSubType
{
    if (officeSubType == _officeSubType) {
        NSLog(@"SubType selected is the same");
        return;
    }
    
    [self setOfficeSubType:officeSubType];
    [self refreshData];
}

- (void)queryOfficeSubTypeSelected:(NSInteger)queryOfficeSubType
{
    [self setQueryOfficeSubType:queryOfficeSubType];
}

// 后台线程，获取咨询列表数据
- (void)threadInitQAData
{
    @autoreleasepool {
        // 线程开始前保存当前载入的subtype值
        NSInteger curLoadingSubType = _officeSubType;
        
        NSMutableString *post = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"action=questionlist&type=%ld&typechild=%ld&userid=%ld", (long)_officeType, (long)_officeSubType, (long)_userID]];
        if (lastQuestionTime) {
            [post appendFormat:@"&lasttime=%@", [[CureMeUtils defaultCureMeUtil].detailDateFormatter stringFromDate: lastQuestionTime]];
        }
//        NSString *post = [NSString stringWithFormat:@"action=questionlist&type=%d&typechild=%d&userid=%d&page=%d", _officeType, _officeSubType, _userID, _pageNo];
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"initQAsWithCondition post: %@ resp:%@", post, strResp);
        
        // 如果当前线程载入的subtype与用户选择的不同，则不保存
        if (curLoadingSubType != _officeSubType) {
            NSLog(@"QAViewController threadInitQAData subtype not match curLoadingSubType: %ld officeSubType: %ld", (long)curLoadingSubType, (long)_officeSubType);
            return;
        }
        
        NSDictionary *jsonDict = parseJsonResponse(response);
        NSNumber *result = [jsonDict objectForKey:@"result"];
        if (!result || 0 == [result integerValue]) {
            NSString *error = [jsonDict objectForKey:@"msg"];
            NSLog(@"initQAs req fail %@", error);
            [self performSelectorOnMainThread:@selector(mainThreadRefreshTableView) withObject:nil waitUntilDone:NO];
            return;
        }
        
        // 如果当前线程载入的subtype与用户选择的不同，则不保存
        if (curLoadingSubType != _officeSubType) {
            NSLog(@"QAViewController threadInitQAData subtype not match curLoadingSubType: %ld officeSubType: %ld", (long)curLoadingSubType, (long)_officeSubType);
            return;
        }

        [self performSelectorOnMainThread:@selector(mainThreadRefreshData:) withObject:jsonDict waitUntilDone:NO];
    }
}

- (void)mainThreadRefreshData:(NSDictionary *)data
{
    NSArray *msgArray = [data objectForKey:@"msg"];
    if (!msgArray || msgArray.count <= 0) {
        NSLog(@"action=questionlist param \"msg\" invalid");
        [self performSelectorOnMainThread:@selector(mainThreadRefreshTableView) withObject:nil waitUntilDone:NO];
        return;
    }

    _curPageQueryCount = msgArray.count;
    for (int i = 0; i < MIN(20, [msgArray count]); i++) {
        NSDictionary *msgDict = [msgArray objectAtIndex:i];
        QuestionAnswers *questionAnswer = [[QuestionAnswers alloc] init];
        Question *question = [[Question alloc] init];
        [questionAnswer setQuestion:question];
        
        NSString *questionID = [msgDict objectForKey:@"id"];
        NSInteger iQID = [questionID integerValue];
        [question setIdentifier:[[NSNumber alloc] initWithInteger:iQID]];
        
        NSInteger uID = [[msgDict objectForKey:@"userid"] integerValue];
        // 提问者ID，可能不是用户本身
        [question setUserid:uID];
        
        NSString *message = [msgDict objectForKey:@"title"];
        [question setQuestion:message];
        
        NSInteger unixTime = [[msgDict objectForKey:@"dateadd"] integerValue];
        [question setQuestionTime:[NSDate dateWithTimeIntervalSince1970:unixTime]];
        
        [questionAnswer setReplyCount:[[msgDict objectForKey:@"rcount"] integerValue]];
        
        // 如果回复数为0，设置replycount为0
        NSArray *replies = [msgDict objectForKey:@"replys"];
        if (!replies || replies.count <= 0) {
            question.hasAnswer = false;
        }
        else {
            question.hasAnswer = true;
            
            for (NSDictionary *replyDict in replies) {
                Answer *answer = [[Answer alloc] init];
                [answer setQuestionID:[NSNumber numberWithInteger:[[question identifier] integerValue]]];
                [answer setIdentifier:[[NSNumber alloc] initWithInteger:[[replyDict objectForKey:@"id"] integerValue]]];
                [answer setUserID:uID];     // 设置问题的提问者ID
                [answer setDoctorID:[[NSNumber alloc] initWithInteger:[[replyDict objectForKey:@"did"] integerValue]]];
                [answer setDoctorName:[NSString stringWithFormat:@"%@", [replyDict objectForKey:@"dname"]]];
                [answer setDoctorImageKey:[replyDict objectForKey:@"dpic"]];
                [answer setDoctorTitle:[NSString stringWithFormat:@"%@", [replyDict objectForKey:@"dtitle"]]];
                [answer setHospitalName:[NSString stringWithFormat:@"%@", [replyDict objectForKey:@"hname"]]];
                NSNumber *officeID = [replyDict objectForKey:@"oid"];
                [answer setOfficeID:officeID.integerValue];
                NSNumber *hospitalID = [replyDict objectForKey:@"hid"];
                [answer setHospitalID:hospitalID.integerValue];
                [answer setOfficeName:[NSString stringWithFormat:@"%@", [replyDict objectForKey:@"oname"]]];
                [answer setAnswer:[replyDict objectForKey:@"reply"]];
                NSInteger unixTime = [[replyDict objectForKey:@"dateadd"] integerValue];
                [answer setReplyTime:[NSDate dateWithTimeIntervalSince1970:unixTime]];
                [[questionAnswer answerArray] addObject:answer];
            }
        }
        
        [_qaTable.qaArray addObject:questionAnswer];
    }
    NSLog(@"msg count %lu", (unsigned long)[msgArray count]);
    
    // 获得最早一条消息的时间
    NSDictionary *lastMsgDict = [msgArray lastObject];
    lastQuestionTime = [NSDate dateWithTimeIntervalSince1970:[[lastMsgDict objectForKey:@"dateadd"] integerValue]];
    NSLog(@"lastQuestionTime: %@", [[CureMeUtils defaultCureMeUtil].dateFormatter stringFromDate:lastQuestionTime]);
    
    [self startImageDownloader];
    
    [self mainThreadRefreshTableView];
}

// 主线程刷新TableView
- (void)mainThreadRefreshTableView
{
    // 更新未读消息数
    [[CureMeUtils defaultCureMeUtil] updateUnreadMsgCount];
//    [activityIndicator stopAnimating];
    if (_qaTable.qaArray.count <= 0) {
        _qaTable.noDataBgView.hidden = NO;
    }
    _qaTable.loadingBgView.hidden = YES;

    [self.qaTable.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.qaTable];

    [self.qaTable reloadData];
}

- (void)startImageDownloader
{
    @autoreleasepool {
        if (!_qaTable.qaArray || _qaTable.qaArray.count <= 0) {
            return;
        }

        if (!imageDownloadHelper) {
            imageDownloadHelper = [[ImageDownloadHelper alloc] init];
            [imageDownloadHelper setDelegate:self];
        }
        
        // 添加下载任务
        for (QuestionAnswers *questionAnswers in _qaTable.qaArray) {
            NSArray *answers = questionAnswers.answerArray;
            for (Answer *answer in answers) {
                NSString *imageKey = answer.doctorImageKey;
                [imageDownloadHelper addImageKey:imageKey andSizeType:@"90"];
            }
        }
        
        // 启动下载
        [imageDownloadHelper startDownload];
    }
}

#pragma mark ImageDownloadHelperDelegate method:
- (void)imageDownloadComplete:(NSString *)imageKey andType:(NSString *)type andImage:(UIImage*)image
{
    if (!headImageDict) {
        headImageDict = [[NSMutableDictionary alloc] init];
    }
    
    [headImageDict setObject:image forKey:imageKey];
}

- (void)allImageComplete
{
    // ReloadData，确保能够正确初始化TableView的Section
    [self performSelectorOnMainThread:@selector(mainThreadRefreshTableView) withObject:nil waitUntilDone:NO];
}

- (UIImage *)getHeadImage:(NSString *)imageKey
{
    if (!headImageDict || headImageDict.count <= 0)
        return nil;
    
    return [headImageDict objectForKey:imageKey];
}

#pragma mark LeveyPopListViewDelegate
- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex
{
    NSArray *officeTypes = [CMDataUtils defaultDataUtil].officeTypeArray;
    if (!officeTypes || officeTypes.count <= anIndex) {
        return;
    }

    OfficeTypeUnit *unit = [officeTypes objectAtIndex:anIndex];
    _officeType = unit.officeID;
    _officeSubType = 0;
    
    // 2. 刷新列表数据
    [self performSelectorOnMainThread:@selector(refreshData) withObject:nil waitUntilDone:NO];
}

- (void)leveyPopListViewDidCancel
{
    NSLog(@"CMQAViewController leveyPopListViewDidCancel");
    
//    CMQAViewControllerTitleView *titleView = nil;
//    if (_isMainTabQAPage) {
//        titleView = ((CMQAViewControllerTitleView *)self.tabBarController.navigationItem.titleView);
//    }
//    else {
//        titleView = (CMQAViewControllerTitleView *)self.navigationItem.titleView;
//    }
    
    if ([titleView respondsToSelector:@selector(rotateTitleTriangle)]) {
        [titleView rotateTitleTriangle];
    }
}

- (void)appendData
{
//    _pageNo++;

//    [activityIndicator startAnimating];
    _qaTable.loadingBgView.hidden = NO;

    [self performSelectorInBackground:@selector(threadInitQAData) withObject:nil];
}

- (void)refreshData
{
    // 0. 先隐藏TableView的NoDataView
    _qaTable.noDataBgView.hidden = YES;
    _qaTable.loadingBgView.hidden = NO;
//    [activityIndicator startAnimating];

    // 1. 刷新子分类的View
    if (lastOfficeType != _officeType) {
        // 0）更新tableView主分类ID，并且置子分类ID为0
        [_qaTable setOfficeType:_officeType];
        if (lastOfficeType != 0) {
            _officeSubType = 0;
        }
        // 1）更新子分类View
        [_qaTable refreshOfficeSubTypes];
        // 2）更新主分类TitleView
        [titleView setOfficeID:_officeType];
        
        lastOfficeType = _officeType;
    }

    // 2013-08-20 首次进入QA列表时，选中想要的子分类
    [_qaTable setOfficeSubType:_officeSubType];
    
    [_qaTable.qaArray removeAllObjects];
    [_qaTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

    lastQuestionTime = nil;
    // 2. 重新载入咨询列表
    [self performSelectorInBackground:@selector(threadInitQAData) withObject:nil];
}

#pragma mark functions
- (void)showDoctorInfoPage:(NSInteger)doctorID
{
    if (doctorID <= 0) {
        return;
    }
    
    WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    [webVC setStrURL:[NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/hospital/dinfo.php?did=%ld", (long)doctorID]];
    [self.navigationController pushViewController:webVC animated:YES];

//    // 以下显示医生信息页面
//    DoctorInfoViewController *doctorInfoVC = [[DoctorInfoViewController alloc] initWithNibName:@"DoctorInfoViewController" bundle:nil];
//    [doctorInfoVC setDoctorID:doctorID];
//    
//    [self.navigationController pushViewController:doctorInfoVC animated:YES];
}

- (void)showDialogPage:(NSInteger)talkerID andReply:(Answer *)answer andSourceType:(NSString *)sourceType
{
    if (talkerID <= 0) {
        return;
    }
    
    BubbleViewController *talkVC = [[BubbleViewController alloc] initWithNibName:@"BubbleViewController" bundle:nil];
    if (!talkVC) {
        NSLog(@"showDialogPage create BubbleViewController failed");
        return;
    }
    
    // 判断是自己的咨询还是别人的咨询
    NSArray *qaArray = _qaTable.qaArray;
    
    for (QuestionAnswers *qa in qaArray) {
        if (qa.question.identifier.integerValue == answer.questionID.integerValue) {
            [talkVC setChatUserID:qa.question.userid];
            NSLog(@"showDialogPage %@", qa.question);
            break;
        }
    }
    
    [talkVC setChatOpenType:@"mylist"];
    [talkVC setTalkerID:talkerID];
    [talkVC setTalkerName:answer.doctorName];
    [talkVC setSourceID:answer.identifier.integerValue];
    [talkVC setSourceType:sourceType];
    [talkVC setOfficeType:_officeType];
    [talkVC setOfficeSubType:_officeSubType];
    NSLog(@"showDialogPage chatUserID: %ld talkerID: %ld talkerName: %@ sourceID: %ld sourceType: %@", (long)talkVC.chatUserID, (long)talkerID, answer.doctorName, (long)answer.identifier.integerValue, sourceType);
    
    [self.navigationController pushViewController:talkVC animated:YES];
}

- (void)dismissLeveyPopListView
{
    if (!_leveyPopListView)
        return;
    
    [_leveyPopListView dismissFromSuperView];
    _leveyPopListView = nil;
}

- (void)showAllOfficeTypeView
{

    NSArray *options = [[NSArray alloc] init];

    _leveyPopListView = [[LeveyPopListView alloc] initWithTitle:nil options:options];
    _leveyPopListView.delegate = self;
    [_leveyPopListView showInView:self.view animated:YES];

    if (IOS_VERSION >= 7.0) {
        CGRect tableFrame = _leveyPopListView.frame;
        //tableFrame.origin.y = 20 + NAVIGATIONBAR_HEIGHT;
        //tableFrame.origin.y = 64;
        //tableFrame.size.height = SCREEN_HEIGHT - 20 - NAVIGATIONBAR_HEIGHT - 50;
        tableFrame.size.height = SCREEN_HEIGHT - 49 - 64;
        _leveyPopListView.frame = tableFrame;
    }
}

- (IBAction)sendQueryBtnClicked:(id)sender {
//    NSString *oriQuestion = [_sendAreaInputField text];
//    NSString *question = [oriQuestion stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    
//    if ([question length] <= 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"咨询"
//                                                        message:@"请输入要咨询的内容"
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
//
//    if ([question isEqualToString:lastQueryString]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"咨询"
//                                                        message:@"您已咨询过相同问题，请勿重复发送"
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
//    
//    NSString *sendQuestion = [question stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"sendQuestion: before encoding: %@ after encoding: %@", question, sendQuestion);
//    
//    NSString *encodeAddr = [CureMeUtils defaultCureMeUtil].encodedLocateInfo;
//    NSString *post = [NSString stringWithFormat:@"action=postquestion&userid=%d&type=%d&typechild=%d&question=%@&img=&addrdetail=%@", [CureMeUtils defaultCureMeUtil].userID, _officeType, _queryOfficeSubType, sendQuestion, encodeAddr ? encodeAddr : @""];
//    NSLog(@"zixun: %@", post);
//    NSData *response = sendRequest(@"m.php", post);
//    NSDictionary *respDict = parseJsonResponse(response);
//    NSNumber *result = [respDict objectForKey:@"result"];
//    if (!result || 0 == [result integerValue]) {
//        NSString *error = [respDict objectForKey:@"msg"];
//        NSLog(@"sendQuestion failed %@", error);
//    }
//    else {
//        if (!alertViewController) {
//            alertViewController = [[CMAlertViewController alloc] initWithNibName:@"CMAlertViewController" bundle:nil];
//            alertViewController.delegate = self;
//            [alertViewController setMsgTitle:@"发布咨询"];
//            [alertViewController setMsgContent:@"咨询发布成功，进入我的咨询查看回复"];
//        }
//        
//        [[KGModal sharedInstance] setModalBackgroundColor:[UIColor clearColor]];
//        [[KGModal sharedInstance] showWithContentView:alertViewController.view andAnimated:YES];
//    }
//    
//    lastQueryString = _sendAreaInputField.text;
//    _sendAreaInputField.text = @"";
//    [_sendAreaInputField endEditing:YES];
}

- (IBAction)startQueryBtnClicked:(id)sender {
    // 准备提交咨询的时候，发起一次定位
    [[CureMeUtils defaultCureMeUtil] startLocationing];
//    NSNumber *regionNum = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
//    if (!regionNum) {
//        [self popPickerView];
//        return;
//    }
    
    NSNumber *hasMarkApp = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_AGREEPROTOCOL];
    if (!hasMarkApp || hasMarkApp.integerValue == 0) {
        [self.view addSubview:protcolView];
        return;
    }

    /*CMQueryViewController *queryVC = [[CMQueryViewController alloc] initWithNibName:@"CMQueryViewController" bundle:nil];
    [queryVC setOfficeType:_officeType];
    [queryVC setSubOfficeType:_officeSubType];
    [self.navigationController pushViewController:queryVC animated:YES];*/
    
    CMNewQueryViewController *queryVC = [CMNewQueryViewController new];
    queryVC.officeType = _officeType;
    queryVC.subOfficeType = _officeSubType;
    queryVC.chatUserID = [CureMeUtils defaultCureMeUtil].userID;
    [self.navigationController pushViewController:queryVC animated:YES];
}

- (void)popPickerView
{
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        NSString *post = [NSString stringWithFormat:@"action=createuserdata&deviceid=%@&appid=7&addrdetail=%@&token=%@", [CureMeUtils defaultCureMeUtil].uniID, [CureMeUtils defaultCureMeUtil].encodedLocateInfo, nil];
        NSData *response = sendRequest(@"m.php", post);
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"createuserdata resp: %@", strResp);
        NSDictionary *respDict = parseJsonResponse(response);
        NSNumber *result = [respDict objectForKey:@"result"];
        if (!result || [result integerValue] != 1) {
            NSLog(@"createuserdata result invalid %@", strResp);
            return;
        }
        
        NSNumber *userid = [respDict objectForKey:@"msg"];
        if (!userid || [userid integerValue] <= 0) {
            NSLog(@"createuserdata userid invalid %@", strResp);
            return;
        }
        
        [CureMeUtils defaultCureMeUtil].userID = [userid integerValue];
        [[NSUserDefaults standardUserDefaults] setObject:userid forKey:USER_ID];
        NSNumber *SWTID = [[NSNumber alloc] initWithInteger:0];
        [[NSUserDefaults standardUserDefaults] setObject:SWTID forKey:USER_SWT_ID];
        [CureMeUtils defaultCureMeUtil].userName = [CureMeUtils defaultCureMeUtil].uniID;
        [[NSUserDefaults standardUserDefaults] setObject:[CureMeUtils defaultCureMeUtil].uniID forKey:USER_REGISTERNAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // 初始化选择地区的Modal ViewController
    if (!pickerViewController) {
        pickerViewController = [[CMPickerViewController alloc] initWithNibName:@"CMPickerViewController" bundle:nil];
        [pickerViewController setPickerColumnCount:PICKER_COLUMN_TWO];
    }
    NSDictionary *regionDict = [[CureMeUtils defaultCureMeUtil] regionDictionaryForUser];
    NSArray *regionArray = [[CureMeUtils defaultCureMeUtil] regionSortedKeys];
    NSMutableArray *pickerDataArray = [[NSMutableArray alloc] init];
    for (NSString *key in regionArray) {
        [pickerDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:key, @"id", [regionDict objectForKey:key], @"name", nil]];
    }
    NSLog(@"firstColumn: %@", pickerDataArray);
    // 设置省份
    [pickerViewController setFirstColumnData:pickerDataArray];
    
    // 设置市区
    NSNumber *firstID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
    NSArray *cityArray = nil;
    if (firstID) {
        cityArray = [[CureMeUtils defaultCureMeUtil] cityArrayWithRegionID:firstID.integerValue];
    }
    else {
        firstID = [[pickerDataArray objectAtIndex:0] objectForKey:@"id"];
        cityArray = [[CureMeUtils defaultCureMeUtil] cityArrayWithRegionID:firstID.integerValue];
    }
    [pickerViewController setSecondColumnData:cityArray];
    
    // 设置选中的省、直辖市、市区数值
    NSNumber *secondID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CITY];
    if (!secondID) {
        secondID = [NSNumber numberWithInt:0];
    }
    [pickerViewController setSelectedIDAtFirstColumn:firstID.integerValue andSecondColumn:secondID.integerValue andThirdColumn:0];
    
    [pickerViewController setPickerDelegate:self];
    [pickerViewController.view setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
    //[pickerViewController.view setBackgroundColor:[UIColor clearColor]];
    [pickerViewController setPickerTitle:[NSString stringWithFormat:@"请选择您所在的地区"]];
    
    [[KGModal sharedInstance] setModalBackgroundColor:[UIColor clearColor]];
    [[KGModal sharedInstance] setYUpOffset:0];
    [[KGModal sharedInstance] showWithContentView:pickerViewController.view andAnimated:YES];
}

#pragma mark CMAlertViewControllerDelegate
- (void)confirmBtnClickForDelegate
{
    // 跳转到“我的咨询”页面
    CMMainTabViewController *mainTabVC = (CMMainTabViewController *)[[self.navigationController viewControllers] objectAtIndex:0];
    
    [mainTabVC setSelectedIndex:1];
    [mainTabVC.customTabBarView selectButtonAtIndex:1];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark CMPickerDelegate
- (void)didSelectOK:(NSDictionary *)firstUnit andSecondColumn:(NSDictionary *)secondUnit andThirdColumn:(NSDictionary *)thirdUnit;
{
    if (!firstUnit) {
        return;
    }
    // 选中的区域与城市信息
    NSNumber *regionID;
    NSString *cityTitle;
    NSNumber *cityID;
    
    regionID = [firstUnit objectForKey:@"id"];
    // 更新内存中用户地区显示
    [[CureMeUtils defaultCureMeUtil] updateUserRegion:regionID];
    
    cityID = [secondUnit objectForKey:@"id"];
    cityTitle = [secondUnit objectForKey:@"name"];
    // 更新内存中用户地区显示
    [[CureMeUtils defaultCureMeUtil] updateUserCity:cityID andCityName:cityTitle];
    
    // 发送请求
    NSString *post = [NSString stringWithFormat:@"action=upduserinfo&userid=%ld&city=%ld&city2=%ld&addrdetail=%@", (long)[CureMeUtils defaultCureMeUtil].userID, (long)regionID.integerValue, (long)cityID.integerValue, [CureMeUtils defaultCureMeUtil].encodedLocateInfo];
    NSData *response = sendRequest(@"m.php", post);
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"post: %@ resp: %@", post, strResp);
}

- (void)pushNewQuary:(NSInteger)office1 and:(NSInteger)office2{
    CMNewQueryViewController *queryVC = [CMNewQueryViewController new];
    queryVC.officeType = _officeType;
    queryVC.subOfficeType = _officeSubType;
    queryVC.chatUserID = [CureMeUtils defaultCureMeUtil].userID;
    [self.navigationController pushViewController:queryVC animated:YES];

}
@end
