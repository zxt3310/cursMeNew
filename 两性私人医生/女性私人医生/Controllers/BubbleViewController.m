//
//  BubbleViewController.m
//  CureMe
//
//  Created by Tim on 12-8-21.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "DDXML.h"
#import "Doctor.h"
#import "BubbleViewController.h"
#import "UIBubbleTableView.h"
#import "CMActionSheet.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "QueryViewController.h"
#import "BookDetailInfoViewController.h"
#import "LoginViewController.h"
#import "CMQAOfficeSubTypeView.h"
#import "WebViewController.h"
#import "CMMarkDoctorViewController.h"
#import "CureMeNavigationController.h"
//#import "CMQueryViewController.h"
#import "CMNewQueryViewController.h"

// Modal
#import "KGModal.h"
#import "CMMarkDoctorViewController.h"

//#import "MainTabViewController.h"
//#import "QuestionViewController.h"
//#import "RaiseQuestionViewController.h"

#import "FullPictureViewController.h"
#import "DoctorInfoViewController.h"
#import "MapViewController.h"
#import "OfficeListInfoTableViewController.h"

CMActionSheet *actionSheet;

@implementation ChatBookInfo

- (NSString *)description
{
    NSString *dscp = [[NSString alloc] initWithFormat:@"\nBookID: %ld\nUserName: %@\nHospitalName: %@\nOfficeName: %@\nBookDate: %@\nAge: %ld\nTelephone: %@\nMemo: %@", (long)self.bookID, self.name, self.hospitalName, self.officeName, self.date, (long)self.age, self.telephone, self.memory];

    return dscp;
}

@end


@interface BubbleViewController ()
{
    NSInteger maxId;
    BOOL talking;
}
@end

@implementation BubbleViewController

@synthesize inputField = _inputField;
@synthesize officeType = _officeType;
@synthesize talkerID = _talkerID;
@synthesize talkerName = _talkerName;
@synthesize sourceType = _sourceType;
@synthesize sourceID = _sourceID;
@synthesize pageName = _pageName;
@synthesize chatID = _chatID;
@synthesize chatUserID = _chatUserID;
@synthesize isTalkFromSelfQuestion = _isTalkFromSelfQuestion;
@synthesize doctorHeadImage = _doctorHeadImage;
@synthesize metaInfoData = _metaInfoData;
@synthesize bookInfoUnit = _bookInfoUnit;
@synthesize hospitalLatitude = _hospitalLatitude;
@synthesize hospitalLongitude = _hospitalLongitude;
@synthesize chatOpenType = _chatOpenType;
@synthesize doctor = _doctor;

CMQAProtocolView *protocolView;
NSString *saveTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (id)init
{
    self = [super initWithNibName:@"BubbleViewController" bundle:nil];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"BubbleViewController dealloc");
    [bubbleData removeAllObjects];
    bubbleData = nil;
    
    _inputField = nil;
    _pageName = nil;
    _sourceType = nil;
    actionSheet = nil;
    
    imageDownloader = nil;
    doctorNames = nil;
    doctorImages = nil;

//    furtherTalkBtn = nil;
    addImageBtn = nil;
    sendMsgBtn = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = nil;
    
    chatBookID = 0;
    maxId = 0;
    talking = NO;
    
    // 1. 初始化DataSource
    bubbleTable.bubbleDataSource = self;
    [bubbleTable setChatViewController:self];
    CGRect temp = bubbleTable.frame;
    temp.size.width = SCREEN_WIDTH;
    bubbleTable.frame = temp;
    
    bubbleData = [[NSMutableArray alloc] init];
    
    // 如果Reply用户不是登录用户，显示开始聊天按钮
    if (_chatUserID != [CureMeUtils defaultCureMeUtil].userID) {
        [_startQueryView setHidden:NO];

        [sendQuestionImage setHidden:NO];
        [sendQuestionLabel setHidden:NO];
        [sendMsgBtn setHidden:YES];
        [addImageBtn setHidden:YES];
        [_inputField setHidden:YES];
        _lineLb.layer.borderColor = UIColorFromHex(0xbcbcbc, 1).CGColor;
        _startQueryView.layer.borderWidth = 0.5;
        _startQueryView.layer.borderColor = UIColorFromHex(0x9b9a9b, 0.51).CGColor;
    }
    // 如果Reply用户是登录用户，显示输入聊天按钮
    else {
        [_startQueryView setHidden:YES];
        
        [sendQuestionImage setHidden:YES];
        [sendQuestionImage setHidden:YES];
        [sendMsgBtn setHidden:NO];
        [addImageBtn setHidden:NO];
        [_inputField setHidden:NO];
        
        // 如果是自己的对话，右上角显示“评价”按钮
//        UIButton *markBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        markBtn.frame = CGRectMake(0, 0, 41, 41);
//        [markBtn setImage:[UIImage imageNamed:@"评分_n.png"] forState:UIControlStateNormal];
//        [markBtn setImage:[UIImage imageNamed:@"评分_p.png"] forState:UIControlStateHighlighted];
//        [markBtn setImage:[UIImage imageNamed:@"评分_p.png"] forState:UIControlStateSelected];
//        [markBtn addTarget:self action:@selector(startMarkChat:) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:markBtn];
//        self.navigationItem.rightBarButtonItem = barBtnItem;
        
        markDoctorViewController = [[CMMarkDoctorViewController alloc] initWithNibName:@"CMMarkDoctorViewController" bundle:nil];
        markDoctorViewController.delegate = self;
    }

    // 保存右上角按钮
    rightBarItem = self.navigationItem.rightBarButtonItem;

    [_inputField setDelegate:self];

    // 当前显示的历史消息第一页
    oldesMessageTime = 0;

    loadingView.hidden = NO;
//    [activityIndicator startAnimating];
    
    // 图片下载器必须在初始化历史记录之前启动
    // 开启图片无尽循环下载模式
    [[self imageDownloader] setDelegate:self];
    
    // 新版App中，不需要始终开启图片下载器
//    [[self imageDownloader] setEndlessMode:true];
    [[self imageDownloader] setShouldEnd:false];

    bubbleTable.hasLoadHistoryComplete = true;
    [NSThread detachNewThreadSelector:@selector(threadInitChatDatas) toTarget:self withObject:nil];

    // 0. 注册Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfPullNewMsgs:) name:NTF_PullNewChatMsgs object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfShowFullImage:) name:NTF_ChatMsgThumbnailClick object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfUpdateUnreadMsgCount:) name:NTF_UNREADMSGCOUNT_UPDATED object:nil];
    
    // 载入中的View
    float topY = 140;
    if ([UIScreen mainScreen].bounds.size.height > 480.0) {
        topY += 40;
    }
    loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 35, topY, 80, 70)];
    loadingView.hidden = YES;
    [self.view addSubview:loadingView];
//    [self.view sendSubviewToBack:loadingView];

    needStopDetectReplies = false;
    [[CureMeUtils defaultCureMeUtil] setCurChatHeartBreakSeed:rand()];
    
    NSNumber *hasMarkApp = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_AGREEPROTOCOL];
    if (!hasMarkApp || hasMarkApp.integerValue == 0) {
        protocolView = [[CMQAProtocolView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        protocolView.CmLocationDelegate = self;
    }
    
    /**
     *  @author Zxt, 17-04-28 10:04:11
     *
     *  修改咨询文本框样式
     */
    addImageBtn.hidden = YES;
    sendQuestionImage.hidden = YES;
    queryInputView.layer.borderWidth = 0.5;
    queryInputView.layer.borderColor = UIColorFromHex(0x9b9b9b, 0.51).CGColor;
    _inputField.placeholder = @"请输入您要咨询的问题";
    _inputField.layer.cornerRadius = 5;
    _inputField.layer.borderWidth = 0.5;
    _inputField.layer.borderColor = queryInputView.layer.borderColor;
    
    //适配 PHONE X
    temp = _startQueryView.frame;
    temp.origin.y = temp.origin.y - (FitIpX(0));
    _startQueryView.frame = temp;
}

-(void)yesBtnClicked:(UIButton *)sender{
    protocolView.hidden = YES;
    NSNumber *hasAgreeProtocol = [NSNumber numberWithInt:1];
    [[NSUserDefaults standardUserDefaults] setObject:hasAgreeProtocol forKey:HAS_AGREEPROTOCOL];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationItem setTitle:saveTitle];
}

-(void)noBtnClicked:(UIButton *)sender{
    protocolView.hidden = YES;
    [self.navigationItem setTitle:saveTitle];
}

- (IBAction)back:(id)sender
{
    NSLog(@"BubbleViewController back");
    [self.view endEditing:YES];
    talking = NO;

    [super back:sender];
    
    needStopDetectReplies = true;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NTF_ChatMsgThumbnailClick object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NTF_PullNewChatMsgs object:nil];
    [[self imageDownloader] setShouldEnd:true];
}

- (void)viewDidUnload
{
    NSLog(@"BubbleViewController viewDidUnload");
    sendQuestionImage = nil;
    sendQuestionLabel = nil;
    [self setStartQueryView:nil];
    [super viewDidUnload];
}

- (IBAction)startBookBtnClicked:(id)sender{
    [self startBooking:nil];
}
- (IBAction)startBooking:(id)sender
{
    if (!_doctor) {
        NSLog(@"BubbleViewController startBooking doctorinfo invalid");
        return;
    }
    
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    else {
        [self showBookingPage];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // TextField Notification
    if (_chatUserID != [CureMeUtils defaultCureMeUtil].userID) {
        /*
        // 如果当前是科室咨询列表页，监听键盘输入事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        // 键盘高度变化通知，ios5.0新增的
        //#ifdef __IPHONE_5_0
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 5.0) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
        }
        //#endif*/
    }

    [super viewWillAppear:animated];

    // 每次显示聊天时，刷新预约单的内容
    NSLog(@"BubbleViewController's nav controller: %@", [self navigationController]);
    
    //jongs add
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    frame.size.height = SCREEN_HEIGHT;
    frame.size.width = SCREEN_WIDTH;
    self.view.frame = frame;
    bubbleTable.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-40);
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    if (_chatUserID != [CureMeUtils defaultCureMeUtil].userID) {
        /*
        // TextField Notification
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 5.0) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
        }*/
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //jongs add
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES; 
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    [self moveBubbleView:height];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [self moveBubbleView:0.0];
}

- (void)moveBubbleView:(CGFloat)height
{
    CGRect frame = self.view.frame;
    if (height>0){
        frame.origin.y = 64 - height;
        self.view.frame = frame;
        //bubbleTable.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-45-height);
    }else{
        frame.origin.y = 64;
        self.view.frame = frame;
    }
}
/*
- (void)keyboardWillShow:(NSNotification *)notification {
 
     //Reduce the size of the text view so that it's not obscured by the keyboard.
     //Animate the resize so that it's in sync with the appearance of the keyboard.
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
 
    // Restore the size of the text view (fill self's view).
    // Animate the resize so that it's in sync with the disappearance of the keyboard.
 
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

- (void)moveInputBarWithKeyboardHeight:(float)height withDuration:(NSTimeInterval)duration
{
    // 如果是键盘还原
    if (height < 0.0001 && height > -0.0001) {
        // 1. 还原键盘
//        float originY = [[UIScreen mainScreen] applicationFrame].size.height;
//        _sendAreaView.frame = CGRectMake(0, originY - 44 - 44, 320, 44);
//        [_sendAreaView setHidden:YES];
        
        // 2. 隐藏咨询子分类View
        [subTypeView setHidden:YES];
        
        // 3.
        [_startQueryView setHidden:NO];
        
        // 4. 替换显示Nav的元素
        self.navigationItem.rightBarButtonItem = rightBarItem;
        self.navigationItem.title = navTitle;
    }
    // 如果是键盘出现
    else if (height > 0.0001) {        
        // 1. 显示子分类View，保证从0高度开始覆盖
        [self initSubTypeView];
        
        // 替换显示Nav的元素
        self.navigationItem.title = @"咨询";
        [self initQueryRightBarItem];
        self.navigationItem.rightBarButtonItem = confirmRightBarItem;
        
//        // 1. 显示键盘
//        float screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
//        float sendAreaHeight = screenHeight - height - 44 - subTypeView.frame.size.height;
//        _sendAreaView.hidden = NO;
//        _sendAreaView.frame = CGRectMake(0, subTypeView.frame.size.height, 320, sendAreaHeight);
//        _sendQueryTextField.frame = CGRectMake(5, 5, 310, _sendAreaView.frame.size.height - 44);
//        NSLog(@"sendAreaView: %@ querySubTypeView: %@", _sendAreaView, subTypeView);
    }
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
}*/

//- (void)initSubTypeView
//{
//    if (!subTypeView || subTypeView.officeType != _officeType) {
//        CGRect frame;
//        [subTypeView removeFromSuperview];
//        
//        subTypeView = [[CMQAOfficeSubTypeView alloc] initWithFrame:CGRectZero];
//        [subTypeView setOfficeType:_officeType];
//        [subTypeView clearAllSubTypeBtns];
//        [subTypeView initSubTypeButtons];
//        [subTypeView switchViewTypeToQuery];
//        [subTypeView updateBackgroundImage:[UIImage imageNamed:@"layout_bg.png"]];
//        [subTypeView setHidden:NO];
//        frame = subTypeView.frame;
//        frame.origin.y = 0;
//        subTypeView.frame = frame;
//        [self.view addSubview:subTypeView];
//    }
//}

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
//    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
//    
//    CGFloat keyboardTop = keyboardRect.origin.y;
//    CGRect newTextViewFrame = self.view.bounds;
//    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
//    
//    // Get the duration of the animation.
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    
//    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:animationDuration];
//
//    NSLog(@"keyboardWillShow viewframe height: %.2f", self.view.frame.size.height);
////    CGRect newFrame = CGRectMake(0, keyboardTop - 460 - 44, self.view.frame.size.width, self.view.frame.size.height);
////    self.view.frame = newFrame;
//    self.view.frame = newTextViewFrame;
//    
//    [UIView commitAnimations];
//}
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
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:animationDuration];
//    
//    self.view.frame = self.view.bounds;
//    
//    [UIView commitAnimations];
//}

- (void)didReceiveMemoryWarning
{
    NSLog(@"BubbleViewController didReceiveMemoryWarning");

    [super didReceiveMemoryWarning];
}

- (void)ntfUpdateUnreadMsgCount:(NSNotification *)note
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

- (void)ntfShowFullImage:(NSNotification *)note
{
    NSString *imageKey = [note.userInfo objectForKey:@"imageKey"];
    
    if (!imageKey)
        return;
    
    FullPictureViewController *fullPicVC = [[FullPictureViewController alloc] initWithNibName:@"FullPictureViewController" bundle:nil];
    
    [fullPicVC setImageKey:imageKey];
    
    [self.navigationController pushViewController:fullPicVC animated:YES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    UITabBarItem *tBI = [self tabBarItem];
//    [tBI setTitle:@"我的聊天"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *setTouches = [event allTouches];
    UITouch *touch = [setTouches anyObject];
    
    if ([touch.view isEqual:sendQuestionImage]) {
        NSLog(@"sendQuestionImage touched");
    }

    switch ([setTouches count]) {
        case 1:
            if (![touch isKindOfClass:[UITextField class]]) {
                [_inputField resignFirstResponder];
                [_inputField.superview resignFirstResponder];
            }
            break;
            
        default:
            break;
    }
    
    [super touchesBegan:touches withEvent:event];
    
    [self.view becomeFirstResponder];
}

- (void)closeKeyboard {
    [self.view endEditing:YES];
}

#pragma mark CMMarkDoctorViewControllerDelegate
- (void)pointMarked:(NSInteger)point withComment:(NSString *)comment
{
    chatMarkPoint = point;
    chatMarkComment = comment;
}

#pragma mark data operations
- (void)loadMoreHistoryMessage
{
    loadingView.hidden = NO;
//    [activityIndicator startAnimating];
    [self performSelectorInBackground:@selector(threadLoadMoreHistoryMessage) withObject:nil];
}

// 无更多消息：{"result":true,"msg":[],"isLastPage":true}
// 有更多消息：{"result":true,"msg":[{"from":"3","to":"1000001","data":"{\"text\":\"ttttttttttttttttttttttttttttrrrrrrrrrrrrrrrrrr\",\"image\":\"\"}","chat_id":"131","time":"1347431397"},{"from":"3","to":"1000001","data":"{\"text\":\"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh\",\"image\":\"\"}","chat_id":"131","time":"1347431410"},{"from":"3","to":"1000001","data":"{\"text\":\"gfffffffffffffffffffffffffffffff\",\"image\":\"\"}","chat_id":"131","time":"1347431651"},{"from":"3","to":"1000001","data":"{\"text\":\"111\",\"image\":\"\"}","chat_id":"131","time":"1347431764"},{"from":"3","to":"1000001","data":"{\"text\":\"222\",\"image\":\"\"}","chat_id":"131","time":"1347431767"},{"from":"3","to":"1000001","data":"{\"text\":\"333\",\"image\":\"\"}","chat_id":"131","time":"1347431769"},{"from":"3","to":"1000001","data":"{\"text\":\"444\",\"image\":\"\"}","chat_id":"131","time":"1347431771"},{"from":"3","to":"1000001","data":"{\"text\":\"222\",\"image\":\"\"}","chat_id":"131","time":"1347431861"},{"from":"3","to":"1000001","data":"{\"text\":\"333\",\"image\":\"\"}","chat_id":"131","time":"1347431864"},{"from":"3","to":"1000001","data":"{\"text\":\"444\",\"image\":\"\"}","chat_id":"131","time":"1347431866"},{"from":"1000001","to":"3","data":"jkkkd","chat_id":"131","time":"1347432141"},{"from":"1000001","to":"3","data":"\u83b7\u6559\u826f\u591a","chat_id":"131","time":"1347432147"},{"from":"3","to":"1000001","data":"{\"text\":\"dddddddddddddddddddddd\",\"image\":\"\"}","chat_id":"131","time":"1347432150"},{"from":"1000001","to":"3","data":"\u56f0\u82e6\u52b3\u987f","chat_id":"131","time":"1347432151"},{"from":"3","to":"1000001","data":"{\"text\":\"wwwwwwwwwwwwwwwwwwwwwwwww\",\"image\":\"\"}","chat_id":"131","time":"1347432154"},{"from":"1000001","to":"3","data":"k\u2006k\u2006l","chat_id":"131","time":"1347432158"},{"from":"3","to":"1000001","data":"{\"text\":\"eeeeeeeeeeeeeeeeeeeeeeeeee\",\"image\":\"\"}","chat_id":"131","time":"1347432162"},{"from":"1000001","to":"3","data":"\u5171\u548c\u519b","chat_id":"131","time":"1347432163"},{"from":"1000001","to":"3","data":"hjkk","chat_id":"131","time":"1347432169"},{"from":"1000001","to":"3","data":"\u80e1\u54af","chat_id":"131","time":"1347432173"}],"isLastPage":false}
- (void)threadLoadMoreHistoryMessage
{
    @autoreleasepool {
        if (bubbleData.count < 20) {
            // 给bubbletable设置islastpage
            [bubbleTable setHasLoadHistoryComplete:true];
            // bubbletable reloaddata
            [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
            return;
        }
        
        // 获得最早消息时间
        NSDate *earlyTime = nil;
//        NSInteger index = 0;
//        for (NSBubbleData *data in bubbleData) {
//            NSDate *msgTime = data.date;
//            NSLog(@"HisMsgTime  : %.2f index: %d", msgTime.timeIntervalSince1970, index++);
//        }

        if ([[_sourceType lowercaseString] isEqualToString:@"reply"]) {
            earlyTime = ((NSBubbleData *)[bubbleData objectAtIndex:2]).date;
        }
        else
            earlyTime = ((NSBubbleData *)[bubbleData objectAtIndex:0]).date;

        NSLog(@"earlyTime : %@", earlyTime);
        
        // 发送请求
        NSInteger unixTime = earlyTime.timeIntervalSince1970;
        NSString *post = [[NSString alloc] initWithFormat:@"action=gethistorymessage&chatid=%ld&totime=%ld", (long)_chatID, (long)unixTime];
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"%@  resp: %@", post, strResp);
        
        // 添加消息并显示
        NSDictionary *jsonData = parseJsonResponse(response);
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSLog(@"action=gethistorymessage result invalid");
            [self performSelectorOnMainThread:@selector(reloadData:) withObject:[[NSNumber alloc] initWithInt:SCROLLNONE] waitUntilDone:NO];
            return;
        }
        
        // 获得医生信息
        NSArray *doctorInfos = [jsonData objectForKey:@"doctors"];
        [self addDoctorsInfo:doctorInfos];
        
        // 解析每一条消息
        NSArray *msgArray = [jsonData objectForKey:@"msg"];
        [self addHistoryMessageArray:msgArray];
        
        NSNumber *isLastPage = [jsonData objectForKey:@"isLastPage"];
        if (isLastPage && isLastPage.integerValue == 1) {
            NSLog(@"action=gethistorymessage isLastPage is true");
            // 给bubbletable设置islastpage
            [bubbleTable setHasLoadHistoryComplete:true];
        }
        else
            [bubbleTable setHasLoadHistoryComplete:false];
        
        NSLog(@"isLastPage: %ld", (long)isLastPage.integerValue);
        
        [self performSelectorOnMainThread:@selector(reloadData:) withObject:[[NSNumber alloc] initWithInt:SCROLLNONE] waitUntilDone:NO];
    }
}

- (void)addHistoryMessageArray:(NSArray *)msgArray
{
    if (!msgArray || msgArray.count <= 0)
        return;
    
    for (NSDictionary *message in msgArray) {
        NSLog(@"historyMessage: %@", message);
        
        if (![self addSingleHisMessage:message]) {
            NSLog(@"addHistoryMessageArray addSingleHisMessage failed: %@", message);
            continue;
        }
    }
    
    [bubbleData sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *firstDate = ((NSBubbleData *)obj1).date;
        NSDate *secondDate = ((NSBubbleData *)obj2).date;
        
        return [firstDate compare:secondDate];
    }];
}

// {"result":true,"msg":[{"from":367,"to":"","data":"{\"text\":\"\",\"image\":\"\",\"type\":\"book\",\"data\":\"432\"}","time":1352089227,"chat_id":11912}],"doctors":[{"did":367,"dname":"ggggg","dpic":""}]}
- (bool)addSingleHisMessage:(NSDictionary *)messageOriginal
{
    @autoreleasepool {
        NSLog(@"addSingleHisMessage jsonData: %@", messageOriginal);
        
        if (!messageOriginal || messageOriginal.count <= 0) {
            NSLog(@"addSingleHisMessage messageOriginal invalid");
            return false;
        }
        
        NSNumber *chat_id = [messageOriginal objectForKey:@"chat_id"];
        if (!chat_id || chat_id.integerValue != _chatID) {
            NSLog(@"addSingleHisMessage chatID not match: %ld, %ld", (long)chat_id.integerValue, (long)_chatID);
            return false;
        }
        NSDate *msgTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[messageOriginal objectForKey:@"time"] integerValue]];
        NSNumber *fromID = [[NSNumber alloc] initWithInteger:[[messageOriginal objectForKey:@"from"] integerValue]];
        NSString *msgType = nil;
        
//        NSLog(@"addSingleHisMessage messageOriginal: %@", messageOriginal);
        
        NSDictionary *messageInternal = parseJsonString([messageOriginal objectForKey:@"data"]);
        
        NSString *text = nil;
        NSInteger talkerID = (fromID.integerValue == _chatUserID) ? 0 : fromID.integerValue;
        NSInteger bubbleType = (fromID.integerValue == _chatUserID) ? BubbleTypeMine : BubbleTypeSomeoneElse;
//        NSInteger bubbleType = (fromID.integerValue == [CureMeUtils defaultCureMeUtil].userID) ? BubbleTypeMine : BubbleTypeSomeoneElse;
        
        // 0. 如果消息不是按照Json格式组装，直接显示Data内容
        if (!messageInternal || messageInternal.count < 2) {
            text = [messageOriginal objectForKey:@"data"];
            UIImage *headImage = (bubbleType == BubbleTypeMine) ? nil : [[CMImageUtils defaultImageUtil] doctorDefaultHeadSImage];
            NSBubbleData *chatData = [NSBubbleData dataWithText:text
                                                        andDate:msgTime
                                                        andType:bubbleType
                                                       andImage:headImage
                                                    andTalkerID:talkerID
                                                    andCellType:CellTypeDetail];
            // 医生头像图片ImageKey
            if (bubbleType == BubbleTypeSomeoneElse) {
                NSNumber *TID = [[NSNumber alloc] initWithInteger:talkerID];
                NSString *headImageKey = [[self doctorIDImageKeys] objectForKey:TID];
                if (headImageKey) {
                    chatData.headImageKey = headImageKey;
                }
            }
            
            [bubbleData addObject:chatData];
            NSLog(@"messageInternal: %@ text: %@ time: %@", messageInternal, text, msgTime);
            return true;
        }

        // 1. 聊天消息有图片的时候
        NSString *imageKey = [messageInternal objectForKey:@"image"];
        if (imageKey && imageKey.length > 0) {
            NSBubbleData *newChatData = nil;
            // 如果是别人对话的图片，则不显示
            if (_chatUserID != [CureMeUtils defaultCureMeUtil].userID) {
                newChatData = [NSBubbleData dataWithText:@"[由于隐私问题，此图片不显示]"
                                                 andDate:msgTime
                                                 andType:bubbleType
                                                andImage:(bubbleType == BubbleTypeMine) ? nil : [CMImageUtils defaultImageUtil].doctorDefaultHeadSImage
                                             andTalkerID:talkerID
                                             andCellType:CellTypeDetail];
            }
            else {
                newChatData = [NSBubbleData dataWithMsgImage:[CMImageUtils defaultImageUtil].chatLoadingImage
                                                 andImageKey:imageKey
                                                     andDate:msgTime
                                                     andType:bubbleType
                                                    andImage:(bubbleType == BubbleTypeMine) ? nil : [CMImageUtils defaultImageUtil].doctorDefaultHeadSImage
                                                 andTalkerID:talkerID
                                                 andCellType:CellTypeDetail];
            }
            
            // 医生头像图片ImageKey
            if (bubbleType == BubbleTypeSomeoneElse) {
                NSNumber *TID = [[NSNumber alloc] initWithInteger:talkerID];
                NSString *headImageKey = [[self doctorIDImageKeys] objectForKey:TID];
                if (headImageKey) {
                    newChatData.headImageKey = headImageKey;
                }
            }
            [bubbleData addObject:newChatData];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:imageKey, @"imageKey", msgTime, @"msgTime", nil];
            [self performSelectorInBackground:@selector(threadGetImage:) withObject:userInfo];
            NSLog(@"messageInternal with Image %@ time: %@", messageInternal, msgTime);
        }

        // 消息类型
        msgType = [messageInternal objectForKey:@"type"];
        // 2. 聊天消息
        if (!msgType || [[msgType lowercaseString] isEqualToString:@""] || [[msgType lowercaseString] isEqualToString:@"text"]) {

            text = [messageInternal objectForKey:@"text"];
            // 如果只是图片没有问题，则不添加该条消息
            if (!text || text.length <= 0) {
                NSLog(@"initChatIDAndTalkData text empty");
                return true;
            }
            
            UIImage *headImage = (bubbleType == BubbleTypeMine) ? nil : [[CMImageUtils defaultImageUtil] doctorDefaultHeadSImage];
            NSBubbleData *chatData = [NSBubbleData dataWithText:text
                                                        andDate:msgTime
                                                        andType:bubbleType
                                                       andImage:headImage
                                                    andTalkerID:talkerID
                                                    andCellType:CellTypeDetail];
            // 医生头像图片ImageKey
            if (bubbleType == BubbleTypeSomeoneElse) {
                NSNumber *TID = [[NSNumber alloc] initWithInteger:talkerID];
                NSString *headImageKey = [[self doctorIDImageKeys] objectForKey:TID];
                if (headImageKey) {
                    chatData.headImageKey = headImageKey;
                }
            }
            
            [bubbleData addObject:chatData];
            NSLog(@"messageInternal: %@ text: %@ time: %@", messageInternal, text, msgTime);
            return true;
        }
        // 3. 预约
        if ([[msgType lowercaseString] isEqualToString:@"book"]) {
            NSString *bookID = [messageInternal objectForKey:@"data"];
            if (!bookID || bookID.length <= 0)
                return true;

            NSString *bookAction = [messageInternal objectForKey:@"action"];
            NSLog(@"book msgInternal: %@", messageInternal);

            NSBubbleType userType = (fromID.integerValue == _chatUserID) ? BubbleTypeSomeoneElse : BubbleTypeMine;
            
            // 获得预约信息，并存入DataSource
            if (chatBookID <= 0)
                chatBookID = bookID.integerValue;

            // 只在new预约时请求获取信息
            if ([[bookAction lowercaseString] isEqualToString:@"new"]) {
                [self getChatBookInfo];
            }
            
            // 添加BubbleData聊天数据
            // 如果是新的预约单消息
            if ([[bookAction lowercaseString] isEqualToString:@"new"]) {
                NSBubbleData *chatData = [NSBubbleData dataWithBookInfo:chatBookID andType:userType andDate:msgTime andCellType:CellTypeBookInfoNew andTalkerID:_chatUserID];
                [bubbleData addObject:chatData];
            }
            // 如果是需要更新的预约单消息
            else {
                NSBubbleData *chatData = [NSBubbleData dataWithBookInfo:chatBookID andType:userType andDate:msgTime andCellType:CellTypeBookInfoUpd andTalkerID:_chatUserID];
                [bubbleData addObject:chatData];
            }
            
            return true;
        }
        // 4. 电话
        else if ([[msgType lowercaseString] isEqualToString:@"tel"]) {
            NSLog(@"teltype msgInternal: %@", messageInternal);
            NSString *telephone = [messageInternal objectForKey:@"data"];
            NSString *text = [messageInternal objectForKey:@"text"];
            NSLog(@"telephone: %@", telephone);
            NSBubbleData *chatData = [NSBubbleData dataWithTelephone:telephone andDate:msgTime andType:BubbleTypeSomeoneElse andTalkerID:_chatUserID andCellType:CellTypeTelInfo andText:text];
            [bubbleData addObject:chatData];
        }
        // 5. 地图
        // {\"text\":\"\\u4e5f\\u5f88\\u597d222\",\"image\":\"\",\"type\":\"map\",\"data\":{\"img\":\"\",\"jingwei\":\"116.395986,39.930152\"},\"action\":\"\"}
        else if ([[msgType lowercaseString] isEqualToString:@"map"]) {
            NSString *strMapData = [messageInternal objectForKey:@"data"];
            if (![strMapData isKindOfClass:[NSString class]]) {
                NSLog(@"Chatdata map messageInternal: %@", messageInternal);
                return true;
            }
            
            NSDictionary *mapData = parseJsonString(strMapData);
            if (!mapData || mapData.count <= 0)
                return true;
            
            NSLog(@"mapData: %@", mapData);
            NSString *jingwei = [mapData objectForKey:@"jingwei"];
            NSArray *subStrings = [jingwei componentsSeparatedByString:@","];
            NSString *longitude = [subStrings objectAtIndex:0];
            NSString *latitude = [subStrings objectAtIndex:1];
            _hospitalLongitude = [longitude floatValue];
            _hospitalLatitude = [latitude floatValue];
            NSLog(@"%.2f %.2f", _hospitalLatitude, _hospitalLongitude);
            
            NSString *text = [messageInternal objectForKey:@"text"];
            NSBubbleData *chatData = [NSBubbleData dataWithMapLatitude:_hospitalLatitude andLongitude:_hospitalLongitude andDate:msgTime andType:BubbleTypeSomeoneElse andTalkerID:_chatUserID andCellType:CellTypeMapInfo andText:text];
            [bubbleData addObject:chatData];
            
            return true;
        }

//        text = [messageInternal objectForKey:@"text"];
//        
//        // 如果只是图片没有问题，则不添加该条消息
//        if (!text || text.length <= 0) {
//            NSLog(@"initChatIDAndTalkData text empty");
//            return true;
//        }
//
//        UIImage *headImage = (bubbleType == BubbleTypeMine) ? nil : [[CureMeUtils defaultCureMeUtil] doctorDefaultHeadSImage];
//        NSBubbleData *chatData = [NSBubbleData dataWithText:text
//                                                    andDate:msgTime
//                                                    andType:bubbleType
//                                                   andImage:headImage
//                                                andTalkerID:talkerID
//                                                andCellType:CellTypeDetail];
//        // 医生头像图片ImageKey
//        if (bubbleType == BubbleTypeSomeoneElse) {
//            NSNumber *TID = [[NSNumber alloc] initWithInt:talkerID];
//            NSString *headImageKey = [[self doctorIDImageKeys] objectForKey:TID];
//            if (headImageKey) {
//                chatData.headImageKey = headImageKey;
//            }
//        }
//
//        [bubbleData addObject:chatData];
//        NSLog(@"messageInternal: %@ text: %@ time: %@", messageInternal, text, msgTime);
        
        return true;
    }
}

- (bool)addTalkingHisMessage:(NSDictionary *)messageOriginal
{
    @autoreleasepool {
        NSLog(@"addSingleHisMessage jsonData: %@", messageOriginal);
        
        if (!messageOriginal || messageOriginal.count <= 0) {
            NSLog(@"addSingleHisMessage messageOriginal invalid");
            return false;
        }
        
        NSNumber *chat_id = [messageOriginal objectForKey:@"chat_id"];
        if (!chat_id || chat_id.integerValue != _chatID) {
            NSLog(@"addSingleHisMessage chatID not match: %ld, %ld", (long)chat_id.integerValue, (long)_chatID);
            return false;
        }
        NSDate *msgTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[messageOriginal objectForKey:@"time"] integerValue]];
        NSNumber *fromID = [[NSNumber alloc] initWithInteger:[[messageOriginal objectForKey:@"from"] integerValue]];
        
        NSDictionary *messageInternal = parseJsonString([messageOriginal objectForKey:@"msg"]);
        maxId = [[messageOriginal objectForKey:@"msgid"] integerValue];
        
        NSString *text = nil;
        NSInteger talkerID = (fromID.integerValue == _chatUserID) ? 0 : fromID.integerValue;
        NSInteger bubbleType = (fromID.integerValue == _chatUserID) ? BubbleTypeMine : BubbleTypeSomeoneElse;
        if (bubbleType == BubbleTypeMine) {
            return true;
        }
        
        // 0. 如果消息不是按照Json格式组装，直接显示Data内容
        if (!messageInternal || messageInternal.count < 2) {
            text = [messageOriginal objectForKey:@"msg"];
            UIImage *headImage = (bubbleType == BubbleTypeMine) ? nil : [[CMImageUtils defaultImageUtil] doctorDefaultHeadSImage];
            NSBubbleData *chatData = [NSBubbleData dataWithText:text
                                                        andDate:msgTime
                                                        andType:bubbleType
                                                       andImage:headImage
                                                    andTalkerID:talkerID
                                                    andCellType:CellTypeDetail];
            // 医生头像图片ImageKey
            if (bubbleType == BubbleTypeSomeoneElse) {
                NSNumber *TID = [[NSNumber alloc] initWithInteger:talkerID];
                NSString *headImageKey = [[self doctorIDImageKeys] objectForKey:TID];
                if (headImageKey) {
                    chatData.headImageKey = headImageKey;
                }
            }
            
            [bubbleData addObject:chatData];
            NSLog(@"messageInternal: %@ text: %@ time: %@", messageInternal, text, msgTime);
            return true;
        }
        return true;
    }
}



- (void)setBookInfoUnit:(BookInfoUnit *)bookInfoUnit
{
    _bookInfoUnit = bookInfoUnit;
    NSLog(@"BubbleVC setBookInfoUnit: %@", _bookInfoUnit);
}

- (void)sendBookActionResponse:(NSString *)action andBookID:(NSInteger)bookID
{
    // action=chat_post2&hospitalid=%d&fromid=%d&toid=%d&chatid=%d&msg=&img=%@
    chatBookID = bookID;
    _bookInfoUnit.bookID = bookID;

    // 只在自己的对话中添加新增预约的记录
    if (_chatUserID == [CureMeUtils defaultCureMeUtil].userID) {
        NSString *post = [[NSString alloc] initWithFormat:@"action=chat_post2&fromid=%ld&msg=&img=&chatid=%ld&type=book&data=%ld&act=%@", (long)[CureMeUtils defaultCureMeUtil].userID, (long)_chatID, (long)_bookInfoUnit.bookID, action];
        
        NSData *response = sendRequest(@"msg.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"chat_post2 bookAction: %@, resp: %@", post, strResp);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        if (!jsonData || jsonData.count <= 0)
            return;
        
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSString *error = [jsonData objectForKey:@"msg"];
            NSLog(@"chat_post2 bookAction result invalid: %@", error);
            return;
        }
        
        NSString *strTime = [jsonData objectForKey:@"msg"];
        NSDate *msgTime = [[NSDate alloc] initWithTimeIntervalSince1970:strTime.integerValue];
        if ([[action lowercaseString] isEqualToString:@"new"]) {
            NSBubbleData *chatData = [NSBubbleData dataWithBookInfo:_bookInfoUnit.bookID andType:BubbleTypeMine andDate:msgTime andCellType:CellTypeBookInfoNew andTalkerID:_chatUserID];
            [bubbleData addObject:chatData];
            [self performSelectorOnMainThread:@selector(reloadData:) withObject:[[NSNumber alloc] initWithInt:SCROLLTOEND] waitUntilDone:NO];
        }
    }
}

// 考虑不使用此函数
- (void)threadGetChatBookInfo
{
    if (chatBookID <= 0) {
        return;
    }
    
    [self getChatBookInfo];
    
    [self performSelectorOnMainThread:@selector(reloadData:) withObject:[[NSNumber alloc] initWithInt:SCROLLNONE] waitUntilDone:NO];
}

// {"result":true,"msg":[{"id":404,"userid":1000001,"hospitalid":169,"officeid":117,"bday":1352528816,"timerange":"","dateadd":1351837505,"username":"22222","usertel":"22222","memo":"22222","state":"1","oname":"\u79d1\u5ba4\u4e00","hname":"\u6d4b\u8bd5\u533b\u9662\u4e00","bookingSucc":"3","bookingSummary":"","doctormemo":"","age":22}]}
- (void)getChatBookInfo
{
    @autoreleasepool {
        if (chatBookID <= 0)
            return;
        
        if (!_bookInfoUnit) {
            _bookInfoUnit = [[BookInfoUnit alloc] init];
        }
        _bookInfoUnit.bookID = chatBookID;
        
        NSString *post = [[NSString alloc] initWithFormat:@"action=bookinginfo&bookingid=%ld", (long)chatBookID];
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"BubbleViewController getbookinfo: %@", strResp);
        
        NSDictionary *dataJson = parseJsonResponse(response);
        NSNumber *result = [dataJson objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSString *error = [dataJson objectForKey:@"msg"];
            NSLog(@"BubbleViewController action=bookinginfo result invalid %@", error);
            return;
        }
        
        NSArray *bookInfoArray = [dataJson objectForKey:@"msg"];
        if (!bookInfoArray || bookInfoArray.count <= 0) {
            NSLog(@"action=bookinginfo bookinfoArray invalid: %@", strResp);
            return;
        }
        
        NSDictionary *bookInfo = [bookInfoArray objectAtIndex:0];
        if (!bookInfo || bookInfo.count <= 0) {
            NSLog(@"action=bookinginfo bookInfo invalid: %@", strResp);
            return;
        }
        
        NSNumber *bookSucceed = [bookInfo objectForKey:@"bookingSucc"];
        if (bookSucceed)
            _bookInfoUnit.bookState = bookSucceed.integerValue;
        
        NSString *bookNo = [bookInfo objectForKey:@"no"];
        if (bookNo)
            _bookInfoUnit.bookNumber = bookNo;

        NSNumber *hosID = [bookInfo objectForKey:@"hospitalid"];
        if (hosID)
            _bookInfoUnit.hospitalID = hosID.integerValue;
        
        NSNumber *offID = [bookInfo objectForKey:@"officeid"];
        if (offID)
            _bookInfoUnit.officeID = offID.integerValue;
        
        NSNumber *age = [bookInfo objectForKey:@"age"];
        if (age)
            _bookInfoUnit.age = age.integerValue;
        
        NSNumber *bookDate = [bookInfo objectForKey:@"bday"];
        if (bookDate)
            _bookInfoUnit.bookDate = [[NSDate alloc] initWithTimeIntervalSince1970:bookDate.integerValue];
        
        NSString *hosName = [bookInfo objectForKey:@"hname"];
        _bookInfoUnit.hospitalName = hosName;
        
        NSString *offName = [bookInfo objectForKey:@"oname"];
        _bookInfoUnit.officeName = offName;
        
        NSString *userName = [bookInfo objectForKey:@"username"];
        _bookInfoUnit.userName = userName;
        
        NSString *telephone = [bookInfo objectForKey:@"usertel"];
        _bookInfoUnit.telephone = telephone;
        
        NSString *bookSummary = [bookInfo objectForKey:@"bookingSummary"];
        _bookInfoUnit.doctorReply = bookSummary;
        
        NSString *memo = [bookInfo objectForKey:@"memo"];
        _bookInfoUnit.memory = memo;
        
        NSLog(@"ChatBookInfo: %@", _bookInfoUnit);
        
        return;
    }
}

- (void)initChatIDAndTalkData
{
    @autoreleasepool {
        NSLog(@"initChatIDAndTalkData begin: %@", [NSDate date]);

        // 1. 获得Chat ID
        // initchatlist: action=initchatlist&sourcetype=xxx&sourceid=xx&userid=xxx&doctorid=xxx
        NSString *post = [NSString stringWithFormat:@"action=initchatlist&sourcetype=%@&sourceid=%ld&userid=%ld&doctorid=%ld&tag=%d&chatsource=%@", _sourceType, (long)_sourceID, (long)[CureMeUtils defaultCureMeUtil].userID, (long)_talkerID, (_chatUserID == [CureMeUtils defaultCureMeUtil].userID) ? 0 : 1, _chatOpenType];
        
        NSData *chatIDResp = sendRequest(@"m.php", post);
        
        NSString *str = [[NSString alloc] initWithData:chatIDResp encoding:NSUTF8StringEncoding];
        NSLog(@"%@", str);
        
        NSDictionary *chatIDRespJson = parseJsonResponse(chatIDResp);
        NSNumber *chatIDResult = [chatIDRespJson objectForKey:@"result"];
        if (chatIDResult.integerValue != 1) {
            NSString *strResp = [[NSString alloc] initWithData:chatIDResp encoding:NSUTF8StringEncoding];
            NSLog(@"Get chat ID failed %@", strResp);
            return;
        }
        
        NSDictionary *chatIDMsgJson = [chatIDRespJson objectForKey:@"msg"];
        
        // 0. 医生信息
        NSDictionary *doctorData = [chatIDMsgJson objectForKey:@"doctorinfo"];
        if (doctorData && doctorData.count > 0) {
            _doctor = [[Doctor alloc] init];
            [[CureMeUtils defaultCureMeUtil] parseDoctorInfoFromJson:doctorData andDoctor:_doctor];
        }

        // 0-1. 如果是自己的对话，则初始化评价数据
        if (_chatUserID == [CureMeUtils defaultCureMeUtil].userID) {
            NSDictionary *markData = [chatIDMsgJson objectForKey:@"chatcomment"];
            [self initMarkData:markData];
        }

        //        {"result":true,"msg":{"hospital":{"id":"174","name":"\u5317\u4eac466\u5987\u79d1\u533b\u9662","address":"\u5317\u4eac\u5e02\u6d77\u6dc0\u533a\u5317\u6d3c\u8def\u5317\u53e3(\u9999\u683c\u91cc\u62c9\u996d\u5e97\u9644\u8fd1)","content":"\u5317\u4eac466\u533b\u9662\u6210\u7acb\u4e8e1951\u5e74,\u662f\u5317\u4eac\u5e02\u9996\u6279\u533b\u4fdd\u5b9a\u70b9\u4e09\u7ea7\u7532\u7b49\u533b\u9662.","pic":"5086051132763"},"doctor":{"id":"377","name":"\u8f9b\u79cb\u534e","title":"\u5934\u8854\t\u5987\u79d1\u4e13\u5bb6","content":"\u8f9b\u79cb\u534e:\u4ece\u4e8b\u5987\u79d1\u5de5\u4f5c20\u4f59\u5e74,\u64c5\u957f\u5987\u79d1\u5185\u5206\u6ccc,\u5987\u79d1\u80bf\u7624\u7684\u8bca\u6cbb.","pic":"50860576c207c"}}}

        // 1. 咨询消息
        NSArray *qaArray = [chatIDMsgJson objectForKey:@"info"];
        if (qaArray && qaArray.count > 0) {
            NSDictionary *questionData = [qaArray objectAtIndex:0];
            if (questionData)
            {
                // 解析每条记录
                NSString *message = [questionData objectForKey:@"data"];
                NSDate *msgTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[questionData objectForKey:@"time"] integerValue]];
                //            NSNumber *fromID = [[NSNumber alloc] initWithInt:[[questionData objectForKey:@"from"] integerValue]];
//                NSNumber *toID = [[NSNumber alloc] initWithInt:[[questionData objectForKey:@"to"] integerValue]];
                NSNumber *fromID = [[NSNumber alloc] initWithInteger:[[questionData objectForKey:@"from"] integerValue]];
                if (fromID.integerValue != [CureMeUtils defaultCureMeUtil].userID) {
                    NSLog(@"initchatlist query fromID: %ld is not equal to userID: %ld", (long)fromID.integerValue, (long)[CureMeUtils defaultCureMeUtil].userID);
                }
                NSInteger bubbleType = BubbleTypeMine;
                [bubbleData addObject:[NSBubbleData dataWithText:message
                                                         andDate:msgTime
                                                         andType:bubbleType
                                                        andImage:nil
                                                     andTalkerID:0
                                                     andCellType:CellTypeDetail]];
            }
            
            // 2. 回复消息
            NSDictionary *replyData = [qaArray objectAtIndex:1];
            NSLog(@"reply: %@", replyData);
            if (replyData)
            {
                // 解析每条记录
                NSString *message = [replyData objectForKey:@"data"];
                NSDate *msgTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[questionData objectForKey:@"time"] integerValue]];
                //            NSNumber *fromID = [[NSNumber alloc] initWithInt:[[questionData objectForKey:@"from"] integerValue]];
                NSNumber *fromID = [[NSNumber alloc] initWithInteger:[[replyData objectForKey:@"from"] integerValue]];
                NSInteger bubbleType = BubbleTypeSomeoneElse;
                NSInteger talkerID = fromID.integerValue;
                NSBubbleData *newChatData = [NSBubbleData dataWithText:message
                                                               andDate:msgTime
                                                               andType:bubbleType
                                                              andImage:[[CMImageUtils defaultImageUtil]
                                                                        doctorDefaultHeadSImage]
                                                           andTalkerID:talkerID
                                                           andCellType:CellTypeDetail];
//                if (_doctor) {
//                    newChatData.headImageKey = _doctor.imageKey;
//                    [[self imageDownloader] addImageKey:_doctor.imageKey andSizeType:@"70"];
//                    NSLog(@"Reply doctorImage: %@", _doctor.imageKey);
//                }
                [bubbleData addObject:newChatData];
            }
        }
        
        // 3. chatID
        NSNumber *chatID = [chatIDMsgJson objectForKey:@"chatid"];
        if (!chatID || chatID.integerValue <= 0) {
            NSLog(@"Chat ID invalid %@", chatID);
            _chatID = 0;
        }
        else {
            _chatID = chatID.integerValue;
            NSLog(@"set chatID: %ld", (long)_chatID);
            
            // 历史消息
            NSDictionary *tempData = [chatIDMsgJson objectForKey:@"history"];
            if (!tempData || tempData.count <= 0) {
                NSLog(@"initChatIDAndTalkData history empty: %@", tempData);
                return;
            }

            // 1. 获得医生信息
            NSArray *doctors = [tempData objectForKey:@"doctors"];
            [self addDoctorsInfo:doctors];
            
            // 2. 获得历史消息
            NSArray *msgArray = [tempData objectForKey:@"msg"];
            
            for (NSDictionary *msgData in msgArray) {
//                NSLog(@"msgData: %@", msgData);
                if (![self addSingleHisMessage:msgData]) {
                    NSLog(@"initChatIDAndTalkData addSingleHisMessage failed");
                    continue;
                }
            }

            // 如果不是本人聊天消息，可展示的消息数量受限，显示提示
            if (msgArray && msgArray.count > 3 && (_chatUserID != [CureMeUtils defaultCureMeUtil].userID)) {
                [self performSelectorOnMainThread:@selector(showMsgLimitAlert) withObject:nil waitUntilDone:NO];
            }
            
            // 3. IsLastPage
            NSNumber *isLastPage = [tempData objectForKey:@"isLastPage"];
            if (!isLastPage || isLastPage.integerValue != 1)
                [bubbleTable setHasLoadHistoryComplete:false];
            else
                [bubbleTable setHasLoadHistoryComplete:true];
        }

        // 0-1. 发送获取医院、医生简介请求
        [self initChatMetaData];

        // 设置NavTitle
        if (_doctor.name && _doctor.name.length > 0)
            [self.navigationItem setTitle:[NSString stringWithFormat:@"与%@对话", _doctor.name]];
        else
            [self.navigationItem setTitle:@"对话"];
        navTitle = self.navigationItem.title;
        
        if (_doctor && _doctor.isOnline && _chatUserID == [CureMeUtils defaultCureMeUtil].userID) {
            [self performSelectorOnMainThread:@selector(startRemindViewTimer:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:@"医生当前在线，您可以和医生直接进行交流", @"remind", [[NSNumber alloc] initWithInt:1], @"interval", nil] waitUntilDone:NO];
//            [self performSelectorOnMainThread:@selector(showRemindView:) withObject:@"医生当前在线，快来聊聊" waitUntilDone:NO];
        }

//        [NSThread detachNewThreadSelector:@selector(threadGetDoctorHeadImage:) toTarget:self withObject:[_doctor.imageKey substringToIndex:_doctor.imageKey.length]];
        
        NSLog(@"initChatIDAndTalkData end: %@", [NSDate date]);
    }
}

// "doctors":[{"did":"2","dname":"\u533b\u751f\u4e8c","dpic":"504ac2b2e04ac"},{"did":"3","dname":"\u533b\u751f\u4e09","dpic":"504ff4f3bb146"}]},
- (void)addDoctorsInfo:(NSArray *)doctors
{
    if (!doctors || doctors.count <= 0) {
        NSLog(@"addDoctorsInfo doctors data invalid");
        
        // tim.wangj.remind 新版App中，不需要始终开启图片下载器
//        [[self imageDownloader] startDownload];
        return;
    }
    
    NSLog(@"addDoctorsInfo doctors: %@", doctors);
    
    for (NSDictionary *oneDoctor in doctors) {
//        // 1. 为下载器添加下载图片
//        NSString *imageKey = [oneDoctor objectForKey:@"dpic"];
//        if (![doctorImages objectForKey:[[NSString alloc] initWithFormat:@"%@-%@", imageKey, @"70"]]) {
//            [[self imageDownloader] addImageKey:imageKey andSizeType:@"70"];
//            NSLog(@"add Doctor HeadImage Download: %@", imageKey);
//        }

//        // 2. 添加聊天的医生姓名字典
//        NSNumber *doctorID = [oneDoctor objectForKey:@"did"];
//        NSString *doctorName = [oneDoctor objectForKey:@"dname"];
//        if (!doctorID || !doctorName || doctorID.integerValue <= 0) {
//            NSLog(@"addDoctorsInfo doctorinfo invalid %@", oneDoctor);
//            continue;
//        }
//        [[self doctorNames] setObject:doctorName forKey:doctorID];
//        
//        // 添加头像图片imagekey
//        [[self doctorIDImageKeys] setObject:imageKey forKey:doctorID];
    }
    
    // tim.wangj.remind新版App中，不需要始终开启图片下载器
//    [[self imageDownloader] startDownload];
}

- (NSMutableDictionary *)doctorIDImageKeys
{
    if (!doctorIDImageKeys) {
        doctorIDImageKeys = [[NSMutableDictionary alloc] init];
    }
    
    return doctorIDImageKeys;
}

- (NSMutableDictionary *)doctorNames
{
    if (!doctorNames) {
        doctorNames = [[NSMutableDictionary alloc] init];
    }
    
    return doctorNames;
}

- (NSString *)doctorNameWithDoctorID:(NSInteger)doctorID
{
    if (!doctorNames || doctorNames.count <= 0)
        return @"";

    NSArray *keys = doctorNames.allKeys;
    for (NSNumber *key in keys) {
        if (key.integerValue == doctorID) {
            return [doctorNames objectForKey:key];
        }
    }
    
    return [doctorNames objectForKey:[keys objectAtIndex:0]];
}

- (UIImage *)metaDataImageWithImageKey:(NSString *)imageKey
{
    if (!doctorImages || doctorImages.count <= 0)
        return nil;
    
    return [doctorImages objectForKey:[[NSString alloc] initWithFormat:@"%@-%@", imageKey, @"90"]];
}

- (UIImage *)doctorHeadImageWithImageKey:(NSString *)imageKey
{
    if (!doctorImages || doctorImages.count <= 0)
        return nil;
    
    return [doctorImages objectForKey:[[NSString alloc] initWithFormat:@"%@-%@", imageKey, @"70"]];
}

- (ImageDownloadHelper *)imageDownloader
{
    if (!imageDownloader) {
        imageDownloader = [[ImageDownloadHelper alloc] init];
    }
    
    return imageDownloader;
}

#pragma mark ImageDownloadHelperDelegate
- (void)imageDownloadComplete:(NSString *)imageKey andType:(NSString *)type andImage:(UIImage*)image
{
    if (!doctorImages) {
        doctorImages = [[NSMutableDictionary alloc] init];
    }
    
    NSLog(@"ImageDownloadcomplete: %@-%@", imageKey, type);
    [doctorImages setObject:image forKey:[[NSString alloc] initWithFormat:@"%@-%@", imageKey, type]];
    
    // 通知刷新
    [self performSelectorOnMainThread:@selector(reloadData:) withObject:[[NSNumber alloc] initWithInt:SCROLLNONE] waitUntilDone:NO];
    
//    // 更新缩略信息View的头像
//    [bubbleTable updateHeadBtnViewHeadImage];
}

- (void)allImageComplete
{
    [self performSelectorOnMainThread:@selector(reloadData:) withObject:[[NSNumber alloc] initWithInt:SCROLLNONE] waitUntilDone:NO];
}

- (void)initTalkData
{
    @autoreleasepool {
        NSLog(@"initTalkData begin: %@", [NSDate date]);

        if (_chatID <= 0) {
            NSLog(@"chatID not set, cannot init talk page");
            return;
        }
        
        NSString *post = [NSString stringWithFormat:@"action=chatinfo&chatid=%ld&userid=%ld&chatsource=%@", (long)_chatID, (long)[CureMeUtils defaultCureMeUtil].userID, _chatOpenType];
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"gethistorymessage: %@", strResp);
        
        NSDictionary *chatIDRespJson = parseJsonResponse(response);
        NSNumber *chatIDResult = [chatIDRespJson objectForKey:@"result"];
        if (chatIDResult.integerValue != 1) {
            NSString *strResp = [chatIDRespJson objectForKey:@"msg"];
            NSLog(@"Get chat ID failed %@", strResp);
            return;
        }

        _sourceType = [chatIDRespJson objectForKey:@"sourcetype"];

        NSDictionary *chatIDMsgJson = [chatIDRespJson objectForKey:@"msg"];

        // 0. 医生信息
        NSDictionary *doctorData = [chatIDMsgJson objectForKey:@"doctorinfo"];
        if (doctorData && doctorData.count > 0) {
            //            NSLog(@"doctorData: %@", doctorData);
            _doctor = [[Doctor alloc] init];
            [[CureMeUtils defaultCureMeUtil] parseDoctorInfoFromJson:doctorData andDoctor:_doctor];
        }

        // 0-1. 发送获取医院、医生简介请求
        [self initChatMetaData];
        
        // 0-2. 如果是自己的对话，则初始化评价数据
        if (_chatUserID == [CureMeUtils defaultCureMeUtil].userID) {
            NSDictionary *markData = [chatIDMsgJson objectForKey:@"chatcomment"];
            [self initMarkData:markData];
        }

        // 1. 咨询消息
        NSArray *qaArray = [chatIDMsgJson objectForKey:@"info"];
        if (qaArray && qaArray.count > 0) {
            NSDictionary *questionData = [qaArray objectAtIndex:0];
            if (questionData)
            {
                // 解析每条记录
                NSString *message = [questionData objectForKey:@"data"];
                NSInteger unixTime = [[questionData objectForKey:@"time"] integerValue];
                NSNumber *fromID = [[NSNumber alloc] initWithInteger:[[questionData objectForKey:@"from"] integerValue]];
                if (fromID.integerValue != [CureMeUtils defaultCureMeUtil].userID) {
                    NSLog(@"chatinfo query fromID: %ld is not equal to userID: %ld", (long)fromID.integerValue, (long)[CureMeUtils defaultCureMeUtil].userID);
                }
                //            NSNumber *toID = [[NSNumber alloc] initWithInt:[[questionData objectForKey:@"to"] integerValue]];
                NSInteger bubbleType = BubbleTypeMine;
                [bubbleData addObject:[NSBubbleData dataWithText:message
                                                         andDate:[NSDate dateWithTimeIntervalSince1970:unixTime]
                                                         andType:bubbleType
                                                        andImage:nil
                                                     andTalkerID:0
                                                     andCellType:CellTypeDetail]];
            }
            
            // 2. 回复消息
            NSDictionary *replyData = [qaArray objectAtIndex:1];
            if (replyData)
            {
                // 解析每条记录
                NSString *message = [replyData objectForKey:@"data"];
                NSInteger unixTime = [[replyData objectForKey:@"time"] integerValue];
                //            NSNumber *fromID = [[NSNumber alloc] initWithInt:[[questionData objectForKey:@"from"] integerValue]];
                NSNumber *fromID = [[NSNumber alloc] initWithInteger:[[replyData objectForKey:@"from"] integerValue]];
                NSInteger bubbleType = BubbleTypeSomeoneElse;
                NSInteger talkerID = fromID.integerValue;
                NSBubbleData *newChatData = [NSBubbleData dataWithText:message
                                                               andDate:[NSDate dateWithTimeIntervalSince1970:unixTime]
                                                               andType:bubbleType
                                                              andImage:[[CMImageUtils defaultImageUtil] doctorDefaultHeadSImage]
                                                           andTalkerID:talkerID
                                                           andCellType:CellTypeDetail];
//                if (_doctor) {
//                    newChatData.headImageKey = _doctor.imageKey;
//                    [[self imageDownloader] addImageKey:_doctor.imageKey andSizeType:@"70"];
//                    NSLog(@"Reply doctorImage: %@", _doctor.imageKey);
//                }
                [bubbleData addObject:newChatData];
            }
        }
        
        // 历史消息
        NSDictionary *tempData = [chatIDMsgJson objectForKey:@"history"];
        if (!tempData || tempData.count <= 0) {
            NSLog(@"initTalkData historydata invalid %@", tempData);
            return;
        }
        
        NSArray *doctorInfos = [tempData objectForKey:@"doctors"];
        [self addDoctorsInfo:doctorInfos];
        
        NSArray *msgArray = [tempData objectForKey:@"msg"];
        for (NSDictionary *msgData in msgArray) {
//            NSLog(@"action=chatinfo msgData: %@", msgData);
            if (![self addSingleHisMessage:msgData]) {
                NSLog(@"initTalkData addSingleHisMessage failed: %@", msgData);
                continue;
            }
        }
        
        // 如果不是本人聊天消息，可展示的消息数量受限，显示提示
        if (msgArray && msgArray.count > 3 && (_chatUserID != [CureMeUtils defaultCureMeUtil].userID)) {
            [self performSelectorOnMainThread:@selector(showMsgLimitAlert) withObject:nil waitUntilDone:NO];
        }

        // IsLastPage
        NSNumber *isLastPage = [tempData objectForKey:@"isLastPage"];
        if (!isLastPage || isLastPage.integerValue != 1)
            [bubbleTable setHasLoadHistoryComplete:false];
        else
            [bubbleTable setHasLoadHistoryComplete:true];
        
        // 医生信息
        if (_doctor) {
            if (_doctor.isOnline && _chatUserID == [CureMeUtils defaultCureMeUtil].userID) {
                //[self performSelectorOnMainThread:@selector(startRemindViewTimer:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:@"医生当前在线，您可以和医生直接进行交流", @"remind", [[NSNumber alloc] initWithInt:1], @"interval", nil] waitUntilDone:NO];
//                [self performSelectorOnMainThread:@selector(showRemindView:) withObject:@"医生当前在线，快来聊聊" waitUntilDone:NO];
            }

            _talkerID = _doctor.doctorID;
            // 设置NavTitle
            if (_doctor.name && _doctor.name.length > 0) {
                [self.navigationItem setTitle:[NSString stringWithFormat:@"与%@对话", _doctor.name]];
            }
            else {
                [self.navigationItem setTitle:@"对话"];
            }
            navTitle = self.navigationItem.title;
            
//            [NSThread detachNewThreadSelector:@selector(threadGetDoctorHeadImage:) toTarget:self withObject:[_doctor.imageKey substringToIndex:_doctor.imageKey.length]];
        }
        else
            self.navigationItem.title = @"对话";
        
        NSLog(@"initTalkData end: %@", [NSDate date]);
    }
}

- (void)initMarkData:(NSDictionary *)data
{
    if (!data || data.count <= 0) {
        return;
    }

    NSNumber *point = [data objectForKey:@"marknum"];
    if (point) {
        chatMarkPoint = point.integerValue;
    }

    chatMarkComment = [data objectForKey:@"summary"];
}

//{"result":true,"msg":{"hospital":{"id":123,"name":"\u4e0a\u6d77\u5b8f\u5eb7\u533b\u9662\u6574\u5f62\u7f8e\u5bb9","address":"\u4e0a\u6d77\u5e02\u666e\u9640\u533a\u5927\u6e21\u6cb3\u8def1933\u53f7","content":"\u4e0a\u6d77\u5e02\u5185\u6700\u4e13\u4e1a\u89c4\u8303\u3001\u6700\u5177\u5f71\u54cd\u529b\u7684\u533b\u5b66\u6574\u5f62\u7f8e\u5bb9\u54c1\u724c\u673a\u6784\u3002","pic":"5077e8bc7ac2a"}}}
- (void)initChatMetaData
{
    // 如果初始化聊天时没有医生信息
    if (!_doctor || _doctor.doctorID <= 0) {
        NSString *post = [[NSString alloc] initWithFormat:@"action=gethospitalinfobychatid&chatid=%ld", (long)_chatID];
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"action=gethospitalinfobychatid resp: %@", strResp);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        if (!jsonData || jsonData.count <= 0) {
            NSLog(@"action=gethospitalinfobychatid resp invalid %@", strResp);
            return;
        }
        
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSString *error = [jsonData objectForKey:@"msg"];
            NSLog(@"action=gethospitalinfobychayid result invalid: %@", error);
            return;
        }
        
        NSDictionary *msgData = [jsonData objectForKey:@"msg"];
        if (!msgData || msgData.count <= 0) {
            NSLog(@"action=gethospitalinfobychatid msg invalid: %@", jsonData);
            return;
        }
        
        NSDictionary *hospitalData = [msgData objectForKey:@"hospital"];
        if (!hospitalData || hospitalData.count <= 0) {
            NSLog(@"action=gethospitalinfobychatid hospital invalid: %@", msgData);
            return;
        }
        
        if (!_metaInfoData)
            _metaInfoData = [[ChatMetaInfoData alloc] init];
        
        _metaInfoData.hasDoctorInfo = false;
        NSNumber *hospID = [hospitalData objectForKey:@"id"];
        if (hospID)
            _metaInfoData.identifier = hospID.integerValue;
        
        NSString *hospName = [hospitalData objectForKey:@"name"];
        _metaInfoData.name = hospName;
        
        NSString *hospIntro = [hospitalData objectForKey:@"content"];
        _metaInfoData.intro = hospIntro;
        
        NSString *hospImageKey = [hospitalData objectForKey:@"pic"];
        _metaInfoData.imageKey = hospImageKey;
        
        [[self imageDownloader] addImageKey:hospImageKey andSizeType:@"90"];
    }
    // 如果有医生信息
    else {
        NSString *post = [[NSString alloc] initWithFormat:@"action=chathdintro&doctorid=%ld", (long)_doctor.doctorID];
        NSData *response = sendRequest(@"m.php", post);
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"action=chathdintro resp: %@", strResp);
        
        NSDictionary *dataResp = parseJsonResponse(response);
        NSNumber *result = [dataResp objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSString *msg = [dataResp objectForKey:@"msg"];
            NSLog(@"action=chathdintro result invalid %@", msg);
        }
        else {
            if (!_metaInfoData)
                _metaInfoData = [[ChatMetaInfoData alloc] init];
            
            _metaInfoData.hasDoctorInfo = true;
            
            NSDictionary *metaDataJson = [dataResp objectForKey:@"msg"];
            NSDictionary *hospitalJson = [metaDataJson objectForKey:@"hospital"];
            NSDictionary *doctorJson = [metaDataJson objectForKey:@"doctor"];
            // 医院ID
            NSNumber *hospitalID = [hospitalJson objectForKey:@"id"];
            if (hospitalID)
                _metaInfoData.identifier = hospitalID.integerValue;
            // 医院名字
            NSString *hospitalName = [hospitalJson objectForKey:@"name"];
            _metaInfoData.name = hospitalName;
//            // 医院简介
//            NSString *hospitalContent = [hospitalJson objectForKey:@"content"];
//            _metaInfoData.hospitalIntro = hospitalContent;
//            // 医院图片
//            NSString *hospitalImageKey = [hospitalJson objectForKey:@"pic"];
//            _metaInfoData.hospitalImageKey = hospitalImageKey;
//            // 添加下载图片
//            [[self imageDownloader] addImageKey:hospitalImageKey andSizeType:@"90"];
            // 医生ID
            NSNumber *doctorID = [doctorJson objectForKey:@"id"];
            if (doctorID)
                _metaInfoData.identifier = doctorID.integerValue;
            // 医生信息
            NSString *doctorName = [doctorJson objectForKey:@"name"];
            NSString *title = [doctorJson objectForKey:@"title"];
            _metaInfoData.info = [[NSString alloc] initWithFormat:@"%@ %@", doctorName, title];
            // 医生简介
            NSString *doctorContent = [doctorJson objectForKey:@"content"];
            _metaInfoData.intro = doctorContent;
            // 医生头像
            NSString *doctorImageKey = [doctorJson objectForKey:@"pic"];
            _metaInfoData.imageKey = doctorImageKey;
            NSLog(@"Metadata doctor Image: %@", doctorImageKey);
            // 添加下载图片
            [[self imageDownloader] addImageKey:doctorImageKey andSizeType:@"90"];
        }
    }
    
    // 开启图片下载器
    [[self imageDownloader] startDownload];
    
    [bubbleTable setMetaDataDoctorHeadImageKey:_metaInfoData.imageKey];
    
    // 计算MetaDataCell的高度
    CGSize textSize = [_metaInfoData.intro sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(292, 100) lineBreakMode:NSLineBreakByTruncatingTail];
    _metaInfoData.metaDataHeight = 10 + 48 + 4 + textSize.height;
}

- (void)threadGetDoctorHeadImage:(NSString *)imageKey
{
    @autoreleasepool {
        if (!imageKey)
            return;
        
        if (!imageKey || imageKey.length <= 0) {
            NSLog(@"BubbleViewController threadGetDoctorHeadImage imagekey invalid %@", _doctor);
            return;
        }
        
        _doctorHeadImage = [[CureMeUtils defaultCureMeUtil] getImageByKey:imageKey andSize:@"70"];
        NSLog(@"threadGetDoctorHeadImage imageKey: %@", imageKey);
        
        [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
    }
}

- (void)loadNextPageHistory
{
    
}

#pragma mark events
- (IBAction)startSelfTalk:(id)sender
{
    BubbleViewController *talkVC = [[BubbleViewController alloc] initWithNibName:@"BubbleViewController" bundle:nil];
    if (!talkVC) {
        NSLog(@"showDialogPage create BubbleViewController failed");
        return;
    }
    
    [talkVC setChatOpenType:@"mylist"];
    [talkVC setChatUserID:[CureMeUtils defaultCureMeUtil].userID];
    [talkVC setTalkerID:_talkerID];
    [talkVC setSourceID:_sourceID];
    [talkVC setSourceType:_sourceType];
    
    [self.navigationController pushViewController:talkVC animated:YES];
}

- (IBAction)startQuery:(id)sender {
    if (_officeType <= 0) {
        NSLog(@"BubbleViewController startQuery office type invalid");
        return;
    }
    
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    else {
        NSInteger count = self.navigationController.viewControllers.count;
        UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:count - 2];
        
        NSLog(@"viewController type: %@", viewController.class);

//        if ([viewController isKindOfClass:[MainTabViewController class]]) {
//            MainTabViewController *mainTabVC = ((MainTabViewController *) viewController);
//            [mainTabVC setSelectedIndex:0];
//            [mainTabVC.customTabBarView selectButtonAtIndex:0];
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        else {
//            RaiseQuestionViewController *raiseQVC = [[RaiseQuestionViewController alloc] initWithNibName:@"RaiseQuestionViewController" bundle:nil];
//            
//            [raiseQVC setOfficeType:_officeType];
//            [viewController.navigationController pushViewController:raiseQVC animated:YES];            
//        }
    }
}

- (IBAction)attachPicture:(id)sender
{
    actionSheet = [[CMActionSheet alloc] init];
    
    // Customize
    [actionSheet addButtonWithTitle:@"拍照" type:CMActionSheetButtonTypeWhite block:^{
        [self takePicture];
    }];
    [actionSheet addButtonWithTitle:@"照片库" type:CMActionSheetButtonTypeWhite block:^{
        [self openPhotoLibrary];
    }];
    [actionSheet addButtonWithTitle:@"个人相册" type:CMActionSheetButtonTypeWhite block:^{
        [self openSavedPhotoLibrary];
    }];
    [actionSheet addSeparator];
    [actionSheet addButtonWithTitle:@"取消" type:CMActionSheetButtonTypeBlue block:^{
        NSLog(@"Dismiss action sheet with \"Close Button\"");
    }];
    
    // Present
    [actionSheet present];
}

- (void)showOfficeListPage
{
    if (!_doctor) {
        NSLog(@"showOfficeListPage doctor data invalid");
        return;
    }
 
    NSInteger hospID = (_doctor.hospitalID <= 0) ? _metaInfoData.identifier : _doctor.hospitalID;
    NSString *hospName = (_doctor.hospitalName) ? _doctor.hospitalName : _metaInfoData.name;
    
    WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    [webVC setStrURL:[NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/hospital/rooms.php?hid=%ld&hname=%@", (long)hospID, hospName]];
    [self.navigationController pushViewController:webVC animated:YES];
    
//    OfficeListInfoTableViewController *officeListTVC = [[OfficeListInfoTableViewController alloc] initWithStyle:UITableViewStylePlain];
//    if (!officeListTVC) {
//        NSLog(@"officeListBtnClick create OfficeListInfoTableViewController failed");
//        return;
//    }
//    
//    [officeListTVC setHospitalID:_doctor.hospitalID];
//    
//    [self.navigationController pushViewController:officeListTVC animated:YES];
}

- (void)showHospitalDetailPage
{
    if (!_doctor) {
        return;
    }
    
    NSInteger hospID = (_doctor.hospitalID <= 0) ? _metaInfoData.identifier : _doctor.hospitalID;

    WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    //[webVC setStrURL:[NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/hospital/hinfo.php?hid=%ld", (long)hospID]];
    [webVC setStrURL:[NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/h5_new/server/app.php?type=doctorinfo&hid=%ld&did=%ld&hname=%@&appid=7",(long)hospID,(long)_doctor.doctorID,_doctor.hospitalName]];
    webVC.subOfficeId = self.officeSubType;
    webVC.childOfficeId = self.officeType;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)showDoctorDetailPage
{
    if (!_doctor) {
        NSLog(@"showDoctorDetailPage doctor data invalid");
        return;
    }
    NSInteger hospID = (_doctor.hospitalID <= 0) ? _metaInfoData.identifier : _doctor.hospitalID;
    WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    //[webVC setStrURL:[NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/hospital/dinfo.php?did=%ld", (long)_doctor.doctorID]];
    [webVC setStrURL:[NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/h5_new/server/app.php?type=doctorinfo&hid=%ld&did=%ld&hname=%@&appid=7",(long)hospID,(long)_doctor.doctorID,_doctor.hospitalName]];
    webVC.subOfficeId = self.officeSubType;
    webVC.childOfficeId = self.officeType;
    [self.navigationController pushViewController:webVC animated:YES];
    
//    DoctorInfoViewController *doctorInfoVC = [[DoctorInfoViewController alloc] initWithNibName:@"DoctorInfoViewController" bundle:nil];
//    if (!doctorInfoVC) {
//        NSLog(@"showDoctorDetailPage create DoctorInfoViewController failed");
//        return;
//    }
//
//    [doctorInfoVC setDoctorID:_doctor.doctorID];
//    
//    [[self navigationController] pushViewController:doctorInfoVC animated:YES];
}

- (void)showBookingPage
{
    if (!_doctor) {
        NSLog(@"showBookingPage doctor data invalid");
        return;
    }
    
    if (_chatUserID == [CureMeUtils defaultCureMeUtil].userID && chatBookID > 0) {
        BookDetailInfoViewController *bookDetailVC = [[BookDetailInfoViewController alloc] initWithNibName:@"BookDetailInfoViewController" bundle:nil];
        [bookDetailVC setBookingID:chatBookID];
        [self.navigationController pushViewController:bookDetailVC animated:YES];
        return;
    }
    
    QueryViewController *queryVC = [[QueryViewController alloc] initWithNibName:@"QueryViewController" bundle:nil];
    if (!_doctor || _doctor.hospitalID <= 0) {
        // 如果没有Doctor对象，说明是从活动来的对话，此时使用MetaData里的医院信息
        [queryVC setHospitalID:_metaInfoData.identifier];
        [queryVC setHospitalName:_metaInfoData.name];
    }
    else {
        [queryVC setHospitalID:_doctor.hospitalID];
        [queryVC setHospitalName:_doctor.hospitalName];
    }
    
    if (_chatUserID == [CureMeUtils defaultCureMeUtil].userID) {
        [queryVC setChatID:_chatID];

        if (chatBookID > 0)
            [queryVC setBookID:chatBookID];

        NSLog(@"showBookingPage bookID: %ld", (long)chatBookID);
    }
    
    [self.navigationController pushViewController:queryVC animated:YES];
}

- (void)showHospitalMapPage
{
    if (_hospitalLatitude > 90 || _hospitalLatitude < -90 || _hospitalLongitude > 180 || _hospitalLongitude < -180) {
        NSLog(@"BubbleViewController showHospitalMapPage coordinate invalid");
        return;
    }
    
    MapViewController *mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    
    [mapVC setHospitalName:_doctor.hospitalName];
    float lat = _hospitalLatitude - 0.0062;
    float lot = _hospitalLongitude - 0.0064;
    [mapVC setLatitude:lat];
    [mapVC setLongitude:lot];
    
    [self.navigationController pushViewController:mapVC animated:YES];
}

// 启动准备显示Remind文字的Timer，可在非UI线程中调用，Interval为等待显示的时间
- (void)startRemindViewTimer:(NSDictionary *)userInfo
{
    if (!userInfo || userInfo.count <= 0) {
        return;
    }
    
    NSString *remind = [userInfo objectForKey:@"remind"];
    NSNumber *interval = [userInfo objectForKey:@"interval"];

    if (!remind || remind.length <= 0) {
        return;
    }
    
    NSLog(@"startRemindViewTimer remind: %@", remind);

    if (!interval || interval.integerValue <= 0) {
        [self performSelectorOnMainThread:@selector(showRemindView:) withObject:remind waitUntilDone:NO];
    }
    else {
        [NSTimer scheduledTimerWithTimeInterval:interval.integerValue target:self selector:@selector(showRemindView:) userInfo:remind repeats:NO];
//        NSTimer *showRemindTimer = [NSTimer timerWithTimeInterval:interval.integerValue target:self selector:@selector(showRemindView:) userInfo:remind repeats:NO];
//        [[NSRunLoop currentRunLoop] addTimer:showRemindTimer forMode:NSDefaultRunLoopMode];
    }
}

// 显示提示View的内容
- (void)showRemindView:(NSTimer *)timer
{
    NSString *remind = timer.userInfo;
    if (!remind || remind.length <= 0)
        return;
    
    NSLog(@"showRemindView remind: %@", remind);
    
    if (!popupRemindView) {
        popupRemindView = [[ChatPopupRemindView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:popupRemindView];
        CGSize textSize = [remind sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByTruncatingTail];
        [popupRemindView setFrame:CGRectMake(160 - textSize.width / 2 - 5, [UIScreen mainScreen].bounds.size.height / 3, textSize.width + 20, textSize.height + 10)];
    }
    
    popupRemindView.remindText = remind;
    [popupRemindView fadeIn];
}

- (void)takePicture
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    
    [imagePicker setDelegate:self];
    
    [self presentModalViewController:imagePicker animated:YES];
    
    imagePicker = nil;
}

- (void)openPhotoLibrary
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [imagePicker setDelegate:self];
    
    [self presentModalViewController:imagePicker animated:YES];
    
    imagePicker = nil;
}

- (void)openSavedPhotoLibrary
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    [imagePicker setDelegate:self];
    
    [self presentModalViewController:imagePicker animated:YES];
    
    imagePicker = nil;
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [addImageBtn setEnabled:NO];
    [sendMsgBtn setEnabled:NO];

    loadingView.hidden = NO;
//    [activityIndicator startAnimating];
    [NSThread detachNewThreadSelector:@selector(threadSendImage:) toTarget:self withObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)threadSendImage:(UIImage *)image
{
    @autoreleasepool {
        // 2. 如果chatID为空，则发出chatnow请求
        if (_chatID <= 0) {
            // action=chatnow &userid=xxxxx&doctorid=xxx&sourcetype=string&sourceid=xxx&pagename=xxx
            NSString *post = [NSString stringWithFormat:@"action=chatnow&userid=%ld&doctorid=%ld&usertype=USER&sourcetype=%@&sourceid=%ld&pagename=%@", (long)[CureMeUtils defaultCureMeUtil].userID, (long)_talkerID, _sourceType, (long)_sourceID, _pageName];
            NSData *response = sendRequest(@"m.php", post);
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"sendMessage generate chatID: %@", strResp);
            
            NSDictionary *jsonData = parseJsonResponse(response);
            NSNumber *result = [jsonData objectForKey:@"result"];
            if (result.integerValue != 1) {
                NSLog(@"sendMessage gen chatID req failed");
                [addImageBtn setEnabled:YES];
                [sendMsgBtn setEnabled:YES];
                return;
            }
            
            NSLog(@"respJson: %@", jsonData);
            NSNumber *ID = [jsonData objectForKey:@"msg"];
            if (!ID || ID.integerValue <= 0) {
                NSLog(@"chatnow req chatID invalid: %@", ID);
                [addImageBtn setEnabled:YES];
                [sendMsgBtn setEnabled:YES];
                return;
            }
            _chatID = ID.integerValue;
        }
        
        // 1. 把image进行压缩（质量度+尺寸），并根据大图片文件名规则保存到本地
        //  1）尺寸压缩
        UIImage *newImage = [[CureMeUtils defaultCureMeUtil] resizeImageWithConstraint:image andMaxSize:1024];
        
        //  2) 质量度压缩，并保存图片
        NSData *newImageData = UIImageJPEGRepresentation(newImage, 0.8);
        
        // 2. 发送压缩后的图片，并获得图片key
        NSString *strUrl = [NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/api/m.php?action=uploadimage&rn=%.2f&version=2.2", [[[NSDate alloc] init] timeIntervalSince1970]];
        NSData *newImageResponse = sendRequestWithData(strUrl, newImageData);
        
        NSString *strResp = [[NSString alloc] initWithData:newImageResponse encoding:NSUTF8StringEncoding];
        NSLog(@"post image resp: %@", strResp);
        
        NSDictionary *jsonData = parseJsonResponse(newImageResponse);
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSLog(@"uploadimage failed");
            [self dismissModalViewControllerAnimated:YES];
            [addImageBtn setEnabled:YES];
            [sendMsgBtn setEnabled:YES];
            return;
        }
        
        // 获得imagekey
        NSString *imageKey = [jsonData objectForKey:@"msg"];
        NSLog(@"threadSendImage imageKey: %@", imageKey);
        
        // 本地保存原始尺寸图
        if (![[CureMeUtils defaultCureMeUtil] saveImage:newImageData withKey:imageKey andSize:@"l"]) {
            NSLog(@"threadSendImage save 1024 size image file failed");
        }
        
        // 本地保存200*200尺寸缩略图
        UIImage *thumbnailImage = [[CureMeUtils defaultCureMeUtil] resizeImageWithConstraint:newImage andMaxSize:200];
        NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 1.0);
        if (![[CureMeUtils defaultCureMeUtil] saveImage:thumbnailImageData withKey:imageKey andSize:@"s"]) {
            NSLog(@"threadSendImage save thumbnail size image file failed");
        }
        
        // 3. 通过请求获得图片的缩略图（获取过程中可以考虑显示中间状态，可选）        
        // 发送消息新请求 action=sendmessage&fromid=xxx&chatid=xxx&msg=xxxxx&img=xxx&hospitalid=xxx
//        NSString *post = [[NSString alloc] initWithFormat:@"action=sendmessage&fromid=%d&chatid=%d&msg=&img=%@", [CureMeUtils defaultCureMeUtil].userID, _chatID, imageKey];
        NSString *post = [[NSString alloc] initWithFormat:@"action=chat_post2&hospitalid=%ld&fromid=%ld&toid=%ld&chatid=%ld&msg=&img=%@&type=text", (long)(_doctor.doctorID > 0 ? _doctor.hospitalID : _metaInfoData.identifier), (long)[CureMeUtils defaultCureMeUtil].userID, (long)_chatUserID, (long)_chatID, imageKey];
        NSData *response = sendRequest(@"msg.php", post);
        
        strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"sendmessage resp: %@", strResp);
        
        jsonData = parseJsonResponse(response);
        if (!jsonData) {
            NSLog(@"action=sendmessage resp json invalid %@", strResp);
            [addImageBtn setEnabled:YES];
            [sendMsgBtn setEnabled:YES];
            return;
        }
        
        result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSLog(@"action=sendmessage resp result invalid %@", [jsonData objectForKey:@"msg"]);
            [addImageBtn setEnabled:YES];
            [sendMsgBtn setEnabled:YES];
            return;
        }
        
        NSDate *msgTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[jsonData objectForKey:@"msg"] integerValue]];
        
        NSBubbleData *newChatData = [NSBubbleData dataWithMsgImage:thumbnailImage
                                                       andImageKey:imageKey
                                                           andDate:msgTime
                                                           andType:BubbleTypeMine
                                                          andImage:nil
                                                       andTalkerID:_talkerID
                                                       andCellType:CellTypeDetail];
        
        _inputField.text = nil;
        [_inputField endEditing:YES];
        
        // 先ReloadData，确保能够正确初始化TableView的Section
        [self performSelectorOnMainThread:@selector(mainThreadAddBubbleData:) withObject:newChatData waitUntilDone:NO];
     }
    
    [addImageBtn setEnabled:YES];
    [sendMsgBtn setEnabled:YES];
}

- (void)mainThreadAddBubbleData:(NSBubbleData *)chatData
{
    if (!chatData || ![chatData isKindOfClass:[NSBubbleData class]])
        return;
    
    [bubbleData addObject:chatData];
    
    loadingView.hidden = YES;
//    [activityIndicator stopAnimating];

    [self reloadData:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendMessage:(id)sender
{
    [_inputField becomeFirstResponder];
    
    NSString *message = _inputField.text;
    
    // 1. 如果消息为空，提示并结束
    if (message.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"聊天"
                              message:@"请输入聊天内容"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    @autoreleasepool {
        // 2. 如果chatID为空，则发出chatnow请求
        if (_chatID <= 0) {
            // action=chatnow &userid=xxxxx&doctorid=xxx&sourcetype=string&sourceid=xxx&pagename=xxx
            NSString *post = [NSString stringWithFormat:@"action=chatnow&userid=%ld&doctorid=%ld&usertype=USER&sourcetype=%@&sourceid=%ld&pagename=%@", (long)[CureMeUtils defaultCureMeUtil].userID, (long)_talkerID, _sourceType, (long)_sourceID, _pageName];
            NSData *response = sendRequest(@"m.php", post);
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"sendMessage generate chatID: %@", strResp);
            
            NSDictionary *jsonData = parseJsonResponse(response);
            NSNumber *result = [jsonData objectForKey:@"result"];
            if (result.integerValue != 1) {
                NSLog(@"sendMessage gen chatID req failed");
                return;
            }
            
            NSLog(@"respJson: %@", jsonData);
            NSNumber *ID = [jsonData objectForKey:@"msg"];
            if (!ID || ID.integerValue <= 0) {
                NSLog(@"chatnow req chatID invalid: %@", ID);
                return;
            }
            _chatID = ID.integerValue;
        }
        
        // 3. 以下，发送消息
        NSString *encodeMessage = [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // 发送消息新请求
        NSString *post = [[NSString alloc] initWithFormat:@"action=chat_post2&hospitalid=%ld&fromid=%ld&toid=%ld&chatid=%ld&msg=%@&img=&type=text", (long)(_doctor.doctorID > 0 ? _doctor.hospitalID : _metaInfoData.identifier), (long)[CureMeUtils defaultCureMeUtil].userID, (long)_chatUserID, (long)_chatID, encodeMessage];
        NSData *response = sendRequest(@"msg.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"chat_post2: %@ resp: %@", post, strResp);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        if (!jsonData) {
            NSLog(@"action=sendmessage resp json invalid %@", strResp);
            return;
        }
        
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSString *error = [jsonData objectForKey:@"msg"];
            NSLog(@"action=sendmessage resp result invalid %@", error);
            return;
        }
        
        NSDate *msgTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[jsonData objectForKey:@"msg"] integerValue]];

        [bubbleData addObject:[NSBubbleData  dataWithText:[NSString stringWithFormat:@"%@", message] andDate:msgTime andType:BubbleTypeMine andImage:nil andTalkerID:0 andCellType:CellTypeDetail]];
        _inputField.text = nil;
        [_inputField endEditing:YES];
        
        if (!talking) {
            talking = YES;
            [NSThread detachNewThreadSelector:@selector(threadDetectReplies) toTarget:self withObject:nil];
        }
                // 先ReloadData，确保能够正确初始化TableView的Section
        [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
    }
}

- (void)reloadData:(NSNumber *)scrollAdjustType
{
    [bubbleTable reloadData];
    loadingView.hidden = YES;
//    [activityIndicator stopAnimating];
    
    if (scrollAdjustType && scrollAdjustType.integerValue == SCROLLNONE)
        return;
    
    // 如果是查看别人聊天，则不滚动到最底部
    if (_chatUserID != [CureMeUtils defaultCureMeUtil].userID) {
        return;
    }
   
    CGPoint newPosition = bubbleTable.contentOffset;
    NSLog(@"contentOffset x: %.2f y: %.2f", newPosition.x, newPosition.y);
    NSLog(@"contentSize width: %.2f height: %.2f", bubbleTable.contentSize.width, bubbleTable.contentSize.height);
    if (bubbleTable.contentSize.height >= 400 *SCREEN_HEIGHT/480) {
        newPosition.y = bubbleTable.contentSize.height - 400 *SCREEN_HEIGHT/480;
    }

    [bubbleTable setContentOffset:newPosition animated:YES];
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (UIImage *)infoImage
{
    return _doctorHeadImage;
}

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
//    NSLog(@"BubbleTableView delegate dataForRow: %d %@", row, [bubbleData objectAtIndex:row]);
    return [bubbleData objectAtIndex:row];
}

#pragma mark notifications
- (void)ntfPullNewMsgs:(NSNotification *)note
{
    @autoreleasepool {
        NSLog(@"nyfPullNewMsgs begin: %@", [NSDate date]);
        
        NSDictionary *userInfo = note.userInfo;
        if (!userInfo) {
            NSLog(@"ntfPullNewMsgs talker id not set");
            return;
        }
//        NSNumber *talkerID = [userInfo objectForKey:@"talkerID"];
//        if (talkerID.integerValue != _talkerID) {
//            NSLog(@"talkID not valid");
//            return;
//        }

        NSString *post = [[NSString alloc] initWithFormat:@"action=chat_pull2&owner=%ld&chatid=%ld", (long)[CureMeUtils defaultCureMeUtil].userID, (long)_chatID];
        NSData *response = sendRequest(@"msg.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"action=getnewmessage resp: %@", strResp);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        if (!jsonData || jsonData.count <= 0) {
            NSLog(@"action=getnewmessage resp json invalid: %@", strResp);
            return;
        }
        
        // {"result":true,"msg":[{"from":367,"to":"","data":"{\"text\":\"\",\"image\":\"\",\"type\":\"book\",\"data\":\"432\"}","time":1352089227,"chat_id":11912}],"doctors":[{"did":367,"dname":"ggggg","dpic":""}]}
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSLog(@"action=getnewmessage resp result invalid %@", [jsonData objectForKey:@"msg"]);
            return;
        }
        
        // 获得医生信息
        NSArray *doctorInfos = [jsonData objectForKey:@"doctors"];
        [self addDoctorsInfo:doctorInfos];

        NSArray *msgs = [jsonData objectForKey:@"msg"];
        NSLog(@"action=getnewmessage msgs: %@", msgs);
        if (!msgs || msgs.count <= 0) {
            return;
        }

        if (msgs && msgs.count > 0) {
            for (NSDictionary *msg in msgs) {
                if (![self addSingleHisMessage:msg]) {
                    NSLog(@"getneewmessage addSingleHisMessage failed: %@", msg);
                    return;
                }
            }
        }
        
        [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark Thread related methods
- (void)threadGetImage:(NSDictionary *)userInfo
{
    @autoreleasepool {
        NSLog(@"threadGetImage");
        
        if (!userInfo || userInfo.count < 2)
            return;
        
        NSString *imageKey = [userInfo objectForKey:@"imageKey"];
        NSDate *msgDate = [userInfo objectForKey:@"msgTime"];
        
        if (!imageKey || imageKey.length <= 0 || !msgDate)
            return;
        
        // 此处下载图片，保存，并显示
        UIImage *thumbnailImage = [[CureMeUtils defaultCureMeUtil] getImageByKey:imageKey andSize:@"s"];
        if (!thumbnailImage) {
            NSLog(@"threadGetImage other's message getimage nil");
            return;
        }
        
        for (NSBubbleData *chatData in bubbleData) {
            if ([chatData.imageKey isEqualToString:imageKey]) {
                chatData.msgImage = thumbnailImage;
                break;
            }
        }
        
//        [self performSelectorOnMainThread:@selector(reloadData:) withObject:[[NSNumber alloc] initWithInt:SCROLLNONE]  waitUntilDone:NO];
//        [self performSelectorOnMainThread:@selector(mainThreadAddBubbleData:) withObject:newChatData waitUntilDone:NO];
    }
}

- (void)threadInitChatDatas
{
    @autoreleasepool {
        // 告诉TableView是否已加载完所有历史消息，并告诉tableview，对话类型

        // 2. 初始化历史消息
        // 如果没有指定chatID，调用initchatlist
        if (_chatID <= 0) {
            if (_talkerID <= 0) {
                UIAlertView *alert = [[UIAlertView alloc]
                                        initWithTitle:@"聊天"
                                        message:@"聊天对象ID未设置"
                                        delegate:self
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
                [alert show];
            }

            [self initChatIDAndTalkData];
        }
        // 如果已经有chatID，调用messagehistory获取第一页历史消息
        else {
            [self initTalkData];
        }
        
//        if (bubbleData.count < 20)
//            bubbleTable.hasLoadHistoryComplete = true;
//        else
//            bubbleTable.hasLoadHistoryComplete = false;

        NSLog(@"BubbleViewController chatID: %ld after init", (long)_chatID);
        
        [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
        
        // 在查看自己对话时，开启轮询更新消息线程
//        if (_chatUserID == [CureMeUtils defaultCureMeUtil].userID) {
//            [NSThread detachNewThreadSelector:@selector(threadDetectReplies) toTarget:self withObject:nil];
//        }
        
        [[CureMeUtils defaultCureMeUtil] updateUnreadMsgCount];
    }
}

- (void)threadDetectReplies
{
    // 1. 轮询Pull消息
    @autoreleasepool {
        maxId = 0;
        while (talking == YES) {
            
            NSString *post = [[NSString alloc] initWithFormat:@"action=chat_pull2&msg_max_id=%ld&chatid=%ld", (long)maxId, (long)_chatID];
            NSData *response = sendRequest(@"msg.php", post);
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"action=getnewmessage resp: %@", strResp);
            
            NSDictionary *jsonData = parseJsonResponse(response);
            if (!jsonData || jsonData.count <= 0) {
                NSLog(@"action=getnewmessage resp json invalid: %@", strResp);
                sleep(3);
                continue;
            }
            
            NSNumber *result = [jsonData objectForKey:@"result"];
            if (!result || result.integerValue != 1) {
                NSLog(@"action=getnewmessage resp result invalid %@", [jsonData objectForKey:@"msg"]);
                sleep(3);
                continue;
            }
            
            
            NSArray *msgs = [jsonData objectForKey:@"msg"];
            
            NSLog(@"action=getnewmessage msgs: %@", msgs);
            if (!msgs || msgs.count <= 0) {
                sleep(3);
                continue;
            }
            
            if (msgs && msgs.count > 0) {
                for (NSDictionary *msg in msgs) {
                    if (maxId == 0) {
                        if ([msg isEqual:msgs[msgs.count - 1]]) {
                            maxId = [[msg objectForKey:@"msgid"] integerValue];
                        }
                        continue;
                    }
                    if (![self addTalkingHisMessage:msg]) {
                        NSLog(@"getneewmessage addSingleHisMessage failed: %@", msg);
                        sleep(3);
                        break;
                    }
                }
            }
            
            [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
            sleep(3);
            continue;
        }
    }
}

#pragma mark –
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark EGO refresh table header view
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{
    NSLog(@"==开始加载数据");
    _reloading = YES;
}

- (void)doneLoadingTableViewData{
    NSLog(@"===加载完数据");
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:bubbleTable];
}

#pragma mark –
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [[NSDate alloc] init];
}

- (void)showMsgLimitAlert
{
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
    // 获得最晚消息的时间，加上固定值
    for (NSBubbleData *cData in bubbleData) {
        if (NSOrderedDescending == [cData.date compare:date]) {
            date = cData.date;
        }
    }
    
    NSLog(@"showMsgLimitAlert last msg time: %@", date);
    date = [date dateByAddingTimeInterval:1];
    NSLog(@"add time interval for last msg: %@", date);
    
    // 创建聊天消息
    NSBubbleData *chatData = [NSBubbleData dataWithTextRemind:@"          由于隐私限制，更多对话将不显示" andData:date andType:BubbleTypeSomeoneElse andTalkerID:_chatUserID andCellType:CellTypeTextRemind];

    [bubbleData addObject:chatData];
    
    [self performSelectorOnMainThread:@selector(reloadData:) withObject:[[NSNumber alloc] initWithInt:SCROLLNONE] waitUntilDone:NO];
}

-(void) dismissAlert:(NSTimer *)timer{
    
    NSLog(@"release timer");
    NSLog(@"%@", [[timer userInfo] objectForKey:@"key"]);
    
    UIAlertView *alert = [[timer userInfo] objectForKey:@"alert"];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    
    //定时器停止使用：
    [timer invalidate];
    timer = nil;
}

- (IBAction)startMarkChat:(id)sender
{
    markDoctorViewController.chatID = _chatID;
    [markDoctorViewController setMarkPoint:chatMarkPoint];
    [markDoctorViewController setMarkComment:chatMarkComment];
    
    [[KGModal sharedInstance] setModalBackgroundColor:[UIColor clearColor]];
    [[KGModal sharedInstance] setYUpOffset:120];
    [[KGModal sharedInstance] showWithContentView:markDoctorViewController.view andAnimated:YES];
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
        [self.view addSubview:protocolView];
//        saveTitle = self.navigationItem.title;
//        [self.navigationItem setTitle:@"用户协议"];
        return;
    }
    
    /*CMQueryViewController *queryVC = [[CMQueryViewController alloc] initWithNibName:@"CMQueryViewController" bundle:nil];
    [queryVC setOfficeType:_officeType];
    [queryVC setSubOfficeType:_officeSubType];*/
    CMNewQueryViewController *queryVC = [CMNewQueryViewController new];
    queryVC.officeType = _officeType;
    queryVC.subOfficeType = _officeSubType;
    queryVC.chatUserID = [CureMeUtils defaultCureMeUtil].userID;
    [self.navigationController pushViewController:queryVC animated:YES];
//    [_startQueryView setHidden:YES];
//    [_sendAreaView setHidden:NO];
//    [subTypeView setHidden:NO];
//    [_sendQueryTextField becomeFirstResponder];
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
        [CureMeUtils defaultCureMeUtil].userName = [CureMeUtils defaultCureMeUtil].uniID;
        [[NSUserDefaults standardUserDefaults] setObject:[CureMeUtils defaultCureMeUtil].uniID forKey:USER_REGISTERNAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [HiChat login:[NSString stringWithFormat:@"%ld",[CureMeUtils defaultCureMeUtil].userID] withPassword:@"" completion:^(NSError *error){
            if (error) {
                NSLog(@"%@",error);
            }
            
            NSData *deviceToken = [NSData dataWithData:[[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN_NSDATA]];
            if (!deviceToken) {
                NSLog(@"push token is nil fail to submit");
            }
            else{
                [HiChat submitDeviceToken:deviceToken];
            }
        }];
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

- (IBAction)sendQueryBtnClicked:(id)sender {
//    if (_officeType <= 0) {
//        NSLog(@"BubbleViewController startQuery office type invalid");
//        return;
//    }
//    
//    NSString *question = [_sendQueryTextField text];
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
//    NSString *post = [NSString stringWithFormat:@"action=postquestion&userid=%d&type=%d&typechild=%d&question=%@&img=&addrdetail=%@", [CureMeUtils defaultCureMeUtil].userID, _officeType, _officeSubType, sendQuestion, encodeAddr ? encodeAddr : @""];
//    NSLog(@"zixun: %@", post);
//    NSData *response = sendRequest(@"m.php", post);
//    NSDictionary *respDict = parseJsonResponse(response);
//    NSNumber *result = [respDict objectForKey:@"result"];
//    if (!result || 0 == [result integerValue]) {
//        NSString *error = [respDict objectForKey:@"msg"];
//        NSLog(@"sendQuestion failed %@", error);
//    }
//    else {
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"咨询"
//                              message:@"咨询发送成功，请进入我的咨询查看回复"
//                              delegate:self
//                              cancelButtonTitle:@"OK"
//                              otherButtonTitles:nil];
//        [alert show];
//    }
//    
//    [subTypeView setHidden:YES];
//    lastQueryString = _sendQueryTextField.text;
//    _sendQueryTextField.text = @"";
//    [_sendQueryTextField endEditing:YES];
}

- (void)pushNewQuary:(NSInteger)office1 and:(NSInteger)office2{
    CMNewQueryViewController *queryVC = [CMNewQueryViewController new];
    queryVC.officeType = _officeType;
    queryVC.subOfficeType = _officeSubType;
    queryVC.chatUserID = [CureMeUtils defaultCureMeUtil].userID;
    [self.navigationController pushViewController:queryVC animated:YES];

}

@end
