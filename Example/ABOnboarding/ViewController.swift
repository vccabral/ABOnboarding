//
//  ViewController.swift
//  ABOnboarding
//
//  Created by Adam Boyd on 04/02/2016.
//  Copyright (c) 2016 Adam Boyd. All rights reserved.
//

import UIKit
import ABOnboarding

class ViewController: UIViewController, ShowsABOnboardingItem {

    var itemsToShow: [ABOnboardingItem] = []
    var onboardingIndex: Int = 0
    var currentBlurViews: [UIView] = []
    var onboardingSection: Int = 0
    
    @IBOutlet weak var awesomeButton: UIButton!
    @IBOutlet weak var anotherButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.shouldShowOnboardingOnThisVC() {
            //Note: if you get an error about constraints here, the onboarding is being shown before the window is ready.
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.itemsToShow = [
                    ABOnboardingItem(message: "This is pointing at a pretty awesome button", placement: .Below(self.awesomeButton), blurredBackground: true),
                    ABOnboardingItem(message: "This is another button, but this time below", placement: .Above(self.anotherButton), blurredBackground: true),
                    ABOnboardingItem(message: "It doesn't have to point at anything!", placement: .RelativeToTop(100), blurredBackground: true),
                    ABOnboardingItem(message: "It doesn't have to have a blurred background", placement: .RelativeToTop(100), blurredBackground: false),
                    ABOnboardingItem(message: "You can delay the next item showing until a user completes an action (press the awesome button)", placement: .RelativeToTop(100), blurredBackground: true, nextItemAutomaticallyShows: false),
                    ABOnboardingItem(message: "This one is delayed. That's pretty cool right?", placement: .Below(self.awesomeButton), blurredBackground: true)
                ]
                
                self.startOnboarding()
            }
        }
    }
    
    @IBAction func awesomeButtonAction(sender: AnyObject) {
        if self.shouldShowOnboardingOnThisVC() {
            self.showNextOnboardingItem()
        }
    }
    
    // MARK: - ShowsABOnboardingItem
    
    func userSkippedOnboarding() {
        print("User hit the skip onboarding button, save the status in this method")
    }
    
    func userCompletedOnboarding() {
        print("User completed all the onboarding, save the status in this method")
    }
    
    /**
     If pod ABOnboarding should be showing items on this view controller
     
     - returns: true if should show, false if not
     */
    func shouldShowOnboardingOnThisVC() -> Bool {
        return true
    }

}

