//
//  UIBubbleTableView.m
//
//  Created by Alex Barinov
//  StexGroup, LLC
//  http://www.stexgroup.com
//
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "UIBubbleTableView.h"
#import "NSBubbleData.h"
#import "NSBubbleDataInternal.h"
#import "ChatMoreHistoryCell.h"
#import "BubbleViewController.h"

@interface UIBubbleTableView ()
@property (nonatomic, retain) NSMutableDictionary *bubbleDictionary;

@end

@interface UIBubbleTableView (private)

- (void)calcInternalDataTextRemindLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection;
- (void)calcInternalDataTextImageLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection;
- (void)calcInternalDataTelephoneLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection;
- (void)calcInternalDataMapInfoLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection;
- (void)calcInternalDataBookInfoNewLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection;
- (void)calcInternalDataBookInfoUptLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection;

@end

@implementation UIBubbleTableView

@synthesize bubbleDataSource = _bubbleDataSource;
@synthesize snapInterval = _snapInterval;
@synthesize bubbleDictionary = _bubbleDictionary;
@synthesize chatViewController = _chatViewController;

@synthesize moreHistoryLayoutType = _moreHistoryLayoutType;
@synthesize hasLoadHistoryComplete = _hasLoadHistoryComplete;
@synthesize metaDataDoctorHeadImageKey = _metaDataDoctorHeadImageKey;

#pragma mark - Initializators

- (void)initializator
{
    // UITableView properties
    
    self.backgroundColor = [UIColor whiteColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    assert(self.style == UITableViewStylePlain);
    
    self.delegate = self;
    self.dataSource = self;
    
    // UIBubbleTableView default properties
    totalYOffset = 0;
    lastYOffset = 0;
    
    self.snapInterval = 120;
}

- (id)init
{
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) [self initializator];
    return self;
}


- (void)dealloc
{
	_bubbleDictionary = nil;
	_bubbleDataSource = nil;
}

- (void)updateHeadBtnViewHeadImage
{
    headBtnView.headImageFrame.image = [_chatViewController metaDataImageWithImageKey:headBtnView.headImageKey];
    [headBtnView setNeedsDisplay];
}

#pragma mark - Initialization
- (void)setChatViewController:(BubbleViewController *)chatViewController
{
    _chatViewController = chatViewController;

    headBtnView = [[CMChatHeaderBtnView alloc] initWithBubbleViewController:_chatViewController andInView:self];
}

- (void)setMetaDataDoctorHeadImageKey:(NSString *)metaDataDoctorHeadImageKey
{
    _metaDataDoctorHeadImageKey = metaDataDoctorHeadImageKey;
    
    if (headBtnView) {
        [headBtnView setHeadImageKey:_metaDataDoctorHeadImageKey];
    }
}

#pragma mark ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    // 本次滚动的偏移
//    float curOffset = scrollView.contentOffset.y - lastYOffset;
//    lastYOffset = scrollView.contentOffset.y;
//    // 顶部医院Cell的高度
//    float metaHeight = _chatViewController.metaInfoData ? _chatViewController.metaInfoData.metaDataHeight : CHATINFOCELL_MIN_HEIGHT;
//    // 滚动总偏移
//    totalYOffset += curOffset;
//    
//    // 如果滚动总偏移小于顶部医院Cell的高度时，隐藏缩略信息View
//    if (totalYOffset < metaHeight) {
//        [headBtnView hide];
//        // 如果总偏移小于0，置0
//        if (totalYOffset < 0)
//            totalYOffset = 0;
//    }
//    // 如果滚动总偏移大于顶部医院Cell的高度时，显示缩略信息View
//    else if (totalYOffset >= metaHeight) {
//        [headBtnView show:YES];
//    }
//    
//    //jongs add
    [_chatViewController closeKeyboard];
}

#pragma mark - Override

- (void)reloadData
{
    // Cleaning up
	self.bubbleDictionary = nil;
    
    // Loading new data
    NSInteger count = 0;
    if (self.bubbleDataSource && (count = [self.bubbleDataSource rowsForBubbleTable:self]) > 0)
    {
        // 初始化数据
        self.bubbleDictionary = [[NSMutableDictionary alloc] init];
        NSMutableArray *bubbleData = [[NSMutableArray alloc] initWithCapacity:count];
        
        // 有效性判断
        for (NSInteger i = 0; i < count; i++)
        {
            NSObject *object = [self.bubbleDataSource bubbleTableView:self dataForRow:i];
            assert([object isKindOfClass:[NSBubbleData class]]);
//            NSLog(@"BubbleTableView data: %@", ((NSBubbleData *)object));
            [bubbleData addObject:object];
        }

        // 排序
        [bubbleData sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {

            NSBubbleData *bubbleData1 = (NSBubbleData *)obj1;
            NSBubbleData *bubbleData2 = (NSBubbleData *)obj2;
            
            return [bubbleData1.date compare:bubbleData2.date];
        }];

        NSMutableArray *currentSection = nil;
        NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
        for (NSInteger i = 0; i < count; i++)
        {
            // 创建DataInternal
            NSBubbleDataInternal *dataInternal = [[NSBubbleDataInternal alloc] init];
            dataInternal.data = (NSBubbleData *)[bubbleData objectAtIndex:i];
            
            switch (dataInternal.data.cellType) {
                case CellTypeDetail:
                    [self calcInternalDataTextImageLayout:dataInternal andIndex:i andLastTime:last andCurList:currentSection];
                    break;
                case CellTypeBookInfoNew:
                    [self calcInternalDataBookInfoNewLayout:dataInternal andIndex:i andLastTime:last andCurList:currentSection];
                    break;
                case CellTypeBookInfoUpd:
                    [self calcInternalDataBookInfoUptLayout:dataInternal andIndex:i andLastTime:last andCurList:currentSection];
                    break;
                case CellTypeTelInfo:
                    [self calcInternalDataTelephoneLayout:dataInternal andIndex:i andLastTime:last andCurList:currentSection];
                    break;
                case CellTypeMapInfo:
                    [self calcInternalDataMapInfoLayout:dataInternal andIndex:i andLastTime:last andCurList:currentSection];
                    break;
                case CellTypeTextRemind:
                    [self calcInternalDataTextRemindLayout:dataInternal andIndex:i andLastTime:last andCurList:currentSection];
                    break;
                default:
                    [self calcInternalDataTextImageLayout:dataInternal andIndex:i andLastTime:last andCurList:currentSection];
                    break;
            }
        }
    }
    
    //[headBtnView updateData];
    [super reloadData];
}

- (void)calcInternalDataTextImageLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:currentSection
{
    // Calculating cell height
    if (dataInternal.data.msgImage) {
        float scale = dataInternal.data.msgImage.size.width / dataInternal.data.msgImage.size.height;
        float msgImageHeight = 200 / scale;
        dataInternal.labelSize = CGSizeMake(200, msgImageHeight + 20);
    }
    else {
        dataInternal.labelSize = [(dataInternal.data.text ? dataInternal.data.text : @"") sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    dataInternal.height = dataInternal.labelSize.height + 5 + 11;
    
    dataInternal.header = nil;
    
    if ([dataInternal.data.date timeIntervalSinceDate:last] > self.snapInterval)
    {
        currentSection = [[NSMutableArray alloc] init];
        [self.bubbleDictionary setObject:currentSection forKey:[NSString stringWithFormat:@"%ld",(long)index]];
//        [self.bubbleDictionary setObject:currentSection forKey:[NSString stringWithFormat:@"%d",i]];
        dataInternal.header = [[[CureMeUtils defaultCureMeUtil] dateFormatter] stringFromDate:dataInternal.data.date];
        dataInternal.height += 30;
    }
    
    [currentSection addObject:dataInternal];
    last = dataInternal.data.date;
    
    if (dataInternal.data.type == BubbleTypeSomeoneElse) {
        // 医生姓名
        [dataInternal.data setTalkerName:[_chatViewController doctorNameWithDoctorID:dataInternal.data.talkerID]];
        // 医生头像
        UIImage *headImage = [_chatViewController doctorHeadImageWithImageKey:dataInternal.data.headImageKey];
        if (headImage)
            dataInternal.data.headImage = headImage;
    }
    
    if (dataInternal.height < MIN_BUBBLECELL_HEIGHT) {
        dataInternal.height = MIN_BUBBLECELL_HEIGHT;
    }
}

- (void)calcInternalDataTextRemindLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection
{
    if (!dataInternal) {
        return;
    }
    
    dataInternal.header = nil;
    dataInternal.height = 40;
    
    if ([dataInternal.data.date timeIntervalSinceDate:last] > self.snapInterval) {
        currentSection = [[NSMutableArray alloc] init];
        [self.bubbleDictionary setObject:currentSection forKey:[NSString stringWithFormat:@"%ld", (long)index]];
        dataInternal.header = [[CureMeUtils defaultCureMeUtil].dateFormatter stringFromDate:dataInternal.data.date];
        dataInternal.height += 30;
    }
    
    last = dataInternal.data.date;
    
    [currentSection addObject:dataInternal];    
}

- (void)calcInternalDataTelephoneLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:currentSection
{
    if (!dataInternal) {
        return;
    }
    
    dataInternal.header = nil;
    NSString *finalString = [NSString stringWithFormat:@"%@%@", dataInternal.data.text, dataInternal.data.telephone];
    CGSize textSize = [finalString sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(160, 60) lineBreakMode:NSLineBreakByTruncatingTail];
    dataInternal.height = textSize.height + 10;
    
    if ([dataInternal.data.date timeIntervalSinceDate:last] > self.snapInterval) {
        currentSection = [[NSMutableArray alloc] init];
        [self.bubbleDictionary setObject:currentSection forKey:[NSString stringWithFormat:@"%ld", (long)index]];
        dataInternal.header = [[CureMeUtils defaultCureMeUtil].dateFormatter stringFromDate:dataInternal.data.date];
        dataInternal.height += 30;
    }

    NSLog(@"cal telheight: %.2f", dataInternal.height);

    last = dataInternal.data.date;
    
    [currentSection addObject:dataInternal];
}

- (void)calcInternalDataMapInfoLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:currentSection
{
    if (!dataInternal) {
        return;
    }
    
    dataInternal.header = nil;
    dataInternal.height = 60;
    
    if ([dataInternal.data.date timeIntervalSinceDate:last] > self.snapInterval) {
        currentSection = [[NSMutableArray alloc] init];
        [self.bubbleDictionary setObject:currentSection forKey:[NSString stringWithFormat:@"%ld", (long)index]];
        dataInternal.header = [[CureMeUtils defaultCureMeUtil].dateFormatter stringFromDate:dataInternal.data.date];
        dataInternal.height += 30;
    }
    
    last = dataInternal.data.date;
    
    [currentSection addObject:dataInternal];
}

- (void)calcInternalDataBookInfoUptLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection
{
    if (!dataInternal) {
        return;
    }
    
    dataInternal.header = nil;
    dataInternal.height = 40;
//    if (dataInternal.data.talkerID != [CureMeUtils defaultCureMeUtil].userID) {
//        dataInternal.height = 35;
//    }
//    else {
//        dataInternal.height = 60;
//    }

    if ([dataInternal.data.date timeIntervalSinceDate:last] > self.snapInterval)
    {
        currentSection = [[NSMutableArray alloc] init];
        [self.bubbleDictionary setObject:currentSection forKey:[NSString stringWithFormat:@"%ld",(long)index]];
        //        [self.bubbleDictionary setObject:currentSection forKey:[NSString stringWithFormat:@"%d",i]];
        dataInternal.header = [[[CureMeUtils defaultCureMeUtil] dateFormatter] stringFromDate:dataInternal.data.date];
        dataInternal.height += 30;
    }
    
    last = dataInternal.data.date;
    
    [currentSection addObject:dataInternal];
}

- (void)calcInternalDataBookInfoNewLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:currentSection
{
    if (!dataInternal) {
        return;
    }
    
    dataInternal.header = nil;
    if (dataInternal.data.talkerID != [CureMeUtils defaultCureMeUtil].userID) {
        dataInternal.height = 35;
    }
    else {
        dataInternal.height = BOOKLISTCELL_TITLEHEIGHT + BOOKLISTCELL_INFOHEIGHT + BOOKLISTCELL_REPLYHEIGHT;
    }
    
    if ([dataInternal.data.date timeIntervalSinceDate:last] > self.snapInterval)
    {
        currentSection = [[NSMutableArray alloc] init];
        [self.bubbleDictionary setObject:currentSection forKey:[NSString stringWithFormat:@"%ld",(long)index]];
        //        [self.bubbleDictionary setObject:currentSection forKey:[NSString stringWithFormat:@"%d",i]];
        dataInternal.header = [[[CureMeUtils defaultCureMeUtil] dateFormatter] stringFromDate:dataInternal.data.date];
        dataInternal.height += 30;
    }

    last = dataInternal.data.date;
    
    [currentSection addObject:dataInternal];
}

#pragma mark - UITableViewDelegate implementation

#pragma mark - UITableViewDataSource implementation
// secion 0 用来显示：医院、医生信息（以及加载更多历史消息）
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.bubbleDictionary) return 1;
    
    NSInteger count = [self.bubbleDictionary allKeys].count;
//    NSLog(@"numberofsectionsintebleview: %d", count);
    return count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger c;

//    NSLog(@"BubbleTableView numberOfRowsInSection: %d hasLoadHisComplete: %d", section, _hasLoadHistoryComplete);
    
    if (section < 0) {
        return 0;
    }
    else if (section == 0) {
        // 医生信息，医院信息
        if (_hasLoadHistoryComplete) {
            return 1;
        }

        // 加上“加载更多历史消息”
        return 2;
    }

    NSArray *keys = [self.bubbleDictionary allKeys];
    if (!keys || keys.count <= 0) {
        NSLog(@"numberOfRowsInSection no chat data");
        return 0;
    }

    NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
        return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
    }];
    if (!sortedArray || sortedArray.count <= section - 1) {
        NSLog(@"numberOfRowsInSection no chat data for section: %ld", (long)(section - 1));
        return 0;
    }

    NSString *key = [sortedArray objectAtIndex:section - 1];
    c = [[self.bubbleDictionary objectForKey:key] count];
//    NSLog(@"numberOfRowsInSection %d count %d", section - 1, c);
    return c;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"UIBubbleTableView heightForRowAtIndexPath: %@", indexPath);
    if (indexPath.section < 0) {
        return 0;
    }
    else if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:         // 如果是医院+医生信息
                if (_chatViewController.metaInfoData) {
                    return _chatViewController.metaInfoData.metaDataHeight;
//                    if (_chatViewController.metaInfoData.hasDoctorInfo)
//                        return 190;
//                    else
//                        return 120;
                }
                else
                    return 0;
            case 1:         // 如果是“加载更多历史消息”
                return 40;
            default:
                break;
        }
        
        return 40;
    }

    NSArray *keys = [self.bubbleDictionary allKeys];
    if (!keys || keys.count <= 0) {
        NSLog(@"heightForRowAtIndexPath no chat data");
        return 0;
    }
    
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
        return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
    }];
    if (!sortedArray || sortedArray.count <= indexPath.section - 1) {
        NSLog(@"heightForRowAtIndexPath no chat data for section:%ld", (long)(indexPath.section - 1));
        return 0;
    }
    
    NSString *key = [sortedArray objectAtIndex:indexPath.section - 1];
    NSBubbleDataInternal *dataInternal = ((NSBubbleDataInternal *)[[self.bubbleDictionary objectForKey:key] objectAtIndex:indexPath.row]);
    
    //        NSLog(@"BubbleTableView heightForRowAtIndexPath height: %.2f", dataInternal.height);
    
//    NSLog(@"BubbleTableView heightForRowAtIndexPath : %.2f", dataInternal.height);
    
    if (dataInternal.data.cellType == CellTypeTelInfo) {
        NSLog(@"telCell height: %.2f", dataInternal.height);
    }

    return dataInternal.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *hospitalInfoCell = @"HospitalInfoCell";
    static NSString *moreHisCellId = @"MoreHistoryCell";
    static NSString *cellId = @"tblBubbleCell";
    static NSString *mapCellID = @"tblBubbleMapCell";
    static NSString *telCellID = @"tblBubbleTelCell";
    static NSString *textRemindCellID = @"tblBubbleTextRemindCell";
    static NSString *bookCellID = @"tblBubbleBookCell";
    static NSString *bookRealCellID = @"tblBubbleBookRealCell";
    static NSString *bookUptCellID = @"tblBubbleBookUptCell";
    static NSString *DefaultCell = @"defaultCell";
    
//    NSLog(@"BubbleTableView cellForRowAtIndexPath: %@ hadLoadHisComplete: %d", indexPath, _hasLoadHistoryComplete);
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {       // 如果是医院信息
            ChatHospitalInfoCell *hosInfoCell = [tableView dequeueReusableCellWithIdentifier:hospitalInfoCell];
            if (!hosInfoCell) {
                hosInfoCell = [[ChatHospitalInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:hospitalInfoCell];
            }
            [hosInfoCell setBubbleViewController:_chatViewController];
            [hosInfoCell setChatMetaInfoData:_chatViewController.metaInfoData];
            
            return hosInfoCell;
        }
        else if (indexPath.row == 1) {  // 如果是“载入更多历史消息”
            ChatMoreHistoryCell *moreHisCell = [tableView dequeueReusableCellWithIdentifier:moreHisCellId];
            if (!moreHisCell) {
                moreHisCell = [[ChatMoreHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:moreHisCellId];
            }
            [moreHisCell generateLayout];
            
            return moreHisCell;
        }
    }
    
    NSArray *keys = [self.bubbleDictionary allKeys];
    if (!keys || keys.count <= 0) {
        NSLog(@"cellForRowAtIndexPath data inconsist no chat data");
    }

    NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
        return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
    }];
    NSString *key = [sortedArray objectAtIndex:indexPath.section - 1];
    NSArray *sectionArray = [self.bubbleDictionary objectForKey:key];
    if (indexPath.row >= sectionArray.count) {
        NSLog(@"cellForRowAtIndexPath data inconsist on indexPath:%@ sectionArray: %@ bubbleDictionary: %@", indexPath, sectionArray, self.bubbleDictionary);
    }
    
    NSBubbleDataInternal *dataInternal = ((NSBubbleDataInternal *)[sectionArray objectAtIndex:indexPath.row]);
//    NSLog(@"BubbleTableView cellForRowAtIndexPath data: %@", dataInternal.data);
    
    if (dataInternal.data.cellType == CellTypeDetail) {
        UIBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"UIBubbleTableViewCell" owner:self options:nil];
            cell = bubbleCell;
        }
        
        cell.dataInternal = dataInternal;
        [cell.contentView setClipsToBounds:YES];
        
        return cell;
    }
    // 地图Cell
    else if (dataInternal.data.cellType == CellTypeMapInfo) {
        UIBubbleTableViewMapInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:mapCellID];
        if (!cell)
            cell = [[UIBubbleTableViewMapInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mapCellID];
        
        cell.dataInternal = dataInternal;
        cell.bubbleViewController = _chatViewController;
        [cell.contentView setClipsToBounds:YES];

        return cell;
    }
    // 新预约Cell
    else if (dataInternal.data.cellType == CellTypeBookInfoNew) {
        // 如果不是自己的对话，沿用旧的预约Cell，显示提示
        if (dataInternal.data.talkerID != [CureMeUtils defaultCureMeUtil].userID) {
            UIBubbleTableViewBookInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:bookCellID];
            if (!cell)
                cell = [[UIBubbleTableViewBookInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookCellID];
            
            cell.dataInternal = dataInternal;
            cell.bubbleViewController = _chatViewController;
            [cell.contentView setClipsToBounds:YES];
            
            return cell;
        }

        CMMyBookListCell *cell = [tableView dequeueReusableCellWithIdentifier:bookRealCellID];
        if (!cell) {
            cell = [[CMMyBookListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookRealCellID];
        }
        cell.bookCellType = MYBOOKCELL_TYPE_CHAT;
        [cell setChatViewController:_chatViewController];
        [cell setBookInfoUnit:_chatViewController.bookInfoUnit];
        return cell;
    }
    // 需要更新的预约Cell
    else if (dataInternal.data.cellType == CellTypeBookInfoUpd) {
        UIBubbleTableViewBookInfoUptCell *cell = [tableView dequeueReusableCellWithIdentifier:bookUptCellID];
        if (!cell) {
            cell = [[UIBubbleTableViewBookInfoUptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookUptCellID];
        }
        
        cell.dataInternal = dataInternal;
        cell.bubbleViewController = _chatViewController;
        [cell.contentView setClipsToBounds:YES];
        
        return cell;
    }
    // 电话Cell
    else if (dataInternal.data.cellType == CellTypeTelInfo) {
        UIBubbleTableViewTelephoneCell *cell = [tableView dequeueReusableCellWithIdentifier:telCellID];
        if (!cell)
            cell = [[UIBubbleTableViewTelephoneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:telCellID];
        
        cell.dataInternal = dataInternal;
        cell.bubbleViewController = _chatViewController;
        [cell.contentView setClipsToBounds:YES];

        return cell;
    }
    else if (dataInternal.data.cellType == CellTypeTextRemind) {
        UIBubbleTableViewTextRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:textRemindCellID];
        if (!cell)
            cell = [[UIBubbleTableViewTextRemindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textRemindCellID];
        
        cell.dataInternal = dataInternal;
        cell.bubbleViewController = _chatViewController;
        
        return cell;
    }
    
    NSLog(@"cellForRowAtIndexPath bubbletableview default cell created, which should not happen!!!");
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        [_chatViewController loadMoreHistoryMessage];
    }
    if (indexPath.section == 0 && indexPath.row == 0) {
        ChatHospitalInfoCell *cell = (ChatHospitalInfoCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell hospitalInfoBtnClick:nil];
    }
}

@end





