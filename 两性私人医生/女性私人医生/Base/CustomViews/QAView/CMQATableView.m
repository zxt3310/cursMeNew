//
//  CMQATableView.m
//  私密健康医生
//
//  Created by Tim on 13-1-10.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMQATableView.h"
#import "CMQACell.h"
#import "CMQAHeaderCell.h"
#import "QAMoreHistoryCell.h"
#import "CMCustomViews.h"


@implementation CMQATableView

@synthesize officeType = _officeType;
@synthesize qaArray = _qaArray;
//@synthesize subTypeView = _subTypeView;

#pragma mark initialization
- (void)initializator
{
    // UITableView properties

    [self setBackgroundColor:[UIColor clearColor]];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    assert(self.style == UITableViewStylePlain);
    lastScrollYOffset = 0;

    // 添加科室子分类的View
//    subTypeView = [[CMQAOfficeSubTypeView alloc] initWithFrame:CGRectMake(0, 0, 320, 39)];
//    subTypeView.delegate = self;
//    [self addSubview:subTypeView];
//    NSLog(@"CMQATableView subTypeView: %@", subTypeView);
    
    self.delegate = self;
    self.dataSource = self;

    // EGO refresh table header view
    if (_refreshHeaderView == nil) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.bounds.size.height, self.frame.size.width, self.bounds.size.height)];
        _refreshHeaderView.delegate = self;
        [self addSubview:_refreshHeaderView];
    }
    [_refreshHeaderView refreshLastUpdatedDate];

    float topY = 140;
    if ([UIScreen mainScreen].bounds.size.height > 480.0) {
        topY += 40;
    }

    _noDataBgView = [[NoDataBackgroundView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 35, topY, 80, 70)];
    _noDataBgView.hidden = YES;
    [self addSubview:_noDataBgView];
    [self sendSubviewToBack:_noDataBgView];
    
    _loadingBgView = [[LoadingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 35, topY, 80, 70)];
    _loadingBgView.hidden = YES;
    [self addSubview:_loadingBgView];
    [self sendSubviewToBack:_loadingBgView];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initializator];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializator];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializator];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        [self initializator];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark CMQAOfficeSubTypeViewDelegate
- (void)officeSubTypeSelected:(NSInteger)subType
{
    if (_qaViewController) {
        [_qaViewController setOfficeSubType:subType];
    }
}

- (void)queryOfficeSubTypeSelected:(NSInteger)querySubType
{
    if (_qaViewController) {
        
    }
}


- (void)setOfficeType:(NSInteger)officeType
{
    _officeType = officeType;

    if (subTypeView) {
        [subTypeView setOfficeType:_officeType];
    }
}

- (void)setOfficeSubType:(NSInteger)subtype
{
    if (subTypeView) {
        [subTypeView setOfficeSubType:subtype];
    }
}

- (void)setQaViewController:(CMQAViewController *)qaViewController
{
    _qaViewController = qaViewController;
    
    subTypeView.delegate = _qaViewController;
//    subTypeView.qaViewController = _qaViewController;
    
    if (_qaViewController.isMainTabQAPage) {
        [subTypeView setHidden:YES];
    }
}

- (void)refreshOfficeSubTypes
{
    [subTypeView clearAllSubTypeBtns];
    [subTypeView initSubTypeButtons];
}

#pragma mark overrides
- (void)reloadData
{
    if (!_qaArray || _qaArray.count <= 0) {
        [super reloadData];
//        _noDataBgView.hidden = NO;
        return;
    }

//    // 更新数据
//    _noDataBgView.hidden = YES;
//    _loadingBgView.hidden = NO;
    
    // Loading new data
    NSUInteger count = 0;
    if ((count = _qaArray.count) > 0)
    {
        for (NSUInteger i = 0; i < count; i++)
            [self calcQACellLayout:i];
    }
    
    // 调用界面更新
    [super reloadData];
}

- (void)calcQACellLayout:(NSInteger)index
{
    if (!_qaArray || _qaArray.count <= index)
        return;
    
    // 以下计算每个QACell的高度
    float finalHeight = 0;
    float inset = 4.0;

    // Question的高度
    QuestionAnswers *questionAnswer = [_qaArray objectAtIndex:index];
    CGSize questionSize = [questionAnswer.question.question sizeWithFont:[UIFont fontWithName:@"Arial" size:15] constrainedToSize:CGSizeMake(249, 60) lineBreakMode:NSLineBreakByTruncatingTail];
    finalHeight += inset + questionSize.height + inset + 15 + 4;
    questionAnswer.question.qViewHeight = finalHeight;
    
    if (!questionAnswer || questionAnswer.answerArray.count <= 0) {
        questionAnswer.cellHeight = finalHeight;
        return;
    }
    
    // Answer的高度
    for (int i = 0; i < questionAnswer.answerArray.count; i++) {
        Answer *answer = [questionAnswer.answerArray objectAtIndex:i];
        CGSize answerSize = [answer.answer sizeWithFont:[UIFont fontWithName:@"Arial" size:15] constrainedToSize:CGSizeMake(249, 60) lineBreakMode:NSLineBreakByTruncatingTail];

        float answerTextHeight = inset + answerSize.height + inset * 2 + 15 + inset;
        if (answerTextHeight < QATABLEVIEW_A_MINHEIGHT)
            answer.answerViewHeight = QATABLEVIEW_A_MINHEIGHT;
        else
            answer.answerViewHeight = answerTextHeight;
        
        finalHeight += answer.answerViewHeight;
    }
    
    questionAnswer.cellHeight = finalHeight;
}

#pragma mark properties
- (NSMutableArray *)qaArray
{
    if (!_qaArray) {
        _qaArray = [[NSMutableArray alloc] init];
    }
    
    return _qaArray;
}

- (void)setQaArray:(NSMutableArray *)qaArray
{
    _qaArray = qaArray;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_qaArray || _qaArray.count <= 0)
        return 0 + 1;       // 加上子分类的隐藏Cell
    
    if (_qaViewController.curPageQueryCount >= 20) {
        return 1 + 1 + 1;
    }
//    if (_qaArray.count % 20 == 0) {
//        return 1 + 1 + 1;   // 加上“更多历史”Cell
//    }
    
    return 1 + 1;           // 加上子分类的隐藏Cell
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        if (!_qaArray || _qaArray.count <= 0)
            return 0;
        
        return _qaArray.count;
    }
    else if (section == 2) {   // 更多历史Cell
        return 1;
    }

    // 意外情况
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *defaulCellID = @"DefaultCell";
    static NSString *HiddenCellID = @"HiddenCell";
    static NSString *qaCellID = @"QACell";
    static NSString *MoreHisCellID = @"MoreHisCell";
    
    // 如果是子分类隐藏Cell
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HiddenCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HiddenCellID];
        }
        
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
    else if (indexPath.section == 1) {
        if (_qaArray && _qaArray.count > indexPath.row) {
            CMQACell *cell = [tableView dequeueReusableCellWithIdentifier:qaCellID];
            if (!cell) {
                cell = [[CMQACell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:qaCellID];
            }
            cell.questionAnswers = [_qaArray objectAtIndex:indexPath.row];
            cell.qaViewController = _qaViewController;
            [cell generateLayout];
            
            return cell;
        }
    }
    else if (indexPath.section == 2) {
        QAMoreHistoryCell *moreHisCell = [tableView dequeueReusableCellWithIdentifier:MoreHisCellID];
        if (!moreHisCell) {
            moreHisCell = [[QAMoreHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MoreHisCellID];
            UILabel *moreHisLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 20)];
            moreHisLb.text = @"点击获取更多历史咨询";
            [moreHisLb setTextAlignment:NSTextAlignmentCenter];
            [moreHisLb setFont:[UIFont systemFontOfSize:15]];
            [moreHisCell.contentView addSubview:moreHisLb];
        }

        return moreHisCell;
    }
    
    // 没有可用的Cell，创建默认Cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:defaulCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaulCellID];
    }
    
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    
//}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 如果是子分类隐藏Cell
    if (indexPath.section == 0) {
        // 如果是“我的咨询”，则不显示子分类
        if ([CureMeUtils defaultCureMeUtil].hasLogin && _qaViewController.userID == [CureMeUtils defaultCureMeUtil].userID) {
            return 0;
        }
        
        if (subTypeView) {
            return subTypeView.frame.size.height;
        }

        return 40;
    }
    else if (indexPath.section == 1) {
        if (_qaArray && _qaArray.count > indexPath.row) {
            QuestionAnswers *qa = (QuestionAnswers *)[_qaArray objectAtIndex:indexPath.row];
//            NSLog(@"heightForRowAtIndexPath: %@  %.2f", indexPath, qa.cellHeight);
            return qa.cellHeight + 5;
        }
    }
    else if (indexPath.section == 2) {
        return 100;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        [_qaViewController appendData];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}


#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [_qaViewController refreshData];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0];
}

- (void)doneLoadingTableViewData{
    NSLog(@"===加载完数据");
    //
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [[NSDate alloc] init];
}

#pragma mark ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollYOffsetDistance = lastScrollYOffset - scrollView.contentOffset.y;
    [subTypeView updateOrigin:scrollYOffsetDistance content:scrollView.contentOffset.y];
//    NSLog(@"subTpyeView: %@, superView: %@, contentOffset: %.2f", subTypeView, subTypeView.superview, scrollView.contentOffset.y);
    
    lastScrollYOffset = scrollView.contentOffset.y;

    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

@end
