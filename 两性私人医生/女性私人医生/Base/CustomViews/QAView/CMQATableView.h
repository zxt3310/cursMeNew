//
//  CMQATableView.h
//  私密健康医生
//
//  Created by Tim on 13-1-10.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"
#import "Answer.h"
#import "QuestionAnswers.h"
#import "EGORefreshTableHeaderView.h"
#import "CMQAOfficeSubTypeView.h"


@class CMQAViewController;
//@class CMQAOfficeSubTypeView;
@class NoDataBackgroundView;
@class LoadingView;

@interface CMQATableView : UITableView <EGORefreshTableHeaderDelegate, UITableViewDataSource, UITableViewDelegate, CMQAOfficeSubTypeViewDelegate>

{
    float lastScrollYOffset;
    float scrollYOffsetDistance;
    
    float lastScrollXOffset;
    
    // Drag refresh datas
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    CMQAOfficeSubTypeView *subTypeView;
    
}

@property (nonatomic, strong) NoDataBackgroundView *noDataBgView;
@property (nonatomic, strong) LoadingView *loadingBgView;

@property (nonatomic) NSInteger officeType;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (strong) NSMutableArray *qaArray;
@property (nonatomic, strong) CMQAViewController *qaViewController;

- (void)refreshOfficeSubTypes;
- (void)calcQACellLayout:(NSInteger)index;

- (void)setOfficeSubType:(NSInteger)subtype;

@end
