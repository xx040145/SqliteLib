//
//  Sqlite.m
//  test
//
//  Created by 张珂 on 2022/8/2.
//

#import "Sqlite.h"

@interface Sqlite ()
{
    sqlite3 *db;
    NSString *dataBasePath;
}
@end

@implementation Sqlite
static Sqlite *sqlite;

+ (instancetype)shareInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sqlite = [[Sqlite alloc] init];
    });
    return sqlite;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sqlite = [super allocWithZone:zone];
        [sqlite getPath];
        sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    });
    return sqlite;
}

//生成路径
- (NSString *)getPath{
    NSArray *documentArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentArr firstObject];
    
    dataBasePath = [NSString stringWithFormat:@"%@/student.sqlite",documentPath];
    NSLog(@"位置path == %@",dataBasePath);
    return dataBasePath;
}

//创建/打开数据库
- (BOOL)openDataBase{
    int databaseResult = sqlite3_open([dataBasePath UTF8String], &db);

    if (databaseResult == SQLITE_OK) {
        NSLog(@"创建／打开数据库成功,%d",databaseResult);
        return TRUE;
    }else{
        NSLog(@"创建／打开数据库失败,%d",databaseResult);
        return FALSE;
    }
}

- (void)closeDataBase{
    sqlite3_close(db);
}

//创建表
- (void)createForm{
//    建表格式: create table if not exists 表名 (列名 类型,....)
//    注: 如需生成默认增加的id: id integer primary key autoincrement
    NSString *createSQL = @"create table if not exists t_students (id integer primary key autoincrement, name text, age integer, sex text)";
    // 执行sql语句
    /**
       第1个参数：数据库对象
       第2个参数：sql语句
       第3个参数：查询时候用到的一个结果集闭包
       第4个参数：用不到
       第5个参数：错误信息
     */
    [self execSql:createSQL];
}

// 查询操作
- (void)sqlData {
    // sql语句
    const char *sql="SELECT id,name,age,sex FROM t_students WHERE age<100;";
    sqlite3_stmt *stmt = NULL;
    /**
         第1个参数：一个已经打开的数据库对象
         第2个参数：sql语句
         第3个参数：参数2中取出多少字节的长度，-1 自动计算，\0停止取出
         第4个参数：准备语句
         第5个参数：通过参数3，取出参数2的长度字节之后，剩下的字符串
       */
    // 进行查询前的准备工作
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
        NSLog(@"sql语句没有问题");
        
        // 每调用一次sqlite3_step函数，stmt就会指向下一条记录
        while (sqlite3_step(stmt) == SQLITE_ROW) {  // 找到一条记录
            // 取出数据
            int ID = sqlite3_column_int(stmt, 0);   // 取出第0列字段的值
            const unsigned char *name = sqlite3_column_text(stmt, 1);
            int age = sqlite3_column_int(stmt, 2);
            const unsigned char *sex = sqlite3_column_text(stmt, 3);
            printf("%d %s %d %s\n",ID,name,age,sex);
        }
    } else {
        NSLog(@"查询语句有问题");
    }
}

// 插入数据
- (void)insertData:(NSString*)name ageinteger:(int)age sexStr:(NSString*)sex{
    // 拼接 sql 语句
    NSString *sql = [NSString stringWithFormat:@"insert into t_students (name,age,sex) values ('%@',%d,'%@');",name,age,sex];
    [self execSql:sql];
}

//修改数据
- (void)updateData{
    //其实Sqlite的数据插入，修改，删除执行的方法都是一样的只是执行的sql语句不一样，想知道sql的更多语句操作自行百度了，比较多这里就不讲解了，只介绍一些基本的操作方法。
    //sqlite3数据(把年龄大于60的学生名字全部改成‘哈哈’)
    NSString *sql = @"update t_students set name = '哈哈' where age > 60";
    [self execSql:sql];
}

//删除数据
- (void)deleteData{
    //删除表中年龄大于60的学生数据
    NSString *sql = @"delete from t_students where age >= 60";
    [self execSql:sql];
}

- (void)execSql:(NSString *)sqlString{
    char *errorMesg = NULL;
    int result = sqlite3_exec(db, sqlString.UTF8String, NULL, NULL, &errorMesg);
    if (result == SQLITE_OK) {
        NSLog(@"成功");
    }else {
        NSLog(@"失败");
    }
}

- (void)transactionMethod{
    NSString *sql = [NSString stringWithFormat:@"insert into t_students (name,age,sex) values ('%@',%d,'%@');",@"transaction",33,@"男"];
    NSArray *arr = [NSArray arrayWithObjects:sql,sql,sql,sql,sql,sql,sql,sql,sql,sql, nil];
    [self execTransaction:arr];
}

- (void)execTransaction:(NSArray *)sqlArray{
    @try {
        char *errorMsg = nil;
        if (sqlite3_exec(db, "BEGIN transaction", 0, 0, &errorMsg) == SQLITE_OK) {
            NSLog(@"事务开始启动");
//            sqlite3_stmt *stmt;
            for (int i=0; i<sqlArray.count; i++) {
                sqlite3_exec(db, [sqlArray[i] UTF8String], NULL, NULL, &errorMsg);
            }
            if (sqlite3_exec(db, "COMMIT transaction", NULL, NULL, &errorMsg) == SQLITE_OK) {
                NSLog(@"事务提交成功");
            }
        }else {
            NSLog(@"%s",errorMsg);
        }
    } @catch (NSException *exception) {
        char *errorMsg = nil;
        if (sqlite3_exec(db, "ROLLBACK", NULL, NULL, &errorMsg) == SQLITE_OK) {
            NSLog(@"事务回滚成功");
        }
    } @finally {
        
    }
}

@end
