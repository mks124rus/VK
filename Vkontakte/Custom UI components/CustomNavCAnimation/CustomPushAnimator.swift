//
//  CustomPushAnimator.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 18.03.2021.
//

import UIKit

final class CustomPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.8
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from) else {return}
        guard let destination = transitionContext.viewController(forKey: .to) else {return}
    
        transitionContext.containerView.addSubview(destination.view)
        destination.view.frame = source.view.frame


        destination.view.transform = CGAffineTransform(translationX: source.view.frame.width, y: 0)
        destination.view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2).translatedBy(x: 0, y: source.view.frame.height)
        
        
        UIView.animateKeyframes(withDuration: self.transitionDuration(using: transitionContext),
                                delay: 0,
                                options: .calculationModeCubicPaced,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.5,
                                                       relativeDuration: 0.3,
                                                       animations: {
                                                        source.view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2).translatedBy(x: 0, y: source.view.frame.height)
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 0,
                                                       relativeDuration: 0.6,
                                                       animations: {
                                                           destination.view.transform = .identity
                                    })
        }) { finished in
            if finished && !transitionContext.transitionWasCancelled {
                source.view.transform = .identity
            }
            transitionContext.completeTransition(finished && !transitionContext.transitionWasCancelled)
        }
    }
    
}
