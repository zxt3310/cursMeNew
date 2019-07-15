//
//  QuestionAnswers.m
//  CureMe
//
//  Created by Tim on 12-8-20.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "Question.h"
#import "Answer.h"
#import "QuestionAnswers.h"

@implementation QuestionAnswers

@synthesize replyCount = _replyCount, cellHeight = _cellHeight, answerArray, question;

- (id) init
{
    self = [super init];
    answerArray = [[NSMutableArray alloc] init];
    _cellHeight = 0;
    
    return self;
}

- (id) initWithQuestion:(Question *)newQuestion
{
    question = newQuestion;
    return [self init];
}

- (NSString *) description
{
    NSMutableString *decription = [[NSMutableString alloc] init];
    [decription appendFormat:@"question: %@", [question question]];
    for (int i = 0; i < [answerArray count]; i++) {
        [decription appendFormat:@"with answer: %@", [[answerArray objectAtIndex:i] answer]];
    }
    
    return decription;
}

@end
