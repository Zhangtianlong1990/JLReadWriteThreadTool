//
//  JLReadWriteThreadtool.m
//  readind-and-writing-problem
//
//  Created by 张天龙 on 2022/5/23.
//

#import "JLReadWriteThreadTool.h"

@interface JLReadWriteThreadTool()
@property (nonatomic,strong) dispatch_semaphore_t readMutex;
@property (nonatomic,strong) dispatch_semaphore_t writeMutex;
@property (nonatomic,strong) dispatch_semaphore_t writeSema;
@property (nonatomic,strong) dispatch_semaphore_t priorSema;
@property (nonatomic,assign) int readCount;
@property (nonatomic,assign) int writeCount;
@end

@implementation JLReadWriteThreadTool
+ (instancetype)shareInstance{
    static JLReadWriteThreadTool *single = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!single) {
            single = [[JLReadWriteThreadTool alloc] init];
        }
    });
    return single;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _threadControlType = JLThreadControlTypeReadingPriority;
        _readMutex = dispatch_semaphore_create(1);
        _writeSema = dispatch_semaphore_create(1);
        _priorSema = dispatch_semaphore_create(1);
        _writeMutex = dispatch_semaphore_create(1);
    }
    return self;
}
#pragma mark - 执行任务

- (void)excuteReadOperation:(void(^)(void))readTask{
    switch (_threadControlType) {
        case JLThreadControlTypeReadingPriority:
        {
            [self excuteReadingPriorityWithReadTask:readTask];
        }
            break;
        case JLThreadControlTypeEquality:
        {
            [self excuteEqualityWithReadTask:readTask];
        }
            break;
        case JLThreadControlTypeWritingPriority:
        {
            [self excuteWritingPriorityWithReadTask:readTask];
        }
            break;
        default:
            break;
    }
}

- (void)excuteWriteOperation:(void(^)(void))writeTask{
    switch (_threadControlType) {
        case JLThreadControlTypeReadingPriority:
        {
            [self excuteReadingPriorityWithWriteTask:writeTask];
        }
            break;
        case JLThreadControlTypeEquality:
        {
            [self excuteEqualityWithWriteTask:writeTask];
        }
            break;
        case JLThreadControlTypeWritingPriority:
        {
            [self excuteWritingPriorityWithWriteTask:writeTask];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 读者优先

- (void)excuteReadingPriorityWithReadTask:(void(^)(void))readTask{
    dispatch_semaphore_wait(_readMutex, DISPATCH_TIME_FOREVER);
    self.readCount = self.readCount+1;
    if (self.readCount==1) {
        dispatch_semaphore_wait(_writeSema, DISPATCH_TIME_FOREVER);
    }
    dispatch_semaphore_signal(_readMutex);
    
    readTask();
    
    dispatch_semaphore_wait(_readMutex, DISPATCH_TIME_FOREVER);
    self.readCount = self.readCount-1;
    if (self.readCount==0) {
        dispatch_semaphore_signal(_writeSema);
    }
    dispatch_semaphore_signal(_readMutex);
}

- (void)excuteReadingPriorityWithWriteTask:(void(^)(void))writeTask{
    
    dispatch_semaphore_wait(_writeSema, DISPATCH_TIME_FOREVER);
    
    writeTask();
    
    dispatch_semaphore_signal(_writeSema);
    
}

#pragma mark - 读写均等

- (void)excuteEqualityWithReadTask:(void(^)(void))readTask{
    dispatch_semaphore_wait(_priorSema, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(_readMutex, DISPATCH_TIME_FOREVER);
    self.readCount = self.readCount+1;
    if (self.readCount==1) {
        dispatch_semaphore_wait(_writeSema, DISPATCH_TIME_FOREVER);
    }
    dispatch_semaphore_signal(_readMutex);
    dispatch_semaphore_signal(_priorSema);

    readTask();
    
    dispatch_semaphore_wait(_readMutex, DISPATCH_TIME_FOREVER);
    self.readCount = self.readCount-1;
    if (self.readCount==0) {
        dispatch_semaphore_signal(_writeSema);
    }
    dispatch_semaphore_signal(_readMutex);
}

- (void)excuteEqualityWithWriteTask:(void(^)(void))writeTask{
    dispatch_semaphore_wait(_priorSema, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(_writeSema, DISPATCH_TIME_FOREVER);
    
    writeTask();
    
    dispatch_semaphore_signal(_writeSema);
    dispatch_semaphore_signal(_priorSema);
    
}

#pragma mark - 写者优先

- (void)excuteWritingPriorityWithReadTask:(void(^)(void))readTask{
    dispatch_semaphore_wait(_priorSema, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(_readMutex, DISPATCH_TIME_FOREVER);
    self.readCount = self.readCount+1;
    if (self.readCount==1) {
        dispatch_semaphore_wait(_writeSema, DISPATCH_TIME_FOREVER);
    }
    dispatch_semaphore_signal(_readMutex);
    dispatch_semaphore_signal(_priorSema);

    readTask();
    
    dispatch_semaphore_wait(_readMutex, DISPATCH_TIME_FOREVER);
    self.readCount = self.readCount-1;
    if (self.readCount==0) {
        dispatch_semaphore_signal(_writeSema);
    }
    dispatch_semaphore_signal(_readMutex);
}

- (void)excuteWritingPriorityWithWriteTask:(void(^)(void))writeTask{
    
    dispatch_semaphore_wait(_writeMutex, DISPATCH_TIME_FOREVER);
    self.writeCount = self.writeCount+1;
    if (self.writeCount==1) {
        dispatch_semaphore_wait(_priorSema, DISPATCH_TIME_FOREVER);
    }
    dispatch_semaphore_signal(_writeMutex);
    
    
    dispatch_semaphore_wait(_writeSema, DISPATCH_TIME_FOREVER);
    writeTask();
    dispatch_semaphore_signal(_writeSema);
    
    
    dispatch_semaphore_wait(_writeMutex, DISPATCH_TIME_FOREVER);
    self.writeCount = self.writeCount-1;
    if (self.writeCount==0) {
        dispatch_semaphore_signal(_priorSema);
    }
    dispatch_semaphore_signal(_writeMutex);
    
}
@end
