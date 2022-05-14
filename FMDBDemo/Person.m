//
//  Person.m
//  FMDBDemo
//
//  Created by 张天龙 on 2021/1/24.
//  Copyright © 2021 张天龙. All rights reserved.
//

#import "Person.h"

@implementation Person
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *names = @[@"张三",@"李四",@"王五"];
        self.ID = arc4random()%100;
        self.name = names[arc4random()%3];
        self.phone = [NSString stringWithFormat:@"%ld",(arc4random()%5000+13825490000)];
        self.score = arc4random()%100;
    }
    return self;
}
@end
