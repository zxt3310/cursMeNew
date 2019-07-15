//
//  CMQAOfficeSubTypeView.m
//  私密健康医生
//
//  Created by Tim on 13-1-13.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CMQAOfficeSubTypeView.h"
//#import "CMQAViewController.h"


@implementation CMQAOfficeSubTypeView


@synthesize officeType = _officeType;
@synthesize officeSubType = _officeSubType;
//@synthesize qaViewController = _qaViewController;

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setBackgroundColor:[UIColor clearColor]];
        
        _backgroundImage = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].qaCellAnswerTailImage];
        [_backgroundImage setBackgroundColor:[UIColor clearColor]];
        _backgroundImage.frame = CGRectZero;
        [self addSubview:_backgroundImage];
        
        // 子类的按钮集合
        _subTypeBtns = [[NSMutableArray alloc] init];
        
        // 整个View的高度
        _viewHeight = 39;

//        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        [opacityAnimation setFromValue:[NSNumber numberWithFloat:0.0]];
//        [opacityAnimation setToValue:[NSNumber numberWithFloat:1.0]];
//        [opacityAnimation setDuration:1.0];
//        [self.layer addAnimation:opacityAnimation forKey:@"InitShow"];
    }
    return self;
}

- (void)updateOrigin:(float)offset content:(float)contentOffset
{
    CGRect frame = self.frame;
    float newOffset = frame.origin.y - contentOffset + offset;
    
    if (newOffset < -frame.size.height) {
        newOffset = -frame.size.height;
    }
    else if (newOffset > 0 && contentOffset > 0) {
        newOffset = 0;
    }
    // 在TableView拉至向下刷新时
    else if (contentOffset <= 0) {
        newOffset = -contentOffset;
    }

//    NSLog(@"CMQAOfficeSubTypeView updateOrigin set: %.2f newOriginY: %.2f", offset, newOriginY);
    
    frame.origin.y = newOffset + contentOffset;
//    NSLog(@"CMQAOfficeSubTypeView newOriginT: %.2f updateOriginY: %.2f", newOffset, frame.origin.y);
    self.frame = frame;
}

- (void)updateBackgroundImage:(UIImage *)bgImage
{
    UIImage *strechableIamge = nil;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 5.0) {
        strechableIamge = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(4, 1, 1, 1)];
    }
    else {
        strechableIamge = [bgImage stretchableImageWithLeftCapWidth:1 topCapHeight:4];
    }
    
    _backgroundImage.image = strechableIamge;
    _backgroundImage.frame = self.frame;
    NSLog(@"backgroundImage: %@", _backgroundImage);
}

- (void)clearAllSubTypeBtns
{
    if (_subTypeBtns && _subTypeBtns.count > 0) {
        for (UIButton *btn in _subTypeBtns) {
            [btn removeFromSuperview];
        }
        
        [_subTypeBtns removeAllObjects];
    }
    
    [self initAllSubTypeButton];
}

- (void)switchViewTypeToQuery
{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300*SCREEN_WIDTH/320, 15)];
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    _titleLabel.text = @"请选择要咨询的问题分类并输入问题内容";
    [self addSubview:_titleLabel];
    for (UIButton *btn in _subTypeBtns) {
        CGRect frame = btn.frame;
        frame.origin.y += 20;
        btn.frame = frame;
    }
    CGRect frame = self.frame;
    frame.size.height += 20;
    self.frame = frame;
    _backgroundImage.frame = frame;
    
    [self switchIBActionToQuery];
}

- (void)switchIBActionToQuery
{
    for (UIButton *btn in _subTypeBtns) {
        [btn removeTarget:self action:@selector(subTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn addTarget:self action:@selector(subtypeClickedForQuery:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [_allSubTypeBtn setTitle:@"未分类" forState:UIControlStateNormal];
    [_allSubTypeBtn setTitle:@"未分类" forState:UIControlStateHighlighted];
    [_allSubTypeBtn setTitle:@"未分类" forState:UIControlStateSelected];
}

- (void)setOfficeSubType:(NSInteger)officeSubType
{
    _officeSubType = officeSubType;
    
    for (UIButton *btn in _subTypeBtns) {
        if (btn.tag != _officeSubType) {
            [btn setSelected:NO];
        }
        else {
            [btn setSelected:YES];
        }        
    }
}

- (void)switchIBActionToQADisplay
{
    for (UIButton *btn in _subTypeBtns) {
        [btn removeTarget:self action:@selector(subtypeClickedForQuery:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn addTarget:self action:@selector(subTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)initAllSubTypeButton
{
    _allSubTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _allSubTypeBtn.frame = CGRectMake(10.0, 5.0, 65, 31);
    [_allSubTypeBtn setBackgroundImage:[CMImageUtils defaultImageUtil].btnBg_NImage forState:UIControlStateNormal];
    [_allSubTypeBtn setBackgroundImage:[CMImageUtils defaultImageUtil].btnBg_PImage forState:UIControlStateHighlighted];
    [_allSubTypeBtn setBackgroundImage:[CMImageUtils defaultImageUtil].btnBg_PImage forState:UIControlStateSelected];
    [_allSubTypeBtn setTitle:@"全部" forState:UIControlStateNormal];
    [_allSubTypeBtn setTitle:@"全部" forState:UIControlStateHighlighted];
    [_allSubTypeBtn setTitle:@"全部" forState:UIControlStateSelected];
    _allSubTypeBtn.tag = 0;
    [_allSubTypeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_allSubTypeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [_allSubTypeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_allSubTypeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_allSubTypeBtn addTarget:self action:@selector(subTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
    _allSubTypeBtn.userInteractionEnabled = YES;
    [_allSubTypeBtn setSelected:YES];
    [self addSubview:_allSubTypeBtn];

    [_subTypeBtns addObject:_allSubTypeBtn];

    // 设置下一个按钮的Origin
    _nextPoint = CGPointMake(80, 5);
    
    _backgroundImage.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    self.frame = _backgroundImage.frame;
}

- (void)initSubTypeButtons
{
    NSDictionary *subTypes = [[CMDataUtils defaultDataUtil].officeTypeDict objectForKey:[NSNumber numberWithInteger:_officeType]];
    NSLog(@"subTypes: %@", subTypes);
    
    if (!subTypes || subTypes.count <= 0) {
        return;
    }
    
    // 初始化所有子类型按钮
    for (NSNumber *subTypeID in [subTypes allKeys]) {
        [self addSubTypeBtnWithType:subTypeID.integerValue andName:[subTypes objectForKey:subTypeID]];
    }
//    for (OfficeSubTypeUnit *unit in subTypes.allValues) {
//        [self addSubTypeBtnWithType:[unit.subTypeID integerValue] andName:unit.subTypeName];
//    }
}

- (void)addSubTypeBtnWithType:(NSInteger)subType andName:(NSString *)subTypeName
{
    UIButton *subTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    subTypeBtn.frame = CGRectMake(_nextPoint.x, _nextPoint.y, 65, 31);

    [subTypeBtn setBackgroundImage:[CMImageUtils defaultImageUtil].btnBg_NImage forState:UIControlStateNormal];
    [subTypeBtn setBackgroundImage:[CMImageUtils defaultImageUtil].btnBg_PImage forState:UIControlStateHighlighted];
    [subTypeBtn setBackgroundImage:[CMImageUtils defaultImageUtil].btnBg_PImage forState:UIControlStateSelected];
    
    [subTypeBtn setTitle:subTypeName forState:UIControlStateNormal];
    [subTypeBtn setTitle:subTypeName forState:UIControlStateHighlighted];
    [subTypeBtn setTitle:subTypeName forState:UIControlStateSelected];
    [subTypeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [subTypeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [subTypeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

    subTypeBtn.tag = subType;
    [subTypeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [subTypeBtn addTarget:self action:@selector(subTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
    subTypeBtn.userInteractionEnabled = YES;
    [self addSubview:subTypeBtn];
    [_subTypeBtns addObject:subTypeBtn];
    
    float newPointX = _nextPoint.x + 70;
    if (newPointX + 70 > SCREEN_WIDTH) {
        _nextPoint = CGPointMake(10.0, _nextPoint.y + 35);
        _backgroundImage.frame = CGRectMake(0, 0, SCREEN_WIDTH, _nextPoint.y + 5);
    }
    else {
        _nextPoint.x += 70;
        _backgroundImage.frame = CGRectMake(0, 0, SCREEN_WIDTH, _nextPoint.y + 30 + 8);
    }
    
    self.frame = _backgroundImage.frame;
}

- (void)generateLayout
{
    // 更新每个子类的布局
    
    // 通知更新
    [self setNeedsDisplay];
}

- (IBAction)subTypeClicked:(id)sender
{
    for (UIButton *btn in _subTypeBtns) {
        if (![btn isEqual:sender]) {
            [btn setSelected:NO];
        }
    }

    UIButton *btn = (UIButton *)sender;
    [btn setSelected:YES];

    if (_delegate && [_delegate respondsToSelector:@selector(officeSubTypeSelected:)]) {
        [_delegate officeSubTypeSelected:btn.tag];
    }
}

- (IBAction)subtypeClickedForQuery:(id)sender
{
    for (UIButton *btn in _subTypeBtns) {
        if (![btn isEqual:sender]) {
            [btn setSelected:NO];
        }
    }
    
    UIButton *btn = (UIButton *)sender;
    [btn setSelected:YES];

    if (_delegate && [_delegate respondsToSelector:@selector(setQueryOfficeSubType:)]) {
        [_delegate queryOfficeSubTypeSelected:btn.tag];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
}

@end
