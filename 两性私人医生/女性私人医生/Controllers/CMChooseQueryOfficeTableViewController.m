//
//  CMChooseQueryOfficeTableViewController.m
//  私密健康医生
//
//  Created by Tim on 13-9-25.
//  Copyright (c) 2013年 Tim. All rights reserved.
//


#import "CMChooseQueryOfficeTableViewController.h"
#import "CMNewQueryViewController.h"
#import "KGModal.h"


@interface CMChooseQueryOfficeTableViewController ()

@end

@implementation CMChooseQueryOfficeTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        officeIndexDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:OFFICE_MEIRONG], [NSNumber numberWithInt:0],
                           [NSNumber numberWithInt:OFFICE_FUKE], [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:OFFICE_CHANKE], [NSNumber numberWithInt:2],
                           [NSNumber numberWithInt:OFFICE_GANBING], [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:OFFICE_PIFUKE], [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:OFFICE_BYBY], [NSNumber numberWithInt:5],
                           [NSNumber numberWithInt:OFFICE_KOUQIANG], [NSNumber numberWithInt:6],
                           [NSNumber numberWithInt:OFFICE_YANKE], [NSNumber numberWithInt:7],
                           //[NSNumber numberWithInt:OFFICE_JIAKANG], [NSNumber numberWithInt:6],
                           //[NSNumber numberWithInt:OFFICE_NAOTAN], [NSNumber numberWithInt:8],
                           //[NSNumber numberWithInt:OFFICE_GUKE], [NSNumber numberWithInt:9],
                           [NSNumber numberWithInt:OFFICE_DIANXIAN], [NSNumber numberWithInt:8],
                           //[NSNumber numberWithInt:OFFICE_XINZANG], [NSNumber numberWithInt:12],
                           //[NSNumber numberWithInt:OFFICE_SHENJING], [NSNumber numberWithInt:13],
                           [NSNumber numberWithInt:OFFICE_ERBIHOU], [NSNumber numberWithInt:9],
                           [NSNumber numberWithInt:OFFICE_WEICHANG], [NSNumber numberWithInt:10],
                           //[NSNumber numberWithInt:OFFICE_TANGNIAOBING], [NSNumber numberWithInt:16],
                           //[NSNumber numberWithInt:OFFICE_ZHONGLIU], [NSNumber numberWithInt:17],
                           [NSNumber numberWithInt:OFFICE_GANGCHANG], [NSNumber numberWithInt:11],
                           nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    [self.officeTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    if (IOS_VERSION >= 7.0) {
        //CGRect viewFrame = self.view.bounds;
        CGRect tableFrame = self.officeTableView.frame;
        //tableFrame.origin.y = 20 + NAVIGATIONBAR_HEIGHT;
        //tableFrame.size.height = viewFrame.size.height - 20 - NAVIGATIONBAR_HEIGHT - 50;
        //tableFrame.size.height = SCREEN_HEIGHT - 20 - NAVIGATIONBAR_HEIGHT - 50;
        tableFrame.size.height = SCREEN_HEIGHT - 49 - 64;
        self.officeTableView.frame = tableFrame;
    }
    
	// Do any additional setup after loading the view.
//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.navigationController setNavigationBarHidden:NO];

    if (IOS_VERSION >= 7.0) {
        CGRect tableFrame = self.officeTableView.frame;
        //tableFrame.origin.y = 20 + NAVIGATIONBAR_HEIGHT;
        //tableFrame.size.height = SCREEN_HEIGHT - 20 - NAVIGATIONBAR_HEIGHT - 50;
        tableFrame.size.height = SCREEN_HEIGHT - 49 - 64;
        self.officeTableView.frame = tableFrame;
    }
    
    NSLog(@"ChooseQueryOfficeVC willAppear: %@ subs: %@", self.view, self.view.subviews);
    
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationItem.leftBarButtonItems = nil;
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    self.tabBarController.navigationItem.title = @"选择咨询科室";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (IOS_VERSION >= 7.0) {
        CGRect tableFrame = self.officeTableView.frame;
        //tableFrame.origin.y = 20 + NAVIGATIONBAR_HEIGHT;
        //tableFrame.size.height = SCREEN_HEIGHT - 20 - NAVIGATIONBAR_HEIGHT - 50;
        tableFrame.size.height = SCREEN_HEIGHT - 49 - 64;
        self.officeTableView.frame = tableFrame;
        //[self.tableView setContentOffset:CGPointMake(0.0, 20.0) animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSLog(@"ChooseQueryOfficeVC willDisappear: %@ subs: %@", self.view, self.view.subviews);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma properties
- (UITableView *)officeTableView
{
    if (!_officeTableView.delegate) {
        _officeTableView.delegate = self;
        _officeTableView.dataSource = self;
    }
    
    return _officeTableView;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 12;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor whiteColor]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    NSNumber *numOffice = [officeIndexDict objectForKey:[NSNumber numberWithInteger:indexPath.row]];
    NSString *officeName = [NSString stringWithFormat:@"    %@", officeStringWithType(numOffice.integerValue) ];
    cell.textLabel.text = officeName;

//    NSNumber *officeID = [officeIndexDict objectForKey:[NSNumber numberWithInt:indexPath.row]];
//    cell.imageView.image = [[CMDataUtils defaultDataUtil].officeImageDict objectForKey:officeID];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *officeID = [officeIndexDict objectForKey:[NSNumber numberWithInteger:indexPath.row]];
    NSNumber *subOfficeID = [NSNumber numberWithInt:0];
    NSNumber *regionNum = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
    if (!regionNum) {
        [self popPickerView];
        return;
    }

    /*CMQueryViewController *queryVC = [[CMQueryViewController alloc] initWithNibName:@"CMQueryViewController" bundle:nil];
    [queryVC setOfficeType:[officeID integerValue]];
    [queryVC setSubOfficeType:[subOfficeID integerValue]];
    [self.navigationController pushViewController:queryVC animated:YES];*/
    
    CMNewQueryViewController *queryVC = [CMNewQueryViewController new];
    queryVC.officeType = [officeID integerValue];
    queryVC.subOfficeType = [subOfficeID integerValue];
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

@end
