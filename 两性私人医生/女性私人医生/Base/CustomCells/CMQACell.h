//
//  CMQACell.h
//  私密健康医生
//
//  Created by Tim on 13-1-10.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"
#import "Answer.h"
#import "QuestionAnswers.h"
#import "CMQAViewController.h"


#pragma mark QAViewController里Question的SubView
@interface QACellQuestionSubView : UIView

{
    UILabel *questionLabel;
    UILabel *timeLabel;
    UILabel *replyCountLabel;
    UIImageView *qImageView;
    UIImageView *qBgImageView;
}

@property (nonatomic, strong) CMQAViewController *qaViewController;
@property (nonatomic, strong) Question *question;
@property NSInteger replyCount;

- (void)generateLayout;

@end


#pragma mark QAViewController里Answer的SubView
@interface QACellAnswerSubView : UIView

{
    UILabel *answerLabel;       // 回复内容Label
    UILabel *nameLabel;
    UILabel *infoLabel;
    UIImageView *imageView;     // 医生头像
    UIImageView *imageViewFrame;    // 医生头像边框
    UIImageView *aBgImageView;
    UILabel *seporatLb;
}

@property (nonatomic, strong) CMQAViewController *qaViewController;
@property (nonatomic, strong) Answer *answer;
@property bool isLastAnswer;

- (void)generateLayout:(float)initHeight;

@end


#pragma mark CMQACell
@interface CMQACell : UITableViewCell

{
    QACellQuestionSubView *questionSubView;
    NSMutableArray *answerSubViews;
}

@property (nonatomic, strong) CMQAViewController *qaViewController;
@property (nonatomic, strong) QuestionAnswers *questionAnswers;

- (void)generateLayout;

@end
