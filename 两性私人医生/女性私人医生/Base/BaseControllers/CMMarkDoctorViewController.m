//
//  CMMarkDoctorViewController.m
//  私密健康医生
//
//  Created by Tim on 13-1-21.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KGModal.h"
#import "CMMarkDoctorViewController.h"


@interface CMMarkDoctorViewController ()

@end

@implementation CMMarkDoctorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _markPoint = 10;
        hasComment = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view.layer setCornerRadius:3.0];
    self.view.clipsToBounds = YES;

    [_markGoodBtn setSelected:YES];
    [_markNormalBtn setSelected:NO];
    [_markBadBtn setSelected:NO];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackground:nil];
    [self setMarkGoodBtn:nil];
    [self setMarkNormalBtn:nil];
    [self setMarkBadBtn:nil];
    [self setCommentField:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateMarkBtnDisplay];
    _commentField.text = _markComment;
}

- (void)setMarkPoint:(NSInteger)markPoint
{
    _markPoint = (markPoint == 0) ? 10 : markPoint;
    [self updateMarkBtnDisplay];
}

- (void)updateMarkBtnDisplay
{
    if (_markPoint == 1) {
        _markBadBtn.selected = YES;
        _markGoodBtn.selected = _markNormalBtn.selected = NO;
        _markPoint = 1;
    }
    else if (_markPoint == 6) {
        _markNormalBtn.selected = YES;
        _markGoodBtn.selected = _markBadBtn.selected = NO;
        _markPoint = 6;
    }
    else if (_markPoint == 10) {
        _markGoodBtn.selected = YES;
        _markNormalBtn.selected = _markBadBtn.selected = NO;
        _markPoint = 10;
    }    
}

- (IBAction)markBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;

    [self setMarkPoint:btn.tag];
    [self updateMarkBtnDisplay];
}

- (IBAction)submitBtnClicked:(id)sender {
    if (hasComment && [_commentField.text isEqualToString:lastCommentString]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"评价对话"
                                                        message:@"您已经提交过相同内容的评价，请勿重复评价，谢谢。"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    lastCommentString = _commentField.text;
    NSString *encodeString = [_commentField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *post = [NSString stringWithFormat:@"action=submitchatcomment&userid=%ld&chatid=%ld&marknum=%ld&summary=%@", (long)[CureMeUtils defaultCureMeUtil].userID, (long)_chatID, (long)_markPoint, encodeString];
    NSData *response = sendRequest(@"m.php", post);
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"post: %@, resp: %@", post, strResp);

    hasComment = true;
    
    if (_delegate && [_delegate respondsToSelector:@selector(pointMarked:withComment:)]) {
        [_delegate pointMarked:_markPoint withComment:_commentField.text];
    }
    
    [[KGModal sharedInstance] hideAnimated:YES];
}

- (void)confirmBtnClickForDelegate
{
    NSLog(@"MarkDoctorVC confirmBtn click");
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:HAS_MARKAPP];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)cancelBtnClickForDelegate
{
    NSLog(@"MarkDoctorVC confirmBtn click");
}

- (IBAction)cancelBtnClicked:(id)sender {
    [[KGModal sharedInstance] hideAnimated:YES];
}
@end
