//
//  RegisterViewController.h
//  CureMe
//
//  Created by Tim on 12-8-14.
//  Copyright (c) 2012年 Tim. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomBaseViewController.h"
#import "CMPickerViewController.h"
#import "HiChat.h"

@class LoginViewController;

@interface RegisterViewController : CustomBaseViewController<UIAlertViewDelegate, CMPickerDelegate>

{
    LoginViewController *loginViewController;
    NSInteger userRegion;
    NSNumber *cityID;
    NSString *cityName;
    
//    MKReverseGeocoder *geocoder;
//    CLLocationManager *locationManager;
    
    // 选择地区的Modal ViewController
    CMPickerViewController *pickerViewController;
}

@property (strong, nonatomic) IBOutlet UITextField *phoneNoField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UILabel *cityField;


- (IBAction)registerBtnClicked:(id)sender;
- (IBAction)gotoLoginBtnClicked:(id)sender;
- (IBAction)selectRegionBtnClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *line1Lb;
@property (strong, nonatomic) IBOutlet UILabel *line2Lb;


- (void)startLocationManager;
- (void)stopLocationManager;


- (void)ntfLocateServiceNotAvailable:(NSNotification *)note;
- (void)mainThreadAlertLocateServiceNotAvailable;
- (void)ntfLocationComfirmed:(NSNotification *)note;

@end
