//
//  UIBubbleTableViewCell.h
//
//  Created by Alex Barinov
//  StexGroup, LLC
//  http://www.stexgroup.com
//
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//


#import <UIKit/UIKit.h>
#import "NSBubbleDataInternal.h"


@interface UIBubbleTableViewCell : UITableViewCell
{
    IBOutlet UILabel *headerLabel;      // 聊天时间label
    IBOutlet UILabel *contentLabel;     // 内容
    IBOutlet UIImageView *bubbleImage;  // 内容背景气泡
    IBOutlet UIImageView *headImage;    // 头像图片
    IBOutlet UIImageView *msgImage;     // 内容图像
    IBOutlet UILabel *doctorNameLabel;  // 医生姓名label
    IBOutlet UIImageView *rectangleView;// 对话三角
}

@property (nonatomic, strong) NSBubbleDataInternal *dataInternal;

- (void)setupInternalTextImageData;
- (void)setupInternalTelephoneData;
- (void)setupInternalMapInfoData;
- (void)setupInternalBookInfoData;

@end
