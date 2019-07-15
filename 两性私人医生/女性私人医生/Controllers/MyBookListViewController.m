//
//  MyBookListViewController.m
//  CureMe
//
//  Created by Tim on 12-11-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "BookDetailInfoViewController.h"
#import "MyBookListViewController.h"
#import "ListInfoBookCell.h"
#import "LoginViewController.h"
#import "CMMyBookListCell.h"
#import "CMCustomViews.h"

@interface MyBookListViewController ()

@end



@implementation MyBookListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isMainTabPage = false;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        isLoadingDataInBackground = false;
        _isMainTabPage = false;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    // 下拉刷新View
    if (_refreshHeaderView == nil) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.listTableView.bounds.size.height, self.listTableView.frame.size.width, self.listTableView.bounds.size.height)];
        _refreshHeaderView.delegate = self;
        [self.listTableView addSubview:_refreshHeaderView];
    }
    [_refreshHeaderView refreshLastUpdatedDate];

	// Do any additional setup after loading the view.
    if (!hospImages)
        hospImages = [[NSMutableDictionary alloc] init];
    
    if (!bookDataList)
        bookDataList = [[NSMutableArray alloc] init];
    
    [self.listTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    imageDownloadHelper = [[ImageDownloadHelper alloc] init];
    imageDownloadHelper.delegate = self;
    
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
        tableFrame.size.height = SCREEN_HEIGHT - 49 - 64;
        self.listTableView.frame = tableFrame;
    }

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_isMainTabPage) {
        self.tabBarController.navigationItem.leftBarButtonItem = nil;
        self.tabBarController.navigationItem.rightBarButtonItem = nil;
        self.tabBarController.navigationItem.leftBarButtonItems = nil;
        self.tabBarController.navigationItem.rightBarButtonItems = nil;
        self.tabBarController.navigationItem.titleView = nil;
        self.tabBarController.navigationItem.title = @"我的预约";
    }
    else {
        self.tabBarItem.title = @"我的预约";
    }
    
//    if (lastLoginUserID != [CureMeUtils defaultCureMeUtil].userID && bookDataList) {
    if (!isLoadingDataInBackground && bookDataList) {
        [bookDataList removeAllObjects];
        [self.listTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }

    [super viewWillAppear:animated];

    if (IOS_VERSION >= 7.0) {
        CGRect tableFrame = self.listTableView.frame;
        //tableFrame.origin.y = 20 + NAVIGATIONBAR_HEIGHT;
        //tableFrame.size.height = SCREEN_HEIGHT - 20 - NAVIGATIONBAR_HEIGHT - 50;
        tableFrame.size.height = SCREEN_HEIGHT - 49 - 64;
        self.listTableView.frame = tableFrame;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (IOS_VERSION >= 7.0) {
        [self.listTableView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    }

    if (![CureMeUtils defaultCureMeUtil].hasLogin && !hasShownLoginPage) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.tabBarController.navigationController pushViewController:loginVC animated:YES];
        hasShownLoginPage = true;
        return;
    }

    if ([CureMeUtils defaultCureMeUtil].hasLogin) {
        loadingView.hidden = NO;
//        [activityIndicator startAnimating];
        [self performSelectorInBackground:@selector(threadInitBookListInfo) withObject:nil];
        lastLoginUserID = [CureMeUtils defaultCureMeUtil].userID;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma properties
- (UITableView *)listTableView
{
    if (!_listTableView.delegate) {
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"MyBookListViewController didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}

- (void)threadInitBookListInfo
{
    @autoreleasepool {
        if (isLoadingDataInBackground) {
            return;
        }
        
        isLoadingDataInBackground = true;
        
        if (!bookDataList) {
            bookDataList = [[NSMutableArray alloc] init];
        }

        NSString *post = [NSString stringWithFormat:@"action=bookinghistory&userid=%ld", (long)[CureMeUtils defaultCureMeUtil].userID];
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"initMyBookInfoData req: %@", strResp);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (result.intValue != 1) {
            NSLog(@"BookingList req failed.");
            isLoadingDataInBackground = false;
            return;
        }
        
        // {"result":true,"msg":[{"id":13,"userid":1000001,"hospitalid":111,"officeid":40,"bday":"1348302651","timerange":"","dateadd":1348122940,"username":"\u963f\u5341\u5206","usertel":"13810607509","memo":"\u5475\u53d1\u751f\u9515\u814c\u5927\u7237","state":"1","oname":"\u6ce8\u5c04\u7f8e\u5bb9","hname":"\u91d1\u7687\u540e\u6574\u5f62\u7f8e\u5bb9\u533b\u9662"}],"unreadcount":{"replycount":"31","channelcount":"0","chatcount":"0"}}
        NSArray *bookArray = [jsonData objectForKey:@"msg"];
        for (NSDictionary *bookInfo in bookArray) {
            NSLog(@"bookInfo: %@", bookInfo);
            BookInfoUnit *bookDetail = [[BookInfoUnit alloc] init];
//            BookDetail *bookDetail = [[BookDetail alloc] init];

            NSNumber *identifier = [bookInfo objectForKey:@"id"];
            bookDetail.bookID = identifier.intValue;

            NSString *bookNumber = [bookInfo objectForKey:@"no"];
            NSLog(@"bookNumber: %@", bookNumber);
            bookDetail.bookNumber = bookNumber;
            
            NSDate *bookTime = [NSDate dateWithTimeIntervalSince1970:[[bookInfo objectForKey:@"bday"] integerValue]];
            bookDetail.bookDate = bookTime;
            
            bookDetail.userName = [bookInfo objectForKey:@"username"];

            bookDetail.hospitalName = [bookInfo objectForKey:@"hname"];
            
            bookDetail.officeName = [bookInfo objectForKey:@"oname"];
            
            bookDetail.doctorReply = [bookInfo objectForKey:@"bookingSummary"];
            
            bookDetail.doctorImageKey = [bookInfo objectForKey:@"hpic"];

            NSNumber *hosID = [bookInfo objectForKey:@"hospitalid"];
            if (hosID)
                bookDetail.hospitalID = hosID.integerValue;
            
            NSNumber *offID = [bookInfo objectForKey:@"officeid"];
            if (offID)
                bookDetail.officeID = offID.integerValue;

            [imageDownloadHelper addImageKey:bookDetail.doctorImageKey andSizeType:@"90"];
            NSLog(@"BookDetail: %@", bookDetail.debugDescription);

            [bookDataList addObject:bookDetail];
        }

        if (bookDataList && bookDataList.count > 0) {
            self.noDataBgView.hidden = YES;
        }
        else {
            self.noDataBgView.hidden = NO;
        }
            
        
        [imageDownloadHelper startDownload];
        [self performSelectorOnMainThread:@selector(mainThreadRefresh) withObject:nil waitUntilDone:NO];
    }
}

- (void)mainThreadRefresh
{
    [[CureMeUtils defaultCureMeUtil] updateUnreadMsgCount];
    
    isLoadingDataInBackground = false;
    
    loadingView.hidden = YES;
//    [activityIndicator stopAnimating];

    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.listTableView];

    [self.listTableView reloadData];
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    // 如果是下拉刷新，则清理所有数据
    [bookDataList removeAllObjects];
    [self.listTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    [self performSelectorInBackground:@selector(threadInitBookListInfo) withObject:nil];
    
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

#pragma mark TableViewController delegate
#pragma mark - UITableViewDataSource implementation
// secion 0 用来显示：医院、医生信息（以及加载更多历史消息）
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!bookDataList)
        return 0;
    
    return bookDataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return BOOKLISTCELL_TITLEHEIGHT + BOOKLISTCELL_INFOHEIGHT + BOOKLISTCELL_REPLYHEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DefaultCell = @"defaultCell";
    static NSString *bookCellStr = @"bookCell";

    if (indexPath.section > 0 || indexPath.row >= bookDataList.count) {
        NSLog(@"MyBookListViewController cellForRowAtIndexPath indexPath invalid: %@ withData: %@", indexPath, bookDataList);
        UITableViewCell *cell = [self.listTableView dequeueReusableCellWithIdentifier:DefaultCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCell];
        }
        
        return cell;
    }

//    ListInfoBookCell *bookCell = [self.tableView dequeueReusableCellWithIdentifier:bookCellStr];
//    if (!bookCell) {
//        bookCell = [[ListInfoBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookCellStr];
//    }
//    
//    // 设置BookDetail数据结构
//    [bookCell setBookListViewController:self];
//    [bookCell setBookDetail:[bookDataList objectAtIndex:indexPath.row]];
    CMMyBookListCell *cell = [self.listTableView dequeueReusableCellWithIdentifier:bookCellStr];
    if (!cell) {
        cell = [[CMMyBookListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookCellStr];
    }
    [cell setMyBookListViewController:self];
    [cell setBookInfoUnit:[bookDataList objectAtIndex:indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= bookDataList.count)
        return;
    
    BookDetail *bookDetail = [bookDataList objectAtIndex:indexPath.row];
    
//    assert([bookDataList isKindOfClass:[BookDetail class]]);
    
    BookDetailInfoViewController *bookDetailVC = [[BookDetailInfoViewController alloc] initWithNibName:@"BookDetailInfoViewController" bundle:nil];
    [bookDetailVC setBookingID:bookDetail.bookID];
    [bookDetailVC setHospitalID:bookDetail.hospitalID];

    [self.navigationController pushViewController:bookDetailVC animated:YES];
}

#pragma mark ImageDownloadHelper
- (void)imageDownloadComplete:(NSString *)imageKey andType:(NSString *)type andImage:(UIImage*)image
{
    if (!hospImages) {
        hospImages = [[NSMutableDictionary alloc] init];
    }
    
    [hospImages setObject:image forKey:[[NSString alloc] initWithFormat:@"%@-%@", imageKey, type]];
}

- (void)allImageComplete
{
    [self performSelectorOnMainThread:@selector(mainThreadRefresh) withObject:nil waitUntilDone:NO];
}

- (UIImage *)hospitalImageWithKey:(NSString *)imageKey andSize:(NSString *)size
{
    if (!hospImages || hospImages.count <= 0)
        return nil;
    
    if (!imageKey || !size)
        return nil;
    
    return [hospImages objectForKey:[[NSString alloc] initWithFormat:@"%@-%@", imageKey, size]];
}

@end
