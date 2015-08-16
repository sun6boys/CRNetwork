//
//  ViewController.m
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/13.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import "ViewController.h"
#import "TestApi.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)touch:(id)sender {
    TestApi * test = [[TestApi alloc]init];
    [test startWithCompletionBlockWithSuccess:^(XLBaseRequest *request) {
        NSLog(@"%@",[test responseJSONObject]);
    } failure:^(XLBaseRequest *request) {
        NSLog(@"%ld",test.code);
        NSLog(@"%@",test.message);
        NSLog(@"response ==%@",[test responseJSONObject]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
