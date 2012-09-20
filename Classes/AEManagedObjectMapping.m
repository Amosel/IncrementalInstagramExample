
//
//  AEManagedObjectMapping.m
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

#import "AEManagedObjectMapping.h"

NSString*const kAEManagedObjectMappingTopLevel = @"kAEManagedObjectMappingTopLevel";

@interface RWMappingPair : NSObject
@property (readwrite, nonatomic, copy) id attribute;
@property (readwrite, nonatomic, copy) id keyPath;

- (id)initWithAttribute:(id)key keypath:(id)keyPath;

@end

@implementation RWMappingPair
@synthesize attribute = _attribute;
@synthesize keyPath = _keyPath;


-(NSString *)description
{
    return [NSString stringWithFormat:@"attribute:%@, keyPath:%@", self.attribute, self.keyPath];
}

- (id)initWithAttribute:(id)attribute keypath:(id)keyPath {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.attribute = attribute;
    self.keyPath = keyPath;
    
    return self;
}

- (void)dealloc {
    self.attribute = nil;
    self.keyPath = nil;
}

@end

@interface AEManagedObjectMapping ()
@property (nonatomic, strong) NSMutableDictionary* attributeMappings;
@property (nonatomic, strong) NSMutableDictionary* relationshipMappings;

-(void) mapRelationship:(NSString*)relationship mapping:(AEManagedObjectMapping*)mapping;

@end


@implementation AEManagedObjectMapping
@synthesize attributeMappings=_attributeMappings;
@synthesize relationshipMappings=_relationshipMappings;
@synthesize entity=_entity;
@synthesize keypath=_keypath;
@synthesize filterBlock=_filterBlock;
@synthesize entityPrimaryKey = _entityPrimaryKey;
@synthesize isToMany = _isToMany;

-(id)init
{
    [NSException raise:@"should user designated initlizer" format:@"should user designated initlizer"];
    return nil;
}

-(id)initWithEntity:(NSEntityDescription *)entity primaryKey:(NSString *)primaryKey keypath:(NSString *)keypath isToMany:(BOOL)toMany
{
    self = [super init];
    if (self) {
        _entity = entity;
        _entityPrimaryKey = [primaryKey copy];
        _keypath = [keypath copy];
        _isToMany = toMany;
        self.attributeMappings = [NSMutableDictionary new];
        self.relationshipMappings = [NSMutableDictionary new];
    }
    return self;
}

-(AEManagedObjectMapping*)relationshipMappingWithKeyPath:(NSString*)keypath
{
    return [self.relationshipMappings objectForKey:keypath];
}

-(AEManagedObjectMapping*)relationshipForEntity:(NSEntityDescription*)entity
{
    __block AEManagedObjectMapping*relationshipMapping = nil;
    [self.relationshipMappings enumerateKeysAndObjectsUsingBlock:^(id key, AEManagedObjectMapping*aRelationshipMapping, BOOL *stop) {
        if ([aRelationshipMapping.entity.name isEqualToString:entity.name]) {
            relationshipMapping = aRelationshipMapping;
            *stop = YES;
        }
    }];
    
    return relationshipMapping;
}


-(id)initWithEntity:(NSEntityDescription *)entity primaryKey:(NSString *)primaryKey keypath:(NSString *)keypath
{
    return [self initWithEntity:entity primaryKey:primaryKey keypath:keypath isToMany:NO];
}

-(AEManagedObjectMapping *)newRelationshipWithName:(NSString*)name withEntity:(NSEntityDescription *)entity primaryKey:(NSString *)primaryKey keypath:(NSString *)keypath
{
    NSRelationshipDescription* relationship = [self.entity.relationshipsByName objectForKey:name];
    if (entity && relationship && relationship.destinationEntity.name == entity.name) {
        AEManagedObjectMapping * mapping = [[AEManagedObjectMapping alloc] initWithEntity:entity primaryKey:primaryKey keypath:keypath isToMany:relationship.isToMany];
        [self mapRelationship:name mapping:mapping];
        return mapping;
    }
    else
    {
        return nil;
    }
}

-(void)dealloc
{
    self.relationshipMappings = nil;
    self.attributeMappings = nil;
    self.filterBlock = nil;
    _keypath = nil;
    _entity = nil;
    _entityPrimaryKey = nil;
}

#pragma mark attribute mappings

- (void)addAttributeMapping:(NSString*)keyPath;
{
    NSMutableSet* kvoMappings = [[self attributeMappings] objectForKey:@"__KVO__"];
    if (!kvoMappings) {
        kvoMappings = [NSMutableSet new];
        [[self attributeMappings] setObject:kvoMappings
                                     forKey:@"__KVO__"];
    }
    [kvoMappings addObject:keyPath];
}

- (void)addAttributeMappings:(id)firstKey, ... {
    va_list args;
    va_start(args, firstKey);
    for (id key = firstKey; key != nil; key = va_arg(args, id)) {
        [self addAttributeMapping:key];
    }
    va_end(args);
}

- (void)mapAttribute:(NSString*)attributeKey withKeyPath:(NSString*)keypath
{
    NSMutableSet* kvoMappings = [[self attributeMappings] objectForKey:@"__KVO_MAP__"];
    if (!kvoMappings) {
        kvoMappings = [NSMutableSet new];
        [[self attributeMappings] setObject:kvoMappings
                                     forKey:@"__KVO_MAP__"];
    }
    RWMappingPair* pair = [[RWMappingPair alloc] initWithAttribute:attributeKey keypath:keypath];
    [kvoMappings addObject:pair];
}

- (void)mapAttributesWithAttributesAndKeypaths:(id)firstKey, ... {
    va_list args;
    va_start(args, firstKey);
    for (id attribute = firstKey; attribute != nil; attribute = va_arg(args, id)) {
        id keyPath = va_arg(args, id);
        [self mapAttribute:attribute withKeyPath:keyPath];
    }
    va_end(args);
}

- (void)addMappingBlock:(id (^)(id, NSDictionary*))block;
{
    NSMutableSet* blockMappings = [[self attributeMappings] objectForKey:@"__blocks__"];
    if (!blockMappings) {
        blockMappings = [NSMutableSet new];
        [[self attributeMappings] setObject:blockMappings
                                     forKey:@"__blocks__"];
    }
    [blockMappings addObject:block];
}


#pragma mark relationship mapping

- (void)mapRelationship:(NSString *)relationship mapping:(AEManagedObjectMapping *)mapping
{
    NSAssert([mapping isKindOfClass:[AEManagedObjectMapping class]], @"mapping should be kind of AEManagedObjectMapping");
    [self.relationshipMappings setObject:mapping forKey:relationship];
}

-(NSDictionary*)relationshipsRepresentationFromDictioanry:(NSDictionary*)dictionary
{
    NSMutableDictionary* results = [NSMutableDictionary dictionary];
    
    [self.relationshipMappings enumerateKeysAndObjectsUsingBlock:^(NSString* relationship, AEManagedObjectMapping* mapping, BOOL *stop) {
        id relationshipOrRelationships = [dictionary objectForKey:mapping.keypath];
        if (relationshipOrRelationships && [relationshipOrRelationships isKindOfClass:[NSDictionary class]]) {
            if (mapping.isToMany) {
                NSMutableArray* relationshipRepresentation = [NSMutableArray array];
                
                if ([relationshipOrRelationships isKindOfClass:[NSDictionary class]]) {
                    [(NSDictionary*)relationshipOrRelationships enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        if ([obj isKindOfClass:[NSDictionary class]]) {
                            NSMutableDictionary* dictionary = [(NSDictionary*)obj mutableCopy];
                            [dictionary setObject:key forKey:kAEManagedObjectMappingTopLevel];
                            [relationshipRepresentation addObject:[mapping attributesRepresentationFromDictioanry:dictionary]];
                        }
                    }];
                }
                else if([relationshipOrRelationships isKindOfClass:[NSArray class]])
                {
                    [(NSArray*)relationshipOrRelationships enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [relationshipRepresentation addObject:[mapping attributesRepresentationFromDictioanry:obj]];
                    }];
                }
                
                if (relationshipRepresentation) {
                    [results setObject:relationshipRepresentation forKey:relationship];
                }
            }
            else
            {
                id relationshipRepresentation = [mapping attributesRepresentationFromDictioanry:relationshipOrRelationships];
                if ([relationshipRepresentation isKindOfClass:[NSDictionary class]]) {
                    [results setObject:relationshipRepresentation forKey:relationship];
                }
            }
        }
    }];    
    return results;
}

-(NSDictionary*)attributesRepresentationFromDictioanry:(NSDictionary*)dictionary
{
    NSMutableDictionary* results = [NSMutableDictionary dictionary];
    
    [self.attributeMappings enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableSet* set, BOOL *stop) {
        if ([key isEqualToString:@"__KVO__"]) {
            [set enumerateObjectsUsingBlock:^(NSString* attributeKeypath, BOOL *stop) {
                [results setValue:[dictionary valueForKeyPath:attributeKeypath]
                       forKeyPath:attributeKeypath];
            }];
        }
        if ([key isEqualToString:@"__KVO_MAP__"]) {
            [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                NSAssert1([obj isKindOfClass:[RWMappingPair class]], @"object:%@ should with with class kind: RWMappingPair", obj);
                RWMappingPair* pair = (RWMappingPair*)obj;
                [results setValue:[dictionary valueForKeyPath:pair.keyPath]
                       forKeyPath:pair.attribute];
            }];
        }
        if ([key isEqualToString:@"__blocks__"]) {
            [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                id(^block)(id value) = obj;
                NSDictionary*assignment = block(dictionary);
                [results setValuesForKeysWithDictionary:assignment];
            }];
        }
    }];
    return results;
}

@end