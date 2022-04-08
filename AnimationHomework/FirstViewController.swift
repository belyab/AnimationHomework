//
//  FirstViewController.swift
//  AnimationHomework
//
//  Created by Эльмира Байгулова on 08.04.2022.
//

import UIKit

class FirstViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var transitioningView: UIView!
    @IBOutlet weak var toEventLabel: UILabel!
    
    //Dependencies
    var tapGesture: UITapGestureRecognizer!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTapGesture()
        configureTransitioningView()
    }
    
    // MARK: - Functions
    func configureTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(transitioningViewDidTap))
    }
    
    func configureTransitioningView() {
        transitioningView.layer.cornerRadius = 8.0
        transitioningView.clipsToBounds = true
        
        transitioningView.addGestureRecognizer(tapGesture)
    }
    
    // objc functions
    @objc func transitioningViewDidTap() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .fullScreen
        
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension FirstViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let fromViewController = presenting as? FirstViewController,
              let toViewController = presented as? EventViewController else {
                  return nil
              }
        
        return AnimatedTransitioning(fromViewController: fromViewController, toViewController: toViewController)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return nil
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
final class AnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    //Dependencies
    private let fromViewController: UIViewController
    private let toViewController: UIViewController
    private let duration: TimeInterval = 1.5
    
    // MARK: - Life cycle
    init(fromViewController: UIViewController, toViewController: UIViewController) {
        
        self.fromViewController = fromViewController
        self.toViewController = toViewController
    }
    
    // MARK: - Functions
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let toView = toViewController.view else {
            
            transitionContext.completeTransition(false)
            return
        }
        
        guard let firstViewController = fromViewController as? FirstViewController else {
                  
                  transitionContext.completeTransition(false)
                  return
              }
        
        toView.alpha = 0
        containerView.addSubview(toView)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic) {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                firstViewController.toEventLabel.alpha = 0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: self.duration - 0.2) {
                firstViewController.transitioningView.transform = CGAffineTransform(scaleX: 10, y: 10)
                toView.alpha = 1
            }
            
        } completion: { _ in
            
            transitionContext.completeTransition(true)
            firstViewController.transitioningView.transform = .identity
            firstViewController.toEventLabel.alpha = 1
            
            return
        }
    }
}



