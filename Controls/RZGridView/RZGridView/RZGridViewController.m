//
//  RZGridViewViewController.m
//  RZGridView
//
//  Created by Joe Goullaud on 10/3/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZGridViewController.h"

@implementation RZGridViewController

@synthesize gridView = _gridView;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gridView = [[[RZGridView alloc] initWithFrame:self.view.bounds] autorelease];
    self.gridView.dataSource = self;
    
    [self.view addSubview:self.gridView];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - RZGridViewDataSource

- (NSInteger)gridView:(RZGridView*)gridView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

- (NSInteger)gridView:(RZGridView*)gridView numberOfColumnsInRow:(NSInteger)row inSection:(NSInteger)section
{
    return 3;
}

- (RZGridViewCell*)gridView:(RZGridView*)gridView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    RZGridViewCell *cell = [[[RZGridViewCell alloc] initWithFrame:CGRectZero] autorelease];
    
    NSInteger colorIndex = indexPath.gridRow * 3 + indexPath.gridColumn;
    
    UIColor *color = nil;
    
    switch (colorIndex % 9) {
        case 0:
            color = [UIColor redColor];
            break;
        case 1:
            color = [UIColor orangeColor];
            break;
        case 2:
            color = [UIColor yellowColor];
            break;
        case 3:
            color = [UIColor greenColor];
            break;
        case 4:
            color = [UIColor cyanColor];
            break;
        case 5:
            color = [UIColor blueColor];
            break;
        case 6:
            color = [UIColor purpleColor];
            break;
        case 7:
            color = [UIColor magentaColor];
            break;
        case 8:
            color = [UIColor grayColor];
            break;
            
        default:
            color = [UIColor blackColor];
            break;
    }
    
    cell.backgroundColor = color;
    
    return cell;
}

- (void)gridView:(RZGridView *)gridView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSLog(@"Item Moved from: %@ to: %@", sourceIndexPath, destinationIndexPath);
}

@end
