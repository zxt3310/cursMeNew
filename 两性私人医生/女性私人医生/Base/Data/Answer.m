//
//  Answer.m
//  CureMe
//
//  Created by Tim on 12-8-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "Answer.h"

@implementation Answer

@synthesize userID = _userID;
@synthesize replyTime = _replyTime;
@synthesize answer = _answer;
@synthesize identifier = _identifier;
@synthesize doctorName = _doctorName;
@synthesize doctorTitle = _doctorTitle;
@synthesize questionID = _questionID;
@synthesize doctorID = _doctorID;
@synthesize type = _type;
@synthesize readStatus = _readStatus;
@synthesize officeID = _officeID;
@synthesize officeName = _officeName;
@synthesize hospitalID = _hospitalID;
@synthesize hospitalName = _hospitalName;
@synthesize doctorImageKey = _doctorImageKey;
@synthesize answerViewHeight = _answerViewHeight;

- (NSString *)description
{
    NSString *dscp = [[NSString alloc] initWithFormat:@" userID: %ld\n answer: %@\n id: %@\n questionID: %@\n doctorID: %@\n doctorName:%@\n doctorTitle: %@\n hospitalName: %@\n imageKey: %@\n", (long)_userID, _answer, _identifier, _questionID, _doctorID, _doctorName, _doctorTitle, _hospitalName, _doctorImageKey];
    
    return dscp;
}

- (void)dealloc
{
    _replyTime = nil;
    _answer = nil;
    _identifier = nil;
    _doctorID = nil;
    _doctorName = nil;
    _doctorTitle = nil;
    _officeName = nil;
    _hospitalName = nil;
    _questionID = nil;
    _type = nil;
    _doctorImageKey = nil;
}

@end
