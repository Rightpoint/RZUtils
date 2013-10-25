# RZUtils

This is a collection of helpful utilities and components which makes iOS development quicker and easier.  A demo project is provided that demonstrates the use of most components.

## Categories Overview

 - **NSDictionary+RZExtensions**        Safely using NSDictionaries
 - **UIImage+RZStretchHelpers**         Stretch and cap inset methods for UIImage
 - **UITableViewCell+RZCellStyling**    Methods for styling top, bottom, and middle tableview cells for grouped tableviews
 - **UIView+RZFrameUtils**              Easy adjustments to UIView frames

## Components Overview

 - **RZLoadingImageView**               A drop in solution for a image view that loads from a NSURL and caches to file.
 - **RZViewFactory**                    A simple view factory class

## Headers Overview

 - **RZLogHelper**						A header with debug log macros that extend NSLog, including verbosity levels

## License
RZUtils is distributed under an [MIT License](http://opensource.org/licenses/MIT). See the LICENSE file for more details.

## Guidelines for adding a new component

When adding new components, please try and follow the following guidelines as closely as possible to ensure maximum ease of use and maintanability.

 * No need for unit tests, just make sure it works and solves problems rather than causing them.
 * Ensure that the component has well documented headers.
 * Aggressivly use namespacing (method prefix) for Objective-C categories in order to avoid potential naming collisions.
