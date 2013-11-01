# RZUtils

This is a collection of helpful utilities and components which makes iOS development quicker and easier.  A demo project is provided that demonstrates the use of most components.

## Categories Overview

### KVO

##### *NSObject+RZBlockKVO*

KVO with blocks and automatic observer removal on dealloc

#### NSDate

##### *NSDate+RZExtensions*

Common date manipulations

#### NSDictionary

##### *NSDictionary+RZExtensions*

Convenience methods for NSDictionary (NSNull check, etc)

#### UIAlertView

##### *UIAlertView+RZCompletionBlocks*

Alert view completion blocks

#### UIImage

##### *UIImage+RZFastImageBlur*

Faster version of Apple's image blur method for iOS7 (with view screenshot). iOS7+ only.

##### *UIImage+RZStretchHelpers*

Stretch and cap inset methods for UIImage   

#### UITableViewCell

##### *UITableViewCell+RZCellStyling*

Methods for styling top, bottom, and middle tableview cells for grouped tableviews

#### UIView

##### *UIView+RZAutoLayoutHelpers*

Common code-level autolayout tasks made easier.

##### *UIView+RZBorders*

Borders on arbitrary sides of any UIView, using either a category or a subclass.

##### *UIView+RZFrameUtils* 

Easy adjustments to UIView frames

## Components Overview

##### *RZCollectionTableView*

Is it a Collection View or a Table View? The world may never know... (Hint: It's a Collection View)

RZCollectionTableView is a collection view layout and accomanying collection view and collection view cell subclasses that mimic the class/delegate interface, look, and feel of UITableView, with a few added enhancements such as customizable section insets, row spacings, and more.

##### *RZLoadingImageView*

A drop in solution for a image view that loads from a NSURL and caches to file. 
<br>**Deprecated**: We need to start using native URL caching with an additional in-memory cache, to reduce disk bloat.

##### *RZSingleChildContainerViewController*

A UIViewController subclass for managing a single child view controller contained in any subview container of a parent. Useful for keeping one view static while another view contains one of many potential child view controllers. iOS7+ only.

#### *RZViewFactory*

Extensions to UIView for easily loading a subclass from a xib.

## Headers Overview

##### *RZDispatch*

Useful inline functions for working with GCD.

##### *RZLogHelper*

A header with debug log macros that extend NSLog, including verbosity levels.

##### *RZUIKitUtilityFunctions*

Useful inline functions for working with UIKit.

##### *RZUtilityMacros*

Useful conversion macros and more.


## License

RZUtils is distributed under an [MIT License](http://opensource.org/licenses/MIT). See the LICENSE file for more details.

## Guidelines for adding a new component

When adding new components, please try and follow the following guidelines as closely as possible to ensure maximum ease of use and maintanability.

 * No need for unit tests, just make sure it works and solves problems rather than causing them.
 * Ensure that the component has well documented headers.
 * Aggressivly use namespacing (method prefix) for Objective-C categories in order to avoid potential naming collisions.
