//
//  ABOnboardingSettings.swift
//  ABOnboarding
//
//  Created by Adam Boyd on 2016-04-02.
//
//

import Foundation
import UIKit

public struct ABOnboardingSettings {
    //Background and text
    public static var OnboardingBackground = UIColor.whiteColor()
    public static var OnboardingNextButtonBackground = UIColor.whiteColor()
    public static var OnboardingText = UIColor(rgba: "#9b9b9b")
    public static var OnboardingLaterText = UIColor(rgba: "#9b9b9b")
    public static var BackgroundWhileOnboarding = UIColor.blackColor().colorWithAlphaComponent(0.85)
    public static var Font = UIFont.systemFontOfSize(16)
    
    //Rounded button
    public static var ButtonBackgroundNormal = UIColor(rgba: "#50e3c2")
    public static var ButtonBackgroundHighlighted = UIColor.clearColor()
    public static var ButtonTextNormal = UIColor.whiteColor()
    public static var ButtonTextHighlighted = UIColor(rgba: "#9b9b9b")
    public static var ButtonBorderNormal = UIColor.clearColor()
    public static var ButtonBorderHighlighted = UIColor(rgba: "#9b9b9b")
    
    public static var ViewToShowOnboarding: UIView?
    public static var AnimationDuration: NSTimeInterval = 0.5
    public static var TouchesDisabledOnUncoveredRect: Bool = true
}