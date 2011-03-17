//
//  PostData.m
//  Surveys
//
//  Created by Craig on 7/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PostData.h"
#define kDefaultRequestTimeout 20

@implementation PostData
@synthesize delegate		= _delegate;
@synthesize requestTimeout	= _requestTimeout;
@synthesize receivedData	= _receivedData;
@synthesize api				= _api;
@synthesize useNetworkActivityIndicator = _useNetworkActivityIndicator;

-(id) init
{
	self = [super init];
	
	_requestTimeout = kDefaultRequestTimeout;
	
	self.useNetworkActivityIndicator = NO;
	
	return self;
}

-(id) initWithDelegate:(id<PostDataDelegate>) delegate
{
	self = [self init];
	self.delegate = delegate;
	return self;
}

-(void) dealloc
{
	[_request release];
	self.api = nil;
	self.delegate = nil;
	self.receivedData = nil;
	
	[super dealloc];
}

-(void) postDataInDictionary:(NSDictionary*) params toURL:(NSURL*) url
{
	NSMutableString *str = [[NSMutableString alloc] init];
	
	if (params) 
	{
		
		int i;
		NSArray *names = [params allKeys];
		for (i = 0; i < [names count]; i++) {
			if (i == 0) {
				 //[str appendString:@"?"];
			} else if (i > 0) {
				[str appendString:@"&"];
			}
			NSString *name = [names objectAtIndex:i];
			NSString* strToAdd = [params objectForKey:name ];
			
			//strToAdd = [strToAdd stringByReplacingOccurrencesOfString:@" " withString:@"+"];
			//strToAdd = [strToAdd stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString* nonAlphaNumValidChars = @"!*'();:@&=+$,/?%#[]";
			CFStringRef encodedStringToAdd = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																					 (CFStringRef)strToAdd,
																					 NULL,
																					 (CFStringRef)nonAlphaNumValidChars,
																					 kCFStringEncodingUTF8);
			strToAdd = [NSString stringWithString:(NSString*)encodedStringToAdd];
			
			strToAdd = [strToAdd stringByReplacingOccurrencesOfString:@" " withString:@"+"];
			
			[str appendString:[NSString stringWithFormat:@"%@=%@", name, strToAdd]];
			CFRelease(encodedStringToAdd);
			
		}
	}
	
	// Construct an NSMutableURLRequest for the URL and set appropriate request method.
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url 
															  cachePolicy:NSURLRequestReloadIgnoringCacheData 
														  timeoutInterval:_requestTimeout];
	
	[theRequest setHTTPMethod:@"POST"];    
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	//NSString* encodedString = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"Posting Data: %@", str);
	
	NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
	
	[theRequest setValue:[NSString stringWithFormat:@"%d", data.length] forHTTPHeaderField:@"Content-Length"];
	
	[theRequest setHTTPBody:data];
	
	[_request release];
	_request = [theRequest retain];

	[str release];
	
	NSURLConnection* theConnection = nil;

	theConnection = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
	
	if(nil == theConnection)
	{
		// inform the user that the download could not be made
		if(nil != _delegate && [_delegate respondsToSelector:@selector(postData:error:)])
		{
			[_delegate postData:self error:@"ConnectionError"];
		}
		
	}
	else 
	{
		if(self.useNetworkActivityIndicator)
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		
	}	
}

-(void) getDataFromURL:(NSURL*)url
{
	
	// create the request
	NSMutableURLRequest *theRequest = [NSMutableURLRequest  requestWithURL:url
															   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
														   timeoutInterval:_requestTimeout];
	
	[theRequest setHTTPMethod:@"GET"];  
	NSURLConnection* theConnection = nil;
	theConnection = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
	
	if(nil == theConnection)
	{
		// inform the user that the download could not be made
		if(nil != _delegate && [_delegate respondsToSelector:@selector(postData:error:)])
		{
			[_delegate postData:self error:@"ConnectionError"];
		}
		
	}
	else 
	{
		if(self.useNetworkActivityIndicator) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
		
	}
	
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if([response isKindOfClass:[NSHTTPURLResponse class]])
	{
		NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
		
		NSLog(@"Received http response from NSURLConnection:%d: %@", httpResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]);		
	}

	
	// reset the data object. 
	self.receivedData = [NSMutableData data];
}


- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;
{
    if (redirectResponse) {
		// Clone and retarget request to new URL.
        NSMutableURLRequest *r = [[_request mutableCopy] autorelease];
        [r setURL: [request URL]];
        return [[r copy] autorelease];
    } else {
        return request;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.receivedData = nil;
	
	NSLog(@"Connection didFailWithError: %@", error);
	
	if(self.useNetworkActivityIndicator)
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	// inform the user that the download could not be made
	if(nil != _delegate && [_delegate respondsToSelector:@selector(postData:error:)])
	{
		[_delegate postData:self error:@"ConnectionError"];
	}
	
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if(self.useNetworkActivityIndicator)
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	// inform the user that the download could not be made
	if(nil != _delegate && [_delegate respondsToSelector:@selector(postData:receivedData:)])
	{
		[_delegate postData:self receivedData:self.receivedData];
	}
}



@end
