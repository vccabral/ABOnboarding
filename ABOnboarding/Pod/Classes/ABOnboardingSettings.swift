//
//  ABOnboardingSettings.swift
//  ABOnboarding
//
//  Created by Adam Boyd on 2016-04-02.
//
//

import Foundation
import UIKit

struct ABOnboardingSettings {
    static var OnboardingBackground = UIColor(rgba: "#f3ede5")
    static var OnboardingNextButtonBackground = UIColor.whiteColor()
    static var OnboardingText = UIColor(rgba: "#031514")
    static var OnboardingLaterText = ABOnboardingSettings.OnboardingText.colorWithAlphaComponent(0.80)
    static var BackgroundWhileOnboarding = UIColor.blackColor().colorWithAlphaComponent(0.85)
}