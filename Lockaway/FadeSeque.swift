//
//  FadeSeque.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa

class FadeSegue: NSStoryboardSegue {
    
    override public func perform() {
        (self.sourceController as! NSViewController).presentViewController(self.destinationController as! NSViewController,
                                                                           animator: FadeTransitionAnimator())
    }
}

fileprivate class FadeTransitionAnimator: NSObject, NSViewControllerPresentationAnimator {
    
    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        viewController.view.wantsLayer = true
        viewController.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        viewController.view.alphaValue = 0
        fromViewController.view.addSubview(viewController.view)
        viewController.view.frame = fromViewController.view.frame
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.75
            viewController.view.animator().alphaValue = 1
        }, completionHandler: nil)
    }

    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        viewController.view.wantsLayer = true
        viewController.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.75
            viewController.view.animator().alphaValue = 0
        }, completionHandler: {
            viewController.view.removeFromSuperview()
        })
    }
    
}
