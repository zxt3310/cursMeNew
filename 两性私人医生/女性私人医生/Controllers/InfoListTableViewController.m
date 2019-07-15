//
//  InfoListTableViewController.m
//  CureMe
//
//  Created by Tim on 12-8-30.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "Doctor.h"
#import "Hospital.h"
#import "ListInfoCell.h"
//#import "XYLoadingView.h"
//#import "HospitalInfoViewController.h"
#import "DoctorInfoViewController.h"
#import "InfoListTableViewController.h"
#import "BookDetailInfoViewController.h"



@interface InfoListTableViewController ()

@end

@implementation InfoListTableViewController

@synthesize listType = _listType;
@synthesize hospitalID = _hospitalID;
@synthesize officeType = _officeType;

- (id)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        dataList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    if (dataList) {
        [dataList removeAllObjects];
        dataList = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSString *title = nil;
    if (_listType == LIST_HOSPITAL) {
        title = @"医院列表";
    }
    else if (_listType == LIST_DOCTOR) {
        title = @"医生列表";
    }
    else if (_listType == LIST_BOOK) {
        title = @"预约挂号列表";
    }
    [self.navigationItem setTitle:title];
    
    [activityIndicator startAnimating];
//    if (!loadingView) {
//        loadingView = [XYLoadingView loadingViewWithMessage:@"载入中..."];
//    }
//    
//    [loadingView show];

    headImageDict = [[NSMutableDictionary alloc] init];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    [self.tableView setSeparatorColor:[UIColor colorWithPatternImage:[CureMeUtils defaultCureMeUtil].queryListSeparatorLineImage]];
    
    [NSThread detachNewThreadSelector:@selector(threadInitInfoData) toTarget:self withObject:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    [headImageDict removeAllObjects];
    headImageDict = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_listType == LIST_BOOK) {
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }

    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    NSString *type = nil;
    if (_listType == LIST_HOSPITAL)
        type = @"hospital list";
    else if (_listType == LIST_DOCTOR)
        type = @"doctor list";
    else if (_listType == LIST_BOOK)
        type = @"query list";
    
    NSLog(@"InfoListTableViewController didReceiveMemoryWarning list Type: %@", type);
    
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)threadInitInfoData
{
    @autoreleasepool {
        if (_listType == LIST_HOSPITAL) {
            [self initHospitalInfoData:0];
        }
        else if (_listType == LIST_DOCTOR) {
            [self initDoctorInfoData:0];
        }
        else if (_listType == LIST_BOOK) {
            [self initMyBookInfoData];
        }
        
        [self performSelectorOnMainThread:@selector(reloadData) withObject:self waitUntilDone:NO];
        
        if (_listType != LIST_HOSPITAL) {
            [self startImageDownload];
        }
    }
}

- (void)initMyBookInfoData
{
    @autoreleasepool {
        NSString *post = [NSString stringWithFormat:@"action=bookinghistory&userid=%ld", (long)[CureMeUtils defaultCureMeUtil].userID];
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"initMyBookInfoData req: %@", strResp);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (result.intValue != 1) {
            NSLog(@"BookingList req failed.");
            return;
        }
        
        // {"result":true,"msg":[{"id":13,"userid":1000001,"hospitalid":111,"officeid":40,"bday":"1348302651","timerange":"","dateadd":1348122940,"username":"\u963f\u5341\u5206","usertel":"13810607509","memo":"\u5475\u53d1\u751f\u9515\u814c\u5927\u7237","state":"1","oname":"\u6ce8\u5c04\u7f8e\u5bb9","hname":"\u91d1\u7687\u540e\u6574\u5f62\u7f8e\u5bb9\u533b\u9662"}],"unreadcount":{"replycount":"31","channelcount":"0","chatcount":"0"}}
        NSArray *bookArray = [jsonData objectForKey:@"msg"];
        for (NSDictionary *bookInfo in bookArray) {
            NSLog(@"bookInfo: %@", bookInfo);
            InfoUnit *infoUnit = [[InfoUnit alloc] init];
            [infoUnit setDataListType:_listType];      // 记录是医院信息还是医生信息
            NSNumber *identifier = [bookInfo objectForKey:@"id"];
            [infoUnit setIdentifier:identifier.intValue];
            NSString *nameString = nil;
            NSString *bookNumber = [bookInfo objectForKey:@"no"];
            NSLog(@"bookNumber: %@", bookNumber);
            NSDate *bookTime = [NSDate dateWithTimeIntervalSince1970:[[bookInfo objectForKey:@"bday"] integerValue]];
//            NSNumber *succeed = [bookInfo objectForKey:@"bookingSucc"];
            // 预约状态
//            if (!succeed || succeed.integerValue != 1) {

            // 判断是否预约过期
            bool hasExceed = dateHasExcedded(bookTime, [NSDate date]);
//            if (!bookTime) {
//                hasExceed = true;
//            }
//            else {
//                NSTimeInterval interval = [bookTime timeIntervalSinceNow];
//                if (interval < 0)
//                    hasExceed = true;
//                else
//                    hasExceed = false;
//            }
            
            if (hasExceed) {
                nameString = [NSString stringWithFormat:@"%@的预约（已过期）", [bookInfo objectForKey:@"username"]];
            }
            else if (!bookNumber || bookNumber.length <= 0) {
                nameString = [NSString stringWithFormat:@"%@的预约（待处理）", [bookInfo objectForKey:@"username"]];
            }
            else {
                nameString = [NSString stringWithFormat:@"%@的预约（预约号：%@）", [bookInfo objectForKey:@"username"], bookNumber];
            }
            [infoUnit setName:nameString];

            // 医院ID
            NSNumber *hosID = [bookInfo objectForKey:@"hospitalid"];
            if (hosID)
                [infoUnit setHospitalID:hosID.integerValue];

//            NSDate *addTime = [NSDate dateWithTimeIntervalSince1970:[[bookInfo objectForKey:@"dateadd"] integerValue]];
//            NSString *strAddTime = [[CureMeUtils defaultCureMeUtil].dateFormatter stringFromDate:addTime];
            NSString *strBookTime = [[CureMeUtils defaultCureMeUtil].shortDateFormatter stringFromDate:bookTime];
            [infoUnit setInfo:[NSString stringWithFormat:@"预约时间：%@", strBookTime]];
            [infoUnit setIntroduction:[NSString stringWithFormat:@"医院：%@  科室：%@\n医院回复：%@", [bookInfo objectForKey:@"hname"], [bookInfo objectForKey:@"oname"], [bookInfo objectForKey:@"bookingSummary"]]];
            
            [dataList addObject:infoUnit];
        }
    }
}

// {"result":true,"msg":[{"id":97,"name":"\u674e\u534e","oid":39,"oname":"\u76ae\u80a4\u7f8e\u5bb9","hid":111,"hname":"\u91d1\u7687\u540e\u6574\u5f62\u7f8e\u5bb9\u533b\u9662","title":"\u7f8e\u5bb9\u4e13\u5bb6","pic":"504efa3becd72","isonline":0},{"id":86,"name":"\u675c\u9e4f","oid":38,"oname":"\u6574\u5f62\u7f8e\u5bb9","hid":111,"hname":"\u91d1\u7687\u540e\u6574\u5f62\u7f8e\u5bb9\u533b\u9662","title":"\u6574\u5f62\u533b\u5e08","pic":"504f01466824a","isonline":0},{"id":85,"name":"\u6bb7\u51ac\u96ea","oid":40,"oname":"\u6ce8\u5c04\u7f8e\u5bb9","hid":111,"hname":"\u91d1\u7687\u540e\u6574\u5f62\u7f8e\u5bb9\u533b\u9662","title":"\u6743\u5a01\u4e13\u5bb6","pic":"504f01591661e","isonline":0}]}
- (void)initDoctorInfoData:(int)officeType
{
    @autoreleasepool {
        NSString *post = [NSString stringWithFormat:@"action=doctorlist&type=%d&hospitalid=%ld", officeType, (long)_hospitalID];
        NSData *response = sendRequest(@"m.php", post);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        if (!jsonData || jsonData.count <= 0) {
            NSLog(@"initDoctorInfoData parse json failed");
            return;
        }
        
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSLog(@"initDoctorInfoData result error");
            return;
        }
        
        NSArray *infos = [jsonData objectForKey:@"msg"];
        if (!infos || infos.count <= 0) {
            NSLog(@"No doctor info data");
            return;
        }
        
        for (NSDictionary *info in infos) {
            InfoUnit *infoUnit = [[InfoUnit alloc] init];
            [infoUnit setDataListType:_listType];
            NSNumber *doctorID = [info objectForKey:@"id"];
            [infoUnit setIdentifier:doctorID.integerValue];
            
            NSString *name = [info objectForKey:@"name"];
            [infoUnit setName:name];
            
            [infoUnit setInfo:[NSString stringWithFormat:@"%@ %@ %@", [info objectForKey:@"title"], [info objectForKey:@"hname"], [info objectForKey:@"oname"]]];
            
            [infoUnit setIntroduction:[NSString stringWithFormat:@"%@", [info objectForKey:@"intro"]]];
            
            [infoUnit setImageKey:[NSString stringWithFormat:@"%@", [info objectForKey:@"pic"]]];
            
            [dataList addObject:infoUnit];
        }
    }
}

// {"result":true,"msg":[{"id":111,"name":"\u91d1\u7687\u540e\u6574\u5f62\u7f8e\u5bb9\u533b\u9662","city":"21000","tel":"024-23991658","website":"http:\/\/www.jinhuanghou.com\/","intro":"\u6c88\u9633\u5e02\u91d1\u7687\u540e\u6574\u5f62\u7f8e\u5bb9\u533b\u9662\u662f\u8fbd\u5b81\u6700\u65e9\u521b\u5efa\u7684\u533b\u7597\u7f8e\u5bb9\u673a\u6784\uff0c\u662f\u548c\u7f8e\u56fd\u3001\u4e39\u9ea6\u3001\u65e5\u672c\u3001\u97e9\u56fd\u957f\u5e74\u6280\u672f\u5408\u4f5c\u7684\u5927\u578b\u56fd\u9645\u533b\u7597\u7f8e\u5bb9\u548c\u6fc0\u5149\u7f8e\u5bb9\u7684\u8054\u5408\u4f53\u3002\u5efa\u9662\u4e8c\u5341\u5e74\u6765\uff0c\u59cb\u7ec8\u9075\u5faa\u201c\u5c16\u7aef\u8bbe\u5907\u9886\u5148\u6280\u672f\u4f18\u8d28\u670d\u52a1\u201d\u7684\u5b97\u65e8\u3002\u4e3a\u6765\u81ea\u56fd\u5185\u5916\u7231\u7f8e\u670b\u53cb\u5b9e\u65bd\u6570\u4e07\u4f8b\u6210\u529f\u7f8e\u5bb9\u624b\u672f\u94f8\u9020\u4e86\u575a\u5b9e\u7684\u56fd\u9645\u54c1\u724c\u5f62\u8c61\u3002\u8fde\u5e74\u83b7\u5f97\u653f\u5e9c\u90e8\u95e8\u9881\u53d1\u7684\u201c\u8bda\u4fe1\u5355\u4f4d\u201d\u201c\u6d88\u8d39\u8005\u6ee1\u610f\u5355\u4f4d\u201d\u5149\u8363\u79f0\u53f7\u3002\u88ab\u56fd\u5185\u5916\u6570\u6240\u9ad8\u7b49\u9662\u6821\u9009\u4f5c\u4e13\u4e1a\u4e34\u5e8a\u57fa\u5730.\u662f\u97e9\u56fd\u7f8e\u5bb9\u5e08\u4ee3\u8868\u56e2\u7684\u57f9\u8bad\u57fa\u5730\u3002 \r\n","pic1":"504ee2475a5c9","pic2":"504ee2476b34e","geolocation":"122.753592,41.6216"}]}
- (void)initHospitalInfoData:(int)officeType
{
    @autoreleasepool {
        NSString *post = [NSString stringWithFormat:@"action=hospitallist&type=%d", officeType];
        NSData *response = sendRequest(@"m.php", post);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (result.intValue != 1) {
            NSLog(@"hospitalInfoList req failed.");
            return;
        }
        
        NSArray *hospitalArray = [jsonData objectForKey:@"msg"];
        for (NSDictionary *hospInfo in hospitalArray) {
            InfoUnit *infoUnit = [[InfoUnit alloc] init];
            [infoUnit setDataListType:_listType];      // 记录是医院信息还是医生信息
            NSNumber *identifier = [hospInfo objectForKey:@"id"];
            [infoUnit setIdentifier:identifier.intValue];
            [infoUnit setName:[NSString stringWithFormat:@"%@", [hospInfo objectForKey:@"name"]]];
            [infoUnit setInfo:[NSString stringWithFormat:@"%@  %@", [hospInfo objectForKey:@"cityname"], [hospInfo objectForKey:@"tel"]]];
            [infoUnit setIntroduction:[NSString stringWithFormat:@"%@", [hospInfo objectForKey:@"intro"]]];
            [infoUnit setImageKey:[NSString stringWithFormat:@"%@", [hospInfo objectForKey:@"pic2"]]];
            
            [dataList addObject:infoUnit];
        }
    }
}

- (void)reloadData
{
    [self.tableView reloadData];
    
    [activityIndicator stopAnimating];
//    [loadingView performSelector:@selector(dismissWithMessage:) withObject:nil afterDelay:0];
}

- (void)startImageDownload
{
    if (!imageDownloadHelper) {
        imageDownloadHelper = [[ImageDownloadHelper alloc] init];
        [imageDownloadHelper setDelegate:self];
    }

    for (InfoUnit *infoUnit in dataList) {
        NSString *imageKey = infoUnit.imageKey;
        if (!imageKey || imageKey.length <= 0)
            continue;
        [imageDownloadHelper addImageKey:imageKey andSizeType:@"90"];
    }
    
    [imageDownloadHelper startDownload];
}

- (UIImage *)getHeadImage:(NSString *)imageKey
{
    if (!headImageDict || headImageDict.count <= 0) {
        return nil;
    }
    
    return [headImageDict objectForKey:imageKey];
}

#pragma mark ImageDownloadHelperDelegate
- (void)imageDownloadComplete:(NSString *)imageKey andType:(NSString *)type andImage:(UIImage *)image
{
    if (!headImageDict) {
        headImageDict = [[NSMutableDictionary alloc] init];
    }
    
    [headImageDict setObject:image forKey:imageKey];
}

- (void)allImageComplete
{
    [self performSelectorOnMainThread:@selector(reloadData) withObject:self waitUntilDone:NO];
}

#pragma mark TableView datasource delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"InfoListTableViewCell";

    if (indexPath.row > dataList.count) {
        return nil;
    }
    
    ListInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!infoCell) {
        infoCell = [[ListInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    InfoUnit *unit = [dataList objectAtIndex:indexPath.row];
    [infoCell setInfoUnit:unit];
    [infoCell setViewController:self];
    
    return infoCell;
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

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row will be selected");
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > dataList.count) {
        return 0;
    }
    
    if (_listType == LIST_BOOK) {
        return 111;
    }
    
    return INFOCELL_HEIGHT;
}


#pragma mark Instance methods

- (void)showHospitalInfoPage:(NSInteger)hospID
{
    if (hospID <= 0) {
        NSLog(@"showHospitalInfoPage cannot proceed with hospID <= 0");
        return;
    }
    
//    HospitalInfoViewController *hospInfoVC = [[HospitalInfoViewController alloc] initWithNibName:@"HospitalInfoViewController" bundle:nil];
//    if (!hospInfoVC) {
//        NSLog(@"showHospitalInfoPage create HospitalInfoViewController failed");
//        return;
//    }
//    [hospInfoVC setHospitalID:hospID];
//
//    [[self navigationController] pushViewController:hospInfoVC animated:YES];
}

- (void)showDoctorInfoPage:(NSInteger)doctorID
{
    if (doctorID <= 0) {
        NSLog(@"showDoctorInfoPage cannot proceed with doctorID <= 0");
        return;
    }
    
    DoctorInfoViewController *doctorInfoVC = [[DoctorInfoViewController alloc] initWithNibName:@"DoctorInfoViewController" bundle:nil];
    if (!doctorInfoVC) {
        NSLog(@"showDoctorInfoPage create DoctorInfoViewController failed");
        return;
    }
    [doctorInfoVC setDoctorID:doctorID];
    
    [[self navigationController] pushViewController:doctorInfoVC animated:YES];
}

- (void)showBookDetailInfoPage:(NSInteger)bookingID andHospitalID:(NSInteger)hID
{
    if (bookingID <= 0) {
        NSLog(@"showBookDetailInfoPage bookingID invalid");
        return;
    }
    
    BookDetailInfoViewController *bookDetailInfoVC = [[BookDetailInfoViewController alloc] initWithNibName:@"BookDetailInfoViewController" bundle:nil];
    [bookDetailInfoVC setBookingID:bookingID];
    [bookDetailInfoVC setHospitalID:hID];
    
    [self.navigationController pushViewController:bookDetailInfoVC animated:YES];
}

@end
