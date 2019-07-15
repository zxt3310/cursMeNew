//
//  QuestionAnswers.h
//  CureMe
//
//  Created by Tim on 12-8-20.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Question;
@class Answer;

@interface QuestionAnswers : NSObject

{
}

@property NSInteger replyCount;
@property Question *question;
@property NSMutableArray *answerArray;
@property float cellHeight;

- (id) initWithQuestion:(Question *)newQuestion;

@end
