//
//  Answer.h
//  CureMe
//
//  Created by Tim on 12-8-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

//#import <CoreData/CoreData.h>

@interface Answer : NSObject

@property NSInteger userID;
@property (nonatomic, strong) NSDate *replyTime;
@property (nonatomic, retain) NSString *answer;
@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSNumber *questionID;
@property (nonatomic, retain) NSNumber *doctorID;
@property (nonatomic, retain) NSString *doctorName;
@property (nonatomic, retain) NSString *doctorTitle;
@property (nonatomic, retain) NSNumber *type;
@property NSInteger officeID;
@property (nonatomic, retain) NSString *officeName;
@property NSInteger hospitalID;
@property (nonatomic, retain) NSString *hospitalName;
@property (nonatomic, retain) NSString *doctorImageKey;
@property bool readStatus;
@property float answerViewHeight;

@end
