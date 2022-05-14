//
//  ViewController.m
//  FMDBDemo
//
//  Created by 张天龙 on 2021/1/24.
//  Copyright © 2021 张天龙. All rights reserved.
//

#import "ViewController.h"
#import "DataManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DataManager shareInstance];
    
    [self initUI];
    
    /*
     
     测试步骤：
     insert
     insert -> select
     insert -> combine
     
     测试结论：
     插入
     1、插入10万条数据，包含开关DB的时间，不开启事务，时间为134s左右
     2、插入10万条数据，除掉开关DB的时间，时间在6s左右
     3、插入10万条数据，除掉关闭DB的时间，开启事务，时间在1.2s左右
     
     查询
     1、通过ID查询一条数据，时间在0.02s左右
     2、通过score查询数据，时间也在0.04s左右
     3、通过分数排序后查找前20条，时间也在0.02s
     
     同时开启线程查询和插入，阻塞影响不大
     1、插入在前，查询在后，一次性插入10万条数据1.2s，查询1.5s
     2、插入在后，查询在前，查询0.02s,一次性插入10万条数据1.2s
     
     */
    
    /*
    //1.开启事务
    NSDate *begin = [NSDate date];
    if (![[DataManager shareInstance].db open]) {
        NSLog(@"db open fail");
        return;
    }
    [[DataManager shareInstance].db beginTransaction];
    BOOL rollBack = NO;
    @try {
        
        for (Person *model in modess) {
            [[DataManager shareInstance] insertData:model];
        }
    }
    @catch(NSException *exception) {
        //3.在事务中执行任务失败，退回开启事务之前的状态
        rollBack = YES;
        [[DataManager shareInstance].db rollback];
    }
    @finally {
        //4. 在事务中执行任务成功之后
        rollBack = NO;
        [[DataManager shareInstance].db commit];
    }
    [[DataManager shareInstance].db close];
    */
     
}

#pragma mark - combine

- (void)combine{
    [NSThread detachNewThreadWithBlock:^{
        [self selectWithScoreOrder];
    }];
    [NSThread detachNewThreadWithBlock:^{
        [self insertFrom100000];
    }];
}

#pragma mark - select

-(void)selectWithID{
    NSDate *begin = [NSDate date];
    [[DataManager shareInstance] selectWithID:9990];
    NSDate *end = [NSDate date];
    NSTimeInterval time = [end timeIntervalSinceDate:begin];
    NSLog(@"执行查询任务 所需要的时间 = %f",time);
    for (Person *model in [DataManager shareInstance].seletArrays) {
        NSLog(@"id = %d,name = %@",model.ID,model.name);
    }
}

-(void)selectWithScore{
    NSDate *begin = [NSDate date];
    [[DataManager shareInstance] selectWithScore:60];
    NSDate *end = [NSDate date];
    NSTimeInterval time = [end timeIntervalSinceDate:begin];
    NSLog(@"执行查询任务 所需要的时间 = %f,查询到%ld个数据",time,[DataManager shareInstance].seletArrays.count);
    for (Person *model in [DataManager shareInstance].seletArrays) {
//        NSLog(@"id = %d,name = %@",model.ID,model.name);
    }
}

-(void)selectWithScoreOrder{
    NSDate *begin = [NSDate date];
    [[DataManager shareInstance] selectWithOrderByScore];
    NSDate *end = [NSDate date];
    NSTimeInterval time = [end timeIntervalSinceDate:begin];
    NSLog(@"执行查询任务Score排序所需要的时间 = %f,查询到%ld个数据",time,[DataManager shareInstance].seletArrays.count);
//    for (Person *model in [DataManager shareInstance].seletArrays) {
//        NSLog(@"id = %d,name = %@,score = %d,phone = %@",model.ID,model.name,model.score,model.phone);
//    }
}

#pragma mark - insert

- (void)insert{
    //2.在事务中执行任务
    int count = 100000;
    NSMutableArray *modess = [NSMutableArray array];
    for (int i = 0;i < count; i++) {
        Person *model = [[Person alloc] init] ;
        model.ID = i;
        model.name = [NSString stringWithFormat:@"name_%d",i];
//        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        [modess addObject:model];
    }
    
    NSDate *begin = [NSDate date];
    for (Person *model in modess) {
        [[DataManager shareInstance] insertData:model];
    }
    NSDate *end = [NSDate date];
    NSTimeInterval time = [end timeIntervalSinceDate:begin];
    NSLog(@"执行插入任务 所需要的时间 = %f",time);
}

- (void)insertNotIncludedOpenAndCloseDB{
    [[DataManager shareInstance] insertDataNotCalculatedOpenAndCloseDB];
}

- (void)insertDataBeginTransaction{
    [[DataManager shareInstance] insertDataNotCalculatedOpenAndCloseDBBeginTransaction];
}

- (void)insertFrom100000{
    [[DataManager shareInstance] insertDataNotCalculatedOpenAndCloseDBBeginTransactionFrom100000];
}

#pragma mark - input

- (void)didClickSelectButton{
    [self selectWithScoreOrder];
}

- (void)didClickInsertButton{
    [self insertDataBeginTransaction];
}

- (void)didClickCombineButton{
    [self combine];
}

#pragma mark - UI

- (void)initUI{
    UIButton *selectButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    selectButton.backgroundColor = [UIColor blueColor];
    [selectButton setTitle:@"select" forState:UIControlStateNormal];
    [selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectButton addTarget:self action:@selector(didClickSelectButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectButton];
    
    UIButton *insertButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 250, 100, 100)];
    insertButton.backgroundColor = [UIColor blueColor];
    [insertButton setTitle:@"insert" forState:UIControlStateNormal];
    [insertButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [insertButton addTarget:self action:@selector(didClickInsertButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:insertButton];
    
    UIButton *combineButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 400, 100, 100)];
    combineButton.backgroundColor = [UIColor blueColor];
    [combineButton setTitle:@"combine" forState:UIControlStateNormal];
    [combineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [combineButton addTarget:self action:@selector(didClickCombineButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:combineButton];
}


@end
