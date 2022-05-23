//
//  ViewController.m
//  readind-and-writing-problem
//
//  Created by 张天龙 on 2022/5/22.
//

#import "ViewController.h"
#import "JLReadWriteThreadTool.h"

@interface ViewController ()
@property (nonatomic,strong) NSOperationQueue *queue;
@property (nonatomic,strong) NSMutableDictionary *dic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
     读写问题测试结论：
     并发写入NSMutableDictionary是会导致崩溃的，访问到坏内存，网上说可能是字典的扩容问题，不懂，因此需要同步写入
     读写分离分三种情况：
     1、（读者优先）可以同时读，但是读写分离，写写分离，这种是优先读，因为一旦读进程拿到writeSema就会一直持有，直到所有读进程结束才会释放writeSema给写进程
     2、（读写平等）可以同时读，读写分离，写写分离，但是一旦有写进程的时候，也会写，不会等到所有读进程结束，会中间插入进去，读进程会一直阻塞
     3、（写者优先）可以同时读，读写分离，写写分离，但是一旦有写进程拿到优先级信号的时候，读进程会一直阻塞，直到所有写进程写完为止，貌似也没看到怎么优先，写还是会分开
     */
    self.queue = [[NSOperationQueue alloc] init];
    self.dic = [NSMutableDictionary dictionary];
    self.dic[@"11"] = @"11";
    self.dic[@"22"] = @"22";
    self.dic[@"33"] = @"33";
    self.dic[@"44"] = @"44";
    self.dic[@"55"] = @"55";
    self.dic[@"aa"] = @"aa";
    self.dic[@"bb"] = @"bb";
    self.dic[@"cc"] = @"cc";
    [JLReadWriteThreadTool shareInstance].threadControlType = JLThreadControlTypeWritingPriority;
    NSInvocationOperation *op0 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(op0) object:nil];
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(op1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(op2) object:nil];
    NSInvocationOperation *op3 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(op3) object:nil];
    NSInvocationOperation *op4 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(op4) object:nil];
    NSInvocationOperation *op5 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(op5) object:nil];
    NSInvocationOperation *op6 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(op6) object:nil];
    NSInvocationOperation *op7 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(op7) object:nil];
    NSInvocationOperation *op8 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(op8) object:nil];
    NSInvocationOperation *op9 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(op9) object:nil];
    NSInvocationOperation *op10 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(op10) object:nil];
    [self.queue addOperations:@[op0,op3,op4,op5,op1,op6,op7,op8,op9,op2,op10] waitUntilFinished:NO];
    
}

- (void)op0{

    [self excuteWriteOperation:^{
            self.dic[@"dd"] = @"dd";
            NSLog(@"write---op0: %@,%@",self.dic,[NSThread currentThread]);
    }];
    
}

- (void)op1{

    [self excuteWriteOperation:^{
        self.dic[@"ee"] = @"ee";
        NSLog(@"write---op1: %@,%@",self.dic,[NSThread currentThread]);
    }];
}

- (void)op2{

    [self excuteWriteOperation:^{
        self.dic[@"ff"] = @"ff";
        NSLog(@"write---op2: %@,%@",self.dic,[NSThread currentThread]);
    }];
}

- (void)op3{

    [self excuteReadOperation:^{
        NSString *ggstr = self.dic[@"aa"];
        NSLog(@"read: %@,%@",ggstr,[NSThread currentThread]);
    }];
    
}

- (void)op4{

    [self excuteReadOperation:^{
        NSString *ggstr = self.dic[@"bb"];
        NSLog(@"read: %@,%@",ggstr,[NSThread currentThread]);
    }];
    
}

- (void)op5{
    
    [self excuteReadOperation:^{
        NSString *ggstr = self.dic[@"cc"];
        NSLog(@"read: %@,%@",ggstr,[NSThread currentThread]);
    }];
    
}

- (void)op6{
    [self excuteReadOperation:^{
        NSString *ggstr = self.dic[@"11"];
        NSLog(@"read: %@,%@",ggstr,[NSThread currentThread]);
    }];
    
}

- (void)op7{
    
    [self excuteReadOperation:^{
        NSString *ggstr = self.dic[@"22"];
        NSLog(@"read: %@,%@",ggstr,[NSThread currentThread]);
    }];
    
}

- (void)op8{
    [self excuteReadOperation:^{
        NSString *ggstr = self.dic[@"33"];
        NSLog(@"read: %@,%@",ggstr,[NSThread currentThread]);
    }];
}

- (void)op9{
    [self excuteReadOperation:^{
        NSString *ggstr = self.dic[@"44"];
        NSLog(@"read: %@,%@",ggstr,[NSThread currentThread]);
    }];
    
}

- (void)op10{
    [self excuteReadOperation:^{
            NSString *ggstr = self.dic[@"55"];
            NSLog(@"read: %@,%@",ggstr,[NSThread currentThread]);
    }];
}

#pragma mark - 执行任务

- (void)excuteReadOperation:(void(^)(void))readTask{
    [[JLReadWriteThreadTool shareInstance] excuteReadOperation:readTask];
}

- (void)excuteWriteOperation:(void(^)(void))writeTask{
    [[JLReadWriteThreadTool shareInstance] excuteWriteOperation:writeTask];
}


@end
