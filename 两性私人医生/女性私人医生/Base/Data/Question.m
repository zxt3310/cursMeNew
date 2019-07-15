//
//  Question.m
//  CureMe
//
//  Created by Tim on 12-8-18.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "Question.h"

@implementation Question

@synthesize questionTime = _questionTime;
@synthesize identifier = _identifier;
@synthesize question = _question;
@synthesize type = _type;
@synthesize userid = _userid;
@synthesize qViewHeight = _qViewHeight;
@synthesize hasAnswer = _hasAnswer;

- (NSString *)description
{
    NSString *dscp = [[NSString alloc] initWithFormat:@"\nQuestion:\n id: %@\n userID: %ld\n question: %@\n type: %@\n time: %@\n", _identifier, (long)_userid, _question, _type, _questionTime];

    return dscp;
}

- (void) dealloc
{
    _questionTime = nil;
    _identifier = nil;
    _question = nil;
    _type = nil;
}

@end
