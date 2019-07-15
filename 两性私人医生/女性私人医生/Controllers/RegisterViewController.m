//
//  RegisterViewController.m
//  CureMe
//
//  Created by Tim on 12-8-14.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "CureMeUtils.h"
//#import "UserRegionViewController.h"
#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "CMMainTabViewController.h"
#import "CMMyChatListViewController.h"
#import "MyBookListViewController.h"
#import "KGModal.h"


@interface RegisterViewController ()

@end

@implementation RegisterViewController

@synthesize phoneNoField;
@synthesize passwordField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
//    locationManager = nil;
    [self setPhoneNoField:nil];
    [self setPhoneNoField:nil];
    [self setPasswordField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NTF_LocateServiceNotAvailable object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    [phoneNoField setEnabled:YES];

    [passwordField setEnabled:YES];
    passwordField.secureTextEntry = YES;
    
    _line1Lb.layer.borderWidth = _line2Lb.layer.borderWidth = 1;
    _line1Lb.layer.borderColor = _line2Lb.layer.borderColor = UIColorFromHex(0xbfbfbf,0.3).CGColor;
    
    [self.navigationItem setTitle:@"注册账号"];

//    // 设置NavigationBar的返回按钮效果
//    UIImage *oriImage = [UIImage imageNamed:@"rightitem_button_alpha.png"];
//    UIImage *stretchableImage = [oriImage stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
    
//    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
//    
//    // Set the title to use the same font and shadow as the standard back button
//    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
//    button.titleLabel.textColor = [UIColor whiteColor];
//    button.titleLabel.shadowOffset = CGSizeMake(0,-1);
//    button.titleLabel.shadowColor = [UIColor darkGrayColor];
//    // Set the break mode to truncate at the end like the standard back button
//    button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
//    // Inset the title on the left and right
//    button.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
//    // Make the button as high as the passed in image
//    // Measure the width of the text
//    button.frame = CGRectMake(0, 0, 0, stretchableImage.size.height);;
//    NSString *t = [NSString stringWithFormat:@"完成注册"];
//    CGSize textSize = [t sizeWithFont:button.titleLabel.font];
//    // Change the button's frame. The width is either the width of the new text or the max width
//    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, (textSize.width + (14.0 * 1.5)) > MAX_BACK_BUTTON_WIDTH ? MAX_BACK_BUTTON_WIDTH : (textSize.width + (14.0 * 1.5)), button.frame.size.height);
//    
//    // Set the text on the button
//    [button setTitle:t forState:UIControlStateNormal];
//    
//    [button setBackgroundImage:stretchableImage forState:UIControlStateNormal];
//    // Add an action for going back
//    [button addTarget:self action:@selector(registerBtn:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.rightBarButtonItem = barBtnItem;

    // 注册消息监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfLocateServiceNotAvailable:) name:NTF_LocateServiceNotAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfLocationComfirmed:) name:NTF_LocationComfirmed object:nil];
    
    userRegion = -1;
}

- (void)viewDidUnload
{
    [self setPhoneNoField:nil];
    [self setPhoneNoField:nil];
    [self setPasswordField:nil];
    [self setCityField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    cityID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CITY];
    cityName = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CITY_NAME];
    NSNumber *regionNum = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];

    if (![CureMeUtils defaultCureMeUtil].encodedLocateInfo || [CureMeUtils defaultCureMeUtil].encodedLocateInfo.length <= 0) {
        [[CureMeUtils defaultCureMeUtil] startLocationing];
        //        [[CureMeUtils defaultCureMeUtil] startLocationing];
    }
    else {
        if (!regionNum) {
            return;
        }
        
        NSString *province = [[CureMeUtils defaultCureMeUtil] regionWithRegionID:regionNum.integerValue];
        if (userRegion < 0) {
            userRegion = [regionNum integerValue];
        }
        
        if (!_cityField.text || _cityField.text.length <= 0) {
            if (!cityName) {
                _cityField.text = [NSString stringWithFormat:@"%@", province];
            }
            else {
                _cityField.text = [NSString stringWithFormat:@"%@ %@", province, cityName];
            }
        }

//        NSDictionary *allRegions = [[CureMeUtils defaultCureMeUtil] regionDictionaryForUser];
//        NSArray *regionKeys = allRegions.allKeys;
//        for(NSString *key in regionKeys) {
//            if ([province isEqualToString:[allRegions objectForKey:key]] || [province hasPrefix:[allRegions objectForKey:key]]) {
//                if (userRegion < 0) {
//                    userRegion = key.integerValue;
//                }
//                if (!_cityField.text || _cityField.text.length <= 0) {
//                    if (![CureMeUtils defaultCureMeUtil].cityOrDistrict) {
//                        _cityField.text = [NSString stringWithFormat:@"%@", province];
//                    }
//                    else {
//                        _cityField.text = [NSString stringWithFormat:@"%@ %@", province, cityName];
//                    }
//                }
//                NSLog(@"region ID: %d name: %@", userRegion, _cityField.text);
//                break;
//            }
//        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)registerBtnClicked:(id)sender {
    if (userRegion <= 0 || _cityField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"注册"
                              message:@"请选择您的所在地区"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!phoneNoField.text || phoneNoField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"注册"
                              message:@"请输入您要注册用户名"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!passwordField.text || passwordField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"注册"
                              message:@"请输入您的账号密码"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!_cityField.text || _cityField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"注册"
                              message:@"请选择您所在的地区，以方便我们为您提供更加精准的服务"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!cityName || !cityID) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册" message:@"请点击“选择”地区按钮选择您所在的详细位置，以便我们更好的为您提供服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    // 发送注册请求，获取验证码
    // 发送注册请求，如果失败则提示错误（回到根页面）；如果成功则回到登陆页面
    NSString *post = nil;
    NSData *returnData = nil;
    NSString *responseString = nil;
    
    // 发送注册信息请求
    NSString *encodeAddr = [CureMeUtils defaultCureMeUtil].encodedLocateInfo;
    NSString *encodedUserName = [[phoneNoField text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedPassword = [[passwordField text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 如果是“未注册用户”
    if ([CureMeUtils defaultCureMeUtil].isUnRegLoginUser) {
        post = [[NSString alloc] initWithFormat:@"action=upduserlogindata&userid=%ld&username=%@&password=%@&city=%ld&city2=%ld", (long)[CureMeUtils defaultCureMeUtil].userID, encodedUserName, encodedPassword, (long)userRegion, (long)cityID.integerValue];
    }
    // 如果是“全新注册用户”
    else {
        post = [[NSString alloc] initWithFormat:@"action=register&mobile=&username=%@&password=%@&city=%ld&city2=%ld&addrdetail=%@&token=%@", encodedUserName, encodedPassword, (long)userRegion, (long)cityID.integerValue, encodeAddr ? encodeAddr : @"", nil];
    }
    returnData = sendRequest(@"m.php", post);
    
    responseString = [[NSString alloc] initWithData:returnData encoding:NSASCIIStringEncoding];
    NSLog(@"action=register resp: %@", responseString);
    
    NSDictionary *jsonData = parseJsonResponse(returnData);
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!result || result.integerValue != 1) {
        NSLog(@"registerBtn register user result invalid");
        NSString *errorMsg = [jsonData objectForKey:@"msg"];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"注册"
                              message:errorMsg
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"注册"
                          message:@"注册成功！"
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    
    NSNumber *userID = [jsonData objectForKey:@"msg"];
    
    [[NSUserDefaults standardUserDefaults] setObject:phoneNoField.text forKey:USER_REGISTERNAME];
    [[NSUserDefaults standardUserDefaults] setObject:passwordField.text forKey:USER_PASSWORD];
    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USER_ID];
    NSNumber *SWTID = [[NSNumber alloc] initWithInteger:0];
    [[NSUserDefaults standardUserDefaults] setObject:SWTID forKey:USER_SWT_ID];
    // 保存上次用户登录ID
    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USER_LASTUSERID];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithInteger:userRegion] forKey:USER_REGION];
    [[NSUserDefaults standardUserDefaults] setObject:cityID forKey:USER_CITY];
    [[NSUserDefaults standardUserDefaults] setObject:cityName forKey:USER_CITY_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_PERSONALNAME];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_PHONENO];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_AGE];
    
    if (![[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"RegisterViewController NSUserDefaults synchronize failed!");
    }
    
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
    
    [[CureMeUtils defaultCureMeUtil] initUserLoginInfo];
    [[CureMeUtils defaultCureMeUtil] initUserPersonalInfo];
    
//    {
//        CMMainTabViewController *mainTabVC = (CMMainTabViewController *)[[self.navigationController viewControllers] objectAtIndex:0];
//
//        NSMutableArray *VCs = [[NSMutableArray alloc] initWithArray:[mainTabVC viewControllers]];
//        // “我的咨询”页面
//        UIViewController *listViewController = [VCs objectAtIndex:1];
//        if (![listViewController isKindOfClass:[CMMyChatListViewController class]]) {
//            CMMyChatListViewController *myChatListVC = [[CMMyChatListViewController alloc] initWithNibName:@"CMMyChatListViewController" bundle:nil]; //[[CMMyChatListViewController alloc] initWithStyle:UITableViewStylePlain];
//            [VCs setObject:myChatListVC atIndexedSubscript:1];
//        }
//        
//        // “我的预约”页面
//        listViewController = [VCs objectAtIndex:3];
//        if (![listViewController isKindOfClass:[MyBookListViewController class]]) {
//            MyBookListViewController *myBookListVC = [[MyBookListViewController alloc] initWithNibName:@"MyBookListViewController" bundle:nil]; //[[MyBookListViewController alloc] initWithStyle:UITableViewStylePlain];
//            [VCs setObject:myBookListVC atIndexedSubscript:3];
//        }
//        [mainTabVC setViewControllers:[VCs copy]];
//    }

    // 如果注册成功，发送最新的Push token + GUID + userid
    updateIOSPushInfo();
    
        [[self navigationController] popToRootViewControllerAnimated:YES];
}

- (IBAction)gotoLoginBtnClicked:(id)sender {
    //[self.navigationController popViewControllerAnimated:NO];
    
    if ([CureMeUtils defaultCureMeUtil].hasLogin) {
        NSString *post = [NSString stringWithFormat:@"action=logout&userid=%ld&lastactivity=%.2f", (long)[CureMeUtils defaultCureMeUtil].userID, [[NSDate alloc] init].timeIntervalSince1970];
        NSLog(@"logoff %@", post);
        
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *logoffStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"logOff: %@", logoffStr);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSLog(@"logOff error: %@", [jsonData objectForKey:@"msg"]);
            return;
        }
        [[CureMeUtils defaultCureMeUtil] resetUserInfo];
        [[CureMeUtils defaultCureMeUtil] clearUserInfoStore];
    }

    if (!loginViewController) {
        loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController"
                                                                          bundle:nil];
    }
    
    if (loginViewController) {
        [[self navigationController] pushViewController:loginViewController animated:YES];
    }
}

#pragma mark CMPickerDelegate
- (void)didSelectOK:(NSDictionary *)firstUnit andSecondColumn:(NSDictionary *)secondUnit andThirdColumn:(NSDictionary *)thirdUnit
{
    if (!firstUnit) {
        return;
    }
    
    userRegion = [((NSNumber *)[firstUnit objectForKey:@"id"]) integerValue];
    cityID = [secondUnit objectForKey:@"id"];
    cityName = [secondUnit objectForKey:@"name"];
    _cityField.text = [NSString stringWithFormat:@"%@ %@", [firstUnit objectForKey:@"name"], cityName];
    
    [[KGModal sharedInstance] hideAnimated:YES];
}

- (IBAction)selectRegionBtnClicked:(id)sender {
    if (!pickerViewController) {
        pickerViewController = [[CMPickerViewController alloc] initWithNibName:@"CMPickerViewController" bundle:nil];
        [pickerViewController setPickerColumnCount:PICKER_COLUMN_TWO];
    }
    
    // 设置省份
    NSDictionary *regionDict = [[CureMeUtils defaultCureMeUtil] regionDictionaryForUser];
    NSArray *regionArray = [[CureMeUtils defaultCureMeUtil] regionSortedKeys];
    NSMutableArray *pickerDataArray = [[NSMutableArray alloc] init];
    for (NSString *key in regionArray) {
        [pickerDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:key, @"id", [regionDict objectForKey:key], @"name", nil]];
    }
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

- (void)startLocationManager
{
//    if (!locationManager) {
//        locationManager = [[CLLocationManager alloc] init];
//        [locationManager setDelegate:self];
//        locationManager.distanceFilter = 10.0f; // we don't need to be any more accurate than 10m
//        locationManager.purpose = @"这将会被使用于获取您的位置信息";
//    }
//    
//    [locationManager startUpdatingLocation];
}

- (void)stopLocationManager
{
    
}

//- (MKReverseGeocoder *)geoCoder:(CLLocationCoordinate2D)coordinate
//{
//    if (geocoder) {
//        return geocoder;
//    }
//    
//    geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
//    [geocoder setDelegate:self];
//
//    return geocoder;
//}
//
//- (void)cancelGeocoder
//{
//    if (geocoder) {
//        [geocoder cancel];
//    }
//}


- (void)ntfLocateServiceNotAvailable:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NTF_LocateServiceNotAvailable object:nil];
    
    [self performSelectorOnMainThread:@selector(mainThreadAlertLocateServiceNotAvailable) withObject:nil waitUntilDone:NO];
}

- (void)mainThreadAlertLocateServiceNotAvailable
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位未开启" message:@"开启定位服务有助于您找到合适医生，提高咨询问题的回复率。\nios6以下:设置->定位服务\nios6版本:设置->隐私->定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
}

- (void)ntfLocationComfirmed:(NSNotification *)note
{    
    NSString *province = [CureMeUtils defaultCureMeUtil].province;
    NSDictionary *allRegions = [[CureMeUtils defaultCureMeUtil] regionDictionaryForUser];
    NSArray *regionKeys = allRegions.allKeys;
    for(NSString *key in regionKeys) {
        if ([province isEqualToString:[allRegions objectForKey:key]] || [province hasPrefix:[allRegions objectForKey:key]]) {
            if (userRegion < 0) {
                userRegion = key.integerValue;
            }
            if (!_cityField.text || _cityField.text.length <= 0) {
                _cityField.text = [NSString stringWithFormat:@"%@ %@", province, [CureMeUtils defaultCureMeUtil].cityOrDistrict];
            }
            NSLog(@"region ID: %ld name: %@", (long)userRegion, _cityField.text);
            break;
        }
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"RegisterViewController didReceiveMemoryWarning");
    
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark CLLocationManagerDelegate

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0)
// iOS6 代码
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *lastLocation = [locations lastObject];
    if (!lastLocation) {
        return;
    }
    
    if (fabs([lastLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30)
    {
        return;
    }
    
    CLGeocoder *newGeocoder = [[CLGeocoder alloc] init];
    
    for (CLLocation *location in locations) {
        NSLog(@"location: %@\n", location);
        NSLog(@"latitude: %.2f  longitude: %.2f", location.coordinate.latitude, location.coordinate.longitude);
    }
    NSLog(@"\n\n");
    
//    [locationManager stopUpdatingLocation];
    [newGeocoder reverseGeocodeLocation:lastLocation completionHandler:^(NSArray *placemarks,NSError *error)
     {
         for(CLPlacemark *placemark in placemarks)
         {
             NSLog(@"latitude: %g", lastLocation.coordinate.latitude);
             NSLog(@"longitude: %g", lastLocation.coordinate.longitude);
//             NSString *province = [placemark.administrativeArea substringToIndex:placemark.administrativeArea.length - 1];
             NSString *province = placemark.administrativeArea;
             NSString *format = [NSString stringWithFormat:@"administrativeArea: %@\nsubAdministrativeArea: %@\nlocality: %@\nsubLocality: %@\nCountry: %@\nName: %@\nSubLocality: %@\nThoroughfare: %@\nregion: %@\n",
                                 placemark.administrativeArea,
                                 placemark.subAdministrativeArea,
                                 placemark.locality,
                                 placemark.subLocality,
                                 placemark.country,
                                 [placemark.addressDictionary objectForKey:@"Name"],
                                 [placemark.addressDictionary objectForKey:@"SubLocality"],
                                 [placemark.addressDictionary objectForKey:@"Thoroughfare"],
                                 placemark.region];
             NSLog(@"%@", format);
             
             NSLog(@"Time: %@", [[CureMeUtils defaultCureMeUtil].dateFormatter stringFromDate:lastLocation.timestamp]);
             NSLog(@"Country %@", placemark.country);
             NSLog(@"%@", placemark.addressDictionary);

             //                 [[placemark.addressDictionary objectForKey:@"City"] substringToIndex:2];
             NSDictionary *allRegions = [[CureMeUtils defaultCureMeUtil] regionDictionaryForUser];
             NSArray *regionKeys = allRegions.allKeys;
             for(NSString *key in regionKeys) {
                 if ([province isEqualToString:[allRegions objectForKey:key]] || [province hasPrefix:[allRegions objectForKey:key]]) {
                     userRegion = key.integerValue;
                     NSLog(@"region ID: %ld", (long)userRegion);
                     break;
                 }
             }
         }
     }];
//    [activityIndicator stopAnimating];
}
#endif

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver >= 5.0) {
        // 如果缓存的地址时间间隔过长，不处理，继续定位
        NSDate* newLocDate = newLocation.timestamp;
        NSTimeInterval interval = [newLocDate timeIntervalSinceNow];
        if (abs(interval) > 30) {
            return;
        }
        
        // iOS 5 code
//        [locationManager stopUpdatingLocation];
        CLGeocoder *newGeocoder=[[CLGeocoder alloc]init];
        [newGeocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks,NSError *error)
         {
             for(CLPlacemark *placemark in placemarks)
             {
                 NSLog(@"latitude: %g", newLocation.coordinate.latitude);
                 NSLog(@"longitude: %g", newLocation.coordinate.longitude);
                 //                 NSString *province = [placemark.administrativeArea substringToIndex:placemark.administrativeArea.length - 1];
                 NSString *province = placemark.administrativeArea;
                 NSLog(@"administrativeArea:%@\n subAdministrativeArea:%@\n locality:%@\n subLocality:%@\n",
                       placemark.administrativeArea,
                       placemark.subAdministrativeArea,
                       placemark.locality,
                       placemark.subLocality);
                 
                 NSLog(@"Time: %@", [[CureMeUtils defaultCureMeUtil].dateFormatter stringFromDate:newLocDate]);
                 NSLog(@"Country %@", placemark.country);
                 NSLog(@"%@", placemark.addressDictionary);
                 
                 NSLog(@"Name %@", [placemark.addressDictionary objectForKey:@"Name"]);
                 
                 NSLog(@"SubLocality %@", [placemark.addressDictionary objectForKey:@"SubLocality"]);
                 
                 NSLog(@"Thoroughfare %@", [placemark.addressDictionary objectForKey:@"Thoroughfare"]);
                 
                 NSLog(@"administrativeArea %@", placemark.administrativeArea);
                 NSLog(@"%@", placemark.region);
                 //                 [[placemark.addressDictionary objectForKey:@"City"] substringToIndex:2];
                 NSDictionary *allRegions = [[CureMeUtils defaultCureMeUtil] regionDictionaryForUser];
                 NSArray *regionKeys = allRegions.allKeys;
                 for(NSString *key in regionKeys) {
                     if ([province isEqualToString:[allRegions objectForKey:key]] || [province hasPrefix:[allRegions objectForKey:key]]) {
                         userRegion = key.integerValue;
                         NSLog(@"region ID: %ld", (long)userRegion);
                         break;
                     }
                 }
             }
         }];
//        [activityIndicator stopAnimating];
    }
    else {
        // 如果缓存的地址时间间隔过长，不处理，继续定位
        // iOS 4.x code
        NSDate* newLocDate = newLocation.timestamp;
        NSTimeInterval interval = [newLocDate timeIntervalSinceNow];
        if (abs(interval) > 10) {
            return;
        }
        else {
//            [locationManager stopUpdatingLocation];
//            [[self geoCoder:newLocation.coordinate] start];
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
//    [locationManager stopUpdatingLocation];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"locationManager didFailWithError: %@", error);
}

#pragma mark MKReverseGeocoderDelegate
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark NS_DEPRECATED_IOS(3_0,5_0)
{
//    NSString *address = [NSString stringWithFormat:@"%@ %@ %@ %@ %@%@",
//                         placemark.country,
//                         placemark.administrativeArea,
//                         placemark.locality,
//                         placemark.subLocality,
//                         placemark.thoroughfare,
//                         placemark.subThoroughfare];
    NSString *address = [NSString stringWithFormat:@"%@ %@", placemark.country, placemark.administrativeArea];
    [_cityField setText:address];

    NSLog(@"administrativeArea:%@\n subAdministrativeArea:%@\n locality:%@\n subLocality:%@\n",
          placemark.administrativeArea,
          placemark.subAdministrativeArea,
          placemark.locality,
          placemark.subLocality);
    
    NSString *province = [placemark.administrativeArea substringToIndex:placemark.administrativeArea.length - 1];
    NSLog(@"Province: %@", province);
    
    NSDictionary *allRegions = [[CureMeUtils defaultCureMeUtil] regionDictionaryForUser];
    NSArray *regionKeys = allRegions.allKeys;
    for(NSString *key in regionKeys) {
        if ([province isEqualToString:[allRegions objectForKey:key]]) {
            userRegion = key.integerValue;
            NSLog(@"region ID: %ld", (long)userRegion);
            break;
        }
    }

//    [self cancelGeocoder];

    // 界面状态提示
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//    [activityIndicator stopAnimating];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error NS_DEPRECATED_IOS(3_0,5_0)
{
//    [self cancelGeocoder];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (event.allTouches.count > 1) {
        return;
    }
    
    UITouch *touch = event.allTouches.anyObject;
    if (![touch.view isKindOfClass:[UITextField class]]) {
        [phoneNoField resignFirstResponder];
        [passwordField resignFirstResponder];
        [self.view resignFirstResponder];
    }
}

@end







