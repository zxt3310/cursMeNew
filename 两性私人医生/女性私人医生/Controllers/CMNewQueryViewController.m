//
//  CMNewQueryViewController.m
//  私密健康医生
//
//  Created by jongs zhong on 16/2/29.
//  Copyright © 2016年 Tim. All rights reserved.
//

#import "DDXML.h"
#import "CMActionSheet.h"
#import "CMNewQueryViewController.h"
#import "UINewBubbleTableView.h"
#import "UINewBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "QueryViewController.h"
#import "BookDetailInfoViewController.h"
#import <CommonCrypto/CommonDigest.h>

#import "MapViewController.h"

#define iatao_server_url @"http://yiaitao.lifehealthcare.com/api/"

@interface CMNewQueryViewController ()
{
    NSInteger *msgMaxId;
    BOOL talking;
}
@end

@implementation CMNewQueryViewController

@synthesize officeType = _officeType;
@synthesize subOfficeType = _subOfficeType;
@synthesize chatID = _chatID;
@synthesize chatSWTID = _chatSWTID;
@synthesize chatUserID = _chatUserID;
@synthesize swtUserID = _swtUserID;
@synthesize hospitalLatitude = _hospitalLatitude;
@synthesize hospitalLongitude = _hospitalLongitude;
@synthesize bookInfoUnit = _bookInfoUnit;
@synthesize doctor = _doctor;
@synthesize questionID = _questionID;
@synthesize doctorID = _doctorID;

UIImageView *doctorImg;
UILabel *hospitalLabel;
UILabel *doctorLabel;
NSString *doctorName;
NSString *hospitalName;
NSInteger hospitalID;
NSString *doctorTag;
NSString *welcomeStr;
NSString *dpicKey;
UILabel *infoLabel;

UIView *queryInputView;
UITextField *questionInput;

BOOL isSWT;
BOOL isReady;
BOOL isQuit;
BOOL swtClosed;
/**
 *  @author Zxt, 17-03-30 10:03:40
 *
 *  新增医爱淘状态
 */
BOOL isIAT;
BOOL isIATquit;
//判断用户是否在当前页面，用来停止NSTimer
BOOL isUserActive;

NSTimer *loopGetChatIDTimer;
NSInteger loopCount;

NSTimer *cancelSWTTimer;
BOOL hasCancelSWT;
NSInteger cityid;
NSInteger city2id;
NSString *hospitalIntro;
NSString *hospitalCookie;
NSString *hospitalUrl;
NSString *hospitalUrlBody;
NSDictionary *hospitalParams;
NSTimer *heartBeatTimer;
NSTimer *cdCheckTimer;
NSInteger swtMaxID;

CMActionSheet *actionSheet;
UIButton *picBtn;
UIButton *queryBtn;
NSString *md5Str;

UILabel *nameLabel;
UIView *infoView;
NSString *SWT_url;

- (void)viewDidLoad {
    [super viewDidLoad];
    isUserActive = YES;
    isSWT = NO;
    isReady = NO;
    isQuit = NO;
    swtClosed = NO;
    _questionID = nil;
    loopGetChatIDTimer = nil;
    loopCount = 0;
    cancelSWTTimer = nil;
    hasCancelSWT = NO;
    heartBeatTimer = nil;
    cdCheckTimer = nil;
    /**
     *  @author Zxt, 17-05-10 11:05:01
     *
     *  私人医生端轮询标记
     */
    talking = YES;
    
    [CureMeUtils defaultCureMeUtil].isInNewQuery = YES;
    /**
     *  @author Zxt, 17-03-27 10:03:19
     *
     *  初始化医爱淘开关,先判断医爱淘是否允许
     */
    _isAllowToiatao = YES;
    isIAT = NO;
    isIATquit = NO;
    /**
     *  @author Zxt, 17-05-11 10:05:41
     *
     *  更新MD5值
     */
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formator = [[NSDateFormatter alloc] init];
    [formator setDateFormat:@"yyyyMMdd"];
    NSString *curStr = [formator stringFromDate:currentDate];
    NSString *mdtStr = [NSString stringWithFormat:@"rankswtapp_%@_%ld",curStr,(long)[CureMeUtils defaultCureMeUtil].userID];
    md5Str = [self getmd5WithString:mdtStr];

    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"专家咨询"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 46)];
    infoView.backgroundColor = CM_BACKGROUND_COLOR;
    [self.view addSubview:infoView];
    
    doctorImg = [[UIImageView alloc] initWithFrame:CGRectMake(5.5, 4, 38, 38)];
    doctorImg.image = [UIImage imageNamed:@"doctor_b"];
    [infoView addSubview:doctorImg];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 6, 45, 15)];
    nameLabel.font = [UIFont boldSystemFontOfSize:14];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text = @"机构：";
    [infoView addSubview:nameLabel];
    
    hospitalLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 6, SCREEN_WIDTH-110, 15)];
    hospitalLabel.font = [UIFont systemFontOfSize:14];
    hospitalLabel.textColor = [UIColor grayColor];
    hospitalLabel.text = @"等待机构连接中...";
    [infoView addSubview:hospitalLabel];
    
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 45, 15)];
    infoLabel.font = [UIFont boldSystemFontOfSize:14];
    infoLabel.textColor = [UIColor blackColor];
    infoLabel.text = @"姓名：";
    [infoView addSubview:infoLabel];
    
    doctorLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 25, SCREEN_WIDTH-110, 15)];
    doctorLabel.font = [UIFont systemFontOfSize:14];
    doctorLabel.textColor = [UIColor grayColor];
    doctorLabel.text = @"";
    [infoView addSubview:doctorLabel];
    
    queryInputView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - (FitIpX(64)) - (FitIpX(50)), SCREEN_WIDTH, 50)];
    queryInputView.backgroundColor = CM_BACKGROUND_COLOR;
    queryInputView.layer.borderWidth = 0.5;
    queryInputView.layer.borderColor = UIColorFromHex(0x9b9b9b, 0.51).CGColor;
    
    UIImageView *picImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 40, 40)];
    picImg.image = [UIImage imageNamed:@"jiaoliu_tupian"];
    [queryInputView addSubview:picImg];
    
    picBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [picBtn setBackgroundColor:[UIColor clearColor]];
    [picBtn setTitle:@"" forState:UIControlStateNormal];
    picBtn.layer.masksToBounds = YES;
    [picBtn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    picBtn.frame = CGRectMake(5, 0, 40, 40);
    [picBtn addTarget:self action:@selector(picBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [queryInputView addSubview:picBtn];
    //隐藏图片按钮
    picBtn.hidden = YES;
    picImg.hidden = YES;
    
    queryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [queryBtn setBackgroundColor:UIColorFromHex(0xd0021b,1)];
    [queryBtn setTitle:@"发送" forState:UIControlStateNormal];
    queryBtn.layer.masksToBounds = YES;
    [queryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    queryBtn.frame = CGRectMake(SCREEN_WIDTH-5-65, 8, 65, 34);
    [queryBtn addTarget:self action:@selector(queryBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [queryInputView addSubview:queryBtn];
    
    
    UITapGestureRecognizer *queryTapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapQueryContainer)];
    UIView *query_container = [[UIView alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH-50-75 + 40, 40)];
    questionInput = [[UITextField alloc] initWithFrame:CGRectMake(0, 2, SCREEN_WIDTH - 50 - 75 + 40, 36)];
    questionInput.borderStyle = UITextBorderStyleRoundedRect;
    questionInput.placeholder = @"请输入您要咨询的问题";
    questionInput.layer.cornerRadius = 5;
    [query_container addSubview:questionInput];
    [query_container addGestureRecognizer:queryTapgr];
    [queryInputView addSubview:query_container];
    
    self.bubbleTable = [[UINewBubbleTableView alloc] initWithFrame:CGRectMake(0, 46, SCREEN_WIDTH, SCREEN_HEIGHT-64-46-40) style:UITableViewStylePlain];
    //self.bubbleTable.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bubbleTable];
    
    [self.view addSubview:queryInputView];
    self.navigationItem.rightBarButtonItem = nil;

    
    // 1. 初始化DataSource
    self.bubbleTable.bubbleDataSource = self;
    //self.bubbleTable.delegate = self;
    [self.bubbleTable setChatViewController:self];
    
    self.bubbleData = [[NSMutableArray alloc] init];
    
    // 0. 注册Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfPullNewMsgs:) name:NTF_PullNewChatMsgs object:nil];
    
    // 载入中的View
    float topY = 140;
    if ([UIScreen mainScreen].bounds.size.height > 480.0) {
        topY += 40;
    }
    loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 35, topY, 80, 70)];
    loadingView.hidden = YES;
    [self.view addSubview:loadingView];
    
    needStopDetectReplies = false;
    [[CureMeUtils defaultCureMeUtil] setCurChatHeartBreakSeed:rand()];
    
    chatBookID = 0;
    
    [[self imageDownloader] setDelegate:self];
    [[self imageDownloader] setShouldEnd:false];
    
    if (_chatID==0 && _doctorID==0 && _chatSWTID==0) {
        [self chooseHospital:@"first"];
    }else if (_doctorID>0 && _chatID==0 && _chatSWTID==0) {//医生信息
        //[self initChatIDAndTalkData];
    }else if (_doctorID>0 && _chatID>0 && _chatSWTID==0) {//我的咨询
        //[self initTalkData];
    }else{//推送
        //[self initTalkData];
    }
    
    if (_chatSWTID>0) {
        [self initSWTChat];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)reloadInfoView{
    infoLabel.text = @"姓名：";
    [self.navigationItem setTitle:[NSString stringWithFormat:@"与%@对话", doctorName]];
    hospitalLabel.text = hospitalName;
    doctorLabel.text = [NSString stringWithFormat:@"%@ %@", doctorName, doctorTag];
}

- (void)reloadSWTInfoView{
    infoLabel.text = @"介绍：";
    [self.navigationItem setTitle:[NSString stringWithFormat:@"专家咨询"]];
    hospitalLabel.text = hospitalName;
    if (hospitalIntro.length > 0) {
        doctorLabel.text = [NSString stringWithFormat:@"%@", hospitalIntro];
    }
    else{
        CGRect temp = hospitalLabel.frame;
        temp.origin.y = infoView.frame.size.height / 2 - hospitalLabel.frame.size.height/2;
        hospitalLabel.frame = temp;
        
        temp = nameLabel.frame;
        temp.origin.y = hospitalLabel.frame.origin.y;
        nameLabel.frame = temp;
        
        infoLabel.text = @"";
        doctorLabel.text = @"";
    }
}
/**
 *  @author Zxt, 17-03-29 14:03:23
 *
 *  　医爱淘
 */
- (void)reloadIATinfoView{
    infoLabel.text = @"";
    [self.navigationItem setTitle:@"专家咨询"];
    hospitalLabel.text = hospitalName;
    doctorLabel.text = @"";
}

- (void)addDoctorClientMessage:(NSString *)message msgDate:(NSDate*)msgTime
{
    NSBubbleData *chatData = [NSBubbleData dataWithText:message
                                                andDate:msgTime
                                                andType:BubbleTypeSomeoneElse
                                               andImage:[[CMImageUtils defaultImageUtil] doctorDefaultHeadSImage]
                                            andTalkerID:_doctorID
                                            andCellType:CellTypeDetail];
    // 医生头像图片ImageKey
    NSNumber *TID = [[NSNumber alloc] initWithInteger:_doctorID];
    NSString *headImageKey = [[self doctorIDImageKeys] objectForKey:TID];
    if (headImageKey) {
        chatData.headImageKey = headImageKey;
    }
    [self.bubbleData addObject:chatData];
}

- (void)addSWTDoctorClientMessage:(NSString *)message msgDate:(NSDate*)msgTime
{
    NSBubbleData *chatData = [NSBubbleData dataWithText:message
                                                andDate:msgTime
                                                andType:BubbleTypeSomeoneElse
                                               andImage:[[CMImageUtils defaultImageUtil] doctorDefaultHeadSImage]
                                            andTalkerID:_doctorID
                                            andCellType:CellTypeDetail];
    [self.bubbleData addObject:chatData];
}

- (void)addUserClientMessage:(NSString *)message msgDate:(NSDate*)msgTime
{
    NSBubbleData *chatData = [NSBubbleData dataWithText:message
                                                andDate:msgTime
                                                andType:BubbleTypeMine
                                               andImage:nil
                                            andTalkerID:0
                                            andCellType:CellTypeDetail];    
    [self.bubbleData addObject:chatData];
}

- (IBAction)back:(id)sender
{
    NSLog(@"CMNewQueryViewController back");
    [CureMeUtils defaultCureMeUtil].isInNewQuery = NO;
    [self.view endEditing:YES];
    
    talking = NO;
    
    isUserActive = NO;
    
    swtMaxID = nil;
    
    isIATquit = nil;
    isQuit = nil;
    isIAT = nil;
    isSWT = nil;
    
    [super back:sender];
    if (loopGetChatIDTimer)
    {
        [loopGetChatIDTimer invalidate];
        loopGetChatIDTimer = nil;
    }
    if (cancelSWTTimer)
    {
        [cancelSWTTimer invalidate];
        cancelSWTTimer = nil;
    }
    if (heartBeatTimer)
    {
        [heartBeatTimer invalidate];
        heartBeatTimer = nil;
    }
    if (cdCheckTimer)
    {
        [cdCheckTimer invalidate];
        cdCheckTimer = nil;
    }
    if (isSWT && !swtClosed) {
        [self leaveSWT];
    }
    /**
     *  @author Zxt, 17-03-30 10:03:45
     *
     *  新增医爱淘退出日志
     */
    if (isIAT && !isIATquit) {
        [self sendLogRequest:@"leave"];
    }
    
    needStopDetectReplies = true;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NTF_PullNewChatMsgs object:nil];
    
    [[self imageDownloader] setShouldEnd:true];
    isQuit = YES;
    
    if (self.bubbleData.count>0) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (id obj in self.bubbleData) {
            NSBubbleData *data = (NSBubbleData *)obj;
            NSData *chatData = [NSKeyedArchiver archivedDataWithRootObject:data];
            [array addObject:chatData];
        }
        NSArray *saveAry = [array copy];
        if (isIAT) {
            [[NSUserDefaults standardUserDefaults] setObject:saveAry forKey:[NSString stringWithFormat:@"%ld",_chatID]];
        }
        if (isSWT) {
            [[NSUserDefaults standardUserDefaults] setObject:saveAry forKey:[NSString stringWithFormat:@"%ld",_chatSWTID]];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    [self moveQueryView:height];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [self moveQueryView:0.0];
}

- (void)moveQueryView:(CGFloat)height
{
    queryInputView.frame = CGRectMake(0, SCREEN_HEIGHT-(FitIpX(64))- (FitIpX(50))-height, SCREEN_WIDTH, 50);
}

-(void)tapQueryContainer{
    [questionInput becomeFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (![touch.view isKindOfClass:[UITextField class]] && ![touch.view isKindOfClass:[UIButton class]]) {
        [self.view endEditing:YES];
    }
}

- (void)closeKeyboard {
    [self.view endEditing:YES];
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
        
        for (NSBubbleData *chatData in self.bubbleData) {
            if ([chatData.imageKey isEqualToString:imageKey]) {
                chatData.msgImage = thumbnailImage;
                break;
            }
        }
        
        //        [self performSelectorOnMainThread:@selector(reloadData:) withObject:[[NSNumber alloc] initWithInt:SCROLLNONE]  waitUntilDone:NO];
        //        [self performSelectorOnMainThread:@selector(mainThreadAddBubbleData:) withObject:newChatData waitUntilDone:NO];
    }
}

- (void)threadDetectReplies
{
    // 1. 轮询Pull消息
    @autoreleasepool {
        // 获得当前聊天窗口seed
//        NSInteger curChatSeed = [CureMeUtils defaultCureMeUtil].curChatHeartBreakSeed;
//        
//        NSString *modifyTime = [[NSUserDefaults standardUserDefaults] stringForKey:@"ModifyTime"];
//        if (!modifyTime || modifyTime.length <= 0) {
//            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"ModifyTime"];
//            modifyTime = @"0";
//        }
//        
//        NSString *lastModifyTime = @"";
//        
//        NSLog(@"modifyTime: %@", modifyTime);
//        
//        NSLog(@"threadDetactReplies begin: %@", [NSDate date]);
//        
//        NSInteger eTag = 0;
//        
//        while (true) {
//            if (needStopDetectReplies == true || curChatSeed != [CureMeUtils defaultCureMeUtil].curChatHeartBreakSeed)
//                break;
//            
//            NSString *strURL = [NSString stringWithFormat:@"http://%@:%@/activity?id=%ld&module=iph&log_id=%d",
//                                [CureMeUtils defaultCureMeUtil].pollServer ? [CureMeUtils defaultCureMeUtil].pollServer : @"n.medapp.ranknowcn.com",
//                                [CureMeUtils defaultCureMeUtil].pollServerPort ? [CureMeUtils defaultCureMeUtil].pollServerPort : @"3810",
//                                (long)[CureMeUtils defaultCureMeUtil].userID, rand()];
//            NSLog(@"%@", strURL);
//            
//            NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
//            [headers setObject:modifyTime forKey:@"If-Modified-Since"];
//            
//            if ([lastModifyTime isEqualToString:modifyTime]) {
//                [headers setObject:[[NSString alloc] initWithFormat:@"%ld", (long)eTag] forKey:@"If-None-Match"];
//            }
//            else {
//                eTag = 0;
//            }
//            
//            NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
//            NSData *response = sendGetReqWithHeaderAndRespDict(strURL, headers, respDict, false);
//            if (!response) {
//                continue;
//            }
//            
//            // <notify type="PostMsg" chat_id="241" from="3" time="1348716813" randnum="193921944" />
//            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
//            NSLog(@"activity resp: %@ with headers: %@", strResp, respDict);
//            
//            if (needStopDetectReplies == true || curChatSeed != [CureMeUtils defaultCureMeUtil].curChatHeartBreakSeed)
//                break;
//            
//            // 保存上次modifyTime
//            lastModifyTime = modifyTime;
//            // 获取本次modifyTime
//            modifyTime = [respDict objectForKey:@"Last-Modified"];
//            [[NSUserDefaults standardUserDefaults] setObject:modifyTime forKey:@"ModifyTime"];
//            NSLog(@"ModifyTime: %@ talkerID: %ld", modifyTime, (long)_doctorID);
//            
//            eTag = [[respDict objectForKey:@"Etag"] integerValue];
//            
//            // <notify type="PostMsg" from=发起消息的用户id to=接受消息用户的id />
//            NSError *error = nil;
//            DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:response options:0 error:&error];
//            NSLog(@"activity document: %@", document);
//            //        NSArray *children = [document children];
//            DDXMLElement *rootElem = [document rootElement];
//            
//            if ([[rootElem attributeForName:@"type"].stringValue isEqualToString:@"PostMsg"]) {
//                DDXMLNode *chat_ID = [rootElem attributeForName:@"chat_id"];
//                NSInteger chatID = [chat_ID.stringValue integerValue];
//                if (chatID != _chatID) {
//                    NSLog(@"activity chat_id: %ld is not equal to current chatID: %ld", (long)chatID, (long)_chatID);
//                    continue;
//                }
//                
//                DDXMLNode *fromID = [rootElem attributeForName:@"from"];
//                NSInteger iFromID = [fromID.stringValue integerValue];
//                
//                // 发送Notification，通知Pull最新消息
//                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:iFromID] forKey:@"talkerID"];
//                NSNotification *note = [NSNotification notificationWithName:NTF_PullNewChatMsgs object:self userInfo:userInfo];
//                [[NSNotificationCenter defaultCenter] postNotification:note];
//            }
//            else {
//                NSLog(@"Other type notify");
//            }
//            
//            if (needStopDetectReplies == true || curChatSeed != [CureMeUtils defaultCureMeUtil].curChatHeartBreakSeed)
//                break;
//            
//            sleep(1);
//        }
//        
//        NSLog(@"threadDetectReplies end: %@ seed: %ld", [NSDate date], (long)curChatSeed);
        msgMaxId = 0;
        while (talking == YES) {
            
            NSString *post = [[NSString alloc] initWithFormat:@"action=chat_pull2&msg_max_id=%ld&chatid=%ld", (long)msgMaxId, (long)_chatID];
            NSData *response = sendRequest(@"msg.php", post);
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"action=getnewmessage resp: %@", strResp);
            
            NSDictionary *jsonData = parseJsonResponse(response);
            if (!jsonData || jsonData.count <= 0) {
                NSLog(@"action=getnewmessage resp json invalid: %@", strResp);
                sleep(3);
                continue;
            }
            
            // {"result":true,"msg":[{"from":367,"to":"","data":"{\"text\":\"\",\"image\":\"\",\"type\":\"book\",\"data\":\"432\"}","time":1352089227,"chat_id":11912}],"doctors":[{"did":367,"dname":"ggggg","dpic":""}]}
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
                    if (![self addSingleHisMessage:msg]) {
                        NSLog(@"getneewmessage addSingleHisMessage failed: %@", msg);
                        sleep(3);
                        continue;
                    }
                }
            }
            
            [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
            sleep(3);
            continue;
        }
        [NSThread exit];
    }
}

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
        NSLog(@"CMNewQueryViewController getbookinfo: %@", strResp);
        
        NSDictionary *dataJson = parseJsonResponse(response);
        NSNumber *result = [dataJson objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSString *error = [dataJson objectForKey:@"msg"];
            NSLog(@"CMNewQueryViewController action=bookinginfo result invalid %@", error);
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
        
        NSDictionary *messageInternal = parseJsonString([messageOriginal objectForKey:@"msg"]);
        msgMaxId = [[messageOriginal objectForKey:@"msgid"] integerValue];
        
        NSString *text = nil;
        NSInteger talkerID = (fromID.integerValue == _chatUserID) ? 0 : fromID.integerValue;
        NSBubbleType bubbleType = (fromID.integerValue == _chatUserID) ? BubbleTypeMine : BubbleTypeSomeoneElse;
        if (bubbleType == BubbleTypeMine) {
            return true;
        }
        //        NSInteger bubbleType = (fromID.integerValue == [CureMeUtils defaultCureMeUtil].userID) ? BubbleTypeMine : BubbleTypeSomeoneElse;
        
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
            
            [self.bubbleData addObject:chatData];
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
            [self.bubbleData addObject:newChatData];
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
            
            [self.bubbleData addObject:chatData];
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
                [self.bubbleData addObject:chatData];
            }
            // 如果是需要更新的预约单消息
            else {
                NSBubbleData *chatData = [NSBubbleData dataWithBookInfo:chatBookID andType:userType andDate:msgTime andCellType:CellTypeBookInfoUpd andTalkerID:_chatUserID];
                [self.bubbleData addObject:chatData];
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
            [self.bubbleData addObject:chatData];
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
            [self.bubbleData addObject:chatData];
            
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
        //NSArray *doctorInfos = [jsonData objectForKey:@"doctors"];
        //[self addDoctorsInfo:doctorInfos];
        
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

-(void)picBtnClicked:(UIButton *)sender{
    NSLog(@"picBtnClicked");
    if (!isReady || isSWT) {
        return;
    }
    if (_chatID==0) {
        return;
    }
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

- (void)takePicture
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    imagePicker = nil;
}

- (void)openPhotoLibrary
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    imagePicker = nil;
}

- (void)openSavedPhotoLibrary
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    imagePicker = nil;
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picBtn setEnabled:NO];
    [queryBtn setEnabled:NO];
    
    loadingView.hidden = NO;
    //    [activityIndicator startAnimating];
    [NSThread detachNewThreadSelector:@selector(threadSendImage:) toTarget:self withObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
    //[self dismissModalViewControllerAnimated:YES];
}

- (void)threadSendImage:(UIImage *)image
{
    @autoreleasepool {
        
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
            [self dismissViewControllerAnimated:YES completion:^{}];
            [picBtn setEnabled:YES];
            [queryBtn setEnabled:YES];
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
        NSString *post = [[NSString alloc] initWithFormat:@"action=chat_post2&hospitalid=%ld&fromid=%ld&toid=%ld&chatid=%ld&msg=&img=%@&type=text", (long)hospitalID, (long)[CureMeUtils defaultCureMeUtil].userID, (long)_chatUserID, (long)_chatID, imageKey];
        NSData *response = sendRequest(@"msg.php", post);
        
        strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"sendmessage resp: %@", strResp);
        
        jsonData = parseJsonResponse(response);
        if (!jsonData) {
            NSLog(@"action=sendmessage resp json invalid %@", strResp);
            [picBtn setEnabled:YES];
            [queryBtn setEnabled:YES];
            return;
        }
        
        result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSLog(@"action=sendmessage resp result invalid %@", [jsonData objectForKey:@"msg"]);
            [picBtn setEnabled:YES];
            [queryBtn setEnabled:YES];
            return;
        }
        
        NSDate *msgTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[jsonData objectForKey:@"msg"] integerValue]];
        
        NSBubbleData *newChatData = [NSBubbleData dataWithMsgImage:thumbnailImage
                                                       andImageKey:imageKey
                                                           andDate:msgTime
                                                           andType:BubbleTypeMine
                                                          andImage:nil
                                                       andTalkerID:0
                                                       andCellType:CellTypeDetail];
        
        questionInput.text = @"";
        [questionInput resignFirstResponder];
        
        // 先ReloadData，确保能够正确初始化TableView的Section
        [self performSelectorOnMainThread:@selector(mainThreadAddBubbleData:) withObject:newChatData waitUntilDone:NO];
    }
    
    [picBtn setEnabled:YES];
    [queryBtn setEnabled:YES];
}

- (void)mainThreadAddBubbleData:(NSBubbleData *)chatData
{
    if (!chatData || ![chatData isKindOfClass:[NSBubbleData class]])
        return;
    
    [self.bubbleData addObject:chatData];
    
    loadingView.hidden = YES;
    //    [activityIndicator stopAnimating];
    
    [self reloadData:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    //[self dismissModalViewControllerAnimated:YES];
}

- (void)queryBtnClicked{
    NSLog(@"queryBtnClicked");
    if (!isReady) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"咨询"
                                                        message:@"正在连接医生请稍候"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!isSWT && _questionID && _chatID==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"咨询"
                                                        message:@"正在等待医生回复请稍候"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    /**
     *  @author Zxt, 17-03-30 11:03:09
     *
     *  医爱淘
     *
     *  @return
     */
    if ((isSWT && swtClosed) || (isIAT && isIATquit)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"咨询"
                                                        message:@"本次咨询已经结束"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *oriQuestion = [questionInput text];
    NSString *question = [oriQuestion stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([question length] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"咨询"
                                                        message:@"请输入要咨询的内容"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([question isEqualToString:[CureMeUtils defaultCureMeUtil].lastQueryString]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"咨询"
                                                        message:@"您已咨询过相同问题，请勿重复发送"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (isSWT) {
        [self cdCheckRequest:question];
        return;
    }
    
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
    
    /**
     *  @author Zxt, 17-03-30 11:03:42
     *
     *  如果是医爱淘对话
     */
    if (isIAT){
        [self sendMsgToIAT:question];
        return;
    }
    
    
    if (_chatID==0) {
        [self sendFirstQueryToMed:question];
    }else{
        [self sendMessageToMed:question];
    }
}

//修改私人医生对话机制
- (void)newSendMessageToMed:(NSString *)question{
    [HiChat sendMessage:[NSString stringWithFormat:@"%ld",_doctorID] withBody:question withAttachType:ATTACHMENT_NONE withAttachName:nil withAttachData:nil completion:^(NSError *error){
        if (!error) {
            NSDate *msgTime = [NSDate date];
            
            [self.bubbleData addObject:[NSBubbleData  dataWithText:[NSString stringWithFormat:@"%@", question] andDate:msgTime andType:BubbleTypeMine andImage:nil andTalkerID:0 andCellType:CellTypeDetail]];
            
            [CureMeUtils defaultCureMeUtil].lastQueryString = question;
            questionInput.text = @"";
            [questionInput resignFirstResponder];
            
            // 先ReloadData，确保能够正确初始化TableView的Section
            [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
        }
        else{
            NSLog(@"send message Faild %@",error);
        }
        
    }];
}

- (void)sendMessageToMed:(NSString*)question
{
    // 3. 以下，发送消息
    //NSString *encodeMessage = [question stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodeMessage = urlEncode(question);
    
    //    NSString *encodeMessage = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)message, nil, nil, kCFStringEncodingUTF8);
    // http://n2.medapp.ranknowcn.com:3810/message/post?from=0002&to=0001&data=123123
    
    // 发送消息新请求 action=sendmessage&fromid=xxx&chatid=xxx&msg=xxxxx&img=xxx&hospitalid=xxx
    //        NSString *post = [[NSString alloc] initWithFormat:@"action=sendmessage&fromid=%d&chatid=%d&msg=%@&img=", [CureMeUtils defaultCureMeUtil].userID, _chatID, encodeMessage];
    NSString *post = [[NSString alloc] initWithFormat:@"action=chat_post2&hospitalid=%ld&fromid=%ld&toid=%ld&chatid=%ld&msg=%@&img=&type=text", (long)hospitalID, (long)[CureMeUtils defaultCureMeUtil].userID, (long)_doctorID, (long)_chatID, encodeMessage];
    NSData *response = sendRequest(@"msg.php", post);
    
//    NSString *urlStr = @"http://bd.yiaitao.net/api/msg.php?action=chat_post2&version=3.0";
//    NSString *post = [[NSString alloc] initWithFormat:@"hospitalid=%ld&fromid=%ld&toid=%ld&chatid=%ld&msg=%@&img=&type=text", (long)hospitalID, (long)[CureMeUtils defaultCureMeUtil].userID, (long)_doctorID, (long)_chatID, encodeMessage];
//    
//    NSData *response = sendFullRequest(urlStr, post, nil, NO, NO);
    
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
    
    [self.bubbleData addObject:[NSBubbleData  dataWithText:[NSString stringWithFormat:@"%@", question] andDate:msgTime andType:BubbleTypeMine andImage:nil andTalkerID:0 andCellType:CellTypeDetail]];
    
    [CureMeUtils defaultCureMeUtil].lastQueryString = question;
    questionInput.text = @"";
    [questionInput resignFirstResponder];
    
    // 先ReloadData，确保能够正确初始化TableView的Section
    [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
}

- (void)sendFirstQueryToMed:(NSString*)question
{
    // 发送正式咨询请求
    //NSString *sendQuestion = [question stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *sendQuestion = urlEncode(question);
    NSLog(@"sendQuestion: before encoding: %@ after encoding: %@", question, sendQuestion);
    
    //NSString *encodeAddr = [CureMeUtils defaultCureMeUtil].encodedLocateInfo;
    //    NSString *post = [NSString stringWithFormat:@"action=postquestion&userid=%d&type=%d&typechild=%d&question=%@&img=&addrdetail=%@&MCC=%@&MNC=%@&LAC=%d&CID=%d", [CureMeUtils defaultCureMeUtil].userID, _officeType, _subOfficeType, sendQuestion, encodeAddr ? encodeAddr : @"",
    //                      [CureMeUtils defaultCureMeUtil].gsmData.mcc,
    //                      [CureMeUtils defaultCureMeUtil].gsmData.mnc,
    //                      [CureMeUtils defaultCureMeUtil].gsmData.lac,
    //                      [CureMeUtils defaultCureMeUtil].gsmData.cellID];
    NSString *post;
    if (_officeType == 98) {
        post = [NSString stringWithFormat:@"action=postquestion&userid=%ld&type=%d&typechild=%d&question=%@&img=&addrdetail=%@",
                (long)[CureMeUtils defaultCureMeUtil].userID,
                10, 98,
                sendQuestion,
                @""];
    }
    else {
        post = [NSString stringWithFormat:@"action=postquestion&userid=%ld&type=%ld&typechild=%ld&question=%@&img=&addrdetail=%@",
                (long)[CureMeUtils defaultCureMeUtil].userID,
                (long)_officeType, (long)_subOfficeType,
                sendQuestion,
                @""];
    }
    NSLog(@"zixun: %@", post);
    NSData *response = sendRequest(@"m.php", post);
    NSDictionary *respDict = parseJsonResponse(response);
    NSNumber *result = [respDict objectForKey:@"result"];
    if (!result || 0 == [result integerValue]) {
        NSString *error = [respDict objectForKey:@"msg"];
        NSLog(@"sendQuestion failed %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送咨询失败"
                                                        message:error
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        //增加一条聊天记录并刷新bubble
        _questionID = [respDict objectForKey:@"msg"];
        [self addUserClientMessage:question msgDate:[NSDate date]];
        [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
        loopGetChatIDTimer = [NSTimer scheduledTimerWithTimeInterval:(loopCount+1) target:self selector:@selector(loopGetChatID:) userInfo:nil repeats:NO];
    }
    
    [CureMeUtils defaultCureMeUtil].lastQueryString = question;
    questionInput.text = @"";
    [questionInput resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  @author Zxt, 17-03-30 11:03:10
 *
 *  医爱淘
 *
 *  @param question <#question description#>
 */

- (void)sendMsgToIAT:(NSString *) question{
    //先过滤
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"%@msgfilter/%ld/%ld",iatao_server_url,(long)[CureMeUtils defaultCureMeUtil].userID,_chatID];
        //NSDictionary *postDic = [NSDictionary dictionaryWithObject:question forKey:@"msg"];
        NSString *post = [[NSString stringWithFormat:@"msg=%@",question] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *response = sendFullRequest(urlStr, post, nil, NO, NO);
        
        dispatch_async(dispatch_get_main_queue(), ^{

            NSDictionary *jsonData = parseJsonResponse(response);
            NSNumber *result = [jsonData objectForKey:@"err"];
            if (result != nil && [result integerValue] == 0) {
                NSString *cleanQuestion = [jsonData objectForKey:@"msg"];
                [self sendFilltedMsg:cleanQuestion];
            }
            else{
            NSString *ermsg = [jsonData objectForKey:@"errmsg"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送咨询失败"
                                                                message:ermsg
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                [alert show];
                return ;
            }

        });
    });
    
}

- (void)sendFilltedMsg :(NSString *) msg{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSString *urlStr = [NSString stringWithFormat:@"%@check?imei=%ld&chatid=%ld&maxid=%ld&md5=%@",iatao_server_url,(long)[CureMeUtils defaultCureMeUtil].userID,(long)_chatID,(long)swtMaxID,md5Str];
        NSString *post = [[NSString stringWithFormat:@"msg=%@",msg] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *response = sendFullRequest(urlStr, post, nil, NO, NO);
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            NSDictionary *jsonData = parseJsonResponse(response);
            NSNumber *result = [jsonData objectForKey:@"err"];
            if (result != nil && [result integerValue] == 0) {
                [self addUserClientMessage:msg msgDate:[NSDate date]];
                [self sendLogRequest:@"forward"];
                [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
                
                [CureMeUtils defaultCureMeUtil].lastQueryString = msg;
                questionInput.text = @"";
                [questionInput resignFirstResponder];
            }
            else{
                NSString *ermsg = [jsonData objectForKey:@"errmsg"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送咨询失败"
                                                                message:ermsg
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                [alert show];
                return ;
            }

        });
    });
}

#pragma mark SWT methods
/**
 *  @author Zxt, 17-04-01 14:04:00
 *
 *  修改接口适配医爱淘查看历史对话
 *  http://yiaitao.lifehealthcare.com/api/mychat?imei=867451022317702&chatid=1662173&history=1（0 最后一条记录 1 所有历史记录）
 */

- (void)initSWTChat {
    _swtUserID = [CureMeUtils defaultCureMeUtil].userSWTID;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //NSString *urlStr = [NSString stringWithFormat:@"api2/mychat/%ld/%ld/1", (long)_swtUserID, (long)_chatSWTID];
        NSString *urlStr;
        NSData *response;
        if ([_chatHistoryType isEqualToString:@"swt"]) {
            urlStr = [NSString stringWithFormat:@"api2/mychat/%ld/%ld/1", (long)_swtUserID, (long)_chatSWTID];
            NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
            response = sendRequestWithFullURLNAP([@"http://exswt.lifehealthcare.com/" stringByAppendingString:urlStr], respDict);
        }
        else{
            urlStr = [NSString stringWithFormat:@"mychat?imei=%ld&chatid=%ld&history=1",(long)[CureMeUtils defaultCureMeUtil].userID,(long)_chatSWTID];
            NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
            response = sendRequestWithFullURLNAP([@"http://yiaitao.lifehealthcare.com/api/" stringByAppendingString:urlStr], respDict);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isQuit)
                return;
            if (response==nil){
                return;
            }
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonData = parseJsonResponse(response);
            if (!jsonData)
            {
                NSLog(@"initSWTChat: %@", strResp);
                return;
            }
            NSNumber *errCode = JsonValue([jsonData objectForKey:@"err"], CLASS_NUMBER);
            if (errCode==nil || [errCode integerValue] != 0){
                return;
            }
            hospitalName = jsonData[@"data"][@"hname"];
            hospitalIntro = jsonData[@"data"][@"hintro"];
            hospitalParams = jsonData[@"data"][@"swt_json"];
            _doctorID = [jsonData[@"data"][@"doctorid"] integerValue];
            if ([_chatHistoryType isEqualToString:@"swt"]) {
                swtMaxID = [hospitalParams[@"maxid"] integerValue];
            }
            else{
                _chatID = _chatSWTID;
            }
            if (swtMaxID==0) {
                if ([_chatHistoryType isEqualToString:@"swt"]) {
                    isReady = YES;
                    isSWT = YES;
                    swtClosed = YES;
                    [self reloadSWTInfoView];
                    NSArray *history = jsonData[@"data"][@"history"];
                    if (history.count>0) {
                        for (NSUInteger i=0;i<history.count;i++) {
                            NSDictionary *msgDict = [history objectAtIndex:i];
                            NSInteger from_id = [msgDict[@"from_id"] integerValue];
                            NSString *message = msgDict[@"message"];
                            NSDate *msgTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[msgDict objectForKey:@"create_at"] integerValue]];
                            if (from_id==1) {
                                [self addSWTDoctorClientMessage:message msgDate:msgTime];
                            }else{
                                [self addUserClientMessage:message msgDate:msgTime];
                            }
                        }
                    }
                    [self addSWTDoctorClientMessage:@"咨询已经结束" msgDate:[NSDate date]];
                }
                else{
                    NSInteger *status = [jsonData[@"data"][@"status"] integerValue];
                     swtMaxID = [jsonData[@"data"][@"maxid"] integerValue];
                    isReady = YES;
                    isIAT = YES;
                    isIATquit = YES;
                    [self reloadSWTInfoView];
                    NSArray *history = jsonData[@"data"][@"history"];
                    if (history.count>0) {
                        for (NSUInteger i=0;i<history.count;i++) {
                            NSDictionary *msgDict = [history objectAtIndex:i];
                            NSInteger from_id = [msgDict[@"from_id"] integerValue];
                            NSString *message = msgDict[@"message"];
                            NSDate *msgTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[msgDict objectForKey:@"create_at"] integerValue]];
                            if (from_id==1) {
                                [self addSWTDoctorClientMessage:message msgDate:msgTime];
                            }else{
                                [self addUserClientMessage:message msgDate:msgTime];
                            }
                        }
                    }
                    if (status != 0) {
                        isIATquit = YES;
                        [self addSWTDoctorClientMessage:@"咨询已经结束" msgDate:[NSDate date]];
                    }
                    else{
                        cdCheckTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(cdCheckRequestIAT:) userInfo:nil repeats:YES];
                        [[NSRunLoop currentRunLoop] addTimer:cdCheckTimer forMode:NSRunLoopCommonModes];

                    }
                }
            }
            else{
                hospitalCookie = jsonData[@"data"][@"swt_json"][@"cookie"];
                isReady = YES;
                if ([_chatHistoryType isEqualToString:@"swt"]) {

                    isSWT = YES;
                    heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(heartBeat:) userInfo:nil repeats:YES];
                    cdCheckTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(cdCheck:) userInfo:nil repeats:YES];
                    [self enterSWT];
                }
//                else{
//                    isIAT = YES;
//                    cdCheckTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(cdCheckRequestIAT:) userInfo:nil repeats:YES];
//                    [[NSRunLoop currentRunLoop] addTimer:cdCheckTimer forMode:NSRunLoopCommonModes];
//                }
                
                [self reloadSWTInfoView];
                NSString *tmp = [hospitalParams[@"welcome"] stringByReplacingOccurrencesOfString:@"%u" withString:@"\\u"];
                tmp = [tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if (!tmp) {
                    tmp = @"";
                }
                welcomeStr = replaceUnicode(tmp);
                NSArray *history = jsonData[@"data"][@"history"];
                if (history.count==0) {
                    [self addDoctorClientMessage:welcomeStr msgDate:[NSDate date]];
                }else{
                    if (tmp.length > 0) {
                        NSDate *firstMsgTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[[history objectAtIndex:0] objectForKey:@"create_at"] integerValue]];
                        [self addSWTDoctorClientMessage:welcomeStr msgDate:firstMsgTime];
                    }
                    for (NSUInteger i=0;i<history.count;i++) {
                        NSDictionary *msgDict = [history objectAtIndex:i];
                        NSInteger from_id = [msgDict[@"from_id"] integerValue];
                        NSString *message = msgDict[@"message"];
                        NSDate *msgTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[msgDict objectForKey:@"create_at"] integerValue]];
                        if (from_id==1) {
                            [self addSWTDoctorClientMessage:message msgDate:msgTime];
                        }else{
                            [self addUserClientMessage:message msgDate:msgTime];
                        }
                    }
                }
            }
            [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
        });
    });
}

- (void)cancelSWT:(NSTimer *)timer {
    if (isSWT){
        cancelSWTTimer = nil;
        return;
    }
    if (hasCancelSWT) return;
    hasCancelSWT = YES;
    [self chooseHospital:@"second"];
}

- (void)cancelSWTForError {
    if (isSWT) return;
    if (hasCancelSWT) return;
    [cancelSWTTimer invalidate];
    cancelSWTTimer = nil;
    hasCancelSWT = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self chooseHospital:@"second"];
        });
    });
}

- (void)getSWTuserid {
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
    if (hasCancelSWT)
        return;
    if (isQuit)
        return;
    NSInteger SWTID = [CureMeUtils defaultCureMeUtil].userSWTID;
    if (SWTID>0){
        _swtUserID = SWTID;
        [self connectSWT];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"api2/userid/%ld/medapp/ios", (long)[CureMeUtils defaultCureMeUtil].userID];
        NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
        NSData *response = sendRequestWithFullURLNAP([@"http://exswt.ranknowcn.com/" stringByAppendingString:urlStr], respDict);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hasCancelSWT)
                return;
            if (isQuit)
                return;
            if (response==nil){
                [self cancelSWTForError];
                return;
            }
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonData = parseJsonResponse(response);
            if (!jsonData)
            {
                NSLog(@"getSWTuserid: %@", strResp);
                [self cancelSWTForError];
                return;
            }
            NSNumber *errCode = JsonValue([jsonData objectForKey:@"err"], CLASS_NUMBER);
            if (errCode==nil || [errCode integerValue] != 0){
                [self cancelSWTForError];
                return;
            }
            _swtUserID = [jsonData[@"data"][@"id"] integerValue];
            NSNumber *swtID = [[NSNumber alloc] initWithInteger:_swtUserID];
            [[NSUserDefaults standardUserDefaults] setObject:swtID forKey:USER_SWT_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self connectSWT];
        });
    });
}

- (void)connectSWT {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"api2/connectswt/%ld/%ld/%ld/%ld/%ld?imei=%@", (long)[CureMeUtils defaultCureMeUtil].userSWTID, (long)cityid, (long)_officeType, (long)city2id,(long)_subOfficeType,[CureMeUtils defaultCureMeUtil].UDID];
        NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
        NSData *response = sendRequestWithFullURLNAP([@"http://exswt.ranknowcn.com/" stringByAppendingString:urlStr], respDict);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hasCancelSWT)
                return;
            if (isQuit)
                return;
            if (response==nil){
                [self cancelSWTForError];
                return;
            }
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonData = parseJsonResponse(response);
            if (!jsonData)
            {
                NSLog(@"connectSWT: %@", strResp);
                [self cancelSWTForError];
                return;
            }
            NSNumber *errCode = JsonValue([jsonData objectForKey:@"err"], CLASS_NUMBER);
            if (errCode==nil || [errCode integerValue] != 0){
                [self cancelSWTForError];
                return;
            }
            NSInteger acceptFlag = [jsonData[@"data"][@"accept"] integerValue];
            if (acceptFlag==0)
            {
                [self cancelSWTForError];
                return;
            }
            hospitalName = jsonData[@"data"][@"hname"];
            hospitalIntro = jsonData[@"data"][@"hintro"];
            hospitalCookie = jsonData[@"data"][@"cookie"];
            hospitalUrl = jsonData[@"data"][@"url"];
            _chatSWTID = [jsonData[@"data"][@"chatid"] integerValue];
            SWT_url = jsonData[@"data"][@"swturl"];
            
            [self getUrlBody];
        });
    });
}

- (void)getUrlBody {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = hospitalUrl;
        NSDictionary *additionalHeader = nil;
        additionalHeader = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"appid", hospitalCookie, @"Cookie", nil];
        NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
        NSData *response = sendGetReqWithHeaderAndRespDict(urlStr, additionalHeader, respDict, false);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hasCancelSWT)
                return;
            if (isQuit)
                return;
            if (response==nil){
                [self cancelSWTForError];
                return;
            }
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            hospitalUrlBody = strResp;
            [self startSWT];
        });
    });
}

- (void)startSWT {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //NSString *urlStr = [NSString stringWithFormat:@"http://exswt.ranknowcn.com/api2/startswt/%ld?body=%@", (long)_chatSWTID, urlEncode(hospitalUrlBody)];
        NSString *urlStr = [NSString stringWithFormat:@"http://exswt.ranknowcn.com/api2/startswt/%ld", (long)_chatSWTID];
        
        NSDictionary *additionalHeader = nil;
        additionalHeader = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"appid", hospitalCookie, @"Cookie", nil];
        NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
        NSData *response = sendGetReqWithHeaderAndRespDict(urlStr, additionalHeader, respDict, false);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hasCancelSWT)
                return;
            if (isQuit)
                return;
            if (response==nil){
                [self cancelSWTForError];
                return;
            }
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonData = parseJsonResponse(response);
            if (!jsonData)
            {
                NSLog(@"startSWT: %@", strResp);
                [self cancelSWTForError];
                return;
            }
            NSNumber *errCode = JsonValue([jsonData objectForKey:@"err"], CLASS_NUMBER);
            if (errCode==nil || [errCode integerValue] != 0){
                [self cancelSWTForError];
                return;
            }
            hospitalParams = jsonData[@"data"];
            NSString *action = hospitalParams[@"action"];
            if (action && ([action isEqualToString:@"forward"] || [action isEqualToString:@"directmed"])) {
                [self cancelSWTForError];
                return;
            }
            swtMaxID = [hospitalParams[@"maxid"] integerValue];
            isReady = YES;
            isSWT = YES;
            heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(heartBeat:) userInfo:nil repeats:YES];
            cdCheckTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(cdCheck:) userInfo:nil repeats:YES];
            [self enterSWT];
            
            [self reloadSWTInfoView];
            _doctorID = [hospitalParams[@"doctorid"] integerValue];
            
            NSArray *outAry = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%ld",(long)_chatSWTID]];
            if (outAry) {
                for (NSData *chatData in outAry) {
                    NSBubbleData *data = (NSBubbleData *)[NSKeyedUnarchiver unarchiveObjectWithData:chatData];
                    if (data) {
                        [self.bubbleData addObject:data];
                    }
                }
            }
            
            NSString *tmp = [hospitalParams[@"welcome"] stringByReplacingOccurrencesOfString:@"%u" withString:@"\\u"];
            tmp = [tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (tmp && !outAry) {
                welcomeStr = replaceUnicode(tmp);
                [self addSWTDoctorClientMessage:welcomeStr msgDate:[NSDate date]];

            }
               [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
        });
    });
}

- (void)cdCheck:(NSTimer *)timer {
    [self cdCheckRequest:@""];
}

- (void)cdCheckRequest:(NSString *)msg
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/LR/CdCheck.aspx", hospitalParams[@"swtdomain"]];
        NSString *post;
        if (msg.length ==0) {
            post = [NSString stringWithFormat:@"pp=%@&maxid=%ld&lng=cn&id=%@&_text=&sid1=%@&sid=%@", hospitalParams[@"pp"], (long)swtMaxID, hospitalParams[@"id"], hospitalParams[@"sid"],hospitalParams[@"sid"]];
        }else{
            NSString *txt = [NSString stringWithFormat:@",ACT_TEMP|1|,%@", msg];
            NSString *encodedTXT = urlEncode(txt);
            post = [NSString stringWithFormat:@"pp=%@&maxid=%ld&lng=cn&id=%@&_text=%@&sid=%@&sid1=%@", hospitalParams[@"pp"], (long)swtMaxID, hospitalParams[@"id"], encodedTXT, hospitalParams[@"sid"],hospitalParams[@"sid"]];
        }
        urlStr = [NSString stringWithFormat:@"%@?%@", urlStr, post];
        NSDictionary *additionalHeader = nil;
        additionalHeader = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"appid", hospitalCookie, @"Cookie",SWT_url,@"Referer", nil];
        NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
        NSData *response = sendGetReqWithHeaderAndRespDict(urlStr, additionalHeader, respDict, false);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isQuit)
                return;
            if (response==nil){
                return;
            }
            if (msg.length>0) {
                [CureMeUtils defaultCureMeUtil].lastQueryString = msg;
                questionInput.text = @"";
                [questionInput resignFirstResponder];
                [self addUserClientMessage:msg msgDate:[NSDate date]];
                [self sendMsgOK:msg maxid:swtMaxID userid:_swtUserID];
            }
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *urlStr = [NSString stringWithFormat:@"http://exswt.lifehealthcare.com/api2/msgreceiver/%ld/%ld",(long)[CureMeUtils defaultCureMeUtil].userID,(long)[CureMeUtils defaultCureMeUtil].userSWTID];
                NSString *post = [NSString stringWithFormat:@"data=%@&maxid=%ld",strResp,(long)swtMaxID];
                NSData *receiveData = sendRequestWithFullURL(urlStr, post);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!receiveData) {
                        return ;
                    }
                    NSDictionary *receiveDic = parseJsonResponse(receiveData);
                    NSNumber *res = [receiveDic objectForKey:@"err"];
                    if ([res integerValue] == 0) {
                        id data = [receiveDic objectForKey:@"data"];
                        if (!data || [data isEqual:[NSNull null]]) {
                            return;
                        }
                        NSArray *listAry = [[receiveDic objectForKey:@"data"] objectForKey:@"list"];
                        NSDictionary *dataList = [listAry firstObject];
                        NSString *message = [dataList objectForKey:@"message"];
                        if (message.length == 0) {
                            if (msg.length>0) {
                                [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
                            }
                            return;
                        }
                        swtMaxID = [[[receiveDic objectForKey:@"data"] objectForKey:@"maxid"] integerValue];;
                        [self addSWTDoctorClientMessage:message msgDate:[NSDate date]];
                        [self sendMsgOK:message maxid:swtMaxID userid:_doctorID];
                        if (message.length>0) {
                            [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
                        }
                    }else{
                        [self closeSWT];
                    }
                });
                
            });
            //            strResp = [strResp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            //            NSString *tmp = [strResp stringByReplacingOccurrencesOfString:@"%u" withString:@"\\u"];
            //            tmp = [tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //            NSString *decodedResp = replaceUnicode(tmp);
            //            if ([decodedResp isEqualToString:@",noinput"]) {
            //                if (msg.length>0) {
            //                    [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
            //                }
            //                return;
            //            }
            //            BOOL hasNewMsg = NO;
            //
            //            NSArray *firstSplit = [decodedResp componentsSeparatedByString:@",|"];
            //            if (firstSplit.count==0) {
            //                if (msg.length>0) {
            //                    [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
            //                }
            //                return;
            //            }
            //            for(NSString *line in firstSplit) {
            //                if ([line rangeOfString:@"|direct|"].location != NSNotFound || [line rangeOfString:@"|close|"].location != NSNotFound || [line rangeOfString:@"|end|"].location != NSNotFound) {
            //                        [self closeSWT];
            //                        return;
            //                }
            //                NSArray *secondSplit = [line componentsSeparatedByString:@"||"];
            //                if (secondSplit.count==1)
            //                    continue;
            //                if (secondSplit.count==2){
            //                    for(NSString *fid in secondSplit) {
            //                        NSArray *params = [fid componentsSeparatedByString:@"|"];
            //                        if (params.count==3) {
            //                            NSString *doctorMsg = [params objectAtIndex:0];
            //                            //过滤掉html标签
            //                            doctorMsg = removeHTML(doctorMsg);
            //                            doctorMsg = [doctorMsg stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            //                            swtMaxID = [[params objectAtIndex:2] integerValue];
            //                            [self addSWTDoctorClientMessage:doctorMsg msgDate:[NSDate date]];
            //                            [self sendMsgOK:doctorMsg maxid:swtMaxID userid:_doctorID];
            //                            hasNewMsg = YES;
            //                        }
            //                    }
            //                }
            //            }
        });
    });
}


/**
 *  @author Zxt, 17-03-29 15:03:56
 *
 *  医爱淘轮训取消息
 *
 *  @param timer 3秒1次
 */
//------------------------
- (void)cdCheckRequestIAT:(NSTimer *)timer{
    
    if (isUserActive == NO) {
        [cdCheckTimer invalidate];
        cdCheckTimer = nil;
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"%@check?imei=%ld&chatid=%ld&maxid=%ld&md5=%@&inputtext=%@&inputstate=%ld",iatao_server_url,(long)[CureMeUtils defaultCureMeUtil].userID,(long)self.chatID,(long)swtMaxID,md5Str,[questionInput.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],(long)(questionInput.text.length>0?1:0)];
        NSData *response = sendGetReqWithHeaderAndRespDict(urlStr, nil, nil, NO);
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if (response == nil) {
                NSLog(@"cdCheck response faild");
                return ;
            }
            
            NSDictionary *jsonData = parseJsonResponse(response);
            if (jsonData == nil) {
                NSLog(@"cdCheck jsonData faild");
                return;
            }
            NSNumber *result = JsonValue([jsonData objectForKey:@"err"], CLASS_NUMBER);
            if (result == nil) {
                NSLog(@"cdCheck result faild");
            }
            if ([result integerValue] != 0) {
                NSLog(@"cdCheck faild errMsg:%@",JsonValue([jsonData objectForKey:@"ermsg"],CLASS_STRING));
                return;
            }
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"%@",replaceUnicode(strResp));
            
            NSDictionary *chatData = JsonValue([jsonData objectForKey:@"data"], CLASS_DICTIONARY);
            NSArray *chatList = JsonValue([chatData objectForKey:@"list"],CLASS_ARRAY);
            NSDictionary *lastChatDic = JsonValue([chatList lastObject],CLASS_DICTIONARY);
            NSString *chatStr = JsonValue([lastChatDic objectForKey:@"msg"], CLASS_STRING);
            NSNumber *newMaxid = JsonValue([chatData objectForKey:@"maxid"],CLASS_NUMBER);
            if (chatStr.length>0) {
                [self addDoctorClientMessage:chatStr msgDate:[NSDate date]];
                
                [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
            }
            else return;
            
            if (newMaxid != nil) {
                swtMaxID = [newMaxid integerValue];
                [self sendLogRequest:@"newmsg"];
            }            
        });
    });
}
//------------------------
- (void)heartBeat:(NSTimer *)timer {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"http://exswt.ranknowcn.com/api2/heartbeat/%ld", (long)_chatSWTID];
        NSDictionary *additionalHeader = nil;
        additionalHeader = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"appid", hospitalCookie, @"Cookie", nil];
        NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
        sendGetReqWithHeaderAndRespDict(urlStr, additionalHeader, respDict, false);
    });
}

- (void)sendMsgOK:(NSString *)message maxid:(NSInteger)maxid userid:(NSInteger)userid {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"http://exswt.ranknowcn.com/api2/sendmsgok?chatid=%ld", (long)_chatSWTID];
        NSDate *now = [NSDate date];
        NSString *post = [NSString stringWithFormat:@"msg=%@&maxid=%ld&time=%ld&userid=%ld", urlEncode(message), (long)maxid,(long)now.timeIntervalSince1970, (long)userid];
        urlStr = [NSString stringWithFormat:@"%@&%@", urlStr, post];
        NSDictionary *additionalHeader = nil;
        additionalHeader = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"appid", hospitalCookie, @"Cookie", nil];
        NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
        sendGetReqWithHeaderAndRespDict(urlStr, additionalHeader, respDict, false);
    });
}

- (void)closeSWT {
    swtClosed = YES;
    if (heartBeatTimer)
    {
        [heartBeatTimer invalidate];
        heartBeatTimer = nil;
    }
    if (cdCheckTimer)
    {
        [cdCheckTimer invalidate];
        cdCheckTimer = nil;
    }
    [self addSWTDoctorClientMessage:@"咨询已经结束" msgDate:[NSDate date]];
    [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"http://exswt.ranknowcn.com/api2/closechat/%ld", (long)_chatSWTID];
        NSDictionary *additionalHeader = nil;
        additionalHeader = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"appid", hospitalCookie, @"Cookie", nil];
        NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
        sendGetReqWithHeaderAndRespDict(urlStr, additionalHeader, respDict, false);
    });
}

- (void)enterSWT {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"http://exswt.ranknowcn.com/api2/log/enter/%ld", (long)[CureMeUtils defaultCureMeUtil].userSWTID];
        NSDictionary *additionalHeader = nil;
        additionalHeader = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"appid", nil];
        NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
        sendGetReqWithHeaderAndRespDict(urlStr, additionalHeader, respDict, false);
    });
}

- (void)leaveSWT {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"http://exswt.ranknowcn.com/api2/log/leave/%ld", (long)[CureMeUtils defaultCureMeUtil].userSWTID];
        NSDictionary *additionalHeader = nil;
        additionalHeader = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"appid", nil];
        NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
        sendGetReqWithHeaderAndRespDict(urlStr, additionalHeader, respDict, false);
    });
}

#pragma mark MedApp methods

- (void)loopGetChatID:(NSTimer *)timer {
    loopCount += 1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"api/m.php?action=questionidgetanswerchat&questionid=%@", [_questionID stringValue]];
        NSData *response = sendRequestWithFullURL([@"http://bd.yiaitao.net/" stringByAppendingString:urlStr], @"");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isQuit)
                return;
            if (response==nil){
                loopGetChatIDTimer = [NSTimer scheduledTimerWithTimeInterval:(loopCount+1) target:self selector:@selector(loopGetChatID:) userInfo:nil repeats:NO];
                return;
            }
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonData = parseJsonResponse(response);
            if (!jsonData)
            {
                loopGetChatIDTimer = [NSTimer scheduledTimerWithTimeInterval:(loopCount+1) target:self selector:@selector(loopGetChatID:) userInfo:nil repeats:NO];
                return;
            }
            
            NSNumber *result = JsonValue([jsonData objectForKey:@"result"], CLASS_NUMBER);
            if (result==nil){
                loopGetChatIDTimer = [NSTimer scheduledTimerWithTimeInterval:(loopCount+1) target:self selector:@selector(loopGetChatID:) userInfo:nil repeats:NO];
                return;
            }
            if ([result integerValue] != 1) {
                NSLog(@"loopGetChatID: %@", strResp);
                loopGetChatIDTimer = [NSTimer scheduledTimerWithTimeInterval:(loopCount+1) target:self selector:@selector(loopGetChatID:) userInfo:nil repeats:NO];
                return;
            }else{
                _chatID = [jsonData[@"data"][@"chatid"] integerValue];
                NSString* answerStr = jsonData[@"data"][@"answer"];
                NSDate *answerdate = convertDateFromString(jsonData[@"data"][@"answerdate"], @"yyyy-MM-dd HH:mm:ss");
                [self addDoctorClientMessage:answerStr msgDate:answerdate];
                [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
                NSInteger lastDoctorID = _doctorID;
                _doctorID = [jsonData[@"data"][@"did"] integerValue];
                if (_doctorID!=lastDoctorID) {
                    [self refreshDoctorInfo:_doctorID];
                }
                //addrdetail 医院坐标?
                loopGetChatIDTimer = nil;
                //轮询新的消息，这时候用户也可以正式聊天了
                [NSThread detachNewThreadSelector:@selector(threadDetectReplies) toTarget:self withObject:nil];
            }
        });
    });
}

- (void)refreshDoctorInfo:(NSInteger)doctID
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"api/m.php?action=doctorinfo&doctorid=%ld", (long)doctID];
        NSData *response = sendRequestWithFullURL([@"http://new.medapp.ranknowcn.com/" stringByAppendingString:urlStr], @"");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isQuit)
                return;
            if (response==nil){
                return;
            }
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonData = parseJsonResponse(response);
            if (!jsonData)
            {
                return;
            }
            
            NSNumber *result = JsonValue([jsonData objectForKey:@"result"], CLASS_NUMBER);
            if (result==nil)
                return;
            if ([result integerValue] != 1) {
                NSLog(@"refreshDoctorInfo: %@", strResp);
                return;
            }else{
                if (doctID != _doctorID)
                    return;
                NSDictionary *doctorInfo = [jsonData objectForKey:@"msg"];
                _doctor = [[Doctor alloc] init];
                [[CureMeUtils defaultCureMeUtil] parseDoctorInfoFromJson:doctorInfo andDoctor:_doctor];
                doctorName = jsonData[@"msg"][@"name"];
                doctorTag = jsonData[@"msg"][@"title"];
                hospitalID = [jsonData[@"msg"][@"hid"] integerValue];
                hospitalName = jsonData[@"msg"][@"hname"];
                dpicKey = jsonData[@"msg"][@"pic"];
                [[self imageDownloader] addImageKey:dpicKey andSizeType:@"150"];
                // 开启图片下载器
                [[self imageDownloader] startDownload];
                [self reloadInfoView];
            }
        });
    });
}

- (void)chooseHospital:(NSString*)step
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"api/m.php?action=citytypegethospitalinfo&step=%@", step];
        NSString *post = [NSString stringWithFormat:@"addrdetail=%@&token=%@&type=%ld&typechild=%ld&imei=%@", [CureMeUtils defaultCureMeUtil].encodedLocateInfo, nil, (long)self.officeType, (long)self.subOfficeType,[CureMeUtils defaultCureMeUtil].UDID];
        NSData *response = sendRequestWithFullURL([@"http://new.medapp.ranknowcn.com/" stringByAppendingString:urlStr], post);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isQuit)
                return;
            if (response==nil){
                return;
            }
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonData = parseJsonResponse(response);
            if (!jsonData)
            {
                return;
            }
            
            NSNumber *result = JsonValue([jsonData objectForKey:@"result"], CLASS_NUMBER);
            if (result==nil)
                return;
            
            /**
             *  @author Zxt, 17-03-27 16:03:59
             *
             *  新增医爱淘对话
             */
            if (_isAllowToiatao == YES) {
                //没有账号创建临时账号
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
                
                [self isAllowToConnectIatao:[jsonData[@"city"] integerValue] and:[jsonData[@"city2"] integerValue]];
                
                return;
            }
            if ([result integerValue] != 1) {
                NSLog(@"chooseHospital: %@", strResp);
                if ([step isEqualToString:@"first"]){
                    //connect to SWT
                    cityid = [jsonData[@"city"] integerValue];
                    city2id = [jsonData[@"city2"] integerValue];
                    cancelSWTTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(cancelSWT:) userInfo:nil repeats:NO];
                    [self getSWTuserid];
                }
                return;
            }else{
                _doctorID = [jsonData[@"data"][0][@"did"] integerValue];
                doctorName = jsonData[@"data"][0][@"dname"];
                doctorTag = jsonData[@"data"][0][@"dtitle"];
                hospitalID = [jsonData[@"data"][0][@"hid"] integerValue];
                hospitalName = jsonData[@"data"][0][@"hname"];
                welcomeStr = jsonData[@"data"][0][@"welcome"];
                dpicKey = jsonData[@"data"][0][@"dpic"];
                [[self imageDownloader] addImageKey:dpicKey andSizeType:@"150"];
                // 开启图片下载器
                [[self imageDownloader] startDownload];
                [self reloadInfoView];
                [self addDoctorClientMessage:welcomeStr msgDate:[NSDate date]];
                [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
                isSWT = NO;
                isReady = YES;
            }
        });
    });
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

- (UIImage *)doctorHeadImageWithImageKey:(NSString *)imageKey
{
    if (!doctorImages || doctorImages.count <= 0)
        return nil;
    
    return [doctorImages objectForKey:[[NSString alloc] initWithFormat:@"%@-%@", imageKey, @"70"]];
}

- (void)reloadData:(NSNumber *)newScrollAdjustType
{
    [self.bubbleTable reloadData];
    loadingView.hidden = YES;
    //    [activityIndicator stopAnimating];
    
    if (newScrollAdjustType && newScrollAdjustType.integerValue == NSCROLLNONE)
        return;
    
    // 如果是查看别人聊天，则不滚动到最底部
    if (_chatUserID != [CureMeUtils defaultCureMeUtil].userID) {
        return;
    }
    
    CGPoint newPosition = self.bubbleTable.contentOffset;
    NSLog(@"contentOffset x: %.2f y: %.2f", newPosition.x, newPosition.y);
    NSLog(@"contentSize width: %.2f height: %.2f", self.bubbleTable.contentSize.width, self.bubbleTable.contentSize.height);
    if (self.bubbleTable.contentSize.height >= SCREEN_HEIGHT-64-46-40) {
        newPosition.y = self.bubbleTable.contentSize.height - (SCREEN_HEIGHT-64-46-40);
    }
    
    [self.bubbleTable setContentOffset:newPosition animated:YES];
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
        [queryVC setHospitalID:hospitalID];
        [queryVC setHospitalName:hospitalName];
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
        NSLog(@"CMNewQueryViewController showHospitalMapPage coordinate invalid");
        return;
    }
    
    MapViewController *mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    
    [mapVC setHospitalName:_doctor.hospitalName];
    float lat = _hospitalLatitude - 0.0062;
    float lot = _hospitalLongitude - 0.0064;
    [mapVC setLatitude:lat];
    [mapVC setLongitude:lot];
    //[mapVC setLatitude:_hospitalLatitude];
    //[mapVC setLongitude:_hospitalLongitude];
    
    [self.navigationController pushViewController:mapVC animated:YES];
}

#pragma mark - UINewBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UINewBubbleTableView *)tableView
{
    return [self.bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UINewBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    //    NSLog(@"BubbleTableView delegate dataForRow: %d %@", row, [bubbleData objectAtIndex:row]);
    return [self.bubbleData objectAtIndex:row];
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
    if ([imageKey isEqualToString:dpicKey]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            doctorImg.image = image;
        });
    }
    
//    [self performSelectorOnMainThread:@selector(reloadData:) withObject:[[NSNumber alloc] initWithInt:SCROLLNONE] waitUntilDone:NO];
    
}

- (void)allImageComplete
{
    //[self performSelectorOnMainThread:@selector(reloadData:) withObject:[[NSNumber alloc] initWithInt:SCROLLNONE] waitUntilDone:NO];
}

#pragma mark 医爱淘对话流程
/**
 *  @author Zxt, 17-03-27 17:03:48
 *
 *  是否可以分配到医爱淘
 *
 *  @return city1 省 city2 市 return 是否允许
 */
- (void)isAllowToConnectIatao:(NSInteger) city1 and:(NSInteger) city2{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        NSString *urlStr = [NSString stringWithFormat:@"%@where?imei=%ld&city1=%ld&city2=%ld&office1=%ld&office2=%ld&md5=%@&pn=%@&source=apple&app=1&newimei=%@&version=3.3",iatao_server_url,(long)[CureMeUtils defaultCureMeUtil].userID,(long)city1,(long)city2,(long)self.officeType,(long)self.subOfficeType,md5Str,nil,[CureMeUtils defaultCureMeUtil].UDID];
        
        NSData *response = sendGetReqWithHeaderAndRespDict(urlStr, nil, nil, NO);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response == nil) {
                _isAllowToiatao = NO;
                [self chooseHospital:@"first"];
                return ;
            }
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"%@",replaceUnicode(strResp));
            
            NSDictionary *jsonData = parseJsonResponse(response);
            if (!jsonData)
            {
                _isAllowToiatao = NO;
                [self chooseHospital:@"first"];
                return ;
            }
            NSNumber *error = JsonValue([jsonData objectForKey:@"err"], CLASS_NUMBER);
            if (error == nil) {
                _isAllowToiatao = NO;
                [self chooseHospital:@"first"];
                return ;
            }
            if ([error integerValue] !=0) {
                _isAllowToiatao = NO;
                [self chooseHospital:@"first"];
                return ;
            }
            NSNumber *result = JsonValue([jsonData objectForKey:@"accept"], CLASS_NUMBER);
            if (result==nil){
                _isAllowToiatao = NO;
                [self chooseHospital:@"first"];
                return ;
            }
            if ([result integerValue] !=1) {
                _isAllowToiatao = NO;
                [self chooseHospital:@"first"];
                return ;
                }
            
            NSString *sellerid = JsonValue([jsonData objectForKey:@"sellerid"], CLASS_STRING);
            [self connectToIatao:sellerid city1:city1 city2:city2];
        });
    });
}

- (void)connectToIatao:(NSString *) sellerid city1:(NSInteger) city1 city2:(NSInteger) city2{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"%@start?imei=%ld&city1=%ld&city2=%ld&office1=%ld&office2=%ld&sellerid=%@&chatid=%ld&pushid=&md5=%@&app=1&source=apple&newimei=%@&version=3.3",iatao_server_url,[CureMeUtils defaultCureMeUtil].userID,(long)city1,(long)city2,(long)self.officeType,(long)self.subOfficeType,sellerid,(long)self.chatID,md5Str,[CureMeUtils defaultCureMeUtil].UDID];
        NSData *response = sendGetReqWithHeaderAndRespDict(urlStr, nil, nil, NO);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response == nil) {
                _isAllowToiatao = NO;
                [self chooseHospital:@"first"];
                return;
            }
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"%@",replaceUnicode(strResp));
            
            NSDictionary *jsonData = parseJsonResponse(response);
            if (!jsonData)
            {
                _isAllowToiatao = NO;
                [self chooseHospital:@"first"];
                return;
            }
            NSNumber *error = JsonValue([jsonData objectForKey:@"err"], CLASS_NUMBER);
            if (error == nil) {
                _isAllowToiatao = NO;
                [self chooseHospital:@"first"];
                return;
            }
            if ([error integerValue] !=0) {
                _isAllowToiatao = NO;
                [self chooseHospital:@"first"];
                return;
            }
            NSDictionary *dataDic = JsonValue([jsonData objectForKey:@"data"],CLASS_DICTIONARY);
            NSNumber *chatIdStr = JsonValue([dataDic objectForKey:@"chatid"],CLASS_NUMBER);
            [self setChatID:[chatIdStr integerValue]];
            hospitalName = JsonValue([dataDic objectForKey:@"hname"],CLASS_STRING);
            swtMaxID = [JsonValue([dataDic objectForKey:@"maxid"], CLASS_NUMBER) integerValue];
            NSArray *listDic = JsonValue([dataDic objectForKey:@"list"], CLASS_ARRAY);
            if (listDic.count>0) {
                doctorName = [listDic[0] objectForKey:@"name"];
                welcomeStr = [listDic[0] objectForKey:@"msg"];
            }
            cdCheckTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(cdCheckRequestIAT:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:cdCheckTimer forMode:NSRunLoopCommonModes];
            [self reloadIATinfoView];
            
            NSArray *outAry = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%ld",_chatID]];
            if (outAry) {
                for (NSData *chatData in outAry) {
                    NSBubbleData *data = (NSBubbleData *)[NSKeyedUnarchiver unarchiveObjectWithData:chatData];
                    if (data) {
                        [self.bubbleData addObject:data];
                    }
                }
            }
            
            if (welcomeStr.length>0 && !outAry) {
                [self addSWTDoctorClientMessage:welcomeStr msgDate:[NSDate date]];
            }
            
            [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
            /**
             *  @author Zxt, 17-04-28 15:04:23
             *
             *  医爱淘没有介绍，重设标题位置；
             */
            CGRect temp = hospitalLabel.frame;
            temp.origin.y = infoView.frame.size.height / 2 - hospitalLabel.frame.size.height/2;
            hospitalLabel.frame = temp;
            
            temp = nameLabel.frame;
            temp.origin.y = hospitalLabel.frame.origin.y;
            nameLabel.frame = temp;
            
            //当前分配为医爱淘
            isIAT = YES;
            isReady = YES;
            [self sendLogRequest:@"enter"];
        });
    });
}

/**
 *  @author Zxt, 17-03-29 18:03:40
 *
 *  医爱淘对话日志
 *
 *  @param string enter进入 leave离开 forward发送 newmsg接收
 *
 *  @return void
 */

- (void)sendLogRequest:(NSString *) logStr{
    NSString *urlPath;
    if ([logStr isEqualToString:@"enter"]) {
        urlPath = @"log/enter";
        
    }
    else if ([logStr isEqualToString:@"leave"]){
        urlPath = @"log/leave";
    }
    else if ([logStr isEqualToString:@"forward"]){
        urlPath = @"log/forward";
    }
    else{
        urlPath = @"log/newmsg";
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@%@/%ld",iatao_server_url,urlPath,(long)[CureMeUtils defaultCureMeUtil].userID];
    NSData *response = sendGetReqWithHeaderAndRespDict(urlStr, nil, nil, NO);
    if (response) {
        NSDictionary *jsonData = parseJsonResponse(response);
        NSNumber *result = JsonValue([jsonData objectForKey:@"err"], CLASS_NUMBER);
        if (result !=nil && [result integerValue] == 0) {
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"%@",replaceUnicode(strResp));
            NSLog(@"success log to %@",logStr);
        }
    }
}
#pragma mark same chat pull history
- (void)threadPullHistory{
    
}

- (NSString*)getmd5WithString:(NSString *)string

{
    const char* original_str=[string UTF8String];
    
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    
    CC_MD5(original_str, strlen(original_str), digist);
    
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        
        [outPutStr appendFormat:@"%02x", digist[i]];// 小写 x 表示输出的是小写 MD5 ，大写 X 表示输出的是大写 MD5
    }
    
    return [outPutStr uppercaseString];
    
}
@end
