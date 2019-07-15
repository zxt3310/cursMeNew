//
//  CMQACell.m
//  私密健康医生
//
//  Created by Tim on 13-1-10.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CMQACell.h"


#pragma mark QACell Question子视图
@implementation QACellQuestionSubView

@synthesize qaViewController = _qaViewController;
@synthesize question = _question;
@synthesize replyCount = _replyCount;

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        qBgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        qBgImageView.opaque = FALSE;
        [self addSubview:qBgImageView];

        questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [questionLabel setFont:[UIFont fontWithName:@"Arial" size:16]];
        [questionLabel setTextColor:UIColorFromHex(0x4a4a4a,1)];
        [questionLabel setNumberOfLines:3];
        [questionLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [questionLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:questionLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [timeLabel setFont:[UIFont systemFontOfSize:10]];
        [timeLabel setTextColor:UIColorFromHex(0x9b9b9b, 1)];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:timeLabel];
        
        replyCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [replyCountLabel setFont:[UIFont systemFontOfSize:12]];
        [replyCountLabel setTextColor:[UIColor lightGrayColor]];
        [replyCountLabel setBackgroundColor:[UIColor clearColor]];
        replyCountLabel.hidden = YES;
        [self addSubview:replyCountLabel];
        
        qImageView = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].qaListQuestionDefultImage];
        [qImageView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:qImageView];
                
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)generateLayout
{
    if (!_question) {
        NSLog(@"QACellQuestionSubView generateLayout question invalid");
    }
    
    float inset = 4.0;
    qImageView.frame = CGRectMake(14 + inset, inset * 2, 27, 24);
    
    questionLabel.text = _question.question;
    CGSize qSize = [questionLabel.text sizeWithFont:[UIFont fontWithName:@"Arial" size:16] constrainedToSize:CGSizeMake(249, 60) lineBreakMode:NSLineBreakByTruncatingTail];
    questionLabel.frame = CGRectMake(67, inset * 2, 249 *SCREEN_WIDTH/320, qSize.height);
    
    timeLabel.text = [[CureMeUtils defaultCureMeUtil].dateFormatter stringFromDate:_question.questionTime];
    timeLabel.frame = CGRectMake(67, qSize.height + inset * 2, 100, 15);
    
    replyCountLabel.text = [NSString stringWithFormat:@"共%ld条回复", (long)_replyCount];
    replyCountLabel.frame = CGRectMake(SCREEN_WIDTH - 84, qSize.height + inset * 2, 80, 15);
    
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, _question.qViewHeight);
    
    UIImage *bgImage = nil;
    if (_replyCount <= 0) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
            bgImage = [[CMImageUtils defaultImageUtil].qaCellQuestionBgAllImage imageWithAlignmentRectInsets:UIEdgeInsetsMake(8, 8, 0, 0)];
        }
        else {
            bgImage = [[CMImageUtils defaultImageUtil].qaCellQuestionBgAllImage stretchableImageWithLeftCapWidth:8.0 topCapHeight:8.0];
        }
    }
    else {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
            bgImage = [[CMImageUtils defaultImageUtil].qaCellQuestionBgImage imageWithAlignmentRectInsets:UIEdgeInsetsMake(8, 8, 0, 8)];
        }
        else {
            bgImage = [[CMImageUtils defaultImageUtil].qaCellQuestionBgImage stretchableImageWithLeftCapWidth:8.0 topCapHeight:8.0];
        }
    }

    qBgImageView.frame = CGRectMake(0, 1, 320, self.frame.size.height);
    qBgImageView.image = bgImage;
}

@end


#pragma mark QACell Answer子视图
@implementation QACellAnswerSubView

@synthesize qaViewController = _qaViewController;
@synthesize answer = _answer;

- (id)init
{
    self = [self initWithFrame:CGRectZero];

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        
        aBgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        aBgImageView.opaque = FALSE;
        [self addSubview:aBgImageView];

        answerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [answerLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
        [answerLabel setNumberOfLines:3];
        [answerLabel setTextColor:UIColorFromHex(0x4a4a4a, 1)];
        [answerLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [answerLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:answerLabel];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [nameLabel setFont:[UIFont systemFontOfSize:16]];
        [nameLabel setTextColor:UIColorFromHex(0x4a4a4a, 1)];//setTextColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0]];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:nameLabel];
        
        infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [infoLabel setFont:[UIFont systemFontOfSize:13]];
        [infoLabel setTextColor:UIColorFromHex(0x9b9b9b, 1)];
        [infoLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:infoLabel];
        
        imageView = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].doctorDefaultHeadMImage];
        [imageView setFrame:CGRectMake(5, 4.5, 45, 45)];
        [[imageView layer] setCornerRadius:20];
        [imageView setClipsToBounds:YES];
        [imageView setUserInteractionEnabled:YES];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        imageViewFrame = [[UIImageView alloc] init];
        [imageViewFrame addSubview:imageView];
        imageViewFrame.userInteractionEnabled = YES;
        [self addSubview:imageViewFrame];
        
        seporatLb = [[UILabel alloc] init];
        seporatLb.backgroundColor = UIColorFromHex(0xf9f9f9, 1);
        [self addSubview:seporatLb];
                
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)setAnswer:(Answer *)answer
{
    _answer = answer;
}

- (void)generateLayout:(float)initHeight
{
    if (!_answer)
        return;
    
    float inset = 4.0;
    UIImage *headImage = nil;
    if (_qaViewController && (headImage = [_qaViewController getHeadImage:_answer.doctorImageKey])) {
        [imageView setImage:headImage];
    }
    imageViewFrame.frame = CGRectMake(inset * 2, inset, 55, 58);

    nameLabel.text = _answer.doctorName;
    nameLabel.frame = CGRectMake(67, inset, 140 *SCREEN_WIDTH/375, 20);
    
    infoLabel.text = [NSString stringWithFormat:@"%@ %@", _answer.doctorTitle, _answer.hospitalName];
    infoLabel.frame = CGRectMake(nameLabel.frame.origin.x + nameLabel.text.length * 16 + 7, inset * 2, 165 *SCREEN_WIDTH/320, 15);
    
    answerLabel.text = _answer.answer;
    CGSize answerSize = [answerLabel.text sizeWithFont:[UIFont fontWithName:@"Arial" size:14] constrainedToSize:CGSizeMake(249 *SCREEN_WIDTH/320, 60) lineBreakMode:NSLineBreakByTruncatingTail];
    answerLabel.frame = CGRectMake(67, 20 + inset * 2, 249 *SCREEN_WIDTH/320, answerSize.height);
    
    if (infoLabel.frame.origin.x + infoLabel.frame.size.width > answerLabel.frame.origin.x + answerLabel.frame.size.width) {
        CGRect temp = infoLabel.frame;
        temp.size.width = answerLabel.frame.origin.x + answerLabel.frame.size.width - infoLabel.frame.origin.x;
        infoLabel.frame = temp;
    }
    
    self.frame = CGRectMake(0, initHeight, SCREEN_WIDTH, _answer.answerViewHeight + 5);
    
//    UIImage *bgImage = nil;
//    if (_isLastAnswer) {
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
//            bgImage = [[CMImageUtils defaultImageUtil].qaCellAnswerTailImage imageWithAlignmentRectInsets:UIEdgeInsetsMake(8, 8, 0, 0)];
//        }
//        else {
//            bgImage = [[CMImageUtils defaultImageUtil].qaCellAnswerTailImage stretchableImageWithLeftCapWidth:8.0 topCapHeight:8.0];
//        }
//    }
//    else {
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
//            bgImage = [[CMImageUtils defaultImageUtil].qaCellAnswerMidImage imageWithAlignmentRectInsets:UIEdgeInsetsMake(8, 8, 0, 0)];
//        }
//        else {
//            bgImage = [[CMImageUtils defaultImageUtil].qaCellAnswerMidImage stretchableImageWithLeftCapWidth:8.0 topCapHeight:8.0];
//        }
//    }
//    
//    if (_isLastAnswer) {
//        aBgImageView.frame = CGRectMake(0, 1, SCREEN_WIDTH, self.frame.size.height - 1);
//    }
//    else {
//        aBgImageView.frame = CGRectMake(0, 1, SCREEN_WIDTH, self.frame.size.height);
//    }
//    aBgImageView.image = bgImage;
    seporatLb.frame = CGRectMake(0 , self.frame.size.height - 8, SCREEN_WIDTH, 10);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (!_qaViewController) {
        return;
    }
    
    NSSet *touchSet = [event allTouches];
    UITouch *touch = [touchSet anyObject];

    // 如果点击了头像
    NSLog(@"touch.view: %@ imageView: %@ imageViewFrame: %@", touch.view, imageView, imageViewFrame);
    if ([touch.view isEqual:imageView] || [touch.view isEqual:imageViewFrame]) {
        [_qaViewController showDoctorInfoPage:_answer.doctorID.integerValue];
    }
    else {
        [_qaViewController showDialogPage:_answer.doctorID.integerValue andReply:_answer andSourceType:@"REPLY"];
    }
}

@end


#pragma mark CMQACell
@implementation CMQACell

@synthesize qaViewController = _qaViewController;
@synthesize questionAnswers = _questionAnswers;

- (id)init
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QACell"];
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        questionSubView = [[QACellQuestionSubView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:questionSubView];

        answerSubViews = [[NSMutableArray alloc] init];
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setQaViewController:(CMQAViewController *)qaViewController
{
    _qaViewController = qaViewController;
}

- (void)setQuestionAnswers:(QuestionAnswers *)questionAnswers
{
    _questionAnswers = questionAnswers;
}

- (void)generateLayout
{
    questionSubView.question = _questionAnswers.question;

    questionSubView.replyCount = _questionAnswers.replyCount;
    // Question假定自己从0开始布局
    [questionSubView generateLayout];

    for (UIView *subView in answerSubViews) {
        [subView removeFromSuperview];
    }
    [answerSubViews removeAllObjects];

    if (_questionAnswers.answerArray && _questionAnswers.answerArray.count > 0) {
        float curHeight = _questionAnswers.question.qViewHeight;
        for (int i = 0; i < _questionAnswers.answerArray.count; i++) {
            Answer *answer = [_questionAnswers.answerArray objectAtIndex:i];
            QACellAnswerSubView *answerSubView = [[QACellAnswerSubView alloc] initWithFrame:CGRectMake(0, curHeight, SCREEN_WIDTH, answer.answerViewHeight)];
            answerSubView.qaViewController = _qaViewController;
            answerSubView.answer = answer;
            
            if (i == _questionAnswers.answerArray.count - 1)
                answerSubView.isLastAnswer = true;
            else
                answerSubView.isLastAnswer = false;

            // Answer要从之前已有的布局高度开始布局
            [answerSubView generateLayout:curHeight];
            
            [answerSubViews addObject:answerSubView];
            [self.contentView addSubview:answerSubView];

            curHeight += answer.answerViewHeight;
        }
    }
}

@end
