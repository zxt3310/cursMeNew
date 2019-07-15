//
//  NSBubbleData.h
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

#import <Foundation/Foundation.h>

typedef enum _NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;

typedef enum _NSBubbleCellType
{
    CellTypeList = 0,
    CellTypeDetail = 1,
    CellTypeBookInfoNew,    // 新预约Cell
    CellTypeBookInfoUpd,    // 更新预约Cell
    CellTypeMapInfo,        // 地图Cell
    CellTypeTelInfo,        // 电话Cell
    CellTypeTextRemind      // 文字提示Cell
} NSBubbleCellType;

@interface NSBubbleData : NSObject <NSCoding>

@property (readonly, nonatomic, strong) NSDate *date;
@property (readonly, nonatomic) NSBubbleType type;
@property (readonly, nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIImage *headImage;
@property (nonatomic, strong) UIImage *msgImage;
@property (nonatomic, strong) NSString *imageKey;
@property (nonatomic, strong) NSString *headImageKey;
@property (readonly, nonatomic) NSInteger talkerID;
@property (nonatomic, strong) NSString *talkerName;
@property (readonly, nonatomic) NSBubbleCellType cellType;
@property double mapLatitude;
@property double mapLongitude;
@property (nonatomic, strong) NSString *telephone;
@property NSInteger bookID;


// 预约Cell
- (id)initWithBookInfo:(NSInteger)bID andType:(NSBubbleType)type andDate:(NSDate *)date andCellType:(NSInteger)cType andTalkerID:(NSInteger)tID;
+ (id)dataWithBookInfo:(NSInteger)bID andType:(NSBubbleType)type andDate:(NSDate *)date andCellType:(NSInteger)cType andTalkerID:(NSInteger)tID;

// 文字提醒Cell
- (id)initWIthTextRemind:(NSString *)textRemind andDate:(NSDate *)date andType:(NSBubbleType)type andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType;
+ (id)dataWithTextRemind:(NSString *)textRemind andData:(NSDate *)date andType:(NSBubbleType)type andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType;

// 电话Cell
- (id)initWithTelephone:(NSString *)telephone andDate:(NSDate *)date andType:(NSBubbleType)type andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType andText:(NSString *)text;
+ (id)dataWithTelephone:(NSString *)telephone andDate:(NSDate *)date andType:(NSBubbleType)type andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType andText:(NSString *)text;

// 地图Cell
- (id)initWithMapLatitude:(double)latitude andLongitude:(double)longitude andDate:(NSDate *)date andType:(NSBubbleType)type andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType andText:(NSString *)text;
+ (id)dataWithMapLatitude:(double)latitude andLongitude:(double)longitude andDate:(NSDate *)date andType:(NSBubbleType)type andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType andText:(NSString *)text;

// 图片cell
- (id)initWithMsgImage:(UIImage *)msgImage andImageKey:(NSString *)imageKey andDate:(NSDate *)date andType:(NSBubbleType)type andImage:(UIImage *)image andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType;
+ (id)dataWithMsgImage:(UIImage *)msgImage andImageKey:(NSString *)imageKey andDate:(NSDate *)date andType:(NSBubbleType)type andImage:(UIImage *)image andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType;

- (id)initWithText:(NSString *)text andDate:(NSDate *)date andType:(NSBubbleType)type andImage:(UIImage *)image andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType;
+ (id)dataWithText:(NSString *)text andDate:(NSDate *)date andType:(NSBubbleType)type andImage:(UIImage *)image andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType;

@end
