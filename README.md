# RZUtils

A collection of helpful utilities and components for iOS development.

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
	
### UIFont

- **UIFont+RZExtensions**
	
	Funky fresh font features 
	
### UIImage

- **UIImage+RZFastImageBlur**

	Faster version of Apple's image blur method for iOS7 (with view screenshot). iOS7+ only.

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

#### RZCellHeightManager

Autolayout-based dynamic cell height utility.

**Deprecated**: This will soon be in its own repository.

#### RZCollectionTableView

Is it a Collection View or a Table View? The world may never know... (**Spoiler**: It's a Collection View)

`RZCollectionTableView` is a collection view layout and accompanying collection view and collection view cell subclasses that mimic the class/delegate interface, look, and feel of `UITableView`, with a few added enhancements such as customizable section insets, row spacings, and more.

#### RZCollectionViewAnimationAssistant

Utility for making collection view item insertion/deletion animations easier.

#### RZDelayedOperation

Basic concurrent NSOperation class that takes a block and executes it after a given time interval. Can be cancelled or reset.

#### RZHud

Loading or informational HUD that fills a given view, with custom message and UIAppearance support.

#### RZKeychain

Easier manipulation of the secure keychain.

#### RZLoadingImageView

A drop in solution for a image view that loads from an `NSURL` and caches to file. 

**Note**: This needs some love. Should probably be rewritten to use native URL caching with an additional in-memory cache, to reduce disk bloat.

#### RZLocationService

CoreLocation made easy.

####RZProgressView

`UIProgressView` is a little broken in iOS 7.0 (weird glitches when animating and resizing), and very broken in iOS 7.1 (can't set custom images; radar [here](http://www.openradar.me/16113307)). `RZProgressView` is a drop-in replacement that fixes these problems.

#### RZRevealViewController

A basement/reveal menu component. 

#### RZSingleChildContainerViewController

A `UIViewController` subclass for managing a single child view controller contained in any subview container of a parent. Useful for keeping one view static while another view contains one of many potential child view controllers. iOS7+ only.

### RZTelprompt

Makes NSURLRequest phone calls that use telprompt by making a tel request to a static UIWebView, which in turn privately calls telprompt. This gives you the benifits of using telprompt without calling it from UIApplication where it is not specifically supported by Apple.

#### RZTweenSpirit

Tweening animation utility. Allows tweening of any keypath from one value to another based on a settable timeline position. Similar to a certain "jazzy"-"handy" library, but more flexible.

#### RZViewFactory

Extensions to `UIView` for easily loading a subclass from a XIB file.

##### RZWebviewController

`UIViewController` that manages a web view, with associated chrome.

##### RZSplitViewController

Extends the functionality of `UISplitViewController` including allowing it to be presented Modally.

##### RZSegmentedViewController

`UIViewController` container that uses a segment control to switch between an array of `UIViewControllers`

## Headers Overview

#### RZDispatch

Useful inline functions for working with GCD.

#### RZLogHelper

A header with debug log macros that extend `NSLog`, including verbosity levels.

#### RZUIKitUtilityFunctions

Useful inline functions for working with `UIKit`.

#### RZUtilityMacros

Useful conversion macros and more.

## License

RZUtils is distributed under an [MIT License](http://opensource.org/licenses/MIT). See the LICENSE file for more details.

## Guidelines for adding a new component

When adding new components, please try and follow the following guidelines as closely as possible to ensure maximum ease of use and maintainability.

 * No need for unit tests, just make sure it works and solves problems rather than causing them.
 * Ensure that the component has well documented headers.
 * Aggressively use namespacing (method prefix) for Objective-C categories in order to avoid potential naming collisions.
