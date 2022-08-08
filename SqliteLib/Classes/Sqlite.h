//
//  Sqlite.h
//  test
//
//  Created by 张珂 on 2022/8/2.
//

/**
 [[Sqlite shareInstance] openDataBase];
 [[Sqlite shareInstance] createForm];
//    [[Sqlite shareInstance] insertData:@"zkzk" ageinteger:22 sexStr:@"男"];
 [[Sqlite shareInstance] transactionMethod];
 [[Sqlite shareInstance] sqlData];
 [[Sqlite shareInstance] closeDataBase];
 */

#import <Foundation/Foundation.h>
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN

@interface Sqlite : NSObject

+ (instancetype)shareInstance;

//创建/打开数据库
- (BOOL)openDataBase;
- (void)closeDataBase;
//创建表
- (void)createForm;
//插入数据
- (void)insertData:(NSString*)name ageinteger:(int)age sexStr:(NSString*)sex;
//查询操作
- (void)sqlData;
//修改数据
- (void)updateData;
//删除数据
- (void)deleteData;

- (void)transactionMethod;

@end

NS_ASSUME_NONNULL_END
