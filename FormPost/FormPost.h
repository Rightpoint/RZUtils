//
//  FormPost.h
//  RZUtils
//
//  Created by Craig on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDefaultTimeout 20.0

@class FormPost;

@protocol FormPostDelegate <NSObject>

@optional
-(void) formPost:(FormPost*)post sentBytes:(NSUInteger) sentBytes ofTotal:(NSUInteger)totalBytes;
-(void) formPost:(FormPost*)post completedSuccessfully:(BOOL)success withResult:(NSData*)result;
-(void) formPostStarting:(FormPost*)post; 
@end



@interface FormPost : NSObject 
{
	// fields containing textual data
	NSMutableDictionary* _fields;
	
	// fields containing binary data
	NSMutableArray* _dataFields;
	
	// delegate which receives progress updates. 
	id<FormPostDelegate> _delegate;
	
	// url to which we are going post this data .
	NSURL* _url; 
	
	// when data is received, it is added in here. 
	NSMutableData* _receivedData;
	
	// dictionary the client can use for their own data.
	NSDictionary* _userInfo;
	
	// bool indicating whether the form post is completed and all the data is read in. Also true
	// in case of failures
	BOOL _postCompleted;
	
	// error flag
	BOOL _encounteredError;
	
	// flag indicating whether the error encountered was the timeout error. 
	BOOL _timeoutError;
	
	// The error that was encountered.
	NSError* _error;
	
	// for status updates, we keep track of the last amount of data sent and received
	unsigned long long _lastReadCount;
	unsigned long long _lastSentCount;
	
	// time interval beyond which we timeout.
	float _timeoutInterval;
	
	// last time there was any data sent or received from the server. 
	NSDate* _lastUpdate;
}

-(FormPost*) initWithURL:(NSURL*) url andDelegate:(id<FormPostDelegate>)delegate;

// add a text field to the form post
-(void) addField:(NSString*) fieldName withValue:(NSString*) value;

// add a data field to the form post. This is esentially a file upload. 
-(void) addField:(NSString*) fieldName withData:(NSData*) data andContentType:(NSString*) contentType andFileName:(NSString*)filename;

// start the form post. 
-(void) post;

// generate the form post body based on the fields that have been added so far. 
-(NSData*) generateBody;

// called by the C- callback when the read stream has bytes available
-(void) readStreamHasBytesAvailable:(CFReadStreamRef)readStream;

// called by the C- callback when the read stream has ended
-(void) readStreamEndEncountered:(CFReadStreamRef)readStream;

// called by the C- callback if there was an error. 
-(void) readStreamErrorOccured:(CFReadStreamRef)readStream;

// last time there was any data sent or received from the server. 
@property (retain) NSDate* lastUpdate;

@property float timeoutInterval;
@property (readonly) NSData* receivedData;
@property (readonly) BOOL timeoutError;
@property (nonatomic, retain) NSError* error;
@property (nonatomic, retain) id<FormPostDelegate> delegate;
@property (nonatomic, retain) NSDictionary* userInfo;
@property (readonly) NSURL* url;

@end


