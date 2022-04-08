//
//  ViewController.swift
//  AnimationHomework
//
//  Created by Эльмира Байгулова on 08.04.2022.
//

import UIKit

enum Condition {
    case open
    case closed
    
    var opposite: Condition {
        return self == .open ? .closed : .open
    }
}

class EventViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var eventsView: UIView!
    @IBOutlet weak var eventsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventsTitle: UILabel!
    @IBOutlet weak var titleEventsPositionConstarint: NSLayoutConstraint!
    @IBOutlet weak var blurView: UIVisualEffectView!

    //Dependencies
    var runningAnimators: [UIViewPropertyAnimator] = []
    var condition: Condition = .closed
    var viewOffset: CGFloat = 520
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    // MARK: - Functions
    func animate(to condition: Condition, duration: TimeInterval) {
        guard runningAnimators.isEmpty else { return }

        let basicAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: nil)

        basicAnimator.addAnimations {
            switch condition {
            case .open:
                self.eventsBottomConstraint.constant = self.viewOffset
            case .closed:
                self.eventsBottomConstraint.constant = 0
            }
            self.view.layoutIfNeeded()
        }

        basicAnimator.addAnimations {
            switch condition {
            case .open:
                self.titleEventsPositionConstarint.constant = 130
                self.eventsTitle.transform = CGAffineTransform(scaleX: 1, y: 1)
            case .closed:
                self.titleEventsPositionConstarint.constant = 52
                self.eventsTitle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
            self.view.layoutIfNeeded()
        }

        let blurAnimator = UIViewPropertyAnimator(
            duration: duration,
            controlPoint1: CGPoint(x: 0.5, y: 0.5),
            controlPoint2: CGPoint(x: 0.5, y: 0.5)) {
            switch condition {
            case .open:
                self.blurView.effect = UIBlurEffect(style: .light)
            case .closed:
                self.blurView.effect = nil
            }
        }
        blurAnimator.scrubsLinearly = false


        basicAnimator.addCompletion { position in
            self.runningAnimators.removeAll()
            self.condition = self.condition.opposite
        }
        
        runningAnimators.append(basicAnimator)
        runningAnimators.append(blurAnimator)
    }
    
    func setupViews() {

        self.eventsBottomConstraint.constant = 0
        self.eventsTitle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.blurView.effect = nil
        self.blurView.isHidden = false
        self.view.layoutIfNeeded()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onDrag(_:)))
        self.eventsView.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        self.eventsView.addGestureRecognizer(tapGesture)

    }

    // objc functions
    @objc func onDrag(_ gesture: UIPanGestureRecognizer) {

        switch gesture.state {
        case .began:

            animate(to: condition.opposite, duration: 0.4)
        case .changed:

            let translation = gesture.translation(in: eventsView)
            let fraction = abs(translation.y / viewOffset)

            runningAnimators.forEach { animator in
                animator.fractionComplete = fraction
            }
        case .ended:

            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
        default:
            break
        }

    }

    @objc func onTap(_ gesture: UITapGestureRecognizer) {

        animate(to: condition.opposite, duration: 0.4)
        runningAnimators.forEach { $0.startAnimation() }

    }
}

