//
//  OnboardingItem.swift
//  ABOnboarding
//
//  Created by Adam Boyd on 2016-02-29.
//  Copyright © 2016 Under100. All rights reserved.
//

import Foundation
import UIKit

public enum RelativePlacement {
    case Above(UIView), Below(UIView), RelativeToTop(CGFloat), RelativeToBottom(CGFloat), PointingUpAt(CGRect), PointingDownAt(CGRect)
}

@objc public class ABOnboardingItem: NSObject {
    var message: String
    var placement: RelativePlacement
    var onboardingView: ABOnboardingView!
    var blurredBackground: Bool
    var nextItemAutomaticallyShows: Bool = true
    
    public init(message: String, placement: RelativePlacement, blurredBackground: Bool) {
        self.message = message
        self.placement = placement
        self.blurredBackground = blurredBackground
    }
    
    public init(message: String, placement: RelativePlacement, blurredBackground: Bool, nextItemAutomaticallyShows: Bool) {
        self.message = message
        self.placement = placement
        self.blurredBackground = blurredBackground
        self.nextItemAutomaticallyShows = nextItemAutomaticallyShows
    }
}