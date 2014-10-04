GCDDemo
=======

GCDDemo
原文地址 :http://www.devtang.com/
=================
使用GCD
什么是GCD
Grand Central Dispatch (GCD)是Apple开发的一个多核编程的解决方法。该方法在Mac OS X 10.6雪豹中首次推出，并随后被引入到了iOS4.0中。GCD是一个替代诸如NSThread, NSOperationQueue, NSInvocationOperation等技术的很高效和强大的技术，它看起来象就其它语言的闭包(Closure)一样，但苹果把它叫做blocks。
应用举例
让我们来看一个编程场景。我们要在iPhone上做一个下载网页的功能，该功能非常简单，就是在iPhone上放置一个按钮，点击该按钮时，显示一个转动的圆圈，表示正在进行下载，下载完成之后，将内容加载到界面上的一个文本控件中。
不用GCD前
虽然功能简单，但是我们必须把下载过程放到后台线程中，否则会阻塞UI线程显示。所以，如果不用GCD, 我们需要写如下3个方法：
	•	someClick 方法是点击按钮后的代码，可以看到我们用NSInvocationOperation建了一个后台线程，并且放到NSOperationQueue中。后台线程执行download方法。
	•	download 方法处理下载网页的逻辑。下载完成后用performSelectorOnMainThread执行download_completed 方法。
	•	download_completed 进行clear up的工作，并把下载的内容显示到文本控件中。
这3个方法的代码如下。可以看到，虽然 开始下载 –> 下载中 –> 下载完成 这3个步骤是整个功能的三步。但是它们却被切分成了3块。他们之间因为是3个方法，所以还需要传递数据参数。如果是复杂的应用，数据参数很可能就不象本例子中的NSString那么简单了，另外，下载可能放到Model的类中来做，而界面的控制放到View Controller层来做，这使得本来就分开的代码变得更加散落。代码的可读性大大降低。
```
static NSOperationQueue * queue;

- (IBAction)someClick:(id)sender {
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
    queue = [[NSOperationQueue alloc] init];
    NSInvocationOperation * op = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(download) object:nil] autorelease];
    [queue addOperation:op];
}

- (void)download {
    NSURL * url = [NSURL URLWithString:@"http://www.youdao.com"];
    NSError * error;
    NSString * data = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (data != nil) {
        [self performSelectorOnMainThread:@selector(download_completed:) withObject:data waitUntilDone:NO];
    } else {
        NSLog(@"error when download:%@", error);
        [queue release];
    }
}

- (void) download_completed:(NSString *) data {
    NSLog(@"call back");
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
    self.content.text = data;
    [queue release];
}

使用GCD后
如果使用GCD，以上3个方法都可以放到一起，如下所示：

```
// 原代码块一
self.indicator.hidden = NO;
[self.indicator startAnimating];
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 原代码块二
    NSURL * url = [NSURL URLWithString:@"http://www.youdao.com"];
    NSError * error;
    NSString * data = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (data != nil) {
        // 原代码块三
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator stopAnimating];
            self.indicator.hidden = YES;
            self.content.text = data;
        });
    } else {
        NSLog(@"error when download:%@", error);
    }
});
首先我们可以看到，代码变短了。因为少了原来3个方法的定义，也少了相互之间需要传递的变量的封装。
另外，代码变清楚了，虽然是异步的代码，但是它们被GCD合理的整合在一起，逻辑非常清晰。如果应用上MVC模式，我们也可以将View Controller层的回调函数用GCD的方式传递给Modal层，这相比以前用@selector的方式，代码的逻辑关系会更加清楚。
GCD的定义
简单GCD的定义有点象函数指针，差别是用 ^ 替代了函数指针的 * 号，如下所示：

```
 // 申明变量
 (void) (^loggerBlock)(void);
 // 定义

 loggerBlock = ^{
      NSLog(@"Hello world");
 };
 // 调用
 loggerBlock();
但是大多数时候，我们通常使用内联的方式来定义它，即将它的程序块写在调用的函数里面，例如这样：

1
2
3
 dispatch_async(dispatch_get_global_queue(0, 0), ^{
      // something
 });
从上面大家可以看出，block有如下特点：
	1.	程序块可以在代码中以内联的方式来定义。
	2.	程序块可以访问在创建它的范围内的可用的变量。
系统提供的dispatch方法
为了方便地使用GCD，苹果提供了一些方法方便我们将block放在主线程 或 后台线程执行，或者延后执行。使用的例子如下：

```
 //  后台执行：
 dispatch_async(dispatch_get_global_queue(0, 0), ^{
      // something
 });
 // 主线程执行：
 dispatch_async(dispatch_get_main_queue(), ^{
      // something
 });
 // 一次性执行：
 static dispatch_once_t onceToken;
 dispatch_once(&onceToken, ^{
     // code to be executed once
 });
 // 延迟2秒执行：
 double delayInSeconds = 2.0;
 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
     // code to be executed on the main queue after delay
 });
dispatch_queue_t 也可以自己定义，如要要自定义queue，可以用dispatch_queue_create方法，示例如下：

```
dispatch_queue_t urls_queue = dispatch_queue_create("blog.devtang.com", NULL);
dispatch_async(urls_queue, ^{
     // your code
});
dispatch_release(urls_queue);
另外，GCD还有一些高级用法，例如让后台2个线程并行执行，然后等2个线程都结束后，再汇总执行结果。这个可以用dispatch_group, dispatch_group_async 和 dispatch_group_notify来实现，示例如下：

```
 dispatch_group_t group = dispatch_group_create();
 dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
      // 并行执行的线程一
 });
 dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
      // 并行执行的线程二
 });
 dispatch_group_notify(group, dispatch_get_global_queue(0,0), ^{
      // 汇总结果
 });
修改block之外的变量
默认情况下，在程序块中访问的外部变量是复制过去的，即写操作不对原变量生效。但是你可以加上 __block来让其写操作生效，示例代码如下：

```
 __block int a = 0;
 void  (^foo)(void) = ^{
      a = 1;
 }
 foo();
 // 这里，a的值被修改为1
后台运行
使用block的另一个用处是可以让程序在后台较长久的运行。在以前，当app被按home键退出后，app仅有最多5秒钟的时候做一些保存或清理资源的工作。但是应用可以调用UIApplication的beginBackgroundTaskWithExpirationHandler方法，让app最多有10分钟的时间在后台长久运行。这个时间可以用来做清理本地缓存，发送统计数据等工作。
让程序在后台长久运行的示例代码如下：

```
// AppDelegate.h文件
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;

// AppDelegate.m文件
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self beingBackgroundUpdateTask];
    // 在这里加上你需要长久运行的代码
    [self endBackgroundUpdateTask];
}

- (void)beingBackgroundUpdateTask
{
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void)endBackgroundUpdateTask
{
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}
总结
总体来说，GCD能够极大地方便开发者进行多线程编程。大家应该尽量使用GCD来处理后台线程和UI线程的交互。
