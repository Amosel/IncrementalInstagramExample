//
//  Image.h
//  Incremental Instagram Example
//
// Copyright (c) 2012 Amos Elmaliah (http://amosel.org)
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Picture;

@interface Image : NSManagedObject

@property (nonatomic, retain) id data;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Picture *picture;

@end
