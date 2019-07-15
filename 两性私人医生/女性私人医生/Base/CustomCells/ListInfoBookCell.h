//
//  ListInfoBookCell.h
//  CureMe
//
//  Created by Tim on 12-11-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "MyBookListViewController.h"
#import <UIKit/UIKit.h>


@interface ListInfoBookCell : UITableViewCell

{
    UIImageView *hospitalImageView;
    UIImageView *statusImageView;

    UILabel *dateLabel;
    UILabel *date;
    
    UILabel *bookNoLabel;
    UILabel *bookNo;
    
    UILabel *hospNameLabel;
    UILabel *hospName;
    
    UILabel *offNameLabel;
    UILabel *offName;
    
    UILabel *hospReplyLabel;
    UILabel *hospReply;
}

@property (nonatomic, strong) MyBookListViewController *bookListViewController;
@property (nonatomic, strong) BookDetail *bookDetail;

- (void)generateLayout;

@end
