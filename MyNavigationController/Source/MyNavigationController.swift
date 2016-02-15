//
//  NavigationController.swift
//  TestSwift
//
//  Created by 张九州 on 16/2/15.
//  Copyright © 2016年 admin. All rights reserved.
//
//  带有自定义切换效果的NavigationController，支持手势返回

import UIKit

class MyNavigationController: UINavigationController, UINavigationControllerDelegate {

    let gestureRecognizder = UIScreenEdgePanGestureRecognizer()
    var flag:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        gestureRecognizder.edges = .Left
        gestureRecognizder.addTarget(self, action: Selector("handleGesture:"))
        view.addGestureRecognizer(gestureRecognizder)
    }

    func handleGesture(let g:UIGestureRecognizer) {
        switch g.state {
        case .Began:
            flag = true
            popViewControllerAnimated(true)

        default:
            flag = false
            break
        }
    }

    // MARK: UINavigationControllerDelegate

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .Push {
            return PushAnimationController()
        } else {
            return PopAnimationController()
        }
    }

    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if flag {
            return InteractiveAnimationController(gestureRecognizer: gestureRecognizder)
        }
        return nil
    }

    // MARK: Private Classes

    class PushAnimationController : NSObject, UIViewControllerAnimatedTransitioning {

        func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
            return 0.5
        }

        func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let container = transitionContext.containerView()!

            toView.layer.shadowPath = UIBezierPath(rect: fromView.bounds).CGPath
            toView.layer.shadowColor = UIColor.grayColor().CGColor
            toView.layer.shadowRadius = 4
            toView.layer.shadowOpacity = 0.6

            container.addSubview(toView)
            toView.bounds = fromView.bounds
            toView.transform = CGAffineTransformMakeTranslation(toView.bounds.width, 0)
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
                fromView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                toView.transform = CGAffineTransformIdentity
                }) { (_) -> Void in
                    toView.layer.shadowOpacity = 0

                    let wasCanceled = transitionContext.transitionWasCancelled()
                    if wasCanceled {
                        toView.removeFromSuperview()
                    }
                    transitionContext.completeTransition(!wasCanceled)
            };
        }

    }

    class PopAnimationController : NSObject, UIViewControllerAnimatedTransitioning {

        func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
            return 0.5
        }

        func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let container = transitionContext.containerView()!

            fromView.layer.shadowOpacity = 0.6

            container.insertSubview(toView, belowSubview: fromView)
            toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
                fromView.transform = CGAffineTransformMakeTranslation(fromView.bounds.width, 0)
                toView.transform = CGAffineTransformIdentity
                }) { (_) -> Void in
                    fromView.layer.shadowOpacity = 0

                    let wasCanceled = transitionContext.transitionWasCancelled()
                    if wasCanceled {
                        toView.removeFromSuperview()
                    }
                    transitionContext.completeTransition(!wasCanceled)
            }
        }

    }

    class InteractiveAnimationController : UIPercentDrivenInteractiveTransition {

        var gestureRecognizer:UIScreenEdgePanGestureRecognizer
        var transitionContext:UIViewControllerContextTransitioning?

        init(gestureRecognizer:UIScreenEdgePanGestureRecognizer) {
            self.gestureRecognizer = gestureRecognizer

            super.init()
            gestureRecognizer.addTarget(self, action: Selector("handleGesture"))
        }

        override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
            self.transitionContext = transitionContext

            super.startInteractiveTransition(transitionContext)
        }

        func handleGesture() {
            switch gestureRecognizer.state {
            case .Began:
                break
            case .Changed:
                updateInteractiveTransition(percentForGesture())
            case .Ended:
                if self.percentForGesture() > 0.5 {
                    finishInteractiveTransition()
                } else {
                    cancelInteractiveTransition()
                }
                break
            default:
                cancelInteractiveTransition()
            }
        }
        
        func percentForGesture() -> CGFloat {
            let container = transitionContext!.containerView()!
            let point = gestureRecognizer.translationInView(container)
            return point.x / container.frame.width
        }
        
    }

}

