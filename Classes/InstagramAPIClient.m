// SongAPIClient.m
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

#import "InstagramAPIClient.h"
#import "InstagramPopularRequestMapping.h"

static NSString * const kAFInstagramAPIBaseURLString = @"https://api.instagram.com/v1/";
static NSString * const kAFInstagramClientIDString = @"1a753f23dc684c2096766566af540700";

@interface InstagramAPIClient ()
@property (nonatomic, retain)NSMutableDictionary* requestMappings;
@end

@implementation InstagramAPIClient
@synthesize requestMappings=_requestMappings;
@synthesize oauthToken=_oauthToken;

+ (InstagramAPIClient *)sharedClient {
    static InstagramAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAFInstagramAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    return self;
}

#pragma mark - AFIncrementalStore

-(NSString *)pathForFetchRequest:(NSFetchRequest *)request
{
    __block NSString* urlPath = nil;
    [self.requestMappings enumerateKeysAndObjectsUsingBlock:^(id key, InstagramPopularRequestMapping *requestMapping, BOOL *stop) {
        if ([requestMapping.mapping.entity.name isEqualToString:request.entityName]) {
            urlPath = requestMapping.urlPath;
        }
    }];
     
    return urlPath;
}

- (NSURLRequest *)requestForFetchRequest:(NSFetchRequest *)fetchRequest
                             withContext:(NSManagedObjectContext *)context
{
    if (!self.requestMappings && context) {
        self.requestMappings = [[NSMutableDictionary alloc] init];
        InstagramPopularRequestMapping* requestMapping = [[InstagramPopularRequestMapping alloc] initWithContext:context];
        [self.requestMappings setObject:requestMapping forKey:requestMapping.urlPath];
    }
    
    NSMutableURLRequest *mutableRequest =  [self requestWithMethod:@"GET"
                                                              path:[self pathForFetchRequest:fetchRequest]
                                                        parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    kAFInstagramClientIDString,@"client_id"
                                                                    , nil]];
    
    mutableRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    return mutableRequest;
}

-(NSString*)pathForClientURL:(NSURL*)clientURL
{
    return [[clientURL path] stringByReplacingOccurrencesOfString:[[self.baseURL path] stringByAppendingString:@"/"]
                                                       withString:@""];
}

-(id)representationOrArrayOfRepresentationsFromResponseObject:(id)responseObject
{
    return [responseObject valueForKeyPath:@"data"];
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
                                     ofEntity:(NSEntityDescription *)entity
                                 fromResponse:(NSHTTPURLResponse *)response
{
    NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];

    InstagramPopularRequestMapping* requestMapping =[self.requestMappings objectForKey:[self pathForClientURL:response.URL]];
    if (requestMapping && [entity.name isEqualToString:requestMapping.mapping.entity.name]) {
        [mutablePropertyValues addEntriesFromDictionary:[requestMapping.mapping attributesRepresentationFromDictioanry:representation]];
    }

    return mutablePropertyValues;
}

-(NSDictionary *)representationsForRelationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fromResponse:(NSHTTPURLResponse *)response
{
    NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];
    
    InstagramPopularRequestMapping* requestMapping =[self.requestMappings objectForKey:[self pathForClientURL:response.URL]];
    if (requestMapping) {
        [mutablePropertyValues addEntriesFromDictionary:[requestMapping.mapping relationshipsRepresentationFromDictioanry:representation]];
    }
    
    return mutablePropertyValues;
}

- (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID
                                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
                               forObjectWithID:(NSManagedObjectID *)objectID
                        inManagedObjectContext:(NSManagedObjectContext *)context
{
    return NO;
}

@end
