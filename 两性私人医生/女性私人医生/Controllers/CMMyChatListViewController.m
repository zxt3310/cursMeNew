//
//  CMMyChatListViewController.m
//  私密健康医生
//
//  Created by Tim on 13-1-20.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMMyChatListViewController.h"
#import "LoginViewController.h"

#import "BubbleViewController.h"
#import "KGModal.h"
#import "CMAlertViewController.h"
#import "CMCustomViews.h"
#import "CMNewQueryViewController.h"


@interface CMMyChatListViewController ()

@end

@implementation CMMyChatListViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        hasShownLoginViewController = false;
        _isMainTabController = false;
        isLoadingDataInBackground = false;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];

    if (_refreshHeaderView == nil) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.listTableView.bounds.size.height, self.listTableView.frame.size.width, self.listTableView.bounds.size.height)];
        _refreshHeaderView.delegate = self;
        [self.listTableView addSubview:_refreshHeaderView];
    }
    [_refreshHeaderView refreshLastUpdatedDate];

    [self.listTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
//    // 设置背景“无数据”View可见
//    super.noDataBgView.hidden = NO;
    
    // 医生打分ViewController
    markDoctorViewController = [[CMMarkDoctorViewController alloc] initWithNibName:@"CMMarkDoctorViewController" bundle:nil];
    markDoctorViewController.delegate = self;
    
    // AlertViewController
    alertViewController = [[CMAlertViewController alloc] initWithNibName:@"CMAlertViewController" bundle:nil];
    
    // 接收未读消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfUpdateUnreadMsgCount:) name:NTF_UNREADMSGCOUNT_UPDATED object:nil];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];

    float topY = 140;
    if ([UIScreen mainScreen].bounds.size.height > 480.0) {
        topY += 40;
    }
    loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 35, topY, 80, 70)];
    loadingView.hidden = YES;
    [self.listTableView addSubview:loadingView];
    [self.listTableView sendSubviewToBack:loadingView];

    if (IOS_VERSION >= 7.0) {
        CGRect tableFrame = self.listTableView.frame;
        //tableFrame.origin.y = 20 + NAVIGATIONBAR_HEIGHT;
        //tableFrame.size.height = SCREEN_HEIGHT - 20 - NAVIGATIONBAR_HEIGHT - 50;
        tableFrame.size.height = SCREEN_HEIGHT - (FitIpX(49)) - (FitIpX(64));
        self.listTableView.frame = tableFrame;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_isMainTabController) {
        self.tabBarController.navigationItem.leftBarButtonItem = nil;
        self.tabBarController.navigationItem.rightBarButtonItem = nil;
        self.tabBarController.navigationItem.leftBarButtonItems = nil;
        self.tabBarController.navigationItem.rightBarButtonItems = nil;
        self.tabBarController.navigationItem.title = @"我的咨询";
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.title = @"我的咨询";
    }
    
    // 如果切换用户登录
//    if (lastLoginUserID != [CureMeUtils defaultCureMeUtil].userID && chatInfoArray) {
    // 如果没有正在载入数据，则在准备显示之前清理数据
    if (!isLoadingDataInBackground && chatInfoArray) {
        [chatInfoArray removeAllObjects];
        [self.listTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }

    [super viewWillAppear:animated];
    
    if (IOS_VERSION >= 7.0) {
        CGRect tableFrame = self.listTableView.frame;
        //tableFrame.origin.y = 20 + NAVIGATIONBAR_HEIGHT;
        //tableFrame.size.height = SCREEN_HEIGHT - 20 - NAVIGATIONBAR_HEIGHT - 50;
        tableFrame.size.height = SCREEN_HEIGHT - (FitIpX(49)) - (FitIpX(64));
        self.listTableView.frame = tableFrame;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (IOS_VERSION >= 7.0) {
        [self.listTableView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    }
    
    // 如果未登录，但已经显示过一次登录页面
//    if (![CureMeUtils defaultCureMeUtil].hasLogin && !hasShownLoginViewController) {
//        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//        [self.navigationController pushViewController:loginVC animated:YES];
//        hasShownLoginViewController = true;
//        return;
//    }

    // 如果已登录，并且本次登录ID不同于上次登录ID
//    if ([CureMeUtils defaultCureMeUtil].hasLogin && lastLoginUserID != [CureMeUtils defaultCureMeUtil].userID) {

    // 如果已经登录并且没有正在载入数据
    if ([CureMeUtils defaultCureMeUtil].hasLogin) {
        loadingView.hidden = NO;
//        [activityIndicator startAnimating];
        [self performSelectorInBackground:@selector(threadInitMyChatListData) withObject:nil];
        lastLoginUserID = [CureMeUtils defaultCureMeUtil].userID;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma properties
- (UITableView *)listTableView
{
    if (!_listTableView.delegate) {
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
   //     if (IOS_VERSION >= 7.0) {
   //         CGRect tableFrame = _listTableView.frame;
   //         tableFrame.origin.y = 20 + NAVIGATIONBAR_HEIGHT;
   //         tableFrame.size.height = SCREEN_HEIGHT - 20 - NAVIGATIONBAR_HEIGHT - 50;
   //         _listTableView.frame = tableFrame;
   //     }
    }
    
    return _listTableView;
}

- (NoDataBackgroundView *)noDataBgView
{
    if (!_noDataBgView) {
        float topY = 140;
        if ([UIScreen mainScreen].bounds.size.height > 480.0) {
            topY += 40;
        }
        _noDataBgView = [[NoDataBackgroundView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 35, topY, 80, 70)];
        _noDataBgView.hidden = YES;
        [self.listTableView addSubview:_noDataBgView];
        [self.listTableView sendSubviewToBack:_noDataBgView];
    }
    
    return _noDataBgView;
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        return 0;
    }

    if (!chatInfoArray || chatInfoArray.count <= 0) {
        return 0;
    }

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!chatInfoArray || chatInfoArray.count <= 0) {
        return 0;
    }
    
    return chatInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *ChatInfoCell = @"MyChatCell";

    if (!chatInfoArray || indexPath.row >= chatInfoArray.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        
        return cell;
    }
    
    CMMyChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatInfoCell];
    if (!cell) {
        cell = [[CMMyChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChatInfoCell];
    }
    
    [cell setChatInfoUnit:[chatInfoArray objectAtIndex:indexPath.row]];
    MyChatInfoUnit *unit = [chatInfoArray objectAtIndex:indexPath.row];
    // 如果最后一句话是自己说的，并且只有一行，则高度调小
    if ([unit.lastMsgUserType isEqualToString:@"user"] && unit.lastMsg.length < 16) {
        CGRect temp = cell.lineLb.frame;
        temp.origin.y = MYCHATLIST_CELL_MYWORDHEIGHT + MYCHATLIST_CELL_INFOHEIGHT +18;
        cell.lineLb.frame = temp;
        
        temp = cell.deleteBtn.frame;
        temp.origin.y = MYCHATLIST_CELL_MYWORDHEIGHT + MYCHATLIST_CELL_INFOHEIGHT +1;
        cell.deleteBtn.frame = temp;
    }
    else{
        CGRect temp = cell.lineLb.frame;
        temp.origin.y = MYCHATLIST_CELL_WORDHEIGHT + MYCHATLIST_CELL_INFOHEIGHT +18;
        cell.lineLb.frame = temp;
        
        temp = cell.deleteBtn.frame;
        temp.origin.y = MYCHATLIST_CELL_WORDHEIGHT + MYCHATLIST_CELL_INFOHEIGHT +1;
        cell.deleteBtn.frame = temp;
    }
    
    cell.chatListView = self;
    
    [cell setMyChatListViewController:self];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!chatInfoArray || indexPath.row >= chatInfoArray.count) {
        return 0;
    }
    
    MyChatInfoUnit *unit = [chatInfoArray objectAtIndex:indexPath.row];

    // 如果最后一句话是自己说的，并且只有一行，则高度调小
    if ([unit.lastMsgUserType isEqualToString:@"user"] && unit.lastMsg.length < 16) {
        return MYCHATLIST_CELL_MYWORDHEIGHT + MYCHATLIST_CELL_INFOHEIGHT +23;
    }

    return MYCHATLIST_CELL_WORDHEIGHT + MYCHATLIST_CELL_INFOHEIGHT +23;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    // 如果是下拉刷新，则清理所有的数据
    [chatInfoArray removeAllObjects];
    [self.listTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    [self performSelectorInBackground:@selector(threadInitMyChatListData) withObject:nil];

    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0];
}

- (void)doneLoadingTableViewData{
    NSLog(@"===加载完数据");
    //
    [self.listTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.listTableView];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [[NSDate alloc] init];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if (!chatInfoArray || chatInfoArray.count <= indexPath.row) {
        return;
    }
    
    MyChatInfoUnit *unit = [chatInfoArray objectAtIndex:indexPath.row];
    
    // 如果还未创建对话
    if (unit.chatID <= 0 && !unit.isSWT) {
        alertViewController.msgTitle = @"打开聊天详情";
        alertViewController.msgContent = @"当前该咨询暂无医生回复，谢谢。";
//        [alertViewController.view setNeedsDisplay];
        
        [[KGModal sharedInstance] setModalBackgroundColor:[UIColor clearColor]];
        [[KGModal sharedInstance] showWithContentView:alertViewController.view andAnimated:YES];
        return;
    }
    
    if (unit.isSWT) {
        CMNewQueryViewController *chatViewController = [CMNewQueryViewController new];
        [chatViewController setChatSWTID:unit.chatID];
        [chatViewController setChatUserID:[CureMeUtils defaultCureMeUtil].userID];
        if ([unit.chattype isEqualToString:@"swt"]) {
            chatViewController.chatHistoryType = @"swt";
        }
        [self.navigationController pushViewController:chatViewController animated:YES];
        return;
    }

    BubbleViewController *chatViewController = [[BubbleViewController alloc] initWithNibName:@"BubbleViewController" bundle:nil];
    
    [chatViewController setChatOpenType:@"mylists"];
    [chatViewController setChatID:unit.chatID];
    [chatViewController setTalkerID:unit.doctorID];
    [chatViewController setTalkerName:unit.doctorName];
    [chatViewController setChatUserID:[CureMeUtils defaultCureMeUtil].userID];

    [self.navigationController pushViewController:chatViewController animated:YES];
}


#pragma mark ImageDownloadHelperDelegate method:
- (void)imageDownloadComplete:(NSString *)imageKey andType:(NSString *)type andImage:(UIImage*)image
{
    if (!doctorHeadImages) {
        doctorHeadImages = [[NSMutableDictionary alloc] init];
    }
    
    [doctorHeadImages setObject:image forKey:imageKey];
}

- (void)allImageComplete
{
    // ReloadData，确保能够正确初始化TableView的Section
    [self performSelectorOnMainThread:@selector(reloadChatData) withObject:nil waitUntilDone:NO];
}


#pragma mark Thread Methods
- (void)threadInitMyChatListData
{
    @autoreleasepool {
        //由于进入私人医生对话页面后返回会造成列表缩短问题，在暂时未找到原因的情况下设置如下代码临时解决
        if (IOS_VERSION >= 7.0) {
            CGRect tableFrame = self.listTableView.frame;
            tableFrame.size.height = SCREEN_HEIGHT - (FitIpX(49)) - (FitIpX(64));
            self.listTableView.frame = tableFrame;
        }
        // 如果正在加载数据，则不开始新的加载
        if (isLoadingDataInBackground) {
            return;
        }
        isLoadingDataInBackground = true;
        
        if (!chatInfoArray) {
            chatInfoArray = [[NSMutableArray alloc] init];
        }
        
        // action=chathistory &userid=xxxxx &type=xxx
        NSInteger SWTID = [CureMeUtils defaultCureMeUtil].userSWTID;
        NSString *post;
//        if (SWTID<=0) {
//            post = [NSString stringWithFormat:@"action=userallchatlist&userid=%ld", (long)[CureMeUtils defaultCureMeUtil].userID];
//        }else{
//            post = [NSString stringWithFormat:@"action=userallchatlist&userid=%ld&swtuserid=%ld", (long)[CureMeUtils defaultCureMeUtil].userID, (long)SWTID];
//        }
        /**
         *  @author Zxt, 17-03-31 15:03:21
         *
         *  新增医爱淘 接口更新
         */
        NSString *strUrl = [NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/api/m.php?action=userallchatlist&version=3.0"];
        post = [NSString stringWithFormat:@"source=apple&imei=%@&token=%@&version=3.3&appid=7&deviceid=%@&swtuserid=%ld&os=ios&userid=%ld",[CureMeUtils defaultCureMeUtil].UDID,nil,[[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID],[CureMeUtils defaultCureMeUtil].userSWTID,[CureMeUtils defaultCureMeUtil].userID];
        
        NSData *response = sendFullRequest(strUrl, post, nil, NO, NO);
        //NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"threadInitMyChatListData resp: %@", strResp);
        
        // {"result":true,"msg":[
        // {"chatid":90401,"lastmsg":"\u90fd\u76f8\u5173\u5185\u5bb9","lasttime":1358650445,"type":"user","doctorid":367,"doctorinfo":{"did":367,"dname":"ggggg","dpic":"509bb5b64540b","hid":169,"hname":"\u6d4b\u8bd5\u533b\u9662\u4e00","hpic":"50c6ce81cd590"},"totalnum":2,"unreaduum":0},

        NSDictionary *jsonData = parseJsonResponse(response);
        if (!jsonData) {
            NSLog(@"threadInitMyChatListData parse json failed");
            [self performSelectorOnMainThread:@selector(reloadChatData) withObject:nil waitUntilDone:NO];
            _reloading = NO;
            
            return;
        }
        
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (result.integerValue != 1) {
            NSLog(@"threadInitMyChatListData result invalid");
            [self performSelectorOnMainThread:@selector(reloadChatData) withObject:nil waitUntilDone:NO];
            _reloading = NO;
            return;
        }
        
        NSArray *chatsDict = [jsonData objectForKey:@"msg"];
        
        if (!chatsDict || chatsDict.count <= 0) {
            NSLog(@"threadInitMyChatListData chatinfo list empty %@", chatsDict);
            [self performSelectorOnMainThread:@selector(reloadChatData) withObject:nil waitUntilDone:NO];
            _reloading = NO;
            // 显示“无数据”背景提示View
            self.noDataBgView.hidden = NO;
            return;
        }
        
        // 隐藏“无数据”背景提示View
        self.noDataBgView.hidden = YES;
        
        // {"chatid":0,"lastmsg":"afghan","lasttime":1358696389,"type":"user","doctorid":0,"doctorinfo":{"did":0,"dname":"","dpic":"","hid":0,"hname":"","hpic":""},"totalnum":1,"unreadnum":0},
        for (NSDictionary *chatInfo in chatsDict) {
            //            NSLog(@"chatInfo: %@", chatInfo);
            MyChatInfoUnit *infoUnit = [[MyChatInfoUnit alloc] init];
            NSInteger chatID = [[chatInfo objectForKey:@"chatid"] integerValue];
            if (chatID < 0) {
                infoUnit = nil;
                _reloading = NO;
                continue;
            }
            NSString *chattype = [chatInfo objectForKey:@"chattype"];
            if ([chattype containsString:@"swt"]) {
                [infoUnit setIsSWT:YES];
                if ([chattype isEqualToString:@"swt"]){
                    [infoUnit setChattype:@"swt"];
                }
                else{
                    [infoUnit setChattype:@"zlswt"];
                }
                [infoUnit setChatID:chatID];
                NSInteger endTime = [[chatInfo objectForKey:@"lasttime"] integerValue];
                [infoUnit setLastMsgTime:[NSDate dateWithTimeIntervalSince1970:endTime]];
                [infoUnit setUnreadCount:0];
                NSInteger reCount = [[chatInfo objectForKey:@"totalnum"] integerValue];
                [infoUnit setTotalCount:reCount];
                [infoUnit setLastMsgUserType:@"user"];
                NSString *lastMsg = [chatInfo objectForKey:@"lastmsg"];
                [infoUnit setLastMsg:lastMsg];
                [infoUnit setDoctorID:0];
                NSString *hName = [chatInfo objectForKey:@"hname"];
                [infoUnit  setHospitalName:hName];
                /**
                 *  @author Zxt, 17-04-05 12:04:42
                 *
                 *  医爱淘 新增questionID属性
                 */
//                NSInteger questionID = [chatInfo objectForKey:@"questionid"];
                [infoUnit setQuestionID:0];
                [chatInfoArray addObject:infoUnit];
                
            }else{
                [infoUnit setIsSWT:NO];
                [infoUnit setChatID:chatID];
                /**
                 *  @author Zxt, 17-04-05 12:04:42
                 *
                 *  医爱淘 新增questionID属性
                 */
                NSInteger questionID = [[chatInfo objectForKey:@"questionid"] integerValue];
                [infoUnit setQuestionID:questionID];
                
                NSInteger endTime = [[chatInfo objectForKey:@"lasttime"] integerValue];
                [infoUnit setLastMsgTime:[NSDate dateWithTimeIntervalSince1970:endTime]];
                
                NSInteger unread = [[chatInfo objectForKey:@"unreadnum"] integerValue];
    //            NSLog(@"unreadCount: %d", unread);
                [infoUnit setUnreadCount:unread];
                
                NSInteger reCount = [[chatInfo objectForKey:@"totalnum"] integerValue];
                [infoUnit setTotalCount:reCount];
                
                NSString *lastMsgType = [chatInfo objectForKey:@"type"];
                [infoUnit setLastMsgUserType:lastMsgType];
                
                NSString *lastMsg = [chatInfo objectForKey:@"lastmsg"];
    //            NSLog(@"msgHistory: %@", lastMsg);
                
                NSDictionary *msgJson = parseJsonString(lastMsg);
                if (msgJson) {
                    NSString *type = [msgJson objectForKey:@"type"];
                    if ([[type lowercaseString] isEqualToString:@"book"]) {
                        lastMsg = @"【您有预约单信息需要查看】";
                    }
                    else if ([[type lowercaseString] isEqualToString:@"tel"]) {
                        lastMsg = @"【您收到一条医院联系电话，点击聊聊看】";
                    }
                    else if ([[type lowercaseString] isEqualToString:@"map"]) {
                        lastMsg = @"【您收到一条医院地址信息，点击查看详情】";
                    }
                    else {
                        lastMsg = [msgJson objectForKey:@"text"];
                        NSString *imageKey = [msgJson objectForKey:@"image"];
                        if ((!lastMsg || lastMsg.length <= 0) && imageKey && imageKey.length > 0) {
                            lastMsg = @"【图片】";
                        }
                    }
                }
                [infoUnit setLastMsg:lastMsg];
                
                // {"chatid":0,"lastmsg":"afghan","lasttime":1358696389,"type":"user","doctorid":0,"doctorinfo":{"did":0,"dname":"","dpic":"","hid":0,"hname":"","hpic":""},"totalnum":1,"unreadnum":0},
                NSInteger dID = [[chatInfo objectForKey:@"doctorid"] integerValue];
                [infoUnit setDoctorID:dID];
                
                if (infoUnit.doctorID > 0) {
                    NSDictionary *doctorInfo = [chatInfo objectForKey:@"doctorinfo"];
                    if (doctorInfo && doctorInfo.count > 0) {
                        NSString *dName = [doctorInfo objectForKey:@"dname"];
                        [infoUnit setDoctorName:dName];
                        
                        [infoUnit setHospitalID:[[doctorInfo objectForKey:@"hid"] integerValue]];
                        
                        [infoUnit setDoctorImageKey:[doctorInfo objectForKey:@"dpic"]];
                        
                        NSString *dTitle = [doctorInfo objectForKey:@"dtitle"];
                        infoUnit.doctorTitle = dTitle;
                        
                        NSString *hName = [doctorInfo objectForKey:@"hname"];
                        infoUnit.hospitalName = hName;
                    }
                }
                
                // "chatcomment":{"marknum":10,"summary":"\u597d\u8bc4"}},
                NSDictionary *chatComment = [chatInfo objectForKey:@"chatcomment"];
                if (chatComment) {
                    NSNumber *point = [chatComment objectForKey:@"marknum"];
                    if (point) {
                        infoUnit.markPoint = point.integerValue;
                    }
                    
                    infoUnit.markComment = [chatComment objectForKey:@"summary"];
                }
                
                [chatInfoArray addObject:infoUnit];
            }
        }
        
        // 解析新消息通知
        // "unreadcount":{"replycount":"28","channelcount":"1","chatcount":"4"}
        
        // 开始医生头像下载
        [self startImageDownloader];
        
        loadingView.hidden = YES;
//        [activityIndicator stopAnimating];
        [self performSelectorOnMainThread:@selector(reloadChatData) withObject:nil waitUntilDone:NO];
        
        _reloading = NO;
    }
}

- (void)calcCellLastWordViewHeight
{
    if (!chatInfoArray || chatInfoArray.count <= 0) {
        return;
    }
    
    for (MyChatInfoUnit *unit in chatInfoArray) {
        if (![unit.lastMsgUserType isEqualToString:@"user"]) {
            continue;
        }
        
        CGSize wordSize = [unit.lastMsg sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(240, 40) lineBreakMode:NSLineBreakByTruncatingTail];
        unit.lastWordSubViewHeight = MAX(45, 20 + wordSize.height + 4);
    }
}

- (void)reloadChatData
{
    // 更新未读消息数
    [[CureMeUtils defaultCureMeUtil] updateUnreadMsgCount];
    
    isLoadingDataInBackground = false;
    
    loadingView.hidden = YES;
//    [activityIndicator stopAnimating];
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.listTableView];

    [self.listTableView reloadData];
}


/**
 *  @author Zxt, 17-04-01 17:04:24
 *
 *  chatCell删除方法
 *
 *  @return <#return value description#>
 */
- (void)deleteChatCell:(CMMyChatListCell *)cell{
    NSIndexPath  *path = [self.listTableView indexPathForCell:cell];
    MyChatInfoUnit *unit = [chatInfoArray objectAtIndex:path.row];
    NSInteger chatId = unit.chatID;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您是否确定删除对话"  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    
        NSString *urlStr = @"http://new.medapp.ranknowcn.com/api/m.php?action=userallchatlisthide";
        NSString *post = [NSString stringWithFormat:@"imei=%@&token=%@&chatid=%ld&chattype=%@&questionid=%ld&userid=%ld&os=ios",[CureMeUtils defaultCureMeUtil].UDID,nil,chatId,unit.isSWT?unit.chattype:@"medapp",unit.questionID,[CureMeUtils defaultCureMeUtil].userID];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *response = sendRequestWithFullURL(urlStr, post);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (response) {
                    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                    NSLog(@"%@",replaceUnicode(strResp));
                }
                NSDictionary *dataDic = parseJsonResponse(response);
                NSNumber *result = JsonValue([dataDic objectForKey:@"result"], CLASS_NUMBER);
                if ([result integerValue] == 1) {
                    // 如果未登录，但已经显示过一次登录页面
                    if (![CureMeUtils defaultCureMeUtil].hasLogin && !hasShownLoginViewController) {
                        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                        [self.navigationController pushViewController:loginVC animated:YES];
                        hasShownLoginViewController = true;
                        return;
                    }
                    
                    // 如果已经登录并且没有正在载入数据
                    if ([CureMeUtils defaultCureMeUtil].hasLogin) {
                        loadingView.hidden = NO;
                        //        [activityIndicator startAnimating];
                        [chatInfoArray removeAllObjects];
                        [self performSelectorInBackground:@selector(threadInitMyChatListData) withObject:nil];
                        lastLoginUserID = [CureMeUtils defaultCureMeUtil].userID;
                    }
                }
                else{
                    //NSString *errMsg = JsonValue([dataDic objectForKey:@"result"], CLASS_STRING);
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除对话失败"  preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        });
    }];
    [alert addAction:confirm];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark CMMarkDoctorViewControllerDelegate
- (void)pointMarked:(NSInteger)point withComment:(NSString *)comment
{
    if (!markInfoView) {
        return;
    }
    
    // 先更新Unit Data
    markChatInfoUnit.markPoint = point;
    markChatInfoUnit.markComment = comment;

    // 更新对话Cell
    [markInfoView updatePointDisplay];

    // 如果给了好评，则弹Mark App的窗口
    if (point == 10) {
        NSNumber *hasMarkApp = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_MARKAPP];
        if (!hasMarkApp || hasMarkApp.integerValue == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"很乐意为您提供服务" message:@"为了更加贴近您的需求，恭请尊贵的您为我们打分" delegate:self cancelButtonTitle:@"狠心的拒绝" otherButtonTitles:@"善良的答应", nil];
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"MarkDoctorVC cancelbtn click");
    }
    else if (buttonIndex == 1) {
        NSLog(@"MarkDoctorVC confirmbtn click");
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:HAS_MARKAPP];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@", APPLE_APPID];
//        NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", APPLE_APPID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

- (void)showMarkDialog:(MyChatInfoUnit *)chatInfoUnit andInfoView:(CMMyChatInfoView *)infoView
{
    if (!chatInfoUnit || !infoView) {
        return;
    }

    markInfoView = infoView;
    markChatInfoUnit = chatInfoUnit;
    
    // 如果未创建过对话，弹提示不能评论
    if (chatInfoUnit.chatID <= 0) {
        alertViewController.msgTitle = @"评价此医生的对话";
        alertViewController.msgContent = @"由于还未有医生回复您的咨询，此次对话暂不能评价，谢谢。";
        [alertViewController.view setNeedsDisplay];
        
        [[KGModal sharedInstance] setModalBackgroundColor:[UIColor clearColor]];
        [[KGModal sharedInstance] showWithContentView:alertViewController.view andAnimated:YES];
    }
    // 如果已创建对话，弹窗修改
    else {
        markDoctorViewController.chatID = chatInfoUnit.chatID;
        [markDoctorViewController setMarkPoint:chatInfoUnit.markPoint];
        [markDoctorViewController setMarkComment:chatInfoUnit.markComment];
        
        [[KGModal sharedInstance] setModalBackgroundColor:[UIColor clearColor]];
        [[KGModal sharedInstance] setYUpOffset:120];
        [[KGModal sharedInstance] showWithContentView:markDoctorViewController.view andAnimated:YES];
    }
}

- (void)startImageDownloader
{
    @autoreleasepool {
        if (!imageDownloader) {
            imageDownloader = [[ImageDownloadHelper alloc] init];
            [imageDownloader setDelegate:self];
        }
        
        // 添加需要下载的图片
        
        // 添加下载任务
        for (MyChatInfoUnit *myChatInfo in chatInfoArray) {
            NSString *imageKey = myChatInfo.doctorImageKey;
            if (!imageKey || imageKey.length <= 0)
                continue;
            
            [imageDownloader addImageKey:imageKey andSizeType:@"90"];
        }
        
        // 启动下载
        [imageDownloader startDownload];
    }
}

- (UIImage *)getDoctorHeadImage:(NSString *)imageKey
{
    if (!doctorHeadImages || doctorHeadImages.count <= 0)
        return nil;
    
    return [doctorHeadImages objectForKey:imageKey];
}

@end

UIImage* buttonImageFromColor(UIColor *color)
{
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH,44);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


