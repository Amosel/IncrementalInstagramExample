//
//  Picture.h
//  Incremental Instagram Example
//
// Copyright (c) 2012 Amos Elmaliah (http://amosel.org)
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image, User;

@interface Picture : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) User *user;
@end

@interface Picture (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;


@end
