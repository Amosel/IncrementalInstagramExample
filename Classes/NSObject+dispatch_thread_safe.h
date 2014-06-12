//
//  NSObject+dispatch_thread_safe.h
//  ImageDownloadDemo
//
//  Created by Amos Elmaliah on 6/8/14.
//

#import <Foundation/Foundation.h>

@interface NSObject (dispatch_thread_safe)

/*
 * returns a copy of the object conforms to NSCopying.
 */
-(instancetype) dispatch_get:(dispatch_queue_t)queue;
/*
 * returns a mutable copy in the block that you can mutate freely.
 */
-(void) dispatch_mutate:(dispatch_queue_t)queue block:(void(^)(id mutable))block;
/*
 * convenience concurrent queue for instance.
 */
-(dispatch_queue_t) queue;
/*
 * convenience concurrent queue for class.
 */
+(dispatch_queue_t) queue;
/*
 * uses the instance queue with dispatch_get:
 */
-(instancetype) dispatch_get;
/*
 * uses the instance queue with dispatch_mutate:block:
 */
-(void)	dispatch_mutateWithBlock:(void(^)(id mutable))block;

@end
