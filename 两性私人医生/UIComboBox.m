//
//  UIComboBox.m
//  取样助手
//
//  Created by Zxt3310 on 2016/12/13.
//  Copyright © 2016年 xxx. All rights reserved.
//

#import "UIComboBox.h"

@implementation UIComboBox
{
    UITextField *comboTF;
    UIButton *comboLb;
    UITableView *tableview;
    BOOL isShow;
    CGRect orignFrame;
    NSIndexPath *currentIndex;
    
    UIView *superView; //最外层view，用来避免菜单遮挡
}
@synthesize comboList = _comboList;
@synthesize layerColor = _layerColor;
@synthesize comborColor = _comborColor;
@synthesize textFont = _textFont;
@synthesize textColor = _textColor;
@synthesize placeColor = _placeColor;
@synthesize selectId = _selectId;

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        isShow = NO;
        self.selectId = -1;
        _introductStr = @"-请选择-";
        
        comboTF = [[UITextField alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                self.frame.size.width - self.frame.size.height,
                                                                self.frame.size.height)];
        comboTF.layer.borderWidth = 1;
        comboTF.enabled = NO;
        comboTF.leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
        comboTF.leftViewMode = UITextFieldViewModeAlways;
        [self addSubview:comboTF];
        
        comboLb = [UIButton buttonWithType:UIButtonTypeSystem];
        comboLb.frame = CGRectMake(comboTF.frame.size.width,
                                   0,
                                   self.frame.size.height,
                                   self.frame.size.height);
        comboLb.layer.borderWidth = 1;
        [comboLb setTitle:@"▼" forState:UIControlStateNormal];
        comboLb.titleLabel.textAlignment = NSTextAlignmentCenter;
        comboLb.tintColor = [UIColor blackColor];
        comboLb.titleLabel.font = [UIFont systemFontOfSize:self.frame.size.height * 0.77];
        [self addSubview:comboLb];
        
        tableview = [[UITableView alloc]initWithFrame:CGRectMake(self.frame.origin.x,
                                                                 self.frame.origin.y + self.frame.size.height + 3,
                                                                 self.frame.size.width,
                                                                 40)];
        tableview.delegate = self;
        tableview.dataSource = self;
        tableview.layer.borderWidth = 1;
        tableview.layer.cornerRadius = 10;
        tableview.tableFooterView = [[UITableView alloc] initWithFrame:CGRectZero];
        [comboLb addTarget:self action:@selector(showTable) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (UIColor *)layerColor
{
    return _layerColor;
}
- (void)setLayerColor:(UIColor *)layerColor
{
    _layerColor = layerColor;
    comboTF.layer.borderColor = layerColor.CGColor;
}

- (UIColor *)comborColor
{
    return _comborColor;
}
- (void)setComborColor:(UIColor *)comborColor
{
    _comborColor = comborColor;
    comboLb.layer.borderColor = comborColor.CGColor;
    comboLb.tintColor = comborColor;
}

- (UIFont *)textFont
{
    return _textFont;
}
- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    comboTF.font = textFont;
}

- (UIColor *)textColor
{
    return _textColor;
}
- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    comboTF.textColor = textColor;
}

- (UIColor *)placeColor
{
    return _placeColor;
}
- (void)setPlaceColor:(UIColor *)placeColor
{
    _placeColor = placeColor;
    comboTF.textColor = comboLb.tintColor = placeColor;
    comboTF.layer.borderColor = comboLb.layer.borderColor = placeColor.CGColor;
}

- (NSArray *)comboList
{
    return _comboList;
}
- (void)setComboList:(NSArray *)comboList
{
    _comboList = comboList;
    
    CGRect temp = tableview.frame;
    if (comboList.count > 4) {
        temp.size.height = 200;
    }
    else
    {
        temp.size.height = (comboList.count + 1) * 40;
    }

    tableview.frame = temp;

    [tableview reloadData];

}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"selectString"]) {
        comboTF.text = _selectString = value;
    }
}

- (void)setSelectId:(NSInteger)selectId
{
    _selectId = selectId;
    NSIndexPath *index = [NSIndexPath indexPathForRow:selectId + 1 inSection:0];
    [self tableView:tableview didSelectRowAtIndexPath:index];
}

- (NSInteger)selectId
{
    return _selectId;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _comboList.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect tableTemp = tableView.frame;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = _introductStr;
    }
    else
    {
        cell.textLabel.text = _comboList[indexPath.row - 1];
        if(indexPath == currentIndex)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    //计算文字长度
    //CGSize size = [cell.textLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:cell.font,NSFontAttributeName, nil]];
    tableTemp.size.width = cell.textLabel.text.length * cell.textLabel.font.pointSize+ 20;
    //重算列表宽度
    tableView.frame = (tableTemp.size.width > tableView.frame.size.width)?tableTemp:tableView.frame;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!(indexPath.row == 0))
    {
        _selectString = comboTF.text = (_comboList == nil?@"":_comboList[indexPath.row - 1]);
        _selectId = indexPath.row - 1;

        currentIndex = indexPath;
        
        if(self.delegate)
        {
            [_delegate UIComboBox:self didSelectRow:indexPath];
        }
    }
    [self dismissTable];
}

- (void)showTable
{
    if(!isShow)
    {
        [UIView animateWithDuration:.15 animations:^{
            tableview.alpha = 1;
            //tableview.transform = CGAffineTransformMakeScale(1, 1); //由于需要频繁计算table的frame，此段代码会造成frame变动
        }];
        
        orignFrame = tableview.frame;
        
        //根据宽度重新计算列表位移
        if ([superView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *superScorllView = (UIScrollView *) superView;
            CGRect temp = tableview.frame;
            
            //如果菜单右边缘超出屏幕则向左平移
            if (orignFrame.origin.x + orignFrame.size.width > superScorllView.contentSize.width) {
                temp.origin.x = superScorllView.contentSize.width - orignFrame.size.width - 3;
            }
            //如果菜单下边缘超出屏幕则平移至上方
            CGFloat a = superScorllView.contentOffset.y;
            
            if (orignFrame.origin.y + orignFrame.size.height > superView.frame.size.height + a) {
                temp.origin.y = temp.origin.y - temp.size.height - self.frame.size.height - 6;
            }
            tableview.frame = temp;
        }
        else{
            CGRect temp = orignFrame;
            
            //如果菜单右边缘超出屏幕则向左平移
            if (orignFrame.origin.x + orignFrame.size.width > superView.frame.size.width) {
                temp.origin.x = superView.frame.size.width - orignFrame.size.width - 3;
            }
            //如果菜单下边缘超出屏幕则平移至上方
            if (orignFrame.origin.y + orignFrame.size.height > superView.frame.size.height) {
                temp.origin.y = temp.origin.y - temp.size.height - self.frame.size.height - 6;
            }
            tableview.frame = temp;
        }

        [superView addSubview:tableview];
        
        isShow = YES;
    }
}

- (void)dismissTable
{
    if(isShow)
    {
        [UIView animateWithDuration:.15 animations:^{
            tableview.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [tableview removeFromSuperview];
                [tableview reloadData];
                tableview.frame = orignFrame;
                isShow = NO;
            }
        }];
    }
}

- (void)resetCombo{
    comboTF.text = @"";
    _selectString = nil;
    _selectId = -1;
    currentIndex = nil;
}

- (void)didMoveToSuperview
{
    //保证列表是加载到最外层view上，防止被同级控件遮挡
    superView = self;
    do {
        superView = superView.superview;
        
    } while ([superView.superview isKindOfClass:[UIView class]]);
    
    tableview.frame = [self.superview convertRect:tableview.frame toView:superView];
}
@end
