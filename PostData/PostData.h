//
//  PostData.h
//  Surveys
//
//  Created by Craig on 7/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PostData;

@protocol PostDataDelegate <NSObject>

@optional

// data was received from the post data request. 
-(void) postData:(PostData*)postData receivedData:(NSData*) data;

// there was an error connecting to the specified URL. 
-(void) postData:(PostData*)postData error:(NSString*)error;

@end


@interface PostData : NSObject 
{
	id<PostDataDelegate> _delegate;
	
	// amount of time to allow the request to try
	int _requestTimeout;

	// request
	NSURLRequest *_request;
	
	// data recieved from the web server. 
	NSMutableData* _receivedData;
	
	// code indicating what API was called.
	NSString* _api;

	// flag indicating whether the status bar network activity indicator is shown when sending data. 
	BOOL _useNetworkActivityIndicator;
}

@property(nonatomic, retain) id<PostDataDelegate> delegate;
@property int requestTimeout;
@property (nonatomic, retain) NSMutableData* receivedData;
@property (nonatomic, retain) NSString* api;
@property BOOL useNetworkActivityIndicator;

// initializer with delegate
-(id) initWithDelegate:(id<PostDataDelegate>) delegate;

// HTTP posts the data in the dictionary to the specified URL. 
-(void) postDataInDictionary:(NSDictionary*) dictionary toURL:(NSURL*)url;

// HTTP get the data at a specified URL
-(void) getDataFromURL:(NSURL*)url;

// NSURLConnection delegate methods. 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end