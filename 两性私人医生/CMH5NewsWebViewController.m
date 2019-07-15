//
//  CMH5NewsWebViewController.m
//  女性私人医生
//
//  Created by Zxt3310 on 2017/10/17.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "CMH5NewsWebViewController.h"
#define FF_HEADER_BGCOLOR [UIColor colorWithRed:201.0/255 green:2.0/255 blue:27.0/255 alpha:1.0]
#define FF_TEXTCOLOR_BLACK [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1.0]
@interface CMH5NewsWebViewController ()
{
    UIScrollView *navView;
    UIButton *currentNavBtn;
    CGFloat split_width;
    NSDictionary *typeDataQA;
    
    UIView *qa_selectNavView;
    CGPoint qa_navViewStartPosPoint;
    WebViewCoverView *coverView;
    NSInteger numberOfCurrentRows;
    
    NSArray *currentNewsList;
    NSMutableArray *requesetNewsList;
    NSArray *currentImageArray;
    NSMutableArray *requestImageArray;
    NSInteger currentQtype;
    
    BOOL isLoadingImage;
    
    UITableView *tableview;
    LoadingView *loadingView;
    
    NSMutableDictionary *cacheNewsListDic;
    NSMutableDictionary *cacheNewsPicDic;
}
@end

@implementation CMH5NewsWebViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        cacheNewsPicDic = [[NSMutableDictionary alloc] init];
        cacheNewsListDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 64-40-48)];
    tableview.tableFooterView = [[UITableView alloc] initWithFrame:CGRectZero];
    tableview.delegate = self;
    tableview.dataSource = self;
    [self.view addSubview:tableview];
    
    float topY = 140;
    if ([UIScreen mainScreen].bounds.size.height > 480.0) {
        topY += 40;
    }
    loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 35, topY, 80, 70)];
    loadingView.hidden = YES;
    [self.view addSubview:loadingView];
    
    //初始化
    numberOfCurrentRows = 0;
    isLoadingImage = NO;
    requesetNewsList = [[NSMutableArray alloc] init];
    requestImageArray = [[NSMutableArray alloc] init];
    
    split_width = 15;
    navView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    navView.tag = 999;
    navView.showsHorizontalScrollIndicator = NO;
    navView.showsVerticalScrollIndicator = NO;
    navView.panGestureRecognizer.delaysTouchesBegan = YES;//按钮滑动流畅
    navView.backgroundColor = [UIColor whiteColor];
    navView.layer.shadowColor = [UIColor blackColor].CGColor;
    navView.layer.shadowOffset = CGSizeMake(0, 2);
    navView.layer.shadowOpacity = 0.3;
    navView.clipsToBounds = NO;
    
    CGFloat navStartPos = split_width;
    currentNavBtn = [self createNavButton:@"全部" index:0 startPos:navStartPos width:2*14+2];
    [currentNavBtn setTitleColor:FF_HEADER_BGCOLOR forState:UIControlStateNormal];
    [navView addSubview:currentNavBtn];
    navStartPos += 2*14+2 + split_width*2;
    
    if (_officeTypeArray) {
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        for (int i=0; i<_officeTypeArray.count; i++) {
            NSString *idStr = [_officeTypeArray[i] objectForKey:@"id"];
            NSString *nameStr = [_officeTypeArray[i] objectForKey:@"name"];
            [tempDic setObject:nameStr forKey:idStr];
        }
        typeDataQA = [tempDic copy];
    }
    
    if (typeDataQA) {
        for (NSString *key in typeDataQA) {
            NSString *btnName = [typeDataQA objectForKey:key];
            int length = [self countAsciiLength:btnName];
            CGFloat btnWidth = length*14+2;
            [navView addSubview:[self createNavButton:btnName index:[key integerValue] startPos:navStartPos width:btnWidth]];
            navStartPos += btnWidth + split_width*2;
        }
    }
    qa_selectNavView = [[UIView alloc] initWithFrame:CGRectMake(split_width, 35, 2*14+2, 3)];
    qa_selectNavView.backgroundColor = FF_HEADER_BGCOLOR;//[UIColor colorWithRed:255.0/255 green:205.0/255 blue:206.0/255 alpha:1.0];
    [navView addSubview:qa_selectNavView];
    CGSize contentSize = CGSizeMake(navStartPos + 35, 40);
    navView.contentSize = contentSize;
    
    [self.view addSubview:navView];
    
    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 62, 0, 62, 40)];
    btnView.backgroundColor = [UIColor whiteColor];
    btnView.layer.shadowOffset = CGSizeMake(-1, 0);
    btnView.layer.shadowColor = [UIColor blackColor].CGColor;
    btnView.layer.shadowOpacity = 0.5;
    
    UIButton *listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    listBtn.frame = CGRectMake(22, 11, 18, 18);
    [listBtn setImage:[UIImage imageNamed:@"listBtn_both"] forState:UIControlStateNormal];
    [btnView addSubview:listBtn];
    [listBtn addTarget:self action:@selector(btnViewClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnView];
    
    coverView = [[WebViewCoverView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    coverView.hidden = YES;
    coverView.delegate = self;
    coverView.btnDic = typeDataQA;
    [self.view addSubview:coverView];
    
    [self newsListRequest:0];
    
    
    //测试code
    
//    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    loginBtn.frame = CGRectMake(0, 0, 50, 40);
//    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
//    [loginBtn addTarget:self action:@selector(loginBtn) forControlEvents:UIControlEventTouchUpInside];
//    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loginBtn];
}

- (void)loginBtn{
    CMLoginViewController *login = [[CMLoginViewController alloc] init];
    [self.navigationController pushViewController:login animated:YES];
}

-(UIButton *)createNavButton:(NSString *)title index:(NSInteger)index startPos:(CGFloat)startPos width:(CGFloat)width{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(startPos, 0+6, width, 28);
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button setTitle:title forState:UIControlStateNormal];
    //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:FF_TEXTCOLOR_BLACK forState:UIControlStateNormal];
    [button addTarget:self action:@selector(navBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = index;
    return button;
}

- (int)countAsciiLength:(NSString*)strtemp {
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
}

-(void)navBtnClicked:(UIButton *)sender{
    if (isLoadingImage == YES) {
        return;
    }
    [currentNavBtn setTitleColor:FF_TEXTCOLOR_BLACK forState:UIControlStateNormal];
    currentNavBtn = sender;
    [currentNavBtn setTitleColor:FF_HEADER_BGCOLOR forState:UIControlStateNormal];
    
    [self moveSelectView:sender.tag];
    
    if (sender.frame.origin.x - navView.contentOffset.x > SCREEN_WIDTH - 65) {
        [navView setContentOffset:CGPointMake(sender.frame.origin.x - SCREEN_WIDTH + sender.frame.size.width + 65, 0) animated:YES];
    }
    if (navView.contentOffset.x > sender.frame.origin.x) {
        [navView setContentOffset:CGPointMake(sender.frame.origin.x - 10, 0) animated:YES];
    }
    
    [coverView superSelectBtnAction:sender.tag];
    
    //切换栏目，清空新闻缓存
    [requesetNewsList removeAllObjects];
    [requestImageArray removeAllObjects];
    currentNewsList = nil;
    currentImageArray = nil;
    numberOfCurrentRows = 0;
    currentQtype = sender.tag;
    [self newsListRequest:sender.tag];
}

-(void)moveSelectView:(NSInteger)index{
    CGFloat spos = split_width;
    CGFloat swidth = 14*2+2;
    if (typeDataQA && index !=0) {
        
        for (NSString *key in typeDataQA) {
            NSString *btnName = [typeDataQA objectForKey:key];
            int length = [self countAsciiLength:btnName];
            spos += swidth + split_width*2;
            swidth = length*14+2;
            
            if ([key integerValue] == index)
                break;
        }
    }
    
    CGRect frame = CGRectMake(spos, 35, swidth, 3);
    qa_selectNavView.frame = frame;
}

- (void)btnViewClick:(UIButton *) sender{
    coverView.hidden = NO;
}

- (void)dismissPageAndSelectOffice:(NSInteger)Btntag{
    coverView.hidden = YES;
    if (Btntag != 999) {
        UIButton *selectBtn = (UIButton *)[navView viewWithTag:Btntag];
        [self navBtnClicked:selectBtn];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 142 *SCREEN_HEIGHT/667;
    }
    else
        return 96;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return numberOfCurrentRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld",indexPath.row]];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"cell%ld",indexPath.row]];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(286*SCREEN_WIDTH/375, 12, 69*SCREEN_WIDTH/375, 69*SCREEN_HEIGHT/667)];
        imageView.tag = 1;
        imageView.layer.cornerRadius = 10;
        imageView.layer.masksToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imageView];
        
        UILabel *titleLb = [[UILabel alloc] initWithFrame:CGRectMake(20, 22, 250*SCREEN_WIDTH/375, 21)];
        titleLb.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15];
        titleLb.tag = 2;
        [cell.contentView addSubview:titleLb];
        
        UILabel *textLb = [[UILabel alloc] initWithFrame:CGRectMake(23, 65, 234*SCREEN_WIDTH/375, 13)];
        textLb.font = [UIFont fontWithName:@"STHeitiSC-Light" size:13];
        textLb.tag = 3;
        textLb.numberOfLines = 0;
        textLb.lineBreakMode = NSLineBreakByWordWrapping;
        
        [cell.contentView addSubview:textLb];
    }
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
    imageView.image = currentImageArray[indexPath.row];
    //imageView.contentMode = UIViewContentModeCenter;
    
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:2];
    titleLb.text = (NSString *)[currentNewsList[indexPath.row] objectForKey:@"title"];
    
    UILabel *textView = (UILabel *)[cell.contentView viewWithTag:3];
    textView.text = [(NSString *)[currentNewsList[indexPath.row] objectForKey:@"time"] substringWithRange:NSMakeRange(0, 10)];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0) {
        imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 142*SCREEN_HEIGHT/667);
        imageView.layer.cornerRadius = 0;
        imageView.clipsToBounds = YES;
        titleLb.frame = CGRectMake(SCREEN_WIDTH - 24 - titleLb.text.length * 15 - 20, 110 *SCREEN_HEIGHT/667, titleLb.text.length * 15 +20, 26);
        if (titleLb.frame.origin.x <= 0) {
            titleLb.transform = CGAffineTransformMakeTranslation(20, 0);
        }
        titleLb.backgroundColor = UIColorFromHex(0xff6c89, 1);
        titleLb.text = [NSString stringWithFormat:@"  %@",titleLb.text];
        titleLb.textColor = [UIColor whiteColor];
        titleLb.layer.cornerRadius = 12;
        titleLb.clipsToBounds = YES;
        textView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    webVC.strURL = [(NSString *)[currentNewsList[indexPath.row] objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    if (webVC.strURL == nil || webVC.strURL.length == 0) {
        return;
    }
    [self.navigationController pushViewController:webVC animated:YES];
}

//滚动监听
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height) {
        if (isLoadingImage == NO) {
            numberOfCurrentRows += 15;
            [self newsListRequest:currentQtype];
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 50) animated:YES];
        }
    }
}

- (void)newsListRequest:(NSInteger)qtypeId{
    
    isLoadingImage = YES;
    
    //先从缓存找新闻，没有再请求
    if (numberOfCurrentRows == 0) {
        currentImageArray = [cacheNewsPicDic objectForKey:[NSString stringWithFormat:@"%ld",(long)qtypeId]];
        currentNewsList = [cacheNewsListDic objectForKey:[NSString stringWithFormat:@"%ld",(long)qtypeId]];
        if (currentImageArray.count >0 && currentNewsList.count >0 && currentImageArray.count == currentNewsList.count) {
            requesetNewsList = [currentNewsList mutableCopy];
            requestImageArray = [currentImageArray mutableCopy];
            numberOfCurrentRows = requesetNewsList.count;
            [tableview reloadData];
            [tableview setContentOffset:CGPointMake(0, 0) animated:YES];
            isLoadingImage = NO;
            return;
        }
    }
   
    NSString *urlStr = [NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/h5_new/server/app.php?type=newslist&appid=7&qtype=%ld&limit=%ld",(long)qtypeId,(long)numberOfCurrentRows];
    
    loadingView.hidden = NO;
    tableview.scrollEnabled = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *response = sendGETRequest(urlStr);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!response) {
                NSLog(@"network error!");
                loadingView.hidden = YES;
                return ;
            }
            
            NSDictionary *returnDic = parseJsonResponse(response);
            
            if (!returnDic) {
                NSLog(@"return Data error!");
                loadingView.hidden = YES;
                return;
            }
            NSArray *newListArray = [returnDic objectForKey:@"news_list"];
            
            NSDictionary *topNewsDic = [returnDic objectForKey:@"topNews"];
            if (numberOfCurrentRows == 0) {
                NSString *imgUrl = [(NSString *)[topNewsDic objectForKey:@"img"] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
                if (!image) {
                    image = [[UIImage alloc] init];
                }
                [requestImageArray addObject:image];
                [requesetNewsList addObject:topNewsDic];
            }

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (int i=0; i<newListArray.count; i++) {
                    NSString *imgUrl = [(NSString *)[newListArray[i] objectForKey:@"img"] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
                    if (!image) {
                        image = [[UIImage alloc] init];
                    }
                    [requestImageArray addObject:image];
                    [requesetNewsList addObject:newListArray[i]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    currentNewsList = [requesetNewsList copy];
                    currentImageArray = [requestImageArray copy];
                    numberOfCurrentRows = currentNewsList.count;
                    [tableview reloadData];
                    isLoadingImage = NO;
                    tableview.scrollEnabled = YES;
                    loadingView.hidden = YES;
                    if (numberOfCurrentRows == 16) {
                        [tableview setContentOffset:CGPointMake(0, 0) animated:YES];
                    }
                    [cacheNewsPicDic setObject:currentImageArray forKey:[NSString stringWithFormat:@"%ld",(long)qtypeId]];
                    [cacheNewsListDic setObject:currentNewsList forKey:[NSString stringWithFormat:@"%ld",(long)qtypeId]];
                });
            });
        });
    });
}

-(NSString *)flattenHTML:(NSString *)html trimWhiteSpace:(BOOL)trim
{
    NSScanner *theScanner = [NSScanner scannerWithString:html];
    NSString *text = nil;
    
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [ NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
    }
    return trim ? [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : html;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"健康资讯";
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
