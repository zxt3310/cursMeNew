//
//  CMemulateLocationPageController.m
//  女性私人医生
//
//  Created by Zxt3310 on 2017/12/15.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "CMemulateLocationPageController.h"

@interface CMemulateLocationPageController ()
{
    NSArray *gpsArray;
    NSArray *city1NameAry;
    NSArray *city2NameAry;
    UITextView *locationStringTF;
    UIComboBox *gpsSelectCombox;
}
@end

@implementation CMemulateLocationPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"虚拟定位";
    
    UILabel *modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, SCREEN_WIDTH - 10, 40)];
    modeLabel.text = @"位置信息格式：116.494015,39.922614,41号，东四环中路，朝阳区，北京市，北京市";
    modeLabel.font = [UIFont systemFontOfSize:13];
    modeLabel.numberOfLines = 0;
    [self.view addSubview:modeLabel];
    
    locationStringTF = [[UITextView alloc] initWithFrame:CGRectMake(5, 80, SCREEN_WIDTH-10, 50)];
    locationStringTF.text = [[CureMeUtils defaultCureMeUtil].encodedLocateInfo stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    locationStringTF.textAlignment = NSTextAlignmentLeft;
    locationStringTF.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:locationStringTF];
    
    UILabel *lineLB = [[UILabel alloc] initWithFrame:CGRectMake(5, 130, SCREEN_WIDTH - 10, 1)];
    lineLB.layer.borderWidth = 1;
    lineLB.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:lineLB];
    
    UILabel *locationSelectLb = [[UILabel alloc] initWithFrame:CGRectMake(5, 170, SCREEN_WIDTH - 10, 15)];
    locationSelectLb.text = @"位置信息选择框";
    locationSelectLb.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:locationSelectLb];
    
    UIButton *startEmulateLoactionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startEmulateLoactionBtn.frame = CGRectMake(SCREEN_WIDTH/2-75, 350, 150, 40);
    [startEmulateLoactionBtn setTitle:@"设置虚拟咨询位置" forState:UIControlStateNormal];
    [startEmulateLoactionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [startEmulateLoactionBtn setBackgroundColor:UIColorFromHex(0xdddddd, 1)];
    startEmulateLoactionBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [startEmulateLoactionBtn addTarget:self action:@selector(emulateStart) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *stopEmulateLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stopEmulateLocationBtn.frame = CGRectMake(SCREEN_WIDTH/2-110, 460, 220, 40);
    [stopEmulateLocationBtn setTitle:@"取消虚拟咨询位置（用真实位置）" forState:UIControlStateNormal];
    [stopEmulateLocationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [stopEmulateLocationBtn setBackgroundColor:UIColorFromHex(0xdddddd, 1)];
    [stopEmulateLocationBtn addTarget:self action:@selector(emulateStop) forControlEvents:UIControlEventTouchUpInside];
    stopEmulateLocationBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [self.view addSubview:startEmulateLoactionBtn];
    [self.view addSubview:stopEmulateLocationBtn];
    [self addComboxSelector];
}

- (void)addComboxSelector{
    NSString *urlStr = @"http://new.medapp.ranknowcn.com/api/m.php?action=getgpsandcitylist&version=3.0";
    NSData *responseData = sendGETRequest(urlStr);
    NSDictionary *returnDic = parseJsonResponse(responseData);
    NSArray *dataAry = [returnDic objectForKey:@"data"];
    if (!dataAry) {
        return;
    }
    
    NSMutableArray *gps_str_ary = [[NSMutableArray alloc] init];
    NSMutableArray *cityNameAry = [[NSMutableArray alloc] init];
    NSMutableArray *city1arry = [[NSMutableArray alloc] init];
    NSMutableArray *city2arry = [[NSMutableArray alloc] init];
    
    for (int i=1; i<dataAry.count; i++) {
        NSDictionary *gpsDic = dataAry[i];
        NSString *gpsStr = [gpsDic objectForKey:@"gps"];
        NSString *province = [gpsDic objectForKey:@"cityname"];
        NSString *cityName = [gpsDic objectForKey:@"city2name"];
        [gps_str_ary addObject:gpsStr];
        [cityNameAry addObject:[NSString stringWithFormat:@"%@ - %@",province,cityName]];
        [city1arry addObject:province];
        [city2arry addObject:cityName];
    }
    gpsArray = [gps_str_ary copy];
    city1NameAry = [city1arry copy];
    city2NameAry = [city2arry copy];
    
    gpsSelectCombox = [[UIComboBox alloc] initWithFrame:CGRectMake(5, 210, SCREEN_WIDTH - 10, 40)];
    gpsSelectCombox.comboList = [cityNameAry copy];
    gpsSelectCombox.delegate = self;
    [self.view addSubview:gpsSelectCombox];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)emulateStart{
    if (gpsSelectCombox.selectId == -1) {
        [self alert:@"请选择虚拟位置"];
        return;
    }
    NSString *addStr = [gpsArray[gpsSelectCombox.selectId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //由于主页城市名称只取省市的名字（不带省市单位）而接口数据不带省市单位，故增加单位方便取值。
    NSString *province = [NSString stringWithFormat:@"%@市",city1NameAry[gpsSelectCombox.selectId]];
    NSString *city = city2NameAry[gpsSelectCombox.selectId];
    if (addStr) {
        [[NSUserDefaults standardUserDefaults] setObject:addStr forKey:EMULATE_LOCATION];
        [[NSUserDefaults standardUserDefaults] setObject:province forKey:EMULATE_LOCATION_PROVINCE];
        [[NSUserDefaults standardUserDefaults] setObject:city forKey:EMULATE_LOCATION_CITY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self alert:@"已开启虚拟定位"];
    }
}

- (void)emulateStop{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EMULATE_LOCATION];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EMULATE_LOCATION_PROVINCE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EMULATE_LOCATION_CITY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self alert:@"已关闭虚拟定位"];
}

- (void)alert:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"消息" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)UIComboBox:(UIComboBox *)comboBox didSelectRow:(NSIndexPath *)indexPath{
    locationStringTF.text = gpsArray[indexPath.row - 1];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [gpsSelectCombox dismissTable];
}
@end
