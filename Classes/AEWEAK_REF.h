//
//  AEWEAK_REF.h
//  ImageDownloadDemo
//
//  Created by Amos Elmaliah on 5/11/14.
//

#ifndef ImageDownloadDemo_AEWEAK_REF_h
#define ImageDownloadDemo_AEWEAK_REF_h

#define WEAK_FROM_STRONG(weak, strong) __weak __typeof(&*strong)weak = strong;
#define STRONG_FROM_WEAK(strong, weak) __strong __typeof(&*strong)strong = weak;

#define WEAK(weak) WEAK_FROM_STRONG(w##weak,weak)
#define STRONG(strong) STRONG_FROM_WEAK(strong,w##strong)
#define STRONG_RETURN_THIS(strong,rv) WEAK_FROM_STRONG(strong,w##strong) if(!rv) return rv;

/*
 WEAK_SELF
 dispatch_asynch(dispatch_get_main_queue(), ^{
 		STRONG_SELF(self)
 		[self description]
 });
 
 equal to:
 
 __weak __typeof(&*strong)wself = self;
 dispatch_asynch(dispatch_get_main_queue(), ^{
 		__strong __typeof(&*strong)self = wself;
 		if(!self) return;
  	[self description]
 });
 */
#define WEAK_SELF WEAK(self)
#define STRONG_SELF(this) STRONG(this) if(!this) return;
/*
 
 WEAK_SELF
 id(^myBlock)() = ^{
 	STORNG_SELF_RETURN_THIS(self, nil)
 	return [self description];
 }
 
 equal to:
 
 __weak __typeof(&*strong)wself = self;
 id(^myBlock)() = ^{
	 	__strong __typeof(&*strong)self = wself;
	 	if(!self) {
 			return nil;
		} else {
		 	[self description];
 		}
 });
 */
#define STRONG_SELF_RETURN_THIS(this,rv) STRONG_RETURN_THIS(this, rv)

#endif
