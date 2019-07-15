//
//  CMPickerViewController.m
//  私密健康医生
//
//  Created by Tim on 13-1-21.
//  Copyright (c) 2013年 Tim. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "CMPickerViewController.h"
#import "KGModal.h"




@implementation DataPickUnit

+ (id)UnitWithID:(NSInteger)ID andTitle:(NSString *)t andObject:(NSObject *)object
{
    return [[DataPickUnit alloc] initWithID:ID andTitle:t andObject:object];
}

- (id)initWithID:(NSInteger)ID andTitle:(NSString *)t andObject:(NSObject *)object
{
    self = [super init];
    if (self) {
        _identifier = ID;
        _title = t;
        _unit = object;
    }
    
    return self;
}

@end

@interface CMPickerViewController ()

@end

@implementation CMPickerViewController


@synthesize pickerColumnCount = _pickerColumnCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _pickerColumnCount = PICKER_COLUMN_ONE;
    }
    return self;
}

- (void)viewDidLoad
{
    [_background.layer setCornerRadius:3.0];
    _background.clipsToBounds = YES;

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDataPicker:nil];
    [self setDataPickerTitle:nil];
    [self setOkBtnClick:nil];
    [self setBackground:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    _dataPickerTitle.text = _pickerTitle;
    
    [super viewWillAppear:animated];
    
    if (_firstColumn && [_firstColumn count] > firstClmnSelectedIndex) {
        [self.dataPicker selectRow:firstClmnSelectedIndex inComponent:0 animated:YES];
    }
    
    if (_secondColumn && [_secondColumn count] > secondClmnSelectedIndex) {
        [self.dataPicker selectRow:secondClmnSelectedIndex inComponent:1 animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"PickerViewController view: %@", self.view);
    [super viewDidAppear:animated];
}

- (void)setPickerColumnCount:(NSInteger)pickerColumnCount
{
    _pickerColumnCount = pickerColumnCount;
}

// 设置第一列数据，在开始加上未选择选项
- (void)setFirstColumnData:(NSArray *)firstColumn
{
    if (!_firstColumn) {
        _firstColumn = [[NSMutableArray alloc] init];
    }
    [_firstColumn removeAllObjects];
    
    [_firstColumn addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"id", @"<未选择>", @"name", nil]];
    for (NSDictionary *data in firstColumn) {
        [_firstColumn addObject:data];
    }
    NSLog(@"firstClmn: %@", _firstColumn);

//    firstClmnSelectedData = [_firstColumn objectAtIndex:0];
}

// 设置第二列数据，在开始加上未选择选项
- (void)setSecondColumnData:(NSArray *)secondColumn
{
    if (!_secondColumn) {
        _secondColumn = [[NSMutableArray alloc] init];
    }
    [_secondColumn removeAllObjects];
    
    [_secondColumn addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"id", @"<未选择>", @"name", nil]];
    for (NSDictionary *data in secondColumn) {
        [_secondColumn addObject:data];
    }
    
//    if (_secondColumn && [_secondColumn count] > 0) {
//        [self.dataPicker selectRow:0 inComponent:1 animated:YES];
//        secondClmnSelectedData = [_secondColumn objectAtIndex:0];
//    }
//    else {
//        secondClmnSelectedData = nil;
//    }
    
    [self.dataPicker reloadComponent:1];
    
    NSLog(@"secondClmn: %@", _secondColumn);
}

- (void)setSelectedIDAtFirstColumn:(NSInteger)firstID andSecondColumn:(NSInteger)secondID andThirdColumn:(NSInteger)thirdID
{
    if (!_firstColumn || [_firstColumn count] <= 0) {
        return;
    }
    
    firstClmnSelectedData = nil;
    for (int i = 0; i < [_firstColumn count]; i++) {
        NSNumber *fID = [[_firstColumn objectAtIndex:i] objectForKey:@"id"];
        if (fID && [fID integerValue] == firstID) {
            firstClmnSelectedData = [_firstColumn objectAtIndex:i];
            firstClmnSelectedIndex = i;
            NSLog(@"firstClmnSelected: %@ %ld", firstClmnSelectedData, (long)firstClmnSelectedIndex);
//            [self.dataPicker selectRow:i + 1 inComponent:0 animated:YES];
            break;
        }
    }
    if (!firstClmnSelectedData) {
        firstClmnSelectedIndex = 0;
    }

    if (!_secondColumn || [_secondColumn count] <= 0) {
        return;
    }
    
    secondClmnSelectedData = nil;
    for (int i = 0; i < [_secondColumn count]; i++) {
        NSNumber *sID = [[_secondColumn objectAtIndex:i] objectForKey:@"id"];
        if (sID && [sID integerValue] == secondID) {
            secondClmnSelectedData = [_secondColumn objectAtIndex:i];
            secondClmnSelectedIndex = i;
            NSLog(@"secondClmnSelected: %@ %ld", secondClmnSelectedData, (long)secondClmnSelectedIndex);
//            [self.dataPicker selectRow:i + 1 inComponent:1 animated:YES];
            break;
        }
    }
    if (!secondClmnSelectedData) {
        secondClmnSelectedIndex = 0;
    }

    [self.dataPicker selectRow:firstClmnSelectedIndex inComponent:0 animated:YES];
    [self.dataPicker selectRow:secondClmnSelectedIndex inComponent:1 animated:YES];
}

- (void)setPickerTitle:(NSString *)pickerTitle
{
    _pickerTitle = pickerTitle;
}

//- (void)setData:(NSArray *)data
//{
//    _data = data;
//    if (!_data || _data.count <= 0) {
//        return;
//    }
//    
//    [_dataPicker reloadAllComponents];
//}

#pragma mark UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
//    if (!_data || _data.count <= 0) {
//        return 0;
//    }

    return _pickerColumnCount;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
//    if (!_data || _data.count <= 0) {
//        return 0;
//    }
//    
//    return _data.count;

    if (component == 0) {
        return [_firstColumn count];
    }
    else if (component == 1) {
        if (!_secondColumn)
            return 0;

        return [_secondColumn count];
    }
    else if (component == 2) {
        return [_thirdColumn count];
    }
    
    return 0;
}


#pragma mark UIPickerViewDelegate
//// returns width of column and height of row for each component.
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
//    if (!_data || _data.count <= row) {
//        return nil;
//    }
//    
//    return ((DataPickUnit *)[_data objectAtIndex:row]).title;
    if (component == 0) {
        return [[_firstColumn objectAtIndex:row] objectForKey:@"name"];
    }
    else if (component == 1) {
        if (!_secondColumn || [_secondColumn count] <= 0)
            return nil;
        
        return [[_secondColumn objectAtIndex:row] objectForKey:@"name"];
    }
    else if (component == 2) {
        return [[_thirdColumn objectAtIndex:row] objectForKey:@"name"];
    }
    
    return nil;
}

//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component NS_AVAILABLE_IOS(6_0); // attributed title is favored if both methods are implemented
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    if (!_data || _data.count <= row) {
//        return;
//    }
    //    selectedRow = row;
    
    // 如果选择了省份、直辖市
    if (component == 0) {
        // 记录选中的省、直辖市
        firstClmnSelectedData = [_firstColumn objectAtIndex:row];
        firstClmnSelectedIndex = row;
        
        if (_pickerColumnCount > 1) {
            NSNumber *selectedFirstColumnID = [[_firstColumn objectAtIndex:row] objectForKey:@"id"];
            if (selectedFirstColumnID) {
                NSArray *newSecondColumn = [[CureMeUtils defaultCureMeUtil] cityArrayWithRegionID:selectedFirstColumnID.integerValue];
                [self setSecondColumnData:newSecondColumn];
                [self setSelectedIDAtFirstColumn:selectedFirstColumnID.integerValue andSecondColumn:0 andThirdColumn:0];
            }        
        }
    }
    // 如果选择了市、区
    else if (component == 1) {
        // 记录选中的市区
        secondClmnSelectedData = [_secondColumn objectAtIndex:row];
        secondClmnSelectedIndex = row;
    }
}

- (IBAction)onOkBtnClicked:(id)sender {
    if (firstClmnSelectedIndex == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"选择" message:@"在您继续之前，请先选择内容" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    else if (_pickerColumnCount > 1 && secondClmnSelectedIndex == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"选择地区" message:@"在您继续之前，请先选择一个地区" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (_pickerDelegate && [_pickerDelegate respondsToSelector:@selector(didSelectOK:andSecondColumn:andThirdColumn:)]) {
        [_pickerDelegate didSelectOK:firstClmnSelectedData andSecondColumn:secondClmnSelectedData andThirdColumn:thirdClmnSelectedData];
    }

    [[KGModal sharedInstance] hideAnimated:YES];
}

@end
