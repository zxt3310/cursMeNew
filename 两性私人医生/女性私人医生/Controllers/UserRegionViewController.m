//
//  UserRegionViewController.m
//  CureMe
//
//  Created by Tim on 12-9-20.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "UserRegionViewController.h"

@interface UserRegionViewController ()

@end

@implementation UserRegionViewController
@synthesize userRegionPicker;

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
    if (!regionArray) {
        regionArray = [[NSMutableArray alloc] init];
    }
    
    pickedIndex = 0;
    
    // 初始化城市列表
    NSMutableDictionary *initRegions = [[NSMutableDictionary alloc] initWithDictionary:[[CureMeUtils defaultCureMeUtil] regionDictionaryForUser]];
    NSArray *sortedRegionKeys = [[CureMeUtils defaultCureMeUtil] regionSortedKeys];
    for (NSString *key in sortedRegionKeys) {
        [regionArray addObject:[initRegions objectForKey:key]];
    }
    NSLog(@"regionArray: %@", regionArray);

    assert(regionArray.count > 0);
    
    [userRegionPicker reloadAllComponents];
}

- (void)viewDidUnload
{
    [self setUserRegionPicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self.navigationItem setTitle:@"选择您的所在地区"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)threadInitCityList
{
    @autoreleasepool {
        NSString *post = [[NSString alloc] initWithFormat:@"action=getcitylist"];
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"threadInitCityList req: %@", strResp);
    }
}

#pragma mark button actions
- (IBAction)pickRegionOK:(id)sender
{
    NSNumber *region = nil;
    
    if (pickedIndex < regionArray.count) {
        NSString *regionKey = [[[CureMeUtils defaultCureMeUtil] regionSortedKeys] objectAtIndex:pickedIndex];
        region = [NSNumber numberWithInteger:[regionKey integerValue]];
    }
    
    NSString *regionName = [NSString stringWithFormat:@"%@", [regionArray objectAtIndex:pickedIndex]];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:region, @"regionID", regionName, @"regionName", nil];
    NSLog(@"regionID: %ld name: %@", (long)region.integerValue, regionName);
    
    NSNotification *note = [NSNotification notificationWithName:NTF_UserRegionSelected object:self userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:note];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component > 0)
        return @"";
    
    if (!regionArray)
        return @"";
    
    if (row >= regionArray.count)
        return @"";
    
    NSString *title = [regionArray objectAtIndex:row];
    NSLog(@"titleForRow %ld %@", (long)row, title);
    
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"didSelectRow %ld", (long)row);
    pickedIndex = row;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component > 0)
        return 0;
    
    if (!regionArray)
        return 0;
    
	return regionArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
@end
