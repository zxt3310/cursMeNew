//
//  NSBubbleData.m
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

#import "NSBubbleData.h"

@implementation NSBubbleData
{
    NSInteger bubbleTypeInt;
    NSInteger cellTypeInt;
}

@synthesize date = _date;
@synthesize type = _type;
@synthesize text = _text;
@synthesize headImage = _headImage;
@synthesize talkerID = _talkerID;
@synthesize talkerName = _talkerName;
@synthesize cellType = _cellType;
@synthesize msgImage = _msgImage;
@synthesize imageKey = _imageKey;
@synthesize headImageKey = _headImageKey;
@synthesize mapLatitude = _mapLatitude;
@synthesize mapLongitude = _mapLongitude;
@synthesize telephone = _telephone;
@synthesize bookID = _bookID;

#pragma mark init with NSString date

#pragma mark init with NSDate
// 预约Cell
+ (id)dataWithBookInfo:(NSInteger)bID andType:(NSBubbleType)type andDate:(NSDate *)date andCellType:(NSInteger)cType andTalkerID:(NSInteger)tID
{
    return [[NSBubbleData alloc] initWithBookInfo:bID andType:type andDate:date andCellType:cType andTalkerID:tID];
}

- (id)initWithBookInfo:(NSInteger)bID andType:(NSBubbleType)type andDate:(NSDate *)date andCellType:(NSInteger)cType andTalkerID:(NSInteger)tID
{
    self = [super init];
    if (self) {
        _bookID = bID;
        _date = date;
        _cellType = cType;
        _type = type;
        _talkerID = tID;
    }
    
    return self;
}

+ (id)dataWithTextRemind:(NSString *)textRemind andData:(NSDate *)date andType:(NSBubbleType)type andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType
{
    return [[NSBubbleData alloc] initWIthTextRemind:textRemind andDate:date andType:type andTalkerID:tID andCellType:cType];
}

- (id)initWIthTextRemind:(NSString *)textRemind andDate:(NSDate *)date andType:(NSBubbleType)type andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType
{
    self = [super init];
    if (self) {
        _text = textRemind;
        _date = date;
        _type = type;
        _talkerID = tID;
        _cellType = cType;
    }
    
    return self;
}

// 电话Cell
+ (id)dataWithTelephone:(NSString *)telephone andDate:(NSDate *)date andType:(NSBubbleType)type andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType andText:(NSString *)text
{
    return [[NSBubbleData alloc] initWithTelephone:telephone andDate:date andType:type andTalkerID:tID andCellType:cType andText:text];
}

- (id)initWithTelephone:(NSString *)telephone andDate:(NSDate *)date andType:(NSBubbleType)type andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType andText:(NSString *)text
{
    self = [super init];
    if (self) {
        _telephone = telephone;
        _date = date;
        _type = type;
        _talkerID = tID;
        _cellType = cType;
        _text = text;
    }
    
    return self;
}

// 地图Cell
+ (id)dataWithMapLatitude:(double)latitude andLongitude:(double)longitude andDate:(NSDate *)date andType:(NSBubbleType)type andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType andText:(NSString *)text
{
    return [[NSBubbleData alloc] initWithMapLatitude:latitude andLongitude:longitude andDate:date andType:type andTalkerID:tID andCellType:cType andText:text];
}

- (id)initWithMapLatitude:(double)latitude andLongitude:(double)longitude andDate:(NSDate *)date andType:(NSBubbleType)type andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType andText:(NSString *)text
{
    self = [super init];
    if (self) {
        _mapLongitude = longitude;
        _mapLatitude = latitude;
        _date = date;
        _type = type;
        _talkerID = tID;
        _cellType = cType;
        _text = text;
    }
    
    return self;
}

// 图片Cell
+ (id)dataWithMsgImage:(UIImage *)msgImage andImageKey:(NSString *)imageKey andDate:(NSDate *)date andType:(NSBubbleType)type andImage:(UIImage *)image andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType
{
    return [[NSBubbleData alloc] initWithMsgImage:msgImage andImageKey:imageKey andDate:date andType:type andImage:image andTalkerID:tID andCellType:cType];
}

- (id)initWithMsgImage:(UIImage *)msgImage andImageKey:(NSString *)imageKey andDate:(NSDate *)date andType:(NSBubbleType)type andImage:(UIImage *)image andTalkerID:(NSInteger)tID andCellType:(NSInteger)cType
{
    self = [super init];
    if (self) {
        _msgImage = msgImage;
        _date = date;
        _type = type;
        _headImage = image;
        _talkerID = tID;
        _cellType = cType;
        _imageKey = imageKey;
    }
    
    return self;
}

+ (id)dataWithText:(NSString *)text
           andDate:(NSDate *)date
           andType:(NSBubbleType)type
          andImage:(UIImage*)image
       andTalkerID:(NSInteger)tID
       andCellType:(NSInteger)cType
{
    return [[NSBubbleData alloc] initWithText:text andDate:date andType:type andImage:image andTalkerID:tID andCellType:cType];
}

- (id)initWithText:(NSString *)initText
           andDate:(NSDate *)initDate
           andType:(NSBubbleType)initType
          andImage:(UIImage*)image
       andTalkerID:(NSInteger)tID
       andCellType:(NSInteger)cType
{
    self = [super init];
    if (self)
    {
        _text = initText ? initText : @"";
        _date = initDate;
        self.type = initType;
        _headImage = image;
        _talkerID = tID;
        self.cellType = cType;
    }

    return self;
}

- (void)dealloc
{
    _headImage = nil;
	_date = nil;
	_text = nil;
    _msgImage = nil;
    _talkerName = nil;
    _headImageKey = nil;
}

- (NSString *)description
{
    NSString *dscp = [[NSString alloc] initWithFormat:@"BubbleData text:%@\nimageKey:%@\ntalkerID:%ld\ntime:%@\nCellType:%d\nBookID:%ld", _text, _imageKey, (long)_talkerID, _date, _cellType, (long)_bookID];
    
    return dscp;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeInteger:bubbleTypeInt forKey:@"type"];
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.headImage forKey:@"headImage"];
    [aCoder encodeObject:self.msgImage forKey:@"msgImage"];
    [aCoder encodeObject:self.imageKey forKey:@"imageKey"];
    [aCoder encodeObject:self.headImageKey forKey:@"headImageKey"];
    [aCoder encodeInteger:self.talkerID forKey:@"talkerID"];
    [aCoder encodeObject:self.talkerName forKey:@"talkerName"];
    [aCoder encodeInteger:cellTypeInt forKey:@"cellType"];
    [aCoder encodeDouble:self.mapLatitude forKey:@"mapLatitude"];
    [aCoder encodeDouble:self.mapLongitude forKey:@"mapLongitude"];
    [aCoder encodeObject:self.telephone forKey:@"telephone"];
    [aCoder encodeInteger:self.bookID forKey:@"bookID"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [self init]) {
        _date = [aDecoder decodeObjectForKey:@"date"];
        bubbleTypeInt = [aDecoder decodeIntegerForKey:@"type"];
        _text = [aDecoder decodeObjectForKey:@"text"];
        _headImage = [aDecoder decodeObjectForKey:@"headImage"];
        _msgImage = [aDecoder decodeObjectForKey:@"msgImage"];
        _imageKey = [aDecoder decodeObjectForKey:@"imageKey"];
        _headImageKey = [aDecoder decodeObjectForKey:@"headImageKey"];
        _talkerID = [aDecoder decodeIntegerForKey:@"talkerID"];
        _talkerName = [aDecoder decodeObjectForKey:@"talkerName"];
        cellTypeInt = [aDecoder decodeIntegerForKey:@"cellType"];
        _mapLatitude = [aDecoder decodeDoubleForKey:@"mapLatitude"];
        _mapLongitude = [aDecoder decodeDoubleForKey:@"mapLongitude"];
        _telephone = [aDecoder decodeObjectForKey:@"telephone"];
        _bookID = [aDecoder decodeIntegerForKey:@"bookID"];
        
        [self encodeBubbleType];
        [self encodeCellType];
    }
    return self;
}

- (void)setType:(NSBubbleType)type{
    _type = type;
    if (type == BubbleTypeMine) {
        bubbleTypeInt = 0;
    }
    else{
        bubbleTypeInt = 1;
    }
}

- (void)setCellType:(NSBubbleCellType)cellType{
    _cellType = cellType;
    if (cellType == CellTypeList) {
        cellTypeInt = 0;
    }
    else if (cellType == CellTypeDetail){
        cellTypeInt = 1;
    }
    else{
        cellType = 2;
    }
}

- (void)encodeBubbleType{
    if (bubbleTypeInt == 0) {
        _type = BubbleTypeMine;
    }
    else if(bubbleTypeInt == 1){
        _type = BubbleTypeSomeoneElse;
    }
}
- (void)encodeCellType{
    if (cellTypeInt == 0) {
        _cellType = CellTypeList;
    }
    else if (cellTypeInt == 1){
        _cellType = CellTypeDetail;
    }
}

@end
