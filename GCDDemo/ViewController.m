//
//  ViewController.m
//  GCDDemo
//
//  Created by jianleer on 14-10-4.
//  Copyright (c) 2014年 jianleer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()



@end

@implementation ViewController
//


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//一般情况
// Click 方法是点击按钮后的代码，可以看到我们用NSInvocationOperation建了一个后台线程，并且放到NSOperationQueue中。后台线程执行download方法。
//•	download 方法处理下载网页的逻辑。下载完成后用performSelectorOnMainThread执行download_completed 方法。
//•	download_completed 进行clear up的工作，并把下载的内容显示到文本控件中。
static NSOperationQueue *queue;

- (IBAction)click:(id)sender {
    NSLog(@"click");
    //创建后台线程并放到操作队列中
    queue                       = [[NSOperationQueue alloc] init];
    NSInvocationOperation * op  = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(download) object:nil] autorelease];
    [queue addOperation:op];
}

-(void)download
{
    //处理下载逻辑
    NSURL       *url   =  [NSURL URLWithString:@"http://www.baidu.com"];
    NSError     *error = nil;
    NSString    *data  = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (data != nil) {
        [self performSelectorOnMainThread:@selector(download_completed:) withObject:data waitUntilDone:NO];
    }else
    {
        NSLog(@"error when download:%@",error);
        [queue release];
    }
    
}
-(void)download_completed:(NSString*)data{
    NSLog(@"call back");
    //进行clear up的工作，并把下载的内容显示到文本控件中
    self.textView.text = data;
    [queue release];
    
}

//使用   GCD

- (IBAction)CGDClick:(id)sender {
    
    //原代码块1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //原代码块2
        NSURL   *url    = [NSURL URLWithString:@"http://www.baidu.com"];
        NSError *error  =  nil;
        NSString*data   = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (data != nil) {
            //源代码块3
            dispatch_async(dispatch_get_main_queue(), ^{
                self.GCDTextView.text = data;
            });
        }else
        {
            NSLog(@"error when download :%@",error);
        }
    });
    
}



- (void)dealloc {
    [_textView release];
    [_GCDTextView release];
    [super dealloc];
}
@end
