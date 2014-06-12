//
//  NSObject+dispatch_thread_safe.m
//  ImageDownloadDemo
//
//  Created by Amos Elmaliah on 6/8/14.
//

#import "NSObject+dispatch_thread_safe.h"
#import "AEWEAK_REF.h"
#import <objc/runtime.h>

@implementation NSObject (dispatch_thread_safe)

static id dispatch_sync_get(dispatch_queue_t queue, id(^block)()) {
	__block id results = nil;
	dispatch_sync(queue, ^{
		if (block) {
			results = block();
		}
	});
	return results;
}

-(instancetype)dispatch_get:(dispatch_queue_t)queue {
	NSParameterAssert(queue);
	return dispatch_sync_get(queue, ^id{
		if ([self conformsToProtocol:@protocol(NSCopying)]) {
			return self.copy;
		} else {
			return self;
		}
	});
}

-(void)dispatch_mutate:(dispatch_queue_t)queue block:(void (^)(id))block {
	NSParameterAssert(queue);
	NSParameterAssert(block);
	WEAK_SELF
	dispatch_barrier_async(queue, ^{
		STRONG_SELF(self)
		if (self) {
			block(self);
		}
	});
}

-(void)dispatch_mutateWithBlock:(void (^)(id))block {
	[self dispatch_mutate:self.queue block:block];
}

-(instancetype)dispatch_get {
	return [self dispatch_get:self.queue];
}

+(dispatch_queue_t)queue {
	static dispatch_queue_t q;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
    q = dispatch_queue_create([[NSStringFromClass(self) stringByAppendingFormat:@"-%@", NSStringFromSelector(_cmd)] UTF8String], 0);
	});
	return q;
}

-(dispatch_queue_t)queue {
	dispatch_queue_t q = (__bridge dispatch_queue_t)(objc_getAssociatedObject(self, _cmd));
	if (!q) {
    q = dispatch_queue_create([[NSStringFromClass([self class]) stringByAppendingFormat:@"-%p-%@", self, NSStringFromSelector(_cmd)] UTF8String], 0);
		objc_setAssociatedObject(self, _cmd, (__bridge id)(q), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return q;
}


@end
