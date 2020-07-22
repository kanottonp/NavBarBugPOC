//
//  ViewController.swift
//  NavBarBugPOC
//
//  Created by Athipat Nampetch on 22/7/2563 BE.
//  Copyright © 2563 Athipat Nampetch. All rights reserved.
//

import UIKit


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    static var count = 1
    
    private var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    private var panGestureRecognizer: UIPanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Hello \(ViewController.count)"
        ViewController.count += 1
    }
    
    @IBAction func onTouch(_ sender: Any) {
        guard let newVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") else {
            return
        }
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    private func addGesture() {
        guard panGestureRecognizer == nil else {
            return
        }
        guard self.navigationController?.viewControllers.count > 1 else {
            return
        }
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        panGestureRecognizer.cancelsTouchesInView = true;
        panGestureRecognizer.delaysTouchesBegan = true;
        panGestureRecognizer.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(panGestureRecognizer)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = panGestureRecognizer as? UIGestureRecognizerDelegate
        
    }
    
    @objc private func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        let percent = max(panGesture.translation(in: view).x, 0) / view.frame.width
        switch panGesture.state {
            
        case .began:
            navigationController?.delegate = self
            if panGesture.velocity(in: view).x > 0 {
                _ = navigationController?.popViewController(animated: true)
            }
        case .changed:
            if let percentDrivenInteractiveTransition = percentDrivenInteractiveTransition {
                percentDrivenInteractiveTransition.update(percent)
            }
            
        case .ended:
            let velocity = panGesture.velocity(in: view).x
            // Continue if drag more than 50% of screen width or velocity is higher than 300
            if let percentDrivenInteractiveTransition = percentDrivenInteractiveTransition {
                if percent > 0.5 || velocity > 300 {
                    percentDrivenInteractiveTransition.finish()
                } else {
                    percentDrivenInteractiveTransition.cancel()
                }
            }
            
        case .cancelled, .failed:
            percentDrivenInteractiveTransition.cancel()
            
        default:
            break
        }
    }
    
}

extension ViewController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideAnimatedTransitioning()
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        navigationController.delegate = nil
        
        if panGestureRecognizer.state == .began && panGestureRecognizer.velocity(in: view).x > 0 {
            percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            percentDrivenInteractiveTransition.completionCurve = .easeInOut
        } else {
            percentDrivenInteractiveTransition = nil
        }
        
        return percentDrivenInteractiveTransition
    }
}



