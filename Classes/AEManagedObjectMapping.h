//
//  AEManagedObjectMapping.h
//  Incremental Instagram Example
//
//  Copyright (c) 2012 Amos Elmaliah (http://amosel.org)
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


#import <Foundation/Foundation.h>

extern NSString*const kAEManagedObjectMappingTopLevel;

typedef BOOL(^RWManagedObjectMappingSelector)(id obj, NSUInteger idx);

@interface AEManagedObjectMapping : NSObject
@property (nonatomic, copy) RWManagedObjectMappingSelector (^filterBlock)(NSArray*);
@property (nonatomic, readonly) NSString* keypath;
@property (nonatomic, readonly) NSEntityDescription *entity;
@property (nonatomic, readonly) NSString* entityPrimaryKey;
@property (nonatomic, readonly) BOOL isToMany;


-(id)initWithEntity:(NSEntityDescription *)entity primaryKey:(NSString*)primaryKey keypath:(NSString *)keypath;

-(AEManagedObjectMapping *)newRelationshipWithName:(NSString*)name
                                        withEntity:(NSEntityDescription *)entity
                                        primaryKey:(NSString *)primaryKey
                                           keypath:(NSString *)keypath;


- (void)addAttributeMapping:(NSString*)keyPath;
- (void)addAttributeMappings:(id)firstKey, ...;

- (void)mapAttribute:(NSString*)attributeKey withKeyPath:(NSString*)keypath;
- (void)mapAttributesWithAttributesAndKeypaths:(id)firstKey, ...;

- (void)addMappingBlock:(id (^)(NSDictionary*))block;

-(NSDictionary*)attributesRepresentationFromDictioanry:(NSDictionary*)dictionary;

-(NSDictionary*)relationshipsRepresentationFromDictioanry:(NSDictionary*)dictionary;

// 
-(AEManagedObjectMapping*)relationshipMappingWithKeyPath:(NSString*)keypath;

-(AEManagedObjectMapping*)relationshipForEntity:(NSEntityDescription*)entity;

@end
