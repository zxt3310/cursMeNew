//
//  OfficeListInfoTableViewController.m
//  CureMe
//
//  Created by Tim on 12-9-6.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "OfficeInfoCell.h"
#import "OfficeListInfoTableViewController.h"

@interface OfficeListInfoTableViewController ()

@end

@implementation OfficeListInfoTableViewController

@synthesize hospitalID = _hospitalID;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        officeArray = [[NSMutableArray alloc] init];
        [self.navigationItem setTitle:@"科室列表"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (_hospitalID <= 0) {
        return;
    }

    [NSThread detachNewThreadSelector:@selector(threadInitOfficeInfo) toTarget:self withObject:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"OfficeListInfoTableViewController didReceiveMemoryWarning");
    
    [super didReceiveMemoryWarning];
}

#pragma mark thread methods:
    //{"result":true,"msg":[{"id":34,"name":"\u7f8e\u5bb9\u6574\u5f62","hid":1,"hname":"\u5317\u4eac\u6b66\u8b66\u6574\u5f62\u533b\u9662","intro":"\u81c0\u90e8\u5438\u8102\u540e\u600e\u6837\u62a4\u7406?\u7231\u7f8e\u4e4b\u5fc3\u4eba\u7686\u6709\u4e4b\uff0c\u73b0\u5728\u5f88\u591a\u4eba\u90fd\u5f88\u91cd\u89c6\u66f2\u7ebf\u7f8e\uff0c\u4f46\u662f\u968f\u7740\u751f\u6d3b\u8d28\u91cf\u7684\u4e0d\u65ad\u63d0\u5347\uff0c\r\n\u81c0\u90e8\u5806\u79ef\u7684\u592a\u591a\u8102\u80aa\u8ba9\u7231\u7f8e\u4eba\u58eb\u4eec\u5931\u53bb\u4e86\u8fd9\u79cd\u66f2\u7ebf\u7f8e\uff0c\u4e3a\u6b64\u5f88\u591a\u4eba\u90fd\u53bb\u6574\u5f62\u533b\u9662\u91cc\u505a\u81c0\u90e8\u5438\u8102\u672f\uff0c\u4f46\u662f\u505a\u8fd9\u9879\u624b\u672f\u4e3a\u4e86\u4fdd\u8bc1\u672f\u540e\u6548\u679c\u505a\u597d\u624b\u672f\u7684\u672f\u540e\u62a4\u7406\u662f\u6709\u5fc5\u8981\u7684\uff0c\u90a3\u81c0\u90e8\u5438\u8102\u672f\u540e\u5e94\u600e\u6837\u505a\u62a4\u7406\u5462?"}]}
- (void)threadInitOfficeInfo
{
    if (_hospitalID <= 0) {
        return;
    }
    
    // 1. 请求
    // action=officelist&type=x&hospitalid=0
    NSString *post = [NSString stringWithFormat:@"action=officelist&hospitalid=%ld", (long)_hospitalID];
    NSData *response = sendRequest(@"m.php", post);

    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"%@", strResp);
    
    // 2. 解析并保存
    NSDictionary *jsonData = parseJsonResponse(response);
    if (!jsonData || jsonData.count <= 0) {
        NSLog(@"OfficeListInfoTableViewController threadInitOfficeInfo parsejson failed");
        return;
    }
    
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!result || result.integerValue != 1) {
        NSLog(@"threadInitOfficeInfo parse result failed");
        return;
    }

    NSDictionary *offices = [jsonData objectForKey:@"msg"];
    NSLog(@"Offices: %@", offices);
    if (!offices || offices.count <= 0) {
        NSLog(@"threadInitOfficeInfo parse offices failed");
        return;
    }
    
    for (NSDictionary *office in offices) {
        OfficeInfoUnit *infoUnit = [[OfficeInfoUnit alloc] init];
        [infoUnit setOfficeID:[[office objectForKey:@"id"] integerValue]];
        [infoUnit setOfficeName:[office objectForKey:@"name"]];
        [infoUnit setHospitalID:[[office objectForKey:@"hid"] integerValue]];
        [infoUnit setHospitalName:[office objectForKey:@"hname"]];
        [infoUnit setOfficeIntro:[office objectForKey:@"intro"]];
        
        [officeArray addObject:infoUnit];
    }

    // 3. 通知tableview reload
    [self performSelectorOnMainThread:@selector(refreshTable) withObject:self waitUntilDone:NO];
}

- (void)refreshTable
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (!officeArray) {
        return 0;
    }

    return officeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OfficeInfoCell";
    
    if (!officeArray || officeArray.count <= 0)
        return nil;

    if (indexPath.row >= officeArray.count)
        return nil;

    OfficeInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[OfficeInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setInfoUnit:[officeArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!officeArray || officeArray.count <= 0)
        return 0;
    
    if (indexPath.row >= officeArray.count)
        return 0;
    
    return OFFICEINFO_CELLHEIGHT;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if (!officeArray || officeArray.count <= indexPath.row)
        return;

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
}

@end







