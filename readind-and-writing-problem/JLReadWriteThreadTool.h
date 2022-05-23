//
//  JLReadWriteThreadtool.h
//  readind-and-writing-problem
//
//  Created by 张天龙 on 2022/5/23.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    JLThreadControlTypeReadingPriority,
    JLThreadControlTypeEquality,
    JLThreadControlTypeWritingPriority,
} JLThreadControlType;

NS_ASSUME_NONNULL_BEGIN

@interface JLReadWriteThreadTool : NSObject
@property (nonatomic,assign) JLThreadControlType threadControlType;
+ (instancetype)shareInstance;
- (void)excuteReadOperation:(void(^)(void))readTask;
- (void)excuteWriteOperation:(void(^)(void))writeTask;
@end

NS_ASSUME_NONNULL_END
