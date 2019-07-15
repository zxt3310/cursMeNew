//
//  FMDBHelper.m
//  JSONModelDemo_iOS
//
//  Created by zhou on 14-5-1.
//  Copyright (c) 2014年 Underplot ltd. All rights reserved.
//

#import "FMDBHelper.h"
#import "FMDatabaseQueue.h"
#import "JSONModel.h"


@interface FMDBHelper ()

@property (strong, nonatomic) NSString       *dbPath;

@end

static NSString *const kJMFileNameDefaultDataBase = @"hichat_default.db";

@implementation FMDBHelper

static id sharedInstanceFMDBHelper = nil;

+ (instancetype)sharedInstance;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstanceFMDBHelper = [[self alloc] init];
    });
    if(nil == sharedInstanceFMDBHelper) {
        sharedInstanceFMDBHelper = [[self alloc] init];
    }
    return sharedInstanceFMDBHelper;
}


/**
 *  删除数据库文件
 */
+ (void)deleteDataBaseFile
{

    [[FMDBHelper sharedInstance] close];
    sharedInstanceFMDBHelper = nil;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dataPath = [[self __documentsDir] stringByAppendingPathComponent:kJMFileNameDefaultDataBase];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:dataPath error:&error];
    if (!success) {
        NSLog(@"Could not delete %@ database file -:%@ ", kJMFileNameDefaultDataBase, [error localizedDescription]);
    }
    
}

- (void)dealloc
{
    [self close];
    sharedInstanceFMDBHelper = nil;
}

- (id)init
{
    NSString *dataPath = [[[self class] __documentsDir] stringByAppendingPathComponent:kJMFileNameDefaultDataBase];
    self = [[self class] databaseWithPath:dataPath];
    self.dbPath = dataPath;
    if (![self open]) {
        NSLog(@"Could not open Database: '%@'", [self lastErrorMessage]);
    }
    return self;
}

+ (NSString *)__documentsDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

#pragma mark - 

- (FMResultSet *)JM_executeQuery:(NSString*)sql;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    
    FMResultSet *rsl = [self executeQuery:sql];
    return rsl;
    
#pragma clang diagnostic pop
}

- (void)JM_executeQuery:(NSString*)sql block:(FMDBCompletionBlock)block;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"

    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    [queue inDatabase:^(FMDatabase *adb) {
        FMResultSet *rsl = [adb executeQueryWithFormat:sql];
        if(block)
            block(nil, rsl);
        [rsl close];
        [adb close];
    }];
    
#pragma clang diagnostic pop
 
}

- (BOOL)JM_executeStatements:(NSString *)sql{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    BOOL ret = [self executeStatements:sql];
    return ret;
#pragma clang diagnostic pop
    
}

- (BOOL)JM_executeStatements:(NSString *)sql block:(FMDBExecuteStatementsCallbackBlock)block
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    BOOL ret = [self executeStatements:sql withResultBlock:block];
    return ret;
#pragma clang diagnostic pop
    
}

- (BOOL)JM_executeUpdate:(NSString*)sql;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    BOOL ret = [self executeUpdate:sql];
    return ret;
#pragma clang diagnostic pop

}

- (void)JM_executeUpdate:(NSString*)sql block:(FMDBCompletionBlock)block;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    
    __weak NSString *weakSql = sql;
    __block FMDBCompletionBlock blockCp = block;
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    [queue inDatabase:^(FMDatabase *adb) {
        BOOL ret = [adb executeUpdateWithFormat:weakSql];
        if(ret) {
            if(blockCp)
                blockCp(nil, nil);
        } else {
            NSError *err =  [NSError errorWithDomain:@"data update err"
                                              code:1
                                          userInfo:nil];
            if(blockCp)
                blockCp(err, nil);
        }
        [adb close];
    }];

#pragma clang diagnostic pop

}

@end
