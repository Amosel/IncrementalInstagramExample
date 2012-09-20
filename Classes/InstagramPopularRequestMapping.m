//
//  AERequestMapping.m
//  Incremental Instagram Example
//
// Copyright (c) 2012 Amos Elmaliah (http://amosel.org)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "InstagramPopularRequestMapping.h"
#import "AEManagedObjectMapping.h"

@implementation InstagramPopularRequestMapping
@synthesize urlPath=_urlPath;
@synthesize mapping=_mapping;
@synthesize context = _context;

-initWithContext:(NSManagedObjectContext*)context
{
    self = [super init];
    if (self) {
        self.context = context;
        _mapping = [[AEManagedObjectMapping alloc] initWithEntity:[NSEntityDescription entityForName:@"Picture"
                                                                              inManagedObjectContext:self.context]
                                                       primaryKey:@"id"
                                                          keypath:@"date"];
        
        [_mapping addMappingBlock:^id(id value, NSDictionary *dynamicContent) {
            NSMutableDictionary* mutable = [NSMutableDictionary dictionary];
            NSString* created_time = [value objectForKey:@"created_time"];
            [mutable setObject:[NSDate dateWithTimeIntervalSince1970:[created_time doubleValue]]
                        forKey:@"createdAt"];
            return mutable;
        }];
        [_mapping addAttributeMapping:@"id"];
        
        AEManagedObjectMapping* userMapping = [_mapping newRelationshipWithName:@"user"
                                                                     withEntity:[NSEntityDescription entityForName:@"User"
                                                                                            inManagedObjectContext:self.context]
                                                                     primaryKey:@"id"
                                                                        keypath:@"user"];
        [userMapping addAttributeMappings:@"id", nil];
        [userMapping mapAttributesWithAttributesAndKeypaths:
         @"username", @"username"
         ,@"fullname", @"full_name"
         ,@"profileImageURLString", @"profile_picture"
         , nil];
        
        AEManagedObjectMapping* imageMapping = [_mapping newRelationshipWithName:@"images"
                                                                      withEntity:[NSEntityDescription entityForName:@"Image"
                                                                                             inManagedObjectContext:self.context]
                                                                      primaryKey:@"url"
                                                                         keypath:@"images"];
        
        [imageMapping addMappingBlock:^id(id value, NSDictionary *dynamicContent) {
            NSMutableDictionary* mutable = [NSMutableDictionary dictionary];
            [mutable setValue:[NSNumber numberWithInteger:[[value valueForKey:@"height"] integerValue]]
                       forKey:@"height"];
            [mutable setValue:[NSNumber numberWithInteger:[[value valueForKey:@"width"] integerValue]]
                       forKey:@"width"];
            [mutable setValue:[value valueForKey:@"url"]
                       forKey:@"url"];
            [mutable setValue:[value valueForKey:kAEManagedObjectMappingTopLevel]
                       forKey:@"type"];
            return mutable;
        }];
    }
    return self;
}

-(NSString *)urlPath
{
    return @"media/popular";
}


@end
