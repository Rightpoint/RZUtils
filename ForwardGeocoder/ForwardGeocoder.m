//
//  ForwardGeocoder.m
//  RZUtils
//
//  Created by jkaufman on 1/26/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "ForwardGeocoder.h"
#import "NSString+SBJSON.h"
#import "NSString+URIQuery.h"

static NSString *const kGoogleMapsGeocodeURLFormat = @"http://maps.google.com/maps/geo?q=%@&output=json&sensor=false&key=%@";

@interface ForwardGeocoder ()
- (void)performQuery;
@end


@implementation ForwardGeocoder

@synthesize delegate				= _delegate;
@synthesize formattedAddress		= _formattedAddress;
@synthesize administrativeAreaName	= _administrativeAreaName;
@synthesize localityName			= _localityName;
@synthesize countryName				= _countryName;
@synthesize coordinate				= _coordinate;

- (void)dealloc
{
	self.delegate = nil;
	
	[_dataPoster release];
	[_unformattedAddress release];
	[_formattedAddress release];
	[_administrativeAreaName release];
	[_localityName release];
	[_countryName release];
	[_coordinate release];
	
	[super dealloc];
}

- (id)initWithString:(NSString *)address delegate:(id)aDelegate
{
	if (self = [super init]) {
		
		// Set ivars
		_unformattedAddress = [address retain];
		_delegate = aDelegate;
		
		_dataPoster = [[PostData alloc] initWithDelegate:self];

		// Fire off query
		[self performQuery];
	}
	
	return self;
}

- (void)performQuery
{
	NSString *apiKey = nil;
	if ([_delegate respondsToSelector:@selector(googleMapsAPIKey)])
		apiKey = [_delegate googleMapsAPIKey];

	NSString *getString = [NSString stringWithFormat:kGoogleMapsGeocodeURLFormat, [_unformattedAddress encodePercentEscapesPerRFC2396], apiKey];
	NSURL *getURL = [NSURL URLWithString:getString];

	[_dataPoster getDataFromURL:getURL];
}

#pragma mark PostData Support
- (void) postData:(PostData *)postData error:(NSString *)error
{

	// PostData only ever returns "ConnectionError" so use no forwarding it along
	if ([_delegate respondsToSelector:@selector(forwardGeocoder:didFinishSuccessfully:)])
		[_delegate forwardGeocoder:self didFinishSuccessfully:NO];
}

- (void) postData:(PostData *)postData receivedData:(NSData *)data
{
	// Parse out top-ranking address
	NSString *resultString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	id results = [resultString JSONValue];

	NSDictionary *resultsDict = nil;
	if ([results isKindOfClass:[NSArray class]])
		resultsDict = [(NSArray *)results objectAtIndex:0];
	else
		resultsDict = results;

	NSLog(@"Status code: %@",[resultsDict objectForKey:@"Status"]);
	NSDictionary *addressDict = [[resultsDict objectForKey:@"Placemark"] objectAtIndex:0];
	_formattedAddress = [[addressDict objectForKey:@"address"] retain];
	
	NSDictionary *addressDetails = [addressDict objectForKey:@"AddressDetails"];
	NSDictionary *administrativeArea = [addressDetails objectForKey:@"AdministrativeArea"];

	_administrativeAreaName = [[administrativeArea objectForKey:@"AdministrativeAreaName"] retain];
	_localityName = [[[administrativeArea objectForKey:@"Locality"] objectForKey:@"LocalityName"] retain];
	_countryName = [[[addressDetails objectForKey:@"Country"] objectForKey:@"CountryNameCode"] retain];
	
	NSArray *coordinates = [[addressDict objectForKey:@"Point"] objectForKey:@"coordinates"];
	_coordinate = [[CLLocation alloc] initWithLatitude:[[coordinates objectAtIndex:1] doubleValue] longitude:[[coordinates objectAtIndex:0] doubleValue]];

	// Alert delegate
	if ([_delegate respondsToSelector:@selector(forwardGeocoder:didFinishSuccessfully:)])
		[_delegate forwardGeocoder:self didFinishSuccessfully:YES];

}

@end