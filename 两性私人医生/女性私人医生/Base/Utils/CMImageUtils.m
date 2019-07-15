//
//  CMImageUtils.m
//  私密健康医生
//
//  Created by Tim on 13-1-13.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMImageUtils.h"

static CMImageUtils *defaultImageU = nil;

@implementation CMImageUtils

@synthesize chatLoadingImage = _chatLoadingImage;
@synthesize doctorDefaultBGImage = _doctorDefaultBGImage;
@synthesize doctorDefaultBGMImage = _doctorDefaultBGMImage;
@synthesize doctorDefaultHeadSImage = _doctorDefaultHeadSImage;
@synthesize doctorDefaultHeadMImage = _doctorDefaultHeadMImage;
@synthesize doctorDefaultHeadLImage = _doctorDefaultHeadLImage;
@synthesize doctorDefaultHeadImage = _doctorDefaultHeadImage;
@synthesize hospitalDefaultHeadSImage = _hospitalDefaultHeadSImage;
@synthesize hospitalDefaultHeadMImage = _hospitalDefaultHeadMImage;
@synthesize hospitalDefaultHeadLImage = _hospitalDefaultHeadLImage;
@synthesize qaCellQuestionBgImage = _qaCellQuestionBgImage;
@synthesize qaCellQuestionBgAllImage = _qaCellQuestionBgAllImage;
@synthesize qaCellAnswerMidImage = _qaCellAnswerMidImage;
@synthesize qaCellAnswerTailImage = _qaCellAnswerTailImage;
@synthesize qaListQuestionImage = _qaListQuestionImage;
@synthesize qaListQuestionDefultImage = _qaListQuestionDefultImage;
@synthesize logoImage = _logoImage;
@synthesize userHeadImage = _userHeadImage;

@synthesize chatOtherBubbleImage = _chatOtherBubbleImage;
@synthesize chatSelfBubbleImage = _chatSelfBubbleImage;
@synthesize chatNotifyBubbleImage = _chatNotifyBubbleImage;

@synthesize btnBg_NImage = _btnBg_NImage;
@synthesize btnBg_PImage = _btnBg_PImage;

@synthesize officeIconDict = _officeIconDict;
@synthesize officeNameDict = _officeNameDict;

@synthesize navBackBtnNormal = _navBackBtnNormal;
@synthesize navBackBtnSelected = _navBackBtnSelected;
@synthesize deleteChatBtnImage = _deleteChatBtnImage;

@synthesize chatListNoreplyDefaultImage = _chatListNoreplyDefaultImage;


+ (CMImageUtils *)defaultImageUtil
{
    if (!defaultImageU) {
        defaultImageU = [[super allocWithZone:NULL] init];
    }
    
    return defaultImageU;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultImageUtil];
}

- (id)init
{
    if (defaultImageU) {
        return defaultImageU;
    }
    
    self = [super init];
    
    // ImageUtils initlization work
    
    return self;
}

- (void)dealloc
{
    _doctorDefaultHeadLImage = nil;
    _doctorDefaultHeadMImage = nil;
    _doctorDefaultHeadSImage = nil;
    _doctorDefaultBGImage = nil;
    _hospitalDefaultHeadLImage = nil;
    _hospitalDefaultHeadMImage = nil;
    _hospitalDefaultHeadSImage = nil;
    _chatLoadingImage = nil;
}

#pragma mark Image properties
- (UIImage *)logoImage{
    if (!_logoImage) {
        _logoImage = [UIImage imageNamed:@"logo_woman_B.png"];
    }
    return _logoImage;
}

- (UIImage *)doctorDefaultBGImage
{
    if (!_doctorDefaultBGImage) {
        _doctorDefaultBGImage = [UIImage imageNamed:@"img_bg.png"];
    }
    
    return _doctorDefaultBGImage;
}

- (UIImage *)doctorDefaultBGMImage
{
    if (!_doctorDefaultBGMImage) {
        _doctorDefaultBGMImage = [UIImage imageNamed:@"doctor_bg_m.png"];
    }
    
    return _doctorDefaultBGMImage;
}

- (UIImage *)doctorDefaultHeadSImage
{
    if (!_doctorDefaultHeadSImage) {
        _doctorDefaultHeadSImage = [UIImage imageNamed:@"doctor_s.png"];
    }
    
    return _doctorDefaultHeadSImage;
}

- (UIImage *)doctorDefaultHeadMImage
{
    if (!_doctorDefaultHeadMImage) {
        _doctorDefaultHeadMImage = [UIImage imageNamed:@"doctor_m.png"];
    }
    
    return _doctorDefaultHeadMImage;
}

- (UIImage *)doctorDefaultHeadLImage
{
    if (!_doctorDefaultHeadLImage) {
        _doctorDefaultHeadLImage = [UIImage imageNamed:@"doctor_b.png"];
    }
    
    return _doctorDefaultHeadLImage;
}

- (UIImage *)doctorDefaultHeadImage
{
    if (!_doctorDefaultHeadImage) {
        _doctorDefaultHeadImage = [UIImage imageNamed:@"doctor_bg_s@2x.png"];
    }
    
    return _doctorDefaultHeadImage;
}

- (UIImage *)qaCellQuestionBgImage
{
    if (!_qaCellQuestionBgImage) {
        _qaCellQuestionBgImage = [UIImage imageNamed:@"bg_list_top.png"];
    }
    
    return _qaCellQuestionBgImage;
}

- (UIImage *)qaCellQuestionBgAllImage
{
    if (!_qaCellQuestionBgAllImage) {
        _qaCellQuestionBgAllImage = [UIImage imageNamed:@"bg_list_all.png"];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 6.0) {
            _qaCellQuestionBgAllImage = [_qaCellQuestionBgAllImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeTile];
        }
        else {
            _qaCellQuestionBgAllImage = [_qaCellQuestionBgAllImage stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        }
    }
    
    return _qaCellQuestionBgAllImage;
}

- (UIImage *)qaCellAnswerMidImage
{
    if (!_qaCellAnswerMidImage) {
        _qaCellAnswerMidImage = [UIImage imageNamed:@"bg_list_m.png"];
    }
    
    return _qaCellAnswerMidImage;
}

- (UIImage *)qaCellAnswerTailImage
{
    if (!_qaCellAnswerTailImage) {
        _qaCellAnswerTailImage = [UIImage imageNamed:@"bg_list_bottom.png"];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 6.0) {
            _qaCellAnswerTailImage = [_qaCellAnswerTailImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeTile];
        }
        else {
            _qaCellAnswerTailImage = [_qaCellAnswerTailImage stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        }
    }
    
    return _qaCellAnswerTailImage;
}

- (UIImage *)hospitalDefaultHeadSImage
{
    if (!_hospitalDefaultHeadSImage) {
        _hospitalDefaultHeadSImage = [UIImage imageNamed:@"hospital_s.png"];
    }
    
    return _hospitalDefaultHeadSImage;
}

- (UIImage *)qaListQuestionImage
{
    if (!_qaListQuestionImage) {
        _qaListQuestionImage = [UIImage imageNamed:@"ico_head_hos@2x.png"];
    }
    
    return _qaListQuestionImage;
}

- (UIImage *)userHeadImage{
    if (!_userHeadImage) {
        NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"ico_head_me" ofType:@"png" inDirectory:@"images"];
        _userHeadImage = [UIImage imageWithContentsOfFile:pathStr];
    }
    return _userHeadImage;
}

- (UIImage *)qaListQuestionDefultImage{
    if (!_qaListQuestionDefultImage) {
        _qaListQuestionDefultImage = [UIImage imageNamed:@"ico_msg_and.png"];
    }
    return _qaListQuestionDefultImage;
}

- (UIImage *)hospitalDefaultHeadMImage
{
    if (!_hospitalDefaultHeadMImage) {
        _hospitalDefaultHeadMImage = [UIImage imageNamed:@"hospital_m.png"];
    }
    
    return _hospitalDefaultHeadMImage;
}

- (UIImage *)hospitalDefaultHeadLImage
{
    if (!_hospitalDefaultHeadLImage) {
        _hospitalDefaultHeadLImage = [UIImage imageNamed:@"hospital_b.png"];
    }
    
    return _hospitalDefaultHeadLImage;
}


- (UIImage *)chatListNoreplyDefaultImage
{
    if (!_chatListNoreplyDefaultImage) {
        _chatListNoreplyDefaultImage = [UIImage imageNamed:@"ico_new_list.png"];
    }
    
    return _chatListNoreplyDefaultImage;
}

- (UIImage *)chatNotifyBubbleImage
{
    if (!_chatNotifyBubbleImage) {
        _chatNotifyBubbleImage = [UIImage imageNamed:@"chat_bg_m_normal.png"];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 6.0) {
            _chatNotifyBubbleImage = [_chatNotifyBubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeTile];
        }
        else {
            _chatNotifyBubbleImage = [_chatNotifyBubbleImage stretchableImageWithLeftCapWidth:8 topCapHeight:8];
        }
    }
    
    return _chatNotifyBubbleImage;
}

- (UIImage *)chatOtherBubbleImage
{
    if (!_chatOtherBubbleImage) {
        UIImage *otherBubble = [UIImage imageNamed:@"chat_bg_left_normal.png"];
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 6.0) {
            _chatOtherBubbleImage = [otherBubble resizableImageWithCapInsets:UIEdgeInsetsMake(10, 20, 32, 14) resizingMode:UIImageResizingModeTile];
        }
        else {
            _chatOtherBubbleImage = [otherBubble stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        }
    }
    
    return _chatOtherBubbleImage;
}


- (UIImage *)chatSelfBubbleImage
{
    if (!_chatSelfBubbleImage) {
        UIImage *otherBubble = [UIImage imageNamed:@"chat_bg_right_normal.png"];
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 6.0) {
            _chatSelfBubbleImage = [otherBubble resizableImageWithCapInsets:UIEdgeInsetsMake(10, 14, 32, 20) resizingMode:UIImageResizingModeTile];
        }
        else {
            _chatSelfBubbleImage = [otherBubble stretchableImageWithLeftCapWidth:14 topCapHeight:10];
        }
    }
    
    return _chatSelfBubbleImage;    
}

- (UIImage *)chatLoadingImage
{
    if (!_chatLoadingImage) {
        _chatLoadingImage = [UIImage imageNamed:@"正在载入.png"];
    }
    
    return _chatLoadingImage;
}

- (UIImage *)btnBg_NImage
{
    if (!_btnBg_NImage) {
        _btnBg_NImage = [UIImage imageNamed:@"an_n.png"];
    }
    
    return _btnBg_NImage;
}

- (UIImage *)btnBg_PImage
{
    if (!_btnBg_PImage) {
        _btnBg_PImage = [UIImage imageNamed:@"an_p.png"];
    }
    
    return _btnBg_PImage;
}

- (UIImage *)navBackBtnNormal
{
    if (!_navBackBtnNormal) {
        _navBackBtnNormal = [UIImage imageNamed:@"icon_back.png"];
    }
    
    return _navBackBtnNormal;
}

- (UIImage *)navBackBtnSelected
{
    if (!_navBackBtnSelected) {
        _navBackBtnSelected = [UIImage imageNamed:@"back_n.png"];
    }
    
    return _navBackBtnSelected;
}

- (UIImage *)hasMarkedBtnImage
{
    if (!_hasMarkedBtnImage) {
        _hasMarkedBtnImage = [UIImage imageNamed:@"评价.png"];
    }
    
    return _hasMarkedBtnImage;
}

- (UIImage *)hasNotMarkedBtnImage
{
    if (!_hasNotMarkedBtnImage) {
        _hasNotMarkedBtnImage = [UIImage imageNamed:@"未评价.png"];
    }
    
    return _hasNotMarkedBtnImage;
}
/**
 *  @author Zxt, 17-04-01 17:04:29
 *
 *  删除按钮
 *
 *  @return <#return value description#>
 */
- (UIImage *)deleteChatBtnImage
{
    if (!_deleteChatBtnImage) {
        _deleteChatBtnImage = [UIImage imageNamed:@"icon_trash"];
    }
    return _deleteChatBtnImage;
}

#pragma mark 科室有关的字典（Icon、名称）
- (NSMutableDictionary *)officeIconDict
{
    if (!_officeIconDict) {
        _officeIconDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                           /*[UIImage imageNamed:@"ico_ck_n.png"], [NSNumber numberWithInt:10],
                           [UIImage imageNamed:@"ico_fk_n.png"], [NSNumber numberWithInt:11],
                           [UIImage imageNamed:@"ico_ck_n.png"], [NSNumber numberWithInt:12],
                           [UIImage imageNamed:@"ico_pfk_n.png"], [NSNumber numberWithInt:13],
                           [UIImage imageNamed:@"ico_yk_n.png"], [NSNumber numberWithInt:14],
                           [UIImage imageNamed:@"ico_zy_n.png"], [NSNumber numberWithInt:15],
                           [UIImage imageNamed:@"ico_kouqiang.png"], [NSNumber numberWithInt:16],
                           [UIImage imageNamed:@"ico_ganbing.png"], [NSNumber numberWithInt:OFFICE_GANBING],
                           [UIImage imageNamed:@"ico_naobu.png"], [NSNumber numberWithInt:OFFICE_NAOTAN],
                           [UIImage imageNamed:@"ico_gutou.png"], [NSNumber numberWithInt:OFFICE_GUKE],
                           [UIImage imageNamed:@"ico_dianxian.png"], [NSNumber numberWithInt:OFFICE_DIANXIAN],*/
                            nil, [NSNumber numberWithInt:10],
                            nil, [NSNumber numberWithInt:11],
                            nil, [NSNumber numberWithInt:12],
                            nil, [NSNumber numberWithInt:13],
                            nil, [NSNumber numberWithInt:14],
                            nil, [NSNumber numberWithInt:15],
                            nil, [NSNumber numberWithInt:16],
                            nil, [NSNumber numberWithInt:OFFICE_GANBING],
                            nil, [NSNumber numberWithInt:OFFICE_NAOTAN],
                            nil, [NSNumber numberWithInt:OFFICE_GUKE],
                            nil, [NSNumber numberWithInt:OFFICE_DIANXIAN],
                          nil];
    }
    
    return _officeIconDict;
}

- (NSMutableDictionary *)officeNameDict
{
    if (!_officeNameDict) {
        _officeNameDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                           @"美容", [NSNumber numberWithInt:10],
                           @"妇科", [NSNumber numberWithInt:11],
                           @"产科", [NSNumber numberWithInt:12],
                           @"皮肤科", [NSNumber numberWithInt:13],
                           @"眼科", [NSNumber numberWithInt:14],
                           @"中医", [NSNumber numberWithInt:15],
                           @"口腔", [NSNumber numberWithInt:16],
                           nil];
    }
    
    return _officeNameDict;
}

- (UIImage *)officeIconWithID:(NSInteger)officeID
{
    [self officeIconDict];
    
    return [_officeIconDict objectForKey:[NSNumber numberWithInteger:officeID]];
}

@end
