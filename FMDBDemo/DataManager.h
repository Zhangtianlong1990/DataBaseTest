//
//  DataManager.h
//  FMDBDemo
//
//  Created by 张天龙 on 2021/1/24.
//  Copyright © 2021 张天龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "fmdb/FMDB.h"
NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject
@property (nonatomic,strong) NSMutableArray *seletArrays;
//@property (nonatomic,strong) FMDatabase *db;
+ (instancetype)shareInstance;
- (void)insertData:(Person *)model;
- (void)insertDataNotCalculatedOpenAndCloseDB;
- (void)insertDataNotCalculatedOpenAndCloseDBBeginTransaction;
- (void)insertDataNotCalculatedOpenAndCloseDBBeginTransactionFrom100000;
- (void)selectWithID:(int)ID;
- (void)selectWithScore:(int)score;
- (void)selectWithOrderByScore;
@end

NS_ASSUME_NONNULL_END
