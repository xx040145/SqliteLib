//
//  KHANViewController.m
//  SqliteLib
//
//  Created by khanZhang on 08/08/2022.
//  Copyright (c) 2022 khanZhang. All rights reserved.
//

#import "KHANViewController.h"

@interface KHANViewController ()

@end

@implementation KHANViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    [[Sqlite shareInstance] openDataBase];
    [[Sqlite shareInstance] createForm];
//    [[Sqlite shareInstance] insertData:@"zkzk" ageinteger:22 sexStr:@"男"];
    [[Sqlite shareInstance] transactionMethod];
    [[Sqlite shareInstance] sqlData];
    [[Sqlite shareInstance] closeDataBase];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
