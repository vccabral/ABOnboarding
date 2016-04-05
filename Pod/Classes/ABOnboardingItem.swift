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
    var onboardingView: ABOnboardingView! {
        didSet {
            if let leftTitle = self.leftButtonTitle {
                self.onboardingView.laterButton.setTitle(leftTitle, forState: .Normal)
            }
            
            if let rightTitle = self.rightButtonTitle {
                self.onboardingView.nextButton.setTitle(rightTitle, forState: .Normal)
            }
        }
    }
    var blurredBackground: Bool
    var nextItemAutomaticallyShows: Bool = true
    var leftButtonTitle: String?
    var rightButtonTitle: String?
    
    public init(message: String, placement: RelativePlacement, blurredBackground: Bool, leftButtonTitle: String? = nil, rightButtonTitle: String? = nil) {
        self.message = message
        self.placement = placement
        self.blurredBackground = blurredBackground
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
    }
    
    public init(message: String, placement: RelativePlacement, blurredBackground: Bool, nextItemAutomaticallyShows: Bool, leftButtonTitle: String? = nil, rightButtonTitle: String? = nil) {
        self.message = message
        self.placement = placement
        self.blurredBackground = blurredBackground
        self.nextItemAutomaticallyShows = nextItemAutomaticallyShows
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
    }
}