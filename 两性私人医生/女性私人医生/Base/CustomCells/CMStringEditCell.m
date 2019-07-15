//
//  CMPerCenterEditCell.m
//  私密健康医生
//
//  Created by Tim on 13-1-16.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMStringEditCell.h"

@implementation CMStringEditCell

@synthesize delegate;
@synthesize stringValue;
@synthesize textField;
@synthesize editType = _editType;


- (id)initWithEditType:(NSInteger)editType reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _editType = editType;
		[self initalizeInputView];
    }
    
    return self;
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

- (void)initalizeInputView {
	// Initialization code
    float inset = 10.0;

	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.textField = [[UITextField alloc] initWithFrame:CGRectMake(65, inset + 5, 230 *SCREEN_WIDTH/375, 20)];
	self.textField.autocorrectionType = UITextAutocorrectionTypeDefault;
	self.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	self.textField.textAlignment = NSTextAlignmentRight;
	[self.textField setTextColor:[UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0]];
	self.textField.font = [UIFont systemFontOfSize:17.0f];
	self.textField.clearButtonMode = UITextFieldViewModeNever;
	self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.textField setBackgroundColor:[UIColor clearColor]];
    if (_editType == EDITCELL_AGE || _editType == EDITCELL_PHONE) {
        [self.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    }
    [self.textField setReturnKeyType:UIReturnKeyDone];
	[self.contentView addSubview:self.textField];
	
	self.accessoryType = UITableViewCellAccessoryNone;
	
	self.textField.delegate = self;
    
    variableLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset + 7, inset + 5, 50, 20)];
//    [variableLabel setTextColor:[UIColor grayColor]];
//    [variableLabel setFont:[UIFont systemFontOfSize:16]];
    [variableLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:variableLabel];
    
//    moreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more.png"]];
//    moreImageView.frame = CGRectMake(260, inset, 17, 30);
//    [self.contentView addSubview:moreImageView];
    
    if (_editType == EDITCELL_NAME) {
        variableLabel.text = @"姓名";
        self.textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PERSONALNAME];
    }
    else if (_editType == EDITCELL_AGE) {
        variableLabel.text = @"年龄";
        NSNumber *age = [[NSUserDefaults standardUserDefaults] objectForKey:USER_AGE];
        if (age) {
            self.textField.text = age.stringValue;
        }
    }
    else if (_editType == EDITCELL_PHONE) {
        variableLabel.text = @"手机";
        self.textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PHONENO];
    }
    else if (_editType == EDITCELL_REGION) {
        variableLabel.text = @"地区";
        NSNumber *region = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
        if (region) {
            self.textField.text = [[CureMeUtils defaultCureMeUtil] regionWithRegionID:region.integerValue];
        }
    }

    // 初始化上次编辑Value
    lastValue = self.textField.text;
    
    NSLog(@"CMStringEditCell\ncontentView: %@\n textField: %@\nvariableLabel: %@\n", self.contentView, self.textField, variableLabel);
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	if (selected) {
		[self.textField becomeFirstResponder];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	if (selected) {
		[self.textField becomeFirstResponder];
	}
}

- (void)setStringValue:(NSString *)value {
	self.textField.text = value;
}

- (NSString *)stringValue {
	return self.textField.text;
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    [self.textField resignFirstResponder];
//
//    return YES;
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.textField resignFirstResponder];

	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // 反选当前Cell
    UITableView *tableView = nil;
    if (IOS_VERSION < 7) {
        tableView = (UITableView *)self.superview;
    }
    else {
        tableView = (UITableView *)self.superview.superview;
    }
	[tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
    
    // 调用delegate
	if (delegate && [delegate respondsToSelector:@selector(tableViewCell:didEndEditingWithString:)]) {
		[delegate tableViewCell:self didEndEditingWithString:self.stringValue];
	}
    
    // 如果值相同，则不发送请求
    if ([self.textField.text isEqualToString:lastValue]) {
        return;
    }
    
    // 判断电话Cell的有效性
    if (_editType == EDITCELL_PHONE) {
        if ([self.stringValue length] != 11 || ![[CureMeUtils defaultCureMeUtil] isPureInt:self.stringValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"个人信息" message:@"请检查输入的手机号码是否正确，需为11位数字" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    if (_editType == EDITCELL_AGE) {
        if (![[CureMeUtils defaultCureMeUtil] isPureInt:self.stringValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"个人信息" message:@"请检查输入的年龄是否正确，需为数字" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    NSMutableString *post = [[NSMutableString alloc] init];
    [post appendFormat:@"action=upduserinfo&userid=%ld&username=%@", (long)[CureMeUtils defaultCureMeUtil].userID,[CureMeUtils defaultCureMeUtil].userName];
    switch (_editType) {
        case EDITCELL_AGE:
            [post appendFormat:@"&age=%@", self.stringValue];
            break;
        case EDITCELL_NAME:
            [post appendFormat:@"&name=%@", [self.stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            break;
        case EDITCELL_PHONE:
            [post appendFormat:@"&mobile=%@", self.stringValue];
            break;
        case EDITCELL_REGION:
            [post appendFormat:@"&city=%ld", (long)[[CureMeUtils defaultCureMeUtil] regionIDWithRegionName:self.stringValue].integerValue];
            break;
        default:
            break;
    }
    
    if ([CureMeUtils defaultCureMeUtil].encodedLocateInfo) {
        [post appendFormat:@"&addrdetail=%@", [CureMeUtils defaultCureMeUtil].encodedLocateInfo];
    }
    
    NSData *response = sendRequest(@"m.php", post);
    
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"Post: %@ resp: %@", post, strResp);
    NSDictionary *jsonData = parseJsonResponse(response);
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!result || result.integerValue != 1) {
        NSString *msg = [jsonData objectForKey:@"msg"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改个人信息" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    switch (_editType) {
        case EDITCELL_AGE:
            [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithInteger:self.stringValue.integerValue] forKey:USER_AGE];
            break;
        case EDITCELL_NAME:
            [[NSUserDefaults standardUserDefaults] setObject:self.stringValue forKey:USER_PERSONALNAME];
            break;
        case EDITCELL_PHONE:
            [[NSUserDefaults standardUserDefaults] setObject:self.stringValue forKey:USER_PHONENO];
            break;
        case EDITCELL_REGION:
            [[NSUserDefaults standardUserDefaults] setObject:[[CureMeUtils defaultCureMeUtil] regionIDWithRegionName:self.stringValue] forKey:USER_REGION];
            break;
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[CureMeUtils defaultCureMeUtil] initUserPersonalInfo];

    // 更新上次字符
    lastValue = self.textField.text;
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [event allTouches].anyObject;
//    if (![touch.view isEqual:self.textField]) {
//        [self.textField resignFirstResponder];
//        [self.contentView becomeFirstResponder];
//    }
//    else {
//        [super touchesEnded:touches withEvent:event];
//    }
//}

- (void)layoutSubviews {
	[super layoutSubviews];
//	CGRect editFrame = CGRectInset(self.contentView.frame, 10, 10);
//	
//	if (self.textLabel.text && [self.textLabel.text length] != 0) {
//		CGSize textSize = [self.textLabel sizeThatFits:CGSizeZero];
//		editFrame.origin.x += textSize.width + 10;
//		editFrame.size.width -= textSize.width + 10;
//		self.textField.textAlignment = NSTextAlignmentCenter;
//	} else {
//		self.textField.textAlignment = UITextAlignmentLeft;
//	}
//	
//	self.textField.frame = editFrame;
}

@end
