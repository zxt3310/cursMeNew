//
//  CMDataPickEditCell.m
//  私密健康医生
//
//  Created by Tim on 13-1-18.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMDataPickEditCell.h"

@implementation CMDataPickEditCell


@synthesize picker;

- (void)initalizeInputView {
	self.picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
	self.picker.showsSelectionIndicator = YES;
	self.picker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.picker.delegate = self;
    self.picker.dataSource = self;
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UIViewController *popoverContent = [[UIViewController alloc] init];
		popoverContent.view = self.picker;
		popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
		popoverController.delegate = self;
	}
    
    float inset = 10.0;
    variableLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset, inset, 50, 20)];
    [variableLabel setTextColor:[UIColor grayColor]];
    [variableLabel setFont:[UIFont systemFontOfSize:16]];
    [variableLabel setBackgroundColor:[UIColor clearColor]];
    variableLabel.text = @"地区";
    [self.contentView addSubview:variableLabel];

    valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, inset, 150, 20)];
    [valueLabel setFont:[UIFont systemFontOfSize:15]];
    [valueLabel setBackgroundColor:[UIColor clearColor]];
	[valueLabel setTextColor:[UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0]];
    [self.contentView addSubview:valueLabel];

    // 初始化省/直辖市，市区值
    NSNumber *regionNum = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
    NSNumber *cityNum = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CITY];
    lastCityName = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CITY_NAME];
    if (regionNum) {
        lastRegionID = regionNum.integerValue;
        if (cityNum) {
            lastCityID = [cityNum integerValue];
        }
        else {
            lastCityID = 0;
        }
        valueLabel.text = [NSString stringWithFormat:@"%@ %@", [[CureMeUtils defaultCureMeUtil] regionWithRegionID:lastRegionID], lastCityName];
    }
    else {
        lastRegionID = lastCityID = 0;
    }

    // 省份、直辖市列表
    regionArray = [[NSMutableArray alloc] init];
    NSDictionary *regionDict = [[CureMeUtils defaultCureMeUtil] regionDictionaryForUser];
    NSArray *rArray = [[CureMeUtils defaultCureMeUtil] regionSortedKeys];
    [regionArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"id", @"<未选择>", @"name", nil]];
    
    for (int i = 0; i < [rArray count]; i++) {
        NSString *key = [rArray objectAtIndex:i];
        NSDictionary *region = [NSDictionary dictionaryWithObjectsAndKeys:key, @"id", [regionDict objectForKey:key], @"name", nil];
        [regionArray addObject:region];
        if ([key integerValue] == lastRegionID) {
            lastRegionIndex = i + 1;
            selectedRegion = region;
        }
    }
    NSLog(@"regionArray: %@", regionArray);
    assert(regionArray.count > 1);
    [self.picker selectRow:lastRegionIndex inComponent:0 animated:YES];

    // 市区列表
    NSArray *cArr = [[CureMeUtils defaultCureMeUtil] cityArrayWithRegionID:lastRegionID];
    [self setSecondColumn:cArr];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		[self initalizeInputView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		[self initalizeInputView];
    }
    return self;
}

- (UIView *)inputView {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return nil;
	} else {
		return self.picker;
	}
}

- (UIView *)inputAccessoryView {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return nil;
	} else {
		if (!inputAccessoryView) {
			inputAccessoryView = [[UIToolbar alloc] init];
			inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
			inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			[inputAccessoryView sizeToFit];
			CGRect frame = inputAccessoryView.frame;
			frame.size.height = 44.0f;
			inputAccessoryView.frame = frame;
			
			UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
			UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
			
			NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
			[inputAccessoryView setItems:array];
		}
		return inputAccessoryView;
	}
}

- (void)done:(id)sender {
    if ([[selectedRegion objectForKey:@"id"] integerValue] == 0 || [[selectedCity objectForKey:@"id"] integerValue] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改所在地区" message:@"确认之前，请选择您所在的地区，谢谢。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self resignFirstResponder];

    // 如果地区ID相同，则不请求更新
    if (selectedCity && [[selectedCity objectForKey:@"id"] integerValue] == lastCityID) {
        return;
    }
    
    // 更新地区ID
    lastRegionID = [[selectedRegion objectForKey:@"id"] integerValue];
    if (selectedCity) {
        lastCityID = [[selectedCity objectForKey:@"id"] integerValue];
    }
    else {
        lastCityID = 0;
    }
    
    NSString *regionName = [selectedRegion objectForKey:@"name"];
    NSString *cityName = nil;
    if (selectedCity) {
        cityName = [selectedCity objectForKey:@"name"];
    }
    
    valueLabel.text = [NSString stringWithFormat:@"%@ %@", regionName, cityName];

    // 此处发送修改请求    
    NSString *post = [NSString stringWithFormat:@"action=upduserinfo&userid=%ld&city=%ld&city2=%ld", (long)[CureMeUtils defaultCureMeUtil].userID, (long)lastRegionID, (long)lastCityID];
    
    NSData *response = sendRequest(@"m.php", post);
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"PickerViewController post: %@, resp: %@", post, strResp);
    
    // 本地化存储设置，并重新初始化CureMeUtils
    [[CureMeUtils defaultCureMeUtil] updateUserRegion:[selectedRegion objectForKey:@"id"]];
    if (selectedCity) {
        [[CureMeUtils defaultCureMeUtil] updateUserCity:[selectedCity objectForKey:@"id"] andCityName:[selectedCity objectForKey:@"name"]];
    }
}

- (BOOL)becomeFirstResponder {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		CGSize pickerSize = [self.picker sizeThatFits:CGSizeZero];
		CGRect frame = self.picker.frame;
		frame.size = pickerSize;
		self.picker.frame = frame;
        [self.picker selectRow:lastRegionIndex inComponent:0 animated:YES];
        [self.picker selectRow:lastCityIndex inComponent:1 animated:YES];
        
		popoverController.popoverContentSize = pickerSize;
		[popoverController presentPopoverFromRect:self.detailTextLabel.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		// resign the current first responder
        UITableView *tableView = nil;
        if (IOS_VERSION < 7) {
            tableView = (UITableView *)self.superview;
        }
        else {
            tableView = (UITableView *)self.superview.superview;
        }
        
		for (UIView *subview in tableView.subviews) {
			if ([subview isFirstResponder]) {
				[subview resignFirstResponder];
			}
		}
		return NO;
	} else {
		[self.picker setNeedsLayout];
	}
	return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    UITableView *tableView = nil;
    if (IOS_VERSION < 7) {
        tableView = (UITableView *)self.superview;
    }
    else {
        tableView = (UITableView *)self.superview.superview;
    }

	[tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
	return [super resignFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	if (selected) {
		[self becomeFirstResponder];
	}
}

- (void)deviceDidRotate:(NSNotification*)notification {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// we should only get this call if the popover is visible
		[popoverController presentPopoverFromRect:self.detailTextLabel.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		[self.picker setNeedsLayout];
	}
}

- (void)setSecondColumn:(NSArray *)secondColumn
{
    if (!cityArray) {
        cityArray = [[NSMutableArray alloc] init];
    }
    [cityArray removeAllObjects];

    selectedCity = nil;
    lastCityIndex = 0;
    [cityArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"id", @"<未选择>", @"name", nil]];
    NSLog(@"Picker setSecondColumn: %@", secondColumn);
    for (int i = 0; i < [secondColumn count]; i++) {
        NSDictionary *data = [secondColumn objectAtIndex:i];
        NSLog(@"Picker cityData: %@", data);
        [cityArray addObject:data];
        if (lastCityName && [lastCityName isEqualToString:[data objectForKey:@"name"]]) {
            lastCityIndex = i + 1;
            selectedCity = data;
        }
    }

    [self.picker reloadComponent:1];
    [self.picker selectRow:lastCityIndex inComponent:1 animated:YES];
}

#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        if ([regionArray count] >= row) {
            NSString *name = [[regionArray objectAtIndex:row] objectForKey:@"name"];
            NSLog(@"pickerView clmn0 titleForRow: %@", name);
            return name;
        }
        return nil;
    }
    else if (component == 1) {
        if (cityArray && [cityArray count] >= row) {
            NSString *name = [[cityArray objectAtIndex:row] objectForKey:@"name"];
            NSLog(@"pickerView clmn1 titleForRow: %@", name);
            return name;
        }
        
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"didSelectRow %ld", (long)row);
    // 如果选择了省份、直辖市
    if (component == 0) {
        // 记录选中的省、直辖市
        selectedRegion = [regionArray objectAtIndex:row];
        NSLog(@"selectedRegionArray: %@", selectedRegion);
        lastRegionIndex = row;
        lastCityIndex = 0;
        
        NSNumber *selectedFirstColumnID = [selectedRegion objectForKey:@"id"];
        if (selectedFirstColumnID) {
            NSArray *newSecondColumn = [[CureMeUtils defaultCureMeUtil] cityArrayWithRegionID:selectedFirstColumnID.integerValue];
            [self setSecondColumn:newSecondColumn];
        }
    }
    // 如果选择了市、区
    else if (component == 1) {
        // 记录选中的市区
        selectedCity = [cityArray objectAtIndex:row];
        lastCityIndex = row;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        if (!regionArray || [regionArray count] <= 0) {
            return 0;
        }
        
        NSLog(@"rowsInComponent0: %lu", (unsigned long)[regionArray count]);
        return [regionArray count];
    }
    else if (component == 1) {
        if (!cityArray || [cityArray count] <= 0) {
            return 0;
        }
        
        NSLog(@"rowsInComponent1: %lu", (unsigned long)[cityArray count]);
        return [cityArray count];
    }
    
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}


#pragma mark -
#pragma mark Respond to touch and become first responder.

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark -
#pragma mark UIKeyInput Protocol Methods

- (BOOL)hasText {
	return YES;
}

- (void)insertText:(NSString *)theText {
}

- (void)deleteBackward {
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate Protocol Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    UITableView *tableView = nil;
    if (IOS_VERSION < 7) {
        tableView = (UITableView *)self.superview;
    }
    else {
        tableView = (UITableView *)self.superview.superview;
    }

	[tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
	[self resignFirstResponder];
}

@end





