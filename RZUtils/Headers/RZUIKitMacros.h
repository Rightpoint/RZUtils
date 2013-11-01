//
//  RZUIKitMacros.h
//  VirginPulse
//
//  Created by Nick Donaldson on 10/3/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

inline static UIViewAnimationOptions RZAnimationOptionFromCurve(UIViewAnimationCurve curve)
{
    UIViewAnimationOptions option = 0;
    switch (curve)
    {
        case UIViewAnimationCurveEaseIn:
            option = UIViewAnimationOptionCurveEaseIn;
            break;
            
        case UIViewAnimationCurveEaseInOut:
            option = UIViewAnimationOptionCurveEaseInOut;
            break;
            
        case UIViewAnimationCurveEaseOut:
            option = UIViewAnimationOptionCurveEaseOut;
            break;
            
        case UIViewAnimationCurveLinear:
            option = UIViewAnimationOptionCurveLinear;
            break;
            
        default:
        {
            // This shows up for the keyboard curve in iOS7.
            // As of yet, not documented, but this works...
            // http://stackoverflow.com/questions/18957476/ios-7-keyboard-animation
            if ((int)curve == 7)
            {
                option = (curve << 16);
            }
        }
            break;
    }
    return option;
}