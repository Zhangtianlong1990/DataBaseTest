//
//  Person.h
//  FMDBDemo
//
//  Created by 张天龙 on 2021/1/24.
//  Copyright © 2021 张天龙. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
@property (nonatomic, assign) int ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, assign) int score;
@end

NS_ASSUME_NONNULL_END
