//
//  User.h
//  Incremental Instagram Example
//
// Copyright (c) 2012 Amos Elmaliah (http://amosel.org)
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Picture;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * profileImageURLString;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *pictures;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addPicturesObject:(Picture *)value;
- (void)removePicturesObject:(Picture *)value;
- (void)addPictures:(NSSet *)values;
- (void)removePictures:(NSSet *)values;

@end
