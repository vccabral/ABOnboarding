//
//  ShowsOnboardingItem.swift
//  ABOnboarding
//
//  Created by Adam Boyd on 2016-02-29.
//  Copyright © 2016 Under100. All rights reserved.
//

import Foundation
import UIKit

public protocol ShowsABOnboardingItem: class {
    var itemsToShow: [ABOnboardingItem] { get set }
    var onboardingIndex: Int { get set }
    var currentBlurViews: [UIView] { get set }
    var onboardingSection: Int { get set }
    
    //Already implemented
    func startOnboarding() //Function should be called in viewDidLoad
    func skipOnboarding()
    func showNextOnboardingItem()
    func userSkippedOnboarding()
    func userCompletedOnboarding()
    
    //Must be implemented
    func shouldShowOnboardingOnThisVC() -> Bool
}

public extension ShowsABOnboardingItem where Self: UIViewController {
    
    /**
     Show the onboarding from the beginning if the user hasn't been shown this onboarding before
     */
    public func startOnboarding() {
        self.showOnboardingItem(self.itemsToShow[self.onboardingIndex], firstItem: true, lastItem: (self.itemsToShow.count == 1))
    }
    
    /**
     User skipped the onboarding
     */
    public func skipOnboarding() {
        self.removeOnboardingItem(self.itemsToShow[self.onboardingIndex], onCompletion: nil)
        self.userSkippedOnboarding()
    }
    
    /**
     User hit next on the onboarding item, increment the counter and show that item
     */
    public func showNextOnboardingItem() {
        if self.itemsToShow[self.onboardingIndex].nextItemAutomaticallyShows {
            //If the next item should automatically show, show it
            self.onboardingIndex += 1
            
            if self.onboardingIndex < self.itemsToShow.count {
                //Onboarding is not done, show next item
                self.removeOnboardingItem(self.itemsToShow[self.onboardingIndex - 1]) { () -> Void in
                    
                    self.showOnboardingItem(self.itemsToShow[self.onboardingIndex], firstItem: false, lastItem: (self.onboardingIndex >= self.itemsToShow.count - 1))
                }
            } else {
                //Onboarding is done, complete onboarding
                self.removeOnboardingItem(self.itemsToShow[self.onboardingIndex - 1], onCompletion: nil)
                self.userCompletedOnboarding()
            }
            
        } else {
            
            //If the next item shouldn't show, set this bool to true so that the next time this method is called, the item shows
            self.itemsToShow[self.onboardingIndex].nextItemAutomaticallyShows = true
            
            self.removeOnboardingItem(self.itemsToShow[self.onboardingIndex], onCompletion: nil)
            
        }
    }
    
    /**
     Removes the currently showing onboarding item from the screen
     
     - parameter item: onboarding item to remove
     */
    public func removeOnboardingItem(item: ABOnboardingItem, onCompletion: (() -> Void)?) {
        item.onboardingView.leftConstraint?.constant = -UIScreen.mainScreen().bounds.width
        item.onboardingView.rightConstraint?.constant = -UIScreen.mainScreen().bounds.width
        
        //Animate the views to be hidden
        UIView.animateWithDuration(0.50, animations: {() -> Void in
            for view in self.currentBlurViews {
                view.alpha = 0
            }
            item.onboardingView.alpha = 0
            item.onboardingView.layoutIfNeeded()
            }, completion: { _ -> Void in
                //Removing the blur views after they have been animated away
                for view in self.currentBlurViews {
                    view.removeFromSuperview()
                }
                //Removing the blur views
                self.currentBlurViews = []
                
                item.onboardingView.removeFromSuperview()
                
                if let completion = onCompletion {
                    completion()
                }
        })
    }
    
    /**
     Shows this onboarding on screen
     
     - parameter item:     item to show
     - parameter lastItem: if this item is the last item
     */
    private func showOnboardingItem(item: ABOnboardingItem, firstItem: Bool = false, lastItem: Bool = false) {
        
        switch item.placement {
        case .Above(let view):
            self.showOnboardingItem(item, relativeToView: view, isFirstItem: firstItem, isLastItem: lastItem, isAboveItem: true)
        case .Below(let view):
            self.showOnboardingItem(item, relativeToView: view, isFirstItem: firstItem, isLastItem: lastItem, isAboveItem: false)
        case .RelativeToTop(let toTop):
            self.showOnboardingItem(item, relativeToTop: toTop, isFirstItem: firstItem, isLastItem: lastItem)
        case .RelativeToBottom(let toBottom):
            self.showOnboardingItem(item, relativeToBottom: toBottom, isFirstItem: firstItem, isLastItem: lastItem)
        case .PointingUpAt(let frame):
            self.showOnboardingItem(item, pointingAtOrigin: frame.origin, withItemFrame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), isFirstItem: firstItem, isLastItem: lastItem, isAboveItem: false)
        case .PointingDownAt(let frame):
            self.showOnboardingItem(item, pointingAtOrigin: frame.origin, withItemFrame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), isFirstItem: firstItem, isLastItem: lastItem, isAboveItem: true)
        }
    }
    
    /**
     Shows the onboarding item relative to another view
     
     - parameter item:     onboarding item to show
     - parameter view:     relative to view
     - parameter lastItem: if this item is the last item
     - parameter above:    if the item is above the item it is point at, else below
     */
    private func showOnboardingItem(item: ABOnboardingItem, relativeToView view: UIView, isFirstItem firstItem: Bool, isLastItem lastItem: Bool, isAboveItem above: Bool) {
        let globalWindowView = UIApplication.sharedApplication().keyWindow!
        let itemFrame = view.frame
        let globalPointOrigin = view.superview!.convertPoint(itemFrame.origin, toView: globalWindowView)
        
        self.showOnboardingItem(item, pointingAtOrigin: globalPointOrigin, withItemFrame: itemFrame, isFirstItem: firstItem, isLastItem: lastItem, isAboveItem: above)
        
    }
    
    
    /**
     Shows the onboarding item that is pointing at a point
     
     - parameter item:              onboarding item to show
     - parameter globalPointOrigin: origin to point at. Relative to the global window
     - parameter itemFrame:         frame of the window, needs height and width
     - parameter lastItem:          whether or not this is the last item showing
     - parameter above:             whether or not this points up or down
     */
    private func showOnboardingItem(item: ABOnboardingItem, pointingAtOrigin globalPointOrigin: CGPoint, withItemFrame itemFrame: CGRect, isFirstItem firstItem: Bool, isLastItem lastItem: Bool, isAboveItem above: Bool) {
        let globalWindowView = UIApplication.sharedApplication().keyWindow!
        //If the background should be blurred
        
        let blurOpacity: CGFloat = item.blurredBackground ? 0.8 : 0
        //Setting up top blur
        let topBlur = self.createBlurView(blurOpacity)
        self.currentBlurViews.append(topBlur)
        topBlur.translatesAutoresizingMaskIntoConstraints = false
        globalWindowView.addSubview(topBlur)
        
        //0px from top, left, right, height is determined by selected item
        globalWindowView.addConstraint(NSLayoutConstraint(item: topBlur, attribute: .Top, relatedBy: .Equal, toItem: globalWindowView, attribute: .Top, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: topBlur, attribute: .Left, relatedBy: .Equal, toItem: globalWindowView, attribute: .Left, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: topBlur, attribute: .Right, relatedBy: .Equal, toItem: globalWindowView, attribute: .Right, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: topBlur, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: max(0, globalPointOrigin.y - 5)))
        
        
        //Setting up the bottom blur
        let bottomBlur = self.createBlurView(blurOpacity)
        self.currentBlurViews.append(bottomBlur)
        bottomBlur.translatesAutoresizingMaskIntoConstraints = false
        globalWindowView.addSubview(bottomBlur)
        
        //0px from top, left, right; top from topBlur is the item's height
        globalWindowView.addConstraint(NSLayoutConstraint(item: bottomBlur, attribute: .Bottom, relatedBy: .Equal, toItem: globalWindowView, attribute: .Bottom, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: bottomBlur, attribute: .Left, relatedBy: .Equal, toItem: globalWindowView, attribute: .Left, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: bottomBlur, attribute: .Right, relatedBy: .Equal, toItem: globalWindowView, attribute: .Right, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: bottomBlur, attribute: .Top, relatedBy: .Equal, toItem: topBlur, attribute: .Bottom, multiplier: 1, constant: itemFrame.height + 10))
        
        
        //Setting up the left blur
        let leftBlur = self.createBlurView(blurOpacity)
        self.currentBlurViews.append(leftBlur)
        leftBlur.translatesAutoresizingMaskIntoConstraints = false
        globalWindowView.addSubview(leftBlur)
        
        //0px from left, topBlur, bottomBlur, width depends on item's location
        globalWindowView.addConstraint(NSLayoutConstraint(item: leftBlur, attribute: .Top, relatedBy: .Equal, toItem: topBlur, attribute: .Bottom, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: leftBlur, attribute: .Bottom, relatedBy: .Equal, toItem: bottomBlur, attribute: .Top, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: leftBlur, attribute: .Left, relatedBy: .Equal, toItem: globalWindowView, attribute: .Left, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: leftBlur, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: max(0, globalPointOrigin.x - 5)))
        
        
        //Setting up the right blur
        let rightBlur = self.createBlurView(blurOpacity)
        self.currentBlurViews.append(rightBlur)
        rightBlur.translatesAutoresizingMaskIntoConstraints = false
        globalWindowView.addSubview(rightBlur)
        
        //0px from right, topBlur, bottomBlur, width depends on item's location
        globalWindowView.addConstraint(NSLayoutConstraint(item: rightBlur, attribute: .Top, relatedBy: .Equal, toItem: topBlur, attribute: .Bottom, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: rightBlur, attribute: .Bottom, relatedBy: .Equal, toItem: bottomBlur, attribute: .Top, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: rightBlur, attribute: .Right, relatedBy: .Equal, toItem: globalWindowView, attribute: .Right, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: rightBlur, attribute: .Left, relatedBy: .Equal, toItem: leftBlur, attribute: .Right, multiplier: 1, constant: min(itemFrame.width + 10, UIScreen.mainScreen().bounds.width)))
        
        //Applying some effects to the view to prepare them for animation
        for view in self.currentBlurViews {
            view.alpha = 0
        }
        
        UIView.animateWithDuration(0.50) {
            for view in self.currentBlurViews {
                view.alpha = 1
            }
        }
        
        let onboardingView = self.setUpOnboardingViewWithItem(item, globalWindowView: globalWindowView, isFirstItem: firstItem, isLastItem: lastItem, itemFrame: itemFrame, globalPointOrigin: globalPointOrigin, isAbove: above)
        
        globalWindowView.layoutIfNeeded()
        
        //Animating the onboarding view in
        onboardingView.leftConstraint?.constant = 0
        onboardingView.rightConstraint?.constant = 0
        UIView.animateWithDuration(0.50) { () -> Void in
            onboardingView.alpha = 1
            globalWindowView.layoutIfNeeded()
        }
    }
    
    /**
     Shows onboarding item relative to the top of the screen
     
     - parameter item:          onboarding item to show
     - parameter relativeToTop: number of points away from the top of the screen
     - parameter lastItem:      if this item is the last item
     */
    private func showOnboardingItem(item: ABOnboardingItem, relativeToTop: CGFloat, isFirstItem firstItem: Bool, isLastItem lastItem: Bool) {
        let globalWindowView = UIApplication.sharedApplication().keyWindow!
        
        let blur = self.setUpBlurViewWithAlpha((item.blurredBackground ? 0.8 : 0), globalWindowView: globalWindowView)
        
        let onboardingView = self.setUpOnboardingViewWithItem(item, globalWindowView: globalWindowView, isFirstItem: firstItem, isLastItem: lastItem, itemFrame: nil, globalPointOrigin: nil, isAbove: nil, relativeToTop: relativeToTop)
        
        globalWindowView.layoutIfNeeded()
        
        //Animating the onboarding view in
        onboardingView.leftConstraint?.constant = 0
        onboardingView.rightConstraint?.constant = 0
        UIView.animateWithDuration(0.50) { () -> Void in
            blur.alpha = 1
            onboardingView.alpha = 1
            globalWindowView.layoutIfNeeded()
        }
    }
    
    /**
     Shows onboarding item relative to the top of the screen
     
     - parameter item:              onboarding item to show
     - parameter relativeToBottom:  number of points away from the top of the screen
     - parameter lastItem:          if this item is the last item
     */
    private func showOnboardingItem(item: ABOnboardingItem, relativeToBottom: CGFloat, isFirstItem firstItem: Bool, isLastItem lastItem: Bool) {
        let globalWindowView = UIApplication.sharedApplication().keyWindow!
        
        let blur = self.setUpBlurViewWithAlpha((item.blurredBackground ? 0.8 : 0), globalWindowView: globalWindowView)
        
        let onboardingView = self.setUpOnboardingViewWithItem(item, globalWindowView: globalWindowView, isFirstItem: firstItem, isLastItem: lastItem, itemFrame: nil, globalPointOrigin: nil, isAbove: nil, relativeToBottom: relativeToBottom)
        
        globalWindowView.layoutIfNeeded()
        
        //Animating the onboarding view in
        onboardingView.leftConstraint?.constant = 0
        onboardingView.rightConstraint?.constant = 0
        UIView.animateWithDuration(0.50) { () -> Void in
            blur.alpha = 1
            onboardingView.alpha = 1
            globalWindowView.layoutIfNeeded()
        }
    }
    
    /**
     Sets up an onboarding view, adds it to the global view,  and returns it
     
     - parameter item:              onboarding item
     - parameter globalWindowView:  global window where the view will be added
     - parameter lastItem:          whether or not this item is the last one in the sequence
     - parameter itemFrame:         optional CGRect of the item frame, if the item is relative to another item, this is needed
     - parameter globalPointOrigin: optional CGPoint of the item's point, if the item is relative to another, this is needed
     - parameter relativeToTop:     optional CGFloat of the distance to the top, if the item is relative to the top, this is needed
     - parameter relativeToBottom:  optional CGFloat of the distance to the bottom, if the item is relative to the bottom, this is needed
     
     - returns: set up onboarding view
     */
    private func setUpOnboardingViewWithItem(item: ABOnboardingItem, globalWindowView: UIView, isFirstItem firstItem: Bool, isLastItem lastItem: Bool, itemFrame: CGRect?, globalPointOrigin: CGPoint?, isAbove above: Bool?, relativeToTop: CGFloat? = nil, relativeToBottom: CGFloat? = nil) -> ABOnboardingView {
        let onboardingView = ABOnboardingView()
        onboardingView.setUpWith(item, firstItem: firstItem, lastItem: lastItem)
        item.onboardingView = onboardingView
        onboardingView.alpha = 0
        onboardingView.translatesAutoresizingMaskIntoConstraints = false
        globalWindowView.addSubview(onboardingView)
        
        //Adding the selectors to the next and skip buttons
        onboardingView.nextButton.addAction(forControlEvents: .TouchUpInside) {
            self.showNextOnboardingItem()
        }
        onboardingView.laterButton.addAction(forControlEvents: .TouchUpInside) {
            self.skipOnboarding()
        }
        
        //0px from left, right, height determined by item's potion. It starts 100px over for animation
        onboardingView.leftConstraint = NSLayoutConstraint(item: onboardingView, attribute: .Left, relatedBy: .Equal, toItem: globalWindowView, attribute: .Left, multiplier: 1, constant: UIScreen.mainScreen().bounds.width)
        onboardingView.rightConstraint = NSLayoutConstraint(item: onboardingView, attribute: .Right, relatedBy: .Equal, toItem: globalWindowView, attribute: .Right, multiplier: 1, constant: UIScreen.mainScreen().bounds.width)
        globalWindowView.addConstraint(onboardingView.leftConstraint!)
        globalWindowView.addConstraint(onboardingView.rightConstraint!)
        
        if let itemFrame = itemFrame, globalPointOrigin = globalPointOrigin, above = above {
            //This item is relative to another item, put it in the right place
            
            if above {
                //This item is above the other item, add it above
                //+10 to account for status bar
                globalWindowView.addConstraint(NSLayoutConstraint(item: onboardingView, attribute: .Bottom, relatedBy: .Equal, toItem: globalWindowView, attribute: .Bottom, multiplier: 1, constant: -(UIScreen.mainScreen().bounds.height + 10) + globalPointOrigin.y - 15))
                
            } else {
                //This item is below the item, add it below
                globalWindowView.addConstraint(NSLayoutConstraint(item: onboardingView, attribute: .Top, relatedBy: .Equal, toItem: globalWindowView, attribute: .Top, multiplier: 1, constant: globalPointOrigin.y + itemFrame.height + 25))
            }
            
            //Putting the triangle in the right spot
            onboardingView.addConstraint(NSLayoutConstraint(item: onboardingView.triangleView, attribute: .CenterX, relatedBy: .Equal, toItem: onboardingView, attribute: .Left, multiplier: 1, constant: globalPointOrigin.x + (itemFrame.width / 2)))
            
        } else if let relativeToTop = relativeToTop {
            
            //This item is relative to the top, show it in the right place
            globalWindowView.addConstraint(NSLayoutConstraint(item: onboardingView, attribute: .Top, relatedBy: .Equal, toItem: globalWindowView, attribute: .Top, multiplier: 1, constant: relativeToTop))
            
        } else if let relativeToBottom = relativeToBottom {
            
            //This item is relative to the bottom, show it in the right place
            globalWindowView.addConstraint(NSLayoutConstraint(item: onboardingView, attribute: .Bottom, relatedBy: .Equal, toItem: globalWindowView, attribute: .Bottom, multiplier: 1, constant: -relativeToBottom))
            
        }
        
        return onboardingView
    }
    
    /**
     Completes the onboarding for provided section
     
     - parameter section: section of onboarding to complete
     */
    public func userCompletedOnboarding() {
//        debugPrint("Onboarding done!")
//        let user = CurrentState.sharedInstance.currentUser
//        LoadingView.present()
//        ApiManager.sharedInstance.saveSectionOfOnboarding(self.onboardingSection, newStatus: .Completed, id: user.id) { (_, error) -> Void in
//            if error == nil {
//                
//                //No error, set status and grant rewards
//                switch self.onboardingSection {
//                case .Browse:
//                    CurrentState.sharedInstance.currentUser.onboardingBrowseStatus = OnboardingStatus.Completed.rawValue
//                case .Discover:
//                    CurrentState.sharedInstance.currentUser.onboardingDiscoverStatus = OnboardingStatus.Completed.rawValue
//                case .AddProduct:
//                    CurrentState.sharedInstance.currentUser.onboardingAddProductStatus = OnboardingStatus.Completed.rawValue
//                case .Rewards:
//                    CurrentState.sharedInstance.currentUser.onboardingRewardsStatus = OnboardingStatus.Completed.rawValue
//                case .Profile:
//                    CurrentState.sharedInstance.currentUser.onboardingProfileStatus = OnboardingStatus.Completed.rawValue
//                }
//                
//                ApiManager.sharedInstance.grantUserRewards(user.id, reason: self.onboardingSection) { (newUser, error) -> Void in
//                    if error == nil {
//                        
//                        user.totalRewardsCents = newUser!.availableRewardsCents
//                        user.availableRewardsCents = newUser!.availableRewardsCents
//                        
//                        //Wait until the last onboarding view is off screen
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
//                            //Show user success message
//                            SVProgressHUD.showSuccessWithStatus("Congratulations! You just got 100 rewards points!")
//                        }
//                    } else {
//                        //Show error
//                        self.showAlertWithTitle("Error", message: Constants.ErrorMessages.Rewards)
//                    }
//                    
//                    LoadingView.hide()
//                }
//                
//            } else {
//                //Show errors
//                self.showAlertWithTitle("Error", message: Constants.ErrorMessages.Onboarding)
//            }
//            
//            LoadingView.hide()
//        }
    }
    
    /**
     Records that the user skipped this section of onboarding to the API
     
     - parameter section: section of onboarding to set "later" to
     */
    public func userSkippedOnboarding() {
//        debugPrint("Completing onboarding")
//        let user = CurrentState.sharedInstance.currentUser
//        ApiManager.sharedInstance.saveSectionOfOnboarding(self.onboardingSection, newStatus: .Later, id: user.id) { (_, error) -> Void in
//            if error == nil {
//                
//                //Show message and save status
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
//                    //Show message and save status
//                    SVProgressHUD.showSuccessWithStatus("Got it. You can always complete onboarding later by tapping on the settings gear on the profile page.")
//                }
//                switch self.onboardingSection {
//                case .Browse:
//                    CurrentState.sharedInstance.currentUser.onboardingBrowseStatus = OnboardingStatus.Later.rawValue
//                case .Discover:
//                    CurrentState.sharedInstance.currentUser.onboardingDiscoverStatus = OnboardingStatus.Later.rawValue
//                case .AddProduct:
//                    CurrentState.sharedInstance.currentUser.onboardingAddProductStatus = OnboardingStatus.Later.rawValue
//                case .Rewards:
//                    CurrentState.sharedInstance.currentUser.onboardingRewardsStatus = OnboardingStatus.Later.rawValue
//                case .Profile:
//                    CurrentState.sharedInstance.currentUser.onboardingProfileStatus = OnboardingStatus.Later.rawValue
//                }
//                
//            } else {
//                self.showAlertWithTitle("Error", message: Constants.ErrorMessages.Onboarding)
//            }
//        }
    }
    
    /**
     Sets up a blur view over the entire page
     
     - parameter globalView: global view of the app
     */
    private func setUpBlurViewWithAlpha(alpha: CGFloat, globalWindowView: UIView) -> UIView {
        let blur = self.createBlurView(alpha)
        self.currentBlurViews.append(blur)
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.alpha = 0
        globalWindowView.addSubview(blur)
        
        //0px from top, left, right, bottom
        globalWindowView.addConstraint(NSLayoutConstraint(item: blur, attribute: .Top, relatedBy: .Equal, toItem: globalWindowView, attribute: .Top, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: blur, attribute: .Left, relatedBy: .Equal, toItem: globalWindowView, attribute: .Left, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: blur, attribute: .Right, relatedBy: .Equal, toItem: globalWindowView, attribute: .Right, multiplier: 1, constant: 0))
        globalWindowView.addConstraint(NSLayoutConstraint(item: blur, attribute: .Bottom, relatedBy: .Equal, toItem: globalWindowView, attribute: .Bottom, multiplier: 1, constant: 0))
        
        return blur
    }
    
    /**
     Creates the view that is blurry
     
     - returns: blurred view
     */
    private func createBlurView(alpha: CGFloat = 0.8) -> UIView {
        let blur = UIView()
        blur.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(alpha)
        
        return blur
    }
}