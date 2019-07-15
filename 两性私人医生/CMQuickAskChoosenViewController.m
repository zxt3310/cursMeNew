//
//  CMQuickAskChoosenViewController.m
//  私密健康医生
//
//  Created by 张信涛 on 2017/4/10.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "CMQuickAskChoosenViewController.h"

@interface CMQuickAskChoosenAndLocationViewController ()
{
    NSDictionary *officeSuperTypeDic;
    NSDictionary *officeSubTypeDic;
    NSDictionary *fullProvinceDic;
    NSDictionary *fullCityDic;
    
    NSArray *officeSuperTypeArray;
    NSArray *fullProvinceArray;
    
    NSArray *currentSelectNameArray;
    NSArray *currentSelectKeyArray;
    UITableView *rightView;
    UITableView *leftView;
    
    NSIndexPath *currentLeftIndex;
    NSIndexPath *currentRightIndex;
    
    NSString *currentProvince;
    NSString *currentCity;
}
@end

@implementation CMQuickAskChoosenAndLocationViewController

- (instancetype) init{
    self = [super init];
    if (self) {
        _isQuickAskView = NO;
        currentSelectNameArray = nil; //[[NSArray alloc] init];
        
        officeSuperTypeDic = [CMDataUtils defaultDataUtil].officeSuperTypeDict;
        officeSubTypeDic = [CMDataUtils defaultDataUtil].officeTypeDict;
        fullProvinceDic = [CureMeUtils defaultCureMeUtil].regionDictionaryForUser;
        fullCityDic = [CureMeUtils defaultCureMeUtil].fullCityDictionary;
        
        officeSuperTypeArray = [[officeSuperTypeDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2){
        
            NSNumber *number1 = (NSNumber *)obj1;
            NSNumber *number2 = (NSNumber *)obj2;
            NSComparisonResult result = [number1 compare:number2];
        
            return result == NSOrderedDescending;
        }];
        
        fullProvinceArray = [[fullProvinceDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2){
            
            NSInteger *number1 = [(NSNumber *)obj1 integerValue];
            NSInteger *number2 = [(NSNumber *)obj2 integerValue];
            
            NSComparisonResult result = [self compareBettwin:number1 and:number2];
            
            return result == NSOrderedAscending;
        }];
    }
    return self;
}

- (NSComparisonResult) compareBettwin:(NSInteger) A and:(NSInteger) B{
    
    NSComparisonResult result = nil;
    if (A >= B) {
        result = NSOrderedAscending;
    }
    else{
        result = NSOrderedDescending;
    }
    return result;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    leftView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH/2, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    leftView.tableFooterView = [[UITableView alloc] initWithFrame:CGRectZero];
    leftView.delegate = self;
    leftView.dataSource = self;
    leftView.separatorStyle = UITableViewCellSeparatorStyleNone;
    leftView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    leftView.tag = 1;
    
    rightView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2,0, SCREEN_WIDTH/2, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    rightView.tableFooterView = [[UITableView alloc] initWithFrame:CGRectZero];
    rightView.delegate = self;
    rightView.dataSource = self;
    rightView.tag = 2;
    
    [self.view addSubview:leftView];
    [self.view addSubview:rightView];
    self.view.backgroundColor = leftView.backgroundColor;
    
    if (_isQuickAskView) {
        self.title = @"选择科室";
    }
    else{
        self.title = @"选择地区";
        UILabel *currentLocatStr = [[UILabel alloc] initWithFrame:CGRectMake(17, 17, 80, 15)];
        currentLocatStr.text = @"定位城市：";
        currentLocatStr.font = [UIFont systemFontOfSize:15];
        currentLocatStr.textColor = [UIColor grayColor];
        [self.view addSubview:currentLocatStr];
        _currentLocation = [NSString stringWithFormat:@"%@ %@",[CureMeUtils defaultCureMeUtil].province,[CureMeUtils defaultCureMeUtil].cityOrDistrict];
        
        UILabel *localStr = [[UILabel alloc] initWithFrame:CGRectMake(currentLocatStr.frame.origin.x + currentLocatStr.frame.size.width,15,200,15)];
        localStr.text = _currentLocation;
        [self.view addSubview:localStr];
        
        CGRect temp = leftView.frame;
        temp.origin.y += SCREEN_HEIGHT/14;
        temp.size.height -= SCREEN_HEIGHT/14;
        leftView.frame = temp;
        
        temp = rightView.frame;
        temp.origin.y += SCREEN_HEIGHT/14;
        temp.size.height -= SCREEN_HEIGHT/14;
        rightView.frame = temp;
        
        NSInteger province = [CureMeUtils defaultCureMeUtil].cityCode;
        NSInteger city = [CureMeUtils defaultCureMeUtil].userCity;
        if (province >0) {
            for (int i=0; i<fullProvinceArray.count; i++) {
                if ([fullProvinceArray[i] integerValue] == province ) {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
                    [leftView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                    [self tableView:leftView didSelectRowAtIndexPath:path];
                    break;
                }
            }
            for (int i=0; i<currentSelectKeyArray.count; i++) {
                if ([currentSelectKeyArray[i] integerValue] == city) {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
                    [rightView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                    currentRightIndex = path;
                    [rightView reloadData];
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SCREEN_HEIGHT/14;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger rows = 0;
    
    if (tableView.tag == 1) {
        if (_isQuickAskView) {
            rows = officeSuperTypeDic.count;
        }
        else{
            rows = fullProvinceDic.count;
        }
    }
    else{
        if (!_isQuickAskView) {
            rows = currentSelectNameArray.count;
        }
        else{
            rows = currentSelectNameArray.count;
        }
        
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (tableView.tag == 1) {
        if (_isQuickAskView) {
            cell.textLabel.text = [officeSuperTypeDic objectForKey:officeSuperTypeArray[indexPath.row]];
        }
        else{
            cell.textLabel.text = [fullProvinceDic objectForKey:fullProvinceArray[indexPath.row]];
        }
        cell.backgroundColor = tableView.backgroundColor;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    }
    else{
        if (!currentSelectNameArray) {
            cell.hidden = YES;
        }
        else{
            cell.hidden = NO;
        }
        if (_isQuickAskView){
            
            cell.textLabel.text = currentSelectNameArray[indexPath.row];
            
        }
        else{
            cell.textLabel.text = currentSelectNameArray[indexPath.row];
            if (currentRightIndex == indexPath) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    if (tableView.tag == 1) {
        if (_isQuickAskView) {
             NSDictionary *dic = [officeSubTypeDic objectForKey:officeSuperTypeArray[indexPath.row]];
                
            currentSelectKeyArray = [dic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2){
                NSInteger *a = [obj1 integerValue];
                NSInteger *b = [obj2 integerValue];
                NSComparisonResult result = [self compareBettwin:a and:b];
                return result == NSOrderedAscending;
            }];
            
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            for (int i=0; i<currentSelectKeyArray.count; i++) {
                NSString *nameStr = [dic objectForKey:currentSelectKeyArray[i]];
                [temp addObject:nameStr];
            }
            [temp insertObject:@"全部" atIndex:0];
            currentSelectNameArray = [temp copy];
        }
        else{
            NSArray *arry = [fullCityDic objectForKey:[NSNumber numberWithInteger:[fullProvinceArray[indexPath.row] integerValue]]];
            NSMutableArray *tempName = [[NSMutableArray alloc] init];
            NSMutableArray *tempKey = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in arry) {
                [tempName addObject:[dic objectForKey:@"name"]];
                [tempKey addObject:[dic objectForKey:@"id"]];
            }
            currentSelectNameArray = [tempName copy];
            currentSelectKeyArray = [tempKey copy];
        }
        [rightView reloadData];
        currentLeftIndex = indexPath;
        currentRightIndex = nil;
    }
    else{
        if (_isQuickAskView){
            NSNumber *hasMarkApp = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_AGREEPROTOCOL];
            if (!hasMarkApp || hasMarkApp.integerValue == 0) {
                CMQAProtocolView *protocl = [[CMQAProtocolView alloc] initWithFrame:[UIScreen mainScreen].bounds];
                protocl.CmLocationDelegate = self;
                protocl.office1 = [officeSuperTypeArray[currentLeftIndex.row] integerValue];
                protocl.office2 = (indexPath.row == 0)?0:[currentSelectKeyArray[indexPath.row - 1] integerValue];
                [self.view addSubview:protocl];
            }
            else{
                CMNewQueryViewController *queryVC = [CMNewQueryViewController new];
                queryVC.officeType = [officeSuperTypeArray[currentLeftIndex.row] integerValue];
                if (indexPath.row == 0) {
                    queryVC.subOfficeType = 0;
                }
                else{
                    queryVC.subOfficeType = [currentSelectKeyArray[indexPath.row - 1] integerValue];
                }
                [self.navigationController pushViewController:queryVC animated:YES];
            }
        }
        else
        {
            UITableViewCell *cellLeft = [leftView cellForRowAtIndexPath:currentLeftIndex];
            [CureMeUtils defaultCureMeUtil].cityCode = [fullProvinceArray[currentLeftIndex.row] integerValue];
            NSString *province = cellLeft.textLabel.text;
            
            UITableViewCell *cellRight = [rightView cellForRowAtIndexPath:indexPath];
            [CureMeUtils defaultCureMeUtil].userCity = [currentSelectKeyArray[indexPath.row] integerValue];
            NSString *city = cellRight.textLabel.text;
            
            [self.navigationController popViewControllerAnimated:YES];
            [_chooseDelegate refreshChosedLocation:province City:city Province:[fullProvinceArray[currentLeftIndex.row] integerValue] userCity:[currentSelectKeyArray[indexPath.row] integerValue]];
        }
        currentRightIndex = indexPath;
    }
}

- (void)pushNewQuary:(NSInteger) office1 and:(NSInteger) office2{
    CMNewQueryViewController *queryVC = [CMNewQueryViewController new];
    queryVC.officeType = office1;
    queryVC.subOfficeType = office2;
    queryVC.chatUserID = [CureMeUtils defaultCureMeUtil].userID;
    [self.navigationController pushViewController:queryVC animated:YES];
}

@end
