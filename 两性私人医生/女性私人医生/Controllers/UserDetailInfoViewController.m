//
//  UserDetailInfoViewController.m
//  CureMe
//
//  Created by Tim on 12-9-20.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "UserRegionViewController.h"
#import "UserDetailInfoViewController.h"

@interface UserDetailInfoViewController ()

@end

@implementation UserDetailInfoViewController
@synthesize nameField;
@synthesize ageField;
@synthesize telephoneField;
@synthesize regionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"我的个人信息"];
    
    NSString *phoneNo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PHONENO];
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PERSONALNAME];
    NSNumber *age = [[NSUserDefaults standardUserDefaults] objectForKey:USER_AGE];
    NSNumber *region = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
    
    NSLog(@"UserDetailInfoViewController viewDidLoad phone: %@, name: %@, age: %ld, region: %ld", phoneNo, name, (long)age.integerValue, (long)region.integerValue);
    
    telephoneField.text = phoneNo;
    nameField.text = name;
    if (age) {
        ageField.text = [NSString stringWithFormat:@"%ld", (long)age.integerValue];
    }
    if (region) {
        regionLabel.text = [[CureMeUtils defaultCureMeUtil] regionWithRegionID:region.integerValue];
    }
    
    // 注册notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfUserRegionSelected:) name:NTF_UserRegionSelected object:nil];
}

- (void)viewDidUnload
{
    [self setRegionLabel:nil];
    [self setNameField:nil];
    [self setAgeField:nil];
    [self setTelephoneField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    // 移除notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NTF_UserRegionSelected object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)ntfUserRegionSelected:(NSNotification *)note
{
    if (!note.userInfo || note.userInfo.count <= 0)
        return;
    
    NSNumber *regionID = [note.userInfo objectForKey:@"regionID"];
    NSString *region = [note.userInfo objectForKey:@"regionName"];
    if (!regionID || regionID.integerValue <= 0 || !region)
        return;
    
    [regionLabel setText:region];
}

- (IBAction)selectUserRegion:(id)sender
{
    UserRegionViewController *userRegionVC = [[UserRegionViewController alloc] initWithNibName:@"UserRegionViewController" bundle:nil];
    if (!userRegionVC)
        return;
    
    [self.navigationController pushViewController:userRegionVC animated:YES];
}

- (IBAction)submitUserInfo:(id)sender
{
    NSMutableString *post = [[NSMutableString alloc] init];
    [post appendFormat:@"action=upduserinfo&userid=%ld", (long)[CureMeUtils defaultCureMeUtil].userID];
    
    if (nameField.text && nameField.text.length > 0) {
        NSString *strName = [nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [post appendFormat:@"&name=%@", [strName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (ageField.text && ageField.text.length > 0) {
        NSString *strAge = [ageField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [post appendFormat:@"&age=%@", strAge];
    }
    
    if (telephoneField.text && telephoneField.text.length > 0) {
        NSString *strTel = [telephoneField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [post appendFormat:@"&mobile=%@", strTel];
    }
    
    if (regionLabel.text && regionLabel.text.length > 0) {
        NSString *strRegion = [regionLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [post appendFormat:@"&city=%ld", (long)[[[CureMeUtils defaultCureMeUtil] regionIDWithRegionName:strRegion] integerValue]];
    }

    if ([CureMeUtils defaultCureMeUtil].encodedLocateInfo) {
        [post appendFormat:@"&addrdetail=%@", [CureMeUtils defaultCureMeUtil].encodedLocateInfo];
    }
    
    NSData *response = sendRequest(@"m.php", post);

    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"submitUserInfo req: %@", strResp);
    
    NSDictionary *jsonData = parseJsonResponse(response);
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!result || result.integerValue != 1) {
        NSString *msg = [jsonData objectForKey:@"msg"];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"修改个人信息"
                              message:msg
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *msg = [jsonData objectForKey:@"msg"];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"修改个人信息"
                          message:msg
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    
    // 保存用户信息
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_PHONENO];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_PERSONALNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_AGE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_REGION];
    
    [[NSUserDefaults standardUserDefaults] setObject:telephoneField.text forKey:USER_PHONENO];
    [[NSUserDefaults standardUserDefaults] setObject:nameField.text forKey:USER_PERSONALNAME];
    NSNumber *age = [[NSNumber alloc] initWithInteger:ageField.text.integerValue];
    [[NSUserDefaults standardUserDefaults] setObject:age forKey:USER_AGE];
    NSNumber *regionID = [[CureMeUtils defaultCureMeUtil] regionIDWithRegionName:regionLabel.text];
    [[NSUserDefaults standardUserDefaults] setObject:regionID forKey:USER_REGION];
    
    if (![[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"UserDetailInfoViewController NSUserDefaults synchronize failed!");
    }

    {
        NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PHONENO];
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PERSONALNAME];
        NSNumber *a = [[NSUserDefaults standardUserDefaults] objectForKey:USER_AGE];
        NSNumber *r = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
        NSLog(@"UserDetailInfoViewController submitUserInfo phone: %@, name: %@, age: %ld, region: %ld", phone, name, (long)a.integerValue, (long)r.integerValue);
    }
    
    [[CureMeUtils defaultCureMeUtil] initUserPersonalInfo];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    if ([event allTouches].count != 1)
        return;
    
    UITouch *touch = [event.allTouches anyObject];
    if (![touch.view isKindOfClass:[UITextField class]]) {
        [nameField resignFirstResponder];
        [telephoneField resignFirstResponder];
        [ageField resignFirstResponder];
        [self.view resignFirstResponder];
    }
}

@end







