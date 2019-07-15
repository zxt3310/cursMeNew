//
//  Question.h
//  CureMe
//
//  Created by Tim on 12-8-18.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

//#import <CoreData/CoreData.h>

@interface Question : NSObject

@property (nonatomic, retain) NSDate *questionTime;
@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSString *question;
@property (nonatomic, retain) NSNumber *type;
@property NSInteger userid;
@property float qViewHeight;
@property bool hasAnswer;           // 此问题是否有回复了

@end
