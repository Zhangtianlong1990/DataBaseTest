//
//  DataManager.m
//  FMDBDemo
//
//  Created by 张天龙 on 2021/1/24.
//  Copyright © 2021 张天龙. All rights reserved.
//

#import "DataManager.h"


@interface DataManager()
@property (nonatomic,assign) int count;
@property(nonatomic,strong)FMDatabaseQueue *dataBaseQ;
@end

@implementation DataManager

+ (instancetype)shareInstance{
    static DataManager *single = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!single) {
            single = [[DataManager alloc] init];
        }
    });
    return single;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatDatabase];
    }
    return self;
}

- (void)creatDatabase{
    NSString *docuPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [docuPath stringByAppendingPathComponent:@"test.db"];
    NSLog(@"dbPath=%@",dbPath);
    FMDatabaseQueue *dataBaseQ = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    _dataBaseQ = dataBaseQ;
    
    [_dataBaseQ inDatabase:^(FMDatabase * _Nonnull db) {
        
        if (![db open]) {
            NSLog(@"db open fail");
            return;
        }
        //4.数据库中创建表（可创建多张）
        NSString *sql = @"create table if not exists t_student ('ID' INTEGER PRIMARY KEY,'name' TEXT NOT NULL, 'phone' TEXT NOT NULL,'score' INTEGER NOT NULL)";
        //5.执行更新操作 此处database直接操作，不考虑多线程问题，多线程问题，用FMDatabaseQueue 每次数据库操作之后都会返回bool数值，YES，表示success，NO，表示fail,可以通过 @see lastError @see lastErrorCode @see lastErrorMessage
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"create table success");
            
        }
        [db close];
    }];
    
//    //2.创建对应路径下数据库
//    self.db = [FMDatabase databaseWithPath:dbPath];
//    //3.在数据库中进行增删改查操作时，需要判断数据库是否open，如果open失败，可能是权限或者资源不足，数据库操作完成通常使用close关闭数据库
//    [self.db open];
//    if (![self.db open]) {
//        NSLog(@"db open fail");
//        return;
//    }
//    //4.数据库中创建表（可创建多张）
//    NSString *sql = @"create table if not exists t_student ('ID' INTEGER PRIMARY KEY,'name' TEXT NOT NULL, 'phone' TEXT NOT NULL,'score' INTEGER NOT NULL)";
//    //5.执行更新操作 此处database直接操作，不考虑多线程问题，多线程问题，用FMDatabaseQueue 每次数据库操作之后都会返回bool数值，YES，表示success，NO，表示fail,可以通过 @see lastError @see lastErrorCode @see lastErrorMessage
//    BOOL result = [self.db executeUpdate:sql];
//    if (result) {
//        NSLog(@"create table success");
//
//    }
//    [self.db close];
    
}

- (void)insertData:(Person *)model{
    
    [_dataBaseQ inDatabase:^(FMDatabase * _Nonnull db) {

        if (![db open]) {
            NSLog(@"db open fail");
            return;
        }
        NSMutableArray *insertArr = [NSMutableArray array];
        [insertArr addObject:[NSNumber numberWithInt:model.ID]];
        [insertArr addObject:model.name];
        [insertArr addObject:model.phone];
        [insertArr addObject:[NSNumber numberWithInt:model.score]];
        BOOL result = [db executeUpdate:@"insert or ignore into t_student(ID,name,phone,score) values(?,?,?,?)" withArgumentsInArray:insertArr];
        if (result) {
//            NSLog(@"insert into 't_studet' %d success,%@",model.ID,[NSThread currentThread]);
        } else {
            NSLog(@"insert into 't_studet' faild");
        }
        [db close];
    }];
    
}

- (void)insertDataNotCalculatedOpenAndCloseDB{
    
    [_dataBaseQ inDatabase:^(FMDatabase * _Nonnull db) {

        if (![db open]) {
            NSLog(@"db open fail");
            return;
        }
        
        //2.在事务中执行任务
        int count = 100000;
        NSMutableArray *modess = [NSMutableArray array];
        for (int i = 0;i < count; i++) {
            Person *model = [[Person alloc] init] ;
            model.ID = i;
            model.name = [NSString stringWithFormat:@"name_%d",i];
            [modess addObject:model];
        }
        
        NSDate *begin = [NSDate date];
        for (Person *model in modess) {

            NSMutableArray *insertArr = [NSMutableArray array];
            [insertArr addObject:[NSNumber numberWithInt:model.ID]];
            [insertArr addObject:model.name];
            [insertArr addObject:model.phone];
            [insertArr addObject:[NSNumber numberWithInt:model.score]];
            BOOL result = [db executeUpdate:@"insert or ignore into t_student(ID,name,phone,score) values(?,?,?,?)" withArgumentsInArray:insertArr];
            if (result) {
    //            NSLog(@"insert into 't_studet' %d success,%@",model.ID,[NSThread currentThread]);
            } else {
                NSLog(@"insert into 't_studet' faild");
            }

        }
        NSDate *end = [NSDate date];
        NSTimeInterval time = [end timeIntervalSinceDate:begin];
        NSLog(@"去掉开关数据库,执行插入任务 所需要的时间 = %f",time);
        
        [db close];
    }];
    
}

- (void)insertDataNotCalculatedOpenAndCloseDBBeginTransaction{
    
    [_dataBaseQ inDatabase:^(FMDatabase * _Nonnull db) {

        if (![db open]) {
            NSLog(@"db open fail");
            return;
        }
        
        //2.在事务中执行任务
        int count = 100000;
        NSMutableArray *modess = [NSMutableArray array];
        for (int i = 0;i < count; i++) {
            Person *model = [[Person alloc] init] ;
            model.ID = i;
            model.name = [NSString stringWithFormat:@"name_%d",i];
            [modess addObject:model];
        }
        
        NSDate *begin = [NSDate date];
        [db beginTransaction];
        for (Person *model in modess) {

            NSMutableArray *insertArr = [NSMutableArray array];
            [insertArr addObject:[NSNumber numberWithInt:model.ID]];
            [insertArr addObject:model.name];
            [insertArr addObject:model.phone];
            [insertArr addObject:[NSNumber numberWithInt:model.score]];
            BOOL result = [db executeUpdate:@"insert or ignore into t_student(ID,name,phone,score) values(?,?,?,?)" withArgumentsInArray:insertArr];
            if (result) {
    //            NSLog(@"insert into 't_studet' %d success,%@",model.ID,[NSThread currentThread]);
            } else {
                NSLog(@"insert into 't_studet' faild");
            }

        }
        [db commit];
        NSDate *end = [NSDate date];
        NSTimeInterval time = [end timeIntervalSinceDate:begin];
        NSLog(@"开启事务,去掉开关数据库,执行插入任务 所需要的时间 = %f",time);
        
        [db close];
    }];
    
}

- (void)insertDataNotCalculatedOpenAndCloseDBBeginTransactionFrom100000{
    
    [_dataBaseQ inDatabase:^(FMDatabase * _Nonnull db) {

        if (![db open]) {
            NSLog(@"db open fail");
            return;
        }
        
        //2.在事务中执行任务
        int count = 200000;
        NSMutableArray *modess = [NSMutableArray array];
        for (int i = 100000;i < count; i++) {
            Person *model = [[Person alloc] init] ;
            model.ID = i;
            model.name = [NSString stringWithFormat:@"name_%d",i];
            [modess addObject:model];
        }
        
        NSDate *begin = [NSDate date];
        [db beginTransaction];
        for (Person *model in modess) {

            NSMutableArray *insertArr = [NSMutableArray array];
            [insertArr addObject:[NSNumber numberWithInt:model.ID]];
            [insertArr addObject:model.name];
            [insertArr addObject:model.phone];
            [insertArr addObject:[NSNumber numberWithInt:model.score]];
            BOOL result = [db executeUpdate:@"insert or ignore into t_student(ID,name,phone,score) values(?,?,?,?)" withArgumentsInArray:insertArr];
            if (result) {
    //            NSLog(@"insert into 't_studet' %d success,%@",model.ID,[NSThread currentThread]);
            } else {
                NSLog(@"insert into 't_studet' faild");
            }

        }
        [db commit];
        NSDate *end = [NSDate date];
        NSTimeInterval time = [end timeIntervalSinceDate:begin];
        NSLog(@"200000以后插入，开启事务去掉开关数据库执行插入任务 所需要的时间 = %f",time);
        
        [db close];
    }];
    
}


- (void)selectWithID:(int)ID{
    
    self.seletArrays = [NSMutableArray array];
    
    [_dataBaseQ inDatabase:^(FMDatabase * _Nonnull db) {
        if (![db open]) {
            NSLog(@"db open fail");
            return;
        }
        NSString *name = [NSString stringWithFormat:@"name_%d",ID];
        FMResultSet *result = [db executeQuery:@"select * from t_student where name = ?" withArgumentsInArray:@[name]];
//        FMResultSet *result = [db executeQuery:@"select * from t_student where ID = ?" withArgumentsInArray:@[@(ID)]];
        
        while ([result next]) {
            Person *model = [Person new];
            model.ID = [result intForColumn:@"ID"];
            model.name = [result stringForColumn:@"name"];
            model.phone = [result stringForColumn:@"phone"];
            model.score = [result intForColumn:@"score"];
            [self.seletArrays addObject:model];
//            NSLog(@"从数据库查询到的人员 %d,%@",model.ID,[NSThread currentThread]);
        }
        [db close];
    }];
    

}

- (void)selectWithScore:(int)score{
    
    self.seletArrays = [NSMutableArray array];
    
    [_dataBaseQ inDatabase:^(FMDatabase * _Nonnull db) {
        if (![db open]) {
            NSLog(@"db open fail");
            return;
        }
        FMResultSet *result = [db executeQuery:@"select * from t_student where score = ?" withArgumentsInArray:@[@(score)]];
//        FMResultSet *result = [db executeQuery:@"select * from t_student where ID = ?" withArgumentsInArray:@[@(ID)]];
        
        while ([result next]) {
            Person *model = [Person new];
            model.ID = [result intForColumn:@"ID"];
            model.name = [result stringForColumn:@"name"];
            model.phone = [result stringForColumn:@"phone"];
            model.score = [result intForColumn:@"score"];
            [self.seletArrays addObject:model];
//            NSLog(@"从数据库查询到的人员 %d,%@",model.ID,[NSThread currentThread]);
        }
        [db close];
    }];
    

}

- (void)selectWithOrderByScore{
    
    self.seletArrays = [NSMutableArray array];
    
    [_dataBaseQ inDatabase:^(FMDatabase * _Nonnull db) {
        if (![db open]) {
            NSLog(@"db open fail");
            return;
        }
        FMResultSet *result = [db executeQuery:@"select * from t_student order by score limit 0,20"];
//        FMResultSet *result = [db executeQuery:@"select * from t_student where ID = ?" withArgumentsInArray:@[@(ID)]];
        
        while ([result next]) {
            Person *model = [Person new];
            model.ID = [result intForColumn:@"ID"];
            model.name = [result stringForColumn:@"name"];
            model.phone = [result stringForColumn:@"phone"];
            model.score = [result intForColumn:@"score"];
            [self.seletArrays addObject:model];
//            NSLog(@"从数据库查询到的人员 %d,%@",model.ID,[NSThread currentThread]);
        }
        [db close];
    }];
    

}

@end
