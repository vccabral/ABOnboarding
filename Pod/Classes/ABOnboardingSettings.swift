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
    public static var OnboardingBackground = UIColor(rgba: "#f3ede5")
    public static var OnboardingNextButtonBackground = UIColor.whiteColor()
    public static var OnboardingText = UIColor(rgba: "#031514")
    public static var OnboardingLaterText = ABOnboardingSettings.OnboardingText.colorWithAlphaComponent(0.80)
    public static var BackgroundWhileOnboarding = UIColor.blackColor().colorWithAlphaComponent(0.85)
    public static var viewToShowOnboarding: UIView?
}