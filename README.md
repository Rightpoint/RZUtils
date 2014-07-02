# RZUtils

A collection of helpful utilities and components for iOS development.

## Installation

### CocoaPods

The podspec for RZUtils is fully segmented into subspecs by directory (effectively one subspec per individual category type or component). See below for examples.

##### All of RZUtils

`pod 'RZUtils'`

##### All Categories

`pod 'RZUtils/Categories'`

##### All Components

`pod 'RZUtils/Components'`

##### All Utilities or Test Utilities

`pod 'RZUtils/Utilities'`<br>
`pod 'RZUtils/TestUtilities'`

##### Specific Classes

To import only a specific category, component, or utility, the subspec should mirror the directory structure.
For example:

`pod 'RZUtils/Categories/NSString'`<br>
`pod 'RZUtils/Categories/KVO'`<br>
`pod 'RZUtils/Components/RZProgressView'`

### Manual Installation

Simply copy the relevant file into your project. If the files import any frameworks, link against those frameworks.

## Categories Overview

### CoreAnimation

- **CAAnimation+RZBlocks**

	Completion blocks for `CAAnimation`

### KVO

- **NSObject+RZBlockKVO** 

	KVO with blocks and automatic observer removal on dealloc

### NSDate

- **NSDate+RZExtensions**

	Common date manipulations

### NSDictionary

- **NSDictionary+RZExtensions**
	
	Convenience methods for `NSDictionary` (`NSNull` check, etc)

### NSString

- **NSAttributedString+RZExtensions**
	
	Simplified attributed string initializer and other utils
	
- **NSString+RZStringFormatting**
	
	Common string formatting methods

- **NSString+RZStringSize**

	Replacement for string sizing methods deprecated in iOS 7.
    
    
### NSUndoManager

- **NSUndoManager+RZBlockUndo**

	Block-based interface for undo manager.

### UIAlertView

- **UIAlertView+RZCompletionBlocks**

	Block API for `UIAlertView` actions

### UIColor

- **UIColor+RZExtensions**

  UIColor creation utilities
  
### UIFont

- **UIFont+RZExtensions**
	
	Funky fresh font features 
	
### UIImage

- **UIImage+RZAverageColor**
	
	Calculates the average color of a UIImage instance.

- **UIImage+RZResize**
	
	Methods for resizing an image given an aspect ratio.

- **UIImage+RZSnapshotHelpers**

	Method for snapshotting and creating a UIImage from a UIView using iOS7's `drawViewHierarchyInRect`.  Contains a faster version of Apple's image blur method for iOS7 (with view screenshot). iOS7+ only.

- **UIImage+RZSolidColor**

	Category on `UIImage` to return a solid color image of a specified size. Especially useful to set a state-dependent background color on `UIButton`, like: `[aButton setBackgroundImage:[UIImage rz_solidColorImageWithSize:CGSizeMake(1.0f, 1.0f) color:[UIColor redColor]]]`.

- **UIImage+RZStretchHelpers**

	Stretch and cap inset methods for `UIImage`   

### UITableViewCell

- **UITableViewCell+RZCellStyling**

	Methods for styling top, bottom, and middle tableview cells for grouped table views

### UIView

- **UIView+RZAutoLayoutHelpers**

	Common code-level autolayout tasks made easier.

- **UIView+RZBorders**

	Borders on arbitrary sides of any `UIView`

- **UIView+RZFrameUtils**

	Easy adjustments to `UIView` frames

### UIViewController

- **UIViewController+RZKeyboardWatcher**

	Utility for scripting animation blocks in response to keyboard appearance/disappearance notifications.

## Components Overview

#### RZAnimatedCountingLabel

`UILabel` subclass that animates its text from one value to another with an optional custom formatting block.

#### RZAnimatedImageView

Replacement for `UIImageView`-based animated .png sequences that calls a completion block when the animation is finished. Believe it or not, there is no way to do this otherwise.

#### RZButtonView

`UIControl` subclass that acts like a UIButton but allows the addition and layout of arbitrary subviews.

#### RZCollectionTableView

Is it a Collection View or a Table View? The world may never know... (**Spoiler**: It's a Collection View)

`RZCollectionTableView` is a collection view layout and accompanying collection view and collection view cell subclasses that mimic the class/delegate interface, look, and feel of `UITableView`, with a few added enhancements such as customizable section insets, row spacings, and more.

#### RZCollectionViewAnimationAssistant

Utility for making collection view item insertion/deletion animations easier.

#### RZDelayedOperation

Basic concurrent NSOperation class that takes a block and executes it after a given time interval. Can be cancelled or reset.

#### RZLocationService

CoreLocation made easy.

#### RZProgressView

`UIProgressView` is a little broken in iOS 7.0 (weird glitches when animating and resizing), and very broken in iOS 7.1 (can't set custom images; radar [here](http://www.openradar.me/16113307)). `RZProgressView` is a drop-in replacement that fixes these problems.

#### RZRevealViewController

A basement/reveal menu component. 

#### RZSegmentedViewController

`UIViewController` container that uses a segment control to switch between an array of `UIViewControllers`

#### RZSingleChildContainerViewController

A `UIViewController` subclass for managing a single child view controller contained in any subview container of a parent. Useful for keeping one view static while another view contains one of many potential child view controllers. iOS7+ only.

#### RZSplitViewController

Extends the functionality of `UISplitViewController` including allowing it to be presented Modally.

#### RZTelprompt

Makes NSURLRequest phone calls that use telprompt by making a tel request to a static UIWebView, which in turn privately calls telprompt. This gives you the benifits of using telprompt without calling it from UIApplication where it is not specifically supported by Apple.

#### RZViewFactory

Extensions to `UIView` for easily loading a subclass from a XIB file.

#### RZWebviewController

`UIViewController` that manages a web view, with associated chrome.


## Utilities Overview

#### RZCommonUtils

Useful macros, mathematical functions, and more.

#### RZDispatch

Useful extensions for working with GCD/libdispatch.

#### RZLogHelper

A header with debug log macros that extend `NSLog`, including verbosity levels.

## Test Utilities Overview

All utilities within this directory are intended for use in test code ONLY. 

#### RZWaiter

A utility for aiding in testing asynchronous operations.


## License

RZUtils is distributed under an [MIT License](http://opensource.org/licenses/MIT). See the LICENSE file for more details.

## Contributing

Contributions and pull requests are welcome. Please adhere to the following guidelines:

- Please open Pull Requests against the `develop` branch. We periodically coalesce updates into tagged releases with semantic version numbers, which are pushed as podspec updates then merged to master.
- Ensure that headers are documented using appledoc-style comments. This will allow CocoaDocs to automatically create documentation when the updated podspec is pushed.
- Aggressively use prefixes (`RZ` for classes, `rz_` for methods) for category methods and class names in order to avoid potential naming collisions.
  
