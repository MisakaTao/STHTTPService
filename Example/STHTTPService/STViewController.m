//
//  STViewController.m
//  STHTTPService
//
//  Created by misakatao on 05/25/2018.
//  Copyright (c) 2018 misakatao. All rights reserved.
//

#import "STViewController.h"
#import <STHTTPService/STHTTPService.h>

@interface STViewController ()

@end

@implementation STViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [STHTTPService GET:@"https://www.baidu.com" parameters:@{} success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
