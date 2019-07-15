//
//  CMQAOfficeSubTypeView.h
//  私密健康医生
//
//  Created by Tim on 13-1-13.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CMQAViewController.h"


@protocol CMQAOfficeSubTypeViewDelegate <NSObject>

@optional
- (void)officeSubTypeSelected:(NSInteger)subType;
- (void)queryOfficeSubTypeSelected:(NSInteger)querySubType;

@end


//@class CMQAViewController;

@interface CMQAOfficeSubTypeView : UIView

@property (nonatomic, assign) id<CMQAOfficeSubTypeViewDelegate> delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *allSubTypeBtn;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) NSMutableArray *subTypeBtns;
@property (nonatomic) NSInteger viewHeight;
@property (nonatomic) CGPoint nextPoint;
@property NSInteger officeType;
@property (nonatomic) NSInteger officeSubType;
//@property (nonatomic, strong) CMQAViewController *qaViewController;

- (void)updateBackgroundImage:(UIImage *)bgImage;

- (void)switchViewTypeToQuery;

- (void)switchIBActionToQuery;
- (void)switchIBActionToQADisplay;

- (IBAction)subTypeClicked:(id)sender;
- (IBAction)subtypeClickedForQuery:(id)sender;

// 清楚现有的所有子分类按钮
- (void)clearAllSubTypeBtns;
// 初始化“所有子类”按钮
- (void)initAllSubTypeButton;
// 初始化当前主分类下的所有子类按钮
- (void)initSubTypeButtons;
- (void)updateOrigin:(float)offset content:(float)contentOffset;

- (void)addSubTypeBtnWithType:(NSInteger)subType andName:(NSString *)subTypeName;
- (void)generateLayout;

@end
