//
//  FormPost.m
//  RZUtils
//
//  Created by Craig on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FormPost.h"
#import <CFNetwork/CFNetwork.h>

static const NSString* kBoundary = @"0xRAIZLABSHTMLBoUnDaRY";
static const NSString* kLoopMode = @"RAIZLOOP";

NSError* MakeError(NSInteger code, NSString* description)
{
	return [NSError
		errorWithDomain:@"FormPostError"
		code:code
		userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
			description, NSLocalizedDescriptionKey,
			nil
		]
	];
}

static void ReadStreamClientCallBack(CFReadStreamRef readStream, CFStreamEventType type, void *clientCallBackInfo) 
{
	FormPost* formPost = (FormPost*) clientCallBackInfo;
	
	switch (type) {
		case kCFStreamEventErrorOccurred:
			[formPost readStreamErrorOccured:readStream];
			break;
		case kCFStreamEventEndEncountered:
			[formPost readStreamEndEncountered:readStream];
			break;
		case kCFStreamEventHasBytesAvailable:
			[formPost readStreamHasBytesAvailable:readStream];
			break;
		default:
			break;
	}
}


@implementation FormPost

@synthesize lastUpdate = _lastUpdate;
@synthesize timeoutInterval = _timeoutInterval;
@synthesize receivedData = _receivedData;
@synthesize timeoutError = _timeoutError;
@synthesize error = _error;
@synthesize delegate	= _delegate;
@synthesize userInfo = _userInfo;
@synthesize url = _url;

-(FormPost*) initWithURL:(NSURL*) url andDelegate:(id<FormPostDelegate>)delegate
{
	self = [super init];
	
	// set the default. 
	_timeoutInterval = kDefaultTimeout;
	
	_url = [url retain];
	self.delegate = delegate;
	
	return self;
}

-(void) dealloc
{
	[_fields     release];
	[_dataFields release];
	[_receivedData release];
	
	[_url release];
	
	self.error = nil;
	self.userInfo = nil;
	self.delegate = nil;
	
	
	[super dealloc];
}

-(void) addField:(NSString*) fieldName withValue:(NSString*) value
{
	// if either parameter is empty, do not add the field. 
	if(value == nil || 
		value.length <= 0 || 
		fieldName == nil ||
		fieldName.length <= 0)
	{
		return;
	}
	
	if(nil == _fields)
	{
		_fields = [[NSMutableDictionary dictionaryWithObject:value forKey:fieldName] retain];
	}
	else
	{
		[_fields setObject:value forKey:fieldName];
	}
	
}

-(void) addField:(NSString*) fieldName withData:(NSData*) data andContentType:(NSString*) contentType andFileName:(NSString*)filename
{
	// if either parameter is empty, do not add the field. 
	if(data == nil || data.length <= 0)
	{
		return;
	}
	
	if(nil == _dataFields)
	{
		_dataFields = [[NSMutableArray alloc] initWithCapacity:1];
	}

	// create a dictionary to contain this data object and its meta data (field name and content type)
	NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
	[dataDictionary setObject:data forKey:@"data"];
	
	if(nil != fieldName && [fieldName length] > 0)
		[dataDictionary setValue:fieldName forKey:@"fieldName"];
	
	if(nil != contentType && [contentType length] > 0)
		[dataDictionary setValue:contentType forKey:@"contentType"];
	
	if(nil != filename && [filename length] > 0)
		[dataDictionary setValue:filename forKey:@"filename"];

	[_dataFields addObject:dataDictionary];
	[dataDictionary release];
}


-(NSData*) generateBody
{
    NSMutableData *postBody = [[NSMutableData alloc] init];
    
	// add eaach normal field to the form post. 
	if(nil != _fields)
	{
		NSArray* keys = [_fields allKeys];
		for(int keyIdx = 0; keyIdx < keys.count; keyIdx++)
		{
			NSString* key = [keys objectAtIndex:keyIdx];
			NSString* value = [_fields objectForKey:key];    
			[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",kBoundary] dataUsingEncoding:NSUTF8StringEncoding]];    
			[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			
			if([value isKindOfClass:[NSString class]])
				[postBody appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
			else if([value isKindOfClass:[NSNumber class]])
				[postBody appendData:[[value description] dataUsingEncoding:NSUTF8StringEncoding]];
			
			[postBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		}
    }
	
	// add the data files to the form post. 
	if(nil != _dataFields)
	{
		for(NSMutableDictionary* dataDictionary in _dataFields)
		{
			NSString* fieldName = [dataDictionary valueForKey:@"fieldName"];
			NSString* contentType = [dataDictionary valueForKey:@"contentType"];
			NSString* filename = [dataDictionary valueForKey:@"filename"];
			NSData*   data = [dataDictionary objectForKey:@"data"];

			if(contentType == nil)
				contentType = @"application/octet-stream";
			
			NSString* name = @"";
			if(fieldName != nil)
				name = [NSString stringWithFormat:@" name=%@;", fieldName];
			
			[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",kBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; %@filename=\"%@\"\r\n", name, filename] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:data];
			[postBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		
		/*
		NSArray* keys = [_dataFields allKeys];
		for(NSString* key in keys)
		{
			NSData* data = [_dataFields objectForKey:key];
			[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",kBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; filename=\"%@.bin\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:data];
			[postBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		*/
	}
	
    // end it
    [postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n",kBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	return [postBody autorelease];
	
}

-(void) post
{
	if([_delegate respondsToSelector:@selector(formPostStarting:)])
	{
		[_delegate formPostStarting:self];
	}
	
	[self performSelectorInBackground:@selector(postInternal) withObject:nil];
	
}

-(void) postInternal
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	// clear any previously received data.
	if(nil != _receivedData)
	{
		[_receivedData release];
		_receivedData = nil;
	}
	
	self.lastUpdate = [NSDate date];
	
	_encounteredError = NO;
	_timeoutError = NO;
	
	// generate the body of the HTTP message
	NSData* httpBody = [self generateBody];
	
	//NSString* post = [[NSString alloc] initWithData:httpBody encoding:NSUTF8StringEncoding];
	//NSLog(post);
	
	// create the request
	CFHTTPMessageRef request = CFHTTPMessageCreateRequest(kCFAllocatorDefault, CFSTR("POST"), (CFURLRef)_url, kCFHTTPVersion1_1);
	
	// set the content as mutipart form upload
	NSString* contentHeader = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kBoundary];
	CFHTTPMessageSetHeaderFieldValue(request, CFSTR("Content-Type"), (CFStringRef) contentHeader);

	// set the http body on the message
	CFHTTPMessageSetBody(request, (CFDataRef)httpBody);
	
	// create a read stream for the request 
	CFReadStreamRef readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, request);
	
	// post has not been completed yet
	_postCompleted = NO;
	
	// set the stream client 
	CFStreamClientContext ctxt;
	ctxt.version = 0;
	ctxt.info    = self;
	ctxt.retain  = nil;
	ctxt.release = nil;
	ctxt.copyDescription = nil;
	
    if (!CFReadStreamSetClient(readStream, kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable | kCFStreamEventEndEncountered | kCFStreamEventErrorOccurred, ReadStreamClientCallBack, &ctxt)) {
        CFRelease(readStream);
        readStream = NULL;
		
		_postCompleted = YES;
		_encounteredError = YES;
		self.error = MakeError(1, @"Could not set stream client");
		NSLog(@"FormPost could not set stream client");
	}
		
	// schedule the read stream to be read in 
	if(NULL != readStream)
	{
		CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), (CFStringRef)kLoopMode);
		
		if(!CFReadStreamOpen(readStream))
		{
			NSLog(@"FormPost could not open read stream");
			_postCompleted = YES;
			_encounteredError = YES;
			self.error = MakeError(2, @"Could not open read stream");
			
			// cancel the loop. 
			CFReadStreamSetClient(readStream, 0, NULL, NULL);
			CFReadStreamUnscheduleFromRunLoop(readStream, CFRunLoopGetCurrent(), (CFStringRef)kLoopMode);
			CFRelease(readStream);
			readStream = NULL;			
		}
	}
	
	unsigned long long totalBytesSent = 0;
	
	// wait for the read to be completed
	while(!_postCompleted && !_encounteredError)
	{
		
		// Find out how much data we've uploaded so far
		totalBytesSent = [[(NSNumber *)CFReadStreamCopyProperty(readStream, kCFStreamPropertyHTTPRequestBytesWrittenCount) autorelease] unsignedLongLongValue];
		
		// if there has been an update in the number of bytes sent, tell the delegate. 
		if(_lastSentCount != totalBytesSent)
		{
			self.lastUpdate = [NSDate date];
			
			_lastSentCount = totalBytesSent;
			if([_delegate respondsToSelector:@selector(formPost:sentBytes:ofTotal:)])
			{
				[_delegate formPost:self sentBytes:_lastSentCount ofTotal:httpBody.length];
			}
		}

		if([[NSDate date] timeIntervalSinceDate:self.lastUpdate] >= _timeoutInterval)
		{
			// we timed out. 
			NSLog(@"FormPost timeout");
			_encounteredError = YES;
			_timeoutError = YES;
			self.error = MakeError(3, @"Operation timed out");
		}
			
		// Wait 1/4 second for the stream to do anything. 
		CFRunLoopRunInMode((CFStringRef)kLoopMode, 0.25, YES);
		[pool drain];
		[pool release];
		pool = [[NSAutoreleasePool alloc] init];
		
	}
	
	NSLog(@"FormPost finished. Cleaning up");
	
	// all done. cleanup. 
	if(NULL != readStream)
	{
		CFReadStreamSetClient(readStream, 0, NULL, NULL);
		CFReadStreamUnscheduleFromRunLoop(readStream, CFRunLoopGetCurrent(), (CFStringRef)kLoopMode);
		CFRelease(readStream);
		readStream = NULL;			
	}
	
	// tell the delegate we completed, and send any received data along. 
	if([_delegate respondsToSelector:@selector(formPost:completedSuccessfully:withResult:)])
	{
		[_delegate formPost:self completedSuccessfully:(!_encounteredError && _postCompleted) withResult:_receivedData];
	}
	
	[pool drain];
	[pool release];
}

-(void) readStreamHasBytesAvailable:(CFReadStreamRef)readStream
{

	// if an error occured, return. 
	if(_postCompleted || _encounteredError)
		return;
	
	// create a buffer for reading back the results. 
	UInt8 buffer[1024];
	CFIndex bytesRead = 0;
	
	bytesRead = CFReadStreamRead(readStream, buffer, 1024);
		
	if(nil == _receivedData)
		_receivedData = [[NSMutableData alloc] init];
	
	if(bytesRead > 0)
	{
		[_receivedData appendData:[NSData dataWithBytes:buffer length:bytesRead]];
	}
	
	NSLog(@"FormPost received bytes: %d", _receivedData.length);
	
	// set this so we don't timeout. 
	self.lastUpdate = [NSDate date];	
}

-(void) readStreamEndEncountered:(CFReadStreamRef)readStream
{
	NSLog(@"FormPost End of Stream");
	_postCompleted = YES;
}

-(void) readStreamErrorOccured:(CFReadStreamRef)readStream
{
	NSLog(@"FormPost Stream Error");
	_encounteredError = YES;
	_postCompleted = YES;
	CFErrorRef err = CFReadStreamCopyError(readStream);
	NSString* errDesc = (NSString*)CFErrorCopyDescription(err);
	self.error = MakeError(4, [NSString stringWithFormat:@"%@ (%d)", errDesc, CFErrorGetCode(err)]);
	CFRelease(err);
}

@end
