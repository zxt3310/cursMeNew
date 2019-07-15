//
//  UINewBubbleTableView.m
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

#import "UINewBubbleTableView.h"
#import "NSBubbleData.h"
#import "NSBubbleDataInternal.h"
#import "CMNewQueryViewController.h"

@interface UINewBubbleTableView ()
@property (nonatomic, retain) NSMutableDictionary *bubbleDictionary;

@end

@interface UINewBubbleTableView (private)

- (void)calcInternalDataTextRemindLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection;
- (void)calcInternalDataTextImageLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection;
- (void)calcInternalDataTelephoneLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection;
- (void)calcInternalDataMapInfoLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection;
- (void)calcInternalDataBookInfoNewLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection;
- (void)calcInternalDataBookInfoUptLayout:(NSBubbleDataInternal *)dataInternal andIndex:(NSInteger)index andLastTime:(NSDate *)last andCurList:(NSMutableArray *)currentSection;

@end

@implementation UINewBubbleTableView

@synthesize bubbleDataSource = _bubbleDataSource;
@synthesize snapInterval = _snapInterval;
@synthesize bubbleDictionary = _bubbleDictionary;
@synthesize chatViewController = _chatViewController;

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

#pragma mark - Initialization
- (void)setChatViewController:(CMNewQueryViewController *)chatViewController
{
    _chatViewController = chatViewController;
}

#pragma mark ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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
    
    dataInternal.height = dataInternal.labelSize.height + 5 + 20;
    
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
        UIImage *headImage = [CMImageUtils defaultImageUtil].doctorDefaultHeadLImage;//[_chatViewController doctorHeadImageWithImageKey:dataInternal.data.headImageKey];
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
        dataInternal.height = NBOOKLISTCELL_TITLEHEIGHT + NBOOKLISTCELL_INFOHEIGHT + NBOOKLISTCELL_REPLYHEIGHT;
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.bubbleDictionary) return 0;
    
    NSInteger count = [self.bubbleDictionary allKeys].count;
//    NSLog(@"numberofsectionsintebleview: %d", count);
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger c;

//    NSLog(@"BubbleTableView numberOfRowsInSection: %d hasLoadHisComplete: %d", section, _hasLoadHistoryComplete);
    
    if (section < 0) {
        return 0;
    }

    NSArray *keys = [self.bubbleDictionary allKeys];
    if (!keys || keys.count <= 0) {
        NSLog(@"numberOfRowsInSection no chat data");
        return 0;
    }

    NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
        return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
    }];
    if (!sortedArray || sortedArray.count <= section) {
        NSLog(@"numberOfRowsInSection no chat data for section: %ld", (long)(section));
        return 0;
    }

    NSString *key = [sortedArray objectAtIndex:section];
    c = [[self.bubbleDictionary objectForKey:key] count];
//    NSLog(@"numberOfRowsInSection %d count %d", section, c);
    return c;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"UIBubbleTableView heightForRowAtIndexPath: %@", indexPath);
    if (indexPath.section < 0) {
        return 0;
    }

    NSArray *keys = [self.bubbleDictionary allKeys];
    if (!keys || keys.count <= 0) {
        NSLog(@"heightForRowAtIndexPath no chat data");
        return 0;
    }
    
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
        return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
    }];
    if (!sortedArray || sortedArray.count <= indexPath.section) {
        NSLog(@"heightForRowAtIndexPath no chat data for section:%ld", (long)(indexPath.section));
        return 0;
    }
    
    NSString *key = [sortedArray objectAtIndex:indexPath.section];
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
    static NSString *cellId = @"tblBubbleCell";
    static NSString *mapCellID = @"tblBubbleMapCell";
    static NSString *telCellID = @"tblBubbleTelCell";
    static NSString *textRemindCellID = @"tblBubbleTextRemindCell";
    static NSString *bookCellID = @"tblBubbleBookCell";
    static NSString *bookRealCellID = @"tblBubbleBookRealCell";
    static NSString *bookUptCellID = @"tblBubbleBookUptCell";
    static NSString *DefaultCell = @"defaultCell";
    
    NSArray *keys = [self.bubbleDictionary allKeys];
    if (!keys || keys.count <= 0) {
        NSLog(@"cellForRowAtIndexPath data inconsist no chat data");
    }

    NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
        return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
    }];
    NSString *key = [sortedArray objectAtIndex:indexPath.section];
    NSArray *sectionArray = [self.bubbleDictionary objectForKey:key];
    if (indexPath.row >= sectionArray.count) {
        NSLog(@"cellForRowAtIndexPath data inconsist on indexPath:%@ sectionArray: %@ bubbleDictionary: %@", indexPath, sectionArray, self.bubbleDictionary);
    }
    
    NSBubbleDataInternal *dataInternal = ((NSBubbleDataInternal *)[sectionArray objectAtIndex:indexPath.row]);
//    NSLog(@"BubbleTableView cellForRowAtIndexPath data: %@", dataInternal.data);
    
    if (dataInternal.data.cellType == CellTypeDetail) {
        UINewBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"UINewBubbleTableViewCell" owner:self options:nil];
            cell = bubbleCell;
        }
        
        cell.dataInternal = dataInternal;
        [cell.contentView setClipsToBounds:YES];
        
        return cell;
    }
    // 地图Cell
    else if (dataInternal.data.cellType == CellTypeMapInfo) {
        UINewBubbleTableViewMapInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:mapCellID];
        if (!cell)
            cell = [[UINewBubbleTableViewMapInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mapCellID];
        
        cell.dataInternal = dataInternal;
        cell.bubbleViewController = _chatViewController;
        [cell.contentView setClipsToBounds:YES];

        return cell;
    }
    // 新预约Cell
    else if (dataInternal.data.cellType == CellTypeBookInfoNew) {
        // 如果不是自己的对话，沿用旧的预约Cell，显示提示
        if (dataInternal.data.talkerID != [CureMeUtils defaultCureMeUtil].userID) {
            UINewBubbleTableViewBookInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:bookCellID];
            if (!cell)
                cell = [[UINewBubbleTableViewBookInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookCellID];
            
            cell.dataInternal = dataInternal;
            cell.bubbleViewController = _chatViewController;
            [cell.contentView setClipsToBounds:YES];
            
            return cell;
        }

        CMNewMyBookListCell *cell = [tableView dequeueReusableCellWithIdentifier:bookRealCellID];
        if (!cell) {
            cell = [[CMNewMyBookListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookRealCellID];
        }
        cell.bookCellType = NMYBOOKCELL_TYPE_CHAT;
        [cell setChatViewController:_chatViewController];
        [cell setBookInfoUnit:_chatViewController.bookInfoUnit];
        return cell;
    }
    // 需要更新的预约Cell
    else if (dataInternal.data.cellType == CellTypeBookInfoUpd) {
        UINewBubbleTableViewBookInfoUptCell *cell = [tableView dequeueReusableCellWithIdentifier:bookUptCellID];
        if (!cell) {
            cell = [[UINewBubbleTableViewBookInfoUptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookUptCellID];
        }
        
        cell.dataInternal = dataInternal;
        cell.bubbleViewController = _chatViewController;
        [cell.contentView setClipsToBounds:YES];
        
        return cell;
    }
    // 电话Cell
    else if (dataInternal.data.cellType == CellTypeTelInfo) {
        UINewBubbleTableViewTelephoneCell *cell = [tableView dequeueReusableCellWithIdentifier:telCellID];
        if (!cell)
            cell = [[UINewBubbleTableViewTelephoneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:telCellID];
        
        cell.dataInternal = dataInternal;
        cell.bubbleViewController = _chatViewController;
        [cell.contentView setClipsToBounds:YES];

        return cell;
    }
    else if (dataInternal.data.cellType == CellTypeTextRemind) {
        UINewBubbleTableViewTextRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:textRemindCellID];
        if (!cell)
            cell = [[UINewBubbleTableViewTextRemindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textRemindCellID];
        
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
}

@end





