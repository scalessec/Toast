//
//  Toast.swift
//  ToastTest
//
//  Created by FOODING on 17/1/122.
//  Copyright © 2017年 Noohle. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import ObjectiveC.runtime


// 枚举显示位置
public enum CSToastPosition {
    case Top
    case Center
    case Bottom
}



// keys for values associated with toast views
private var CSToastTimerKey             = "CSToastTimerKey"
private var CSToastPositionKey          = "CSToastPositionKey"
private var CSToastCompletionKey        = "CSToastCompletionKey"
private var CSToastDurationKey          = "CSToastDurationKey"

// keys for values associated with self
private var CSToastActiveKey            = "CSToastActiveKey"
private var CSToastActivityViewKey      = "CSToastActivityViewKey"
private var CSToastQueueKey             = "CSToastQueueKey"


public typealias CSToastCompletionBlock = (_ didTap: Bool) -> Void


extension UIView {
    
    private var cs_activeToasts: [UIView]? {
        get {
            
            return objc_getAssociatedObject(self, &CSToastActiveKey) as? [UIView] ?? [UIView]()
          
        }
        set {
            
            objc_setAssociatedObject(self, &CSToastActiveKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
        
    }
        
    
    private var cs_toastQueues: [UIView]? {
        
        get {
        
            return objc_getAssociatedObject(self, &CSToastQueueKey) as? [UIView] ?? [UIView]()
         
        }
        set {
            
            objc_setAssociatedObject(self, &CSToastQueueKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
        
    }

    
    //MARK: - Make Toast
    
    
    /**
     *  message 不可以nil，不可以是 “”
     */
    public func makeToast(message: String) {
        self.makeToast(message: message, duration: CSToastManager.defaultDuration, position: CSToastManager.defaultPosition, style: nil)
    }
    
    
    public func maketToast(message: String, duration: TimeInterval, position: CSToastPosition) {
        
        self.makeToast(message: message, duration: duration, position: position, style: nil)
        
    }
    
    
    
    
    public func makeToast(message: String, duration: TimeInterval, position: CSToastPosition, style: CSToastStyle?) {
        
        
        self.makeToast(message: message, duration: duration, position: position, title: nil, image: nil, style: style, completion: nil)
        
    }
   
    
    public func makeToast(message: String, 
                          duration: TimeInterval, 
                          position: CSToastPosition, 
                          title: String?, 
                          image: UIImage?,
                          style: CSToastStyle?,
                          completion: CSToastCompletionBlock?) {
        
        let view = self.viewForMessage(message, title: title, image: image, style: style)
        
        self.showToast(toast: view, duration: duration, position: position, completion: completion)
        
    }
    
    // MARK: - Show Toast
    public func showToast(toast: UIView) {
    
        
        self.showToast(toast: toast, duration: CSToastManager.defaultDuration, position: CSToastManager.defaultPosition, completion: nil)
        
    }
    /**
        1. 判断允许 queue
            1. 绑定当前toast的信息
            2. 添加toast 进 queue
        2. 不允许
            1. 显示toast
     
        3. 绑定 toast 和 completion 
     
     **/
   
    
    public func showToast(toast: UIView, duration: TimeInterval, position: CSToastPosition, completion: CSToastCompletionBlock?) {

        
        if ((CSToastManager.queueEnabled) && ((self.cs_activeToasts!.count) > 0)) {
            
            
            objc_setAssociatedObject(toast, &CSToastDurationKey, duration, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            objc_setAssociatedObject(toast, &CSToastPositionKey, position, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
            
            self.cs_toastQueues!.append(toast)
            
        } else {
            self.cs_showToast(toast: toast, duration: duration, position: position)
        }
        
        if let completion = completion {
            
            objc_setAssociatedObject(toast, &CSToastCompletionKey, completion, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
        
        
    }
    
    // MARK: - Hide Toast
    
    public func hideToasts() {
        
        for toast in self.cs_activeToasts! {
            
            self.hideToast(toast: toast)
            
        }
        
    }
    public func hideToast(toast: UIView) {
        
        if (self.cs_activeToasts!.contains(toast)) {
            let timer = objc_getAssociatedObject(toast, &CSToastTimerKey) as! Timer
            
            timer.invalidate()
            
            self.cs_hideToast(toast: toast)
        }
        
       
    }
    
    // MARK: - Private Show/Hide Toast
    private func cs_showToast(toast: UIView,
                              duration: TimeInterval,
                              position: CSToastPosition) {
        
        
        toast.center = self.cs_centerPointForPositon(position, toast: toast)
        toast.alpha = 0.0
        
        if CSToastManager.tapToDismissEnabled {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(cs_handleToastTapped(gesture:)))
            
            toast.addGestureRecognizer(gesture)
            
            toast.isUserInteractionEnabled = true
            toast.isExclusiveTouch = true
        }
        
        self.cs_activeToasts!.append(toast)

        
        self.addSubview(toast)
        
        
        
        
        UIView.animate(withDuration: CSToastManager.sharedStyle.fadeDuration , 
                       delay: 0.0, 
                       options: [.curveEaseInOut, .allowUserInteraction], 
                       animations: { 
        
                        toast.alpha = 1.0
                        
        }) { (finished) in
            
            let timer = Timer(timeInterval: duration, target: self, selector: #selector(self.cs_toastTimerDidFinish(timer:)), userInfo: toast, repeats: false)
            
            RunLoop.main.add(timer, forMode: .commonModes)
            
            objc_setAssociatedObject(toast, &CSToastTimerKey, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }

    }
    
    
    private func cs_hideToast(toast: UIView) {
        
        self.cs_hideToast(toast: toast, fromTap: false)
        
        
        
    }
    private func cs_hideToast(toast: UIView, fromTap: Bool) {
        
        UIView.animate(withDuration: CSToastManager.sharedStyle.fadeDuration, 
                       delay: 0.0, 
                       options: [.curveEaseInOut, .beginFromCurrentState], 
                       animations: { 
           
                        toast.alpha = 0.0            
        
        }) { (finish) in


            if let index = self.cs_activeToasts?.index(of: toast) {
                
                 self.cs_activeToasts?.remove(at: index)
            }
           

            toast.removeFromSuperview()
            
            
            if let completion = objc_getAssociatedObject(toast, &CSToastCompletionKey) as? CSToastCompletionBlock {
                completion(fromTap)
            }
            
            
            guard self.cs_toastQueues != nil  else {
            
                return
            
            }
            
            
            if self.cs_toastQueues!.count > 0 {
                
                let nextToast = self.cs_toastQueues!.first!

                self.cs_toastQueues!.removeFirst()
                    
                let duration = objc_getAssociatedObject(nextToast, &CSToastDurationKey) as! TimeInterval
                
                let position = objc_getAssociatedObject(nextToast, &CSToastPositionKey) as! CSToastPosition
                
                self.cs_showToast(toast: nextToast, duration: duration, position: position)
                
            
            }
            
          
            
        }
        
    }
    
    //MARK: - View Construction
    private func viewForMessage(_ message: String?, title: String?, image: UIImage?, style: CSToastStyle?) -> UIView {
        
        
        let style = style ?? CSToastManager.sharedStyle
  
        var messageLabel: UILabel?
        var titleLab: UILabel? 
        var imgView: UIImageView?
        
        // 最外层view
        let wrapperView = UIView()
        
        wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        wrapperView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            
            wrapperView.layer.shadowOpacity = style.shadowOpacity
            
            wrapperView.layer.shadowRadius = style.shadowRadius
            
            wrapperView.layer.shadowOffset = style.shadowOffset
        }
        
        
        
        wrapperView.backgroundColor = style.backgroundColor
        
    
        if let image = image {
            imgView = UIImageView(image: image)
            imgView?.contentMode = .scaleAspectFit
            imgView?.frame = CGRect(x: style.horizontalPadding, y: style.verticalPadding, width: style.imageSize.width, height: style.imageSize.height)
                        
        }
        
        var imgRect = CGRect.zero
        
        if let imgView = imgView {
            imgRect.origin.x = style.horizontalPadding
            imgRect.origin.y = style.verticalPadding
            imgRect.size.width = imgView.bounds.size.width
            imgRect.size.height = imgView.bounds.size.height
        }
             
        if let title = title {
            titleLab = UILabel()
            
            titleLab?.numberOfLines = style.titleNumberOfLines
            titleLab?.font = style.titleFont
            titleLab?.textAlignment = style.titleAlignment
            titleLab?.textColor = style.titleColor
            titleLab?.lineBreakMode = .byTruncatingTail
            titleLab?.backgroundColor = UIColor.clear
            titleLab?.alpha = 1.0
            titleLab?.text = title
            
            let maxSizeTitle = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - imgRect.size.width, height: self.bounds.size.height * style.maxHeightPercentage)
            
            var expectedSizeTitle = titleLab?.sizeThatFits(maxSizeTitle)
            
            expectedSizeTitle = CGSize(width: min(maxSizeTitle.width, (expectedSizeTitle?.width)!), height: min(maxSizeTitle.height, (expectedSizeTitle?.height)!))
            
            titleLab?.frame = CGRect(x: 0.0, y: 0.0, width: (expectedSizeTitle?.width)!, height: (expectedSizeTitle?.height)!)
        }
        
        if let message = message {
            messageLabel = UILabel()
            messageLabel?.numberOfLines = style.messageNumberOfLines
            messageLabel?.font = style.messageFont
            messageLabel?.textAlignment = style.messageAlignment
            messageLabel?.lineBreakMode = .byTruncatingTail
            messageLabel?.textColor = style.messageColor
            messageLabel?.backgroundColor = UIColor.clear
            messageLabel?.alpha = 1.0
            messageLabel?.text = message
            
            let maxSizeMessage = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - imgRect.size.width, height: self.bounds.size.height * style.maxHeightPercentage)
            var expectedSizeMessage = messageLabel?.sizeThatFits(maxSizeMessage)
            // UILabel can return a size larger than the max size when the number of lines is 1
            expectedSizeMessage = CGSize(width: min(maxSizeMessage.width, (expectedSizeMessage?.width)!), height: min(maxSizeMessage.height, (expectedSizeMessage?.height)!))
            messageLabel?.frame = CGRect(x: 0.0, y: 0.0, width: (expectedSizeMessage?.width)!, height: (expectedSizeMessage?.height)!)
        }
        
        var titleRect = CGRect.zero
        
        if let titleLab = titleLab {
            titleRect.origin.x = imgRect.origin.x + imgRect.size.width + style.horizontalPadding
            titleRect.origin.y = style.verticalPadding
            titleRect.size.width = titleLab.bounds.size.width
            titleRect.size.height = titleLab.bounds.size.height
        }
        
        var  messageRect = CGRect.zero
        
        if let messageLabel = messageLabel {
            messageRect.origin.x = imgRect.origin.x + imgRect.size.width + style.horizontalPadding
            messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding
            messageRect.size.width = messageLabel.bounds.size.width
            messageRect.size.height = messageLabel.bounds.size.height
        }
        
        let longerWidth = max(titleRect.size.width, messageRect.size.width)
        let longerX = max(titleRect.origin.x, messageRect.origin.x)
        
        // Wrapper width uses the longerWidth or the image width, whatever is larger. Same logic applies to the wrapper height.
        let wrapperWidth = max((imgRect.size.width + (style.horizontalPadding * 2.0)), (longerX + longerWidth + style.horizontalPadding))
        let wrapperHeight = max((messageRect.origin.y + messageRect.size.height + style.verticalPadding), (imgRect.size.height + (style.verticalPadding * 2.0)))
        
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        
        if let titleLabel = titleLab {
            titleLabel.frame = titleRect
            wrapperView.addSubview(titleLabel)
        }
        
        if let messageLabel = messageLabel {
            messageLabel.frame = messageRect
            wrapperView.addSubview(messageLabel)
        }
        
        if let imageView = imgView {
            wrapperView.addSubview(imageView)
        }
        
        return wrapperView
                
    }
    
    //MARK: - Event
    @objc private func cs_toastTimerDidFinish(timer: Timer) {
        
        self.cs_hideToast(toast: timer.userInfo as! UIView)
        
        
    }
    
    @objc private func cs_handleToastTapped(gesture: UITapGestureRecognizer) {
        
        let timer = objc_getAssociatedObject(gesture.view, &CSToastTimerKey) as? Timer
        
        if let timer = timer {
            timer.invalidate()            
        }
        self.cs_hideToast(toast: gesture.view!, fromTap: true)
    }
    
    //MARK: - Activity 
    
    public func makeToastActivity() {
        self.makeToastActivity(position: .Center)
    }
    public func makeToastActivity(position: CSToastPosition) {
        
        let existingActivityView = objc_getAssociatedObject(self, &CSToastActivityViewKey) as? UIView
        
        guard existingActivityView == nil else {
            return
        }
        
        let style = CSToastManager.sharedStyle
        
        let activityView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: style.activitySize.width, height: style.activitySize.height))
        
        activityView.center = self.cs_centerPointForPositon(position, toast: activityView)
        
        activityView.backgroundColor = style.backgroundColor
        activityView.alpha = 0.0
        activityView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        activityView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            activityView.layer.shadowColor = style.shadowColor.cgColor
            activityView.layer.shadowOpacity = style.shadowOpacity
            activityView.layer.shadowRadius = style.shadowRadius
            activityView.layer.shadowOffset = style.shadowOffset
            
        }
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge) as UIActivityIndicatorView
        activityIndicatorView.center = CGPoint(x: activityView.bounds.size.width/2, y: activityView.bounds.size.height/2)
        
        activityView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        objc_setAssociatedObject(self, &CSToastActivityViewKey, activityView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        self.addSubview(activityView)
        
        UIView.animate(withDuration: style.fadeDuration, delay: 0.0, options: [.curveEaseOut], animations: { 
            activityView.alpha = 1.0
        }) { (finished) in
            
            self.hideToastActivity()
        }
        
        
        
        
    }
    
    public func hideToastActivity() {
        
        let existingActivityView = objc_getAssociatedObject(self, &CSToastActivityViewKey) as? UIView
        
        if existingActivityView != nil {
            UIView.animate(withDuration: CSToastManager.sharedStyle.fadeDuration, 
                           delay: 0.0, 
                           options: [.curveEaseIn, .beginFromCurrentState], 
                           animations: { 
                            existingActivityView?.alpha = 0.0
            }, 
                           completion: { (finished) in
                            existingActivityView?.removeFromSuperview()
                            objc_setAssociatedObject(self, &CSToastActivityViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            })
        }
        
        
        
    }
    
    //MARK: - Helper
    
    private func cs_centerPointForPositon(_ position: CSToastPosition, toast: UIView) -> CGPoint {
        
        let style = CSToastManager.sharedStyle
        
        let x = self.bounds.size.width/2
        var y = self.bounds.size.height/2
        
        
        
        switch position {
        case .Bottom:
            
            y = self.bounds.size.height - toast.frame.size.height/2 - style.verticalPadding
            
            return CGPoint(x: x, y: y)
        case .Center:
            return CGPoint(x: x, y: y)
        case .Top:
            
            y = toast.frame.size.height/2 + style.verticalPadding
            return CGPoint(x: x, y: y)
        
        }
        
    }
    
    
   
    
}


public class CSToastStyle {
    
    
    
    var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    
    var titleColor: UIColor = UIColor.white
    
    var messageColor: UIColor = UIColor.white
    
    var maxWidthPercentage: CGFloat = 0.8
    
    var maxHeightPercentage: CGFloat = 0.8 
    
    var horizontalPadding: CGFloat = 10.0
    
    var verticalPadding: CGFloat = 10.0
    
    var cornerRadius: CGFloat = 10.0
    
    var titleFont: UIFont = UIFont.boldSystemFont(ofSize: 16.0)
    
    var messageFont: UIFont = UIFont.systemFont(ofSize: 16.0)
    
    var titleAlignment: NSTextAlignment = NSTextAlignment.left
    
    var messageAlignment: NSTextAlignment = .left
    
    var titleNumberOfLines: Int = 0
    
    var messageNumberOfLines: Int = 0
    
    var displayShadow: Bool = false
    
    var shadowOpacity: Float = 0.8
    
    var shadowColor: UIColor = UIColor.black
    
    var shadowRadius: CGFloat = 6.0
    
    var shadowOffset: CGSize = CGSize(width: 4.0, height: 4.0)
    
    var imageSize: CGSize = CGSize(width: 80.0, height: 80.0)
    
    var activitySize: CGSize = CGSize(width: 100.0, height: 100.0)
    
    var fadeDuration: TimeInterval = 0.2
    
    
    
    init() {}
    
    func setMaxWidthPercentage(width: Float) {
        maxWidthPercentage = CGFloat(max(min(width, 1.0), Float(0.0)))
    }
    
    func setMaxHeightPercentage(height: Float) {
        maxHeightPercentage = CGFloat(max(min(height, 1.0), Float(0.0)))
                
    }

    
    
}


 
public class CSToastManager {
    
    static var sharedStyle: CSToastStyle = CSToastStyle()
    
    static var tapToDismissEnabled: Bool = true
    
    static var queueEnabled: Bool = true
    
    static var defaultDuration: TimeInterval = 3.0
    
    static var defaultPosition: CSToastPosition = .Bottom
    
    
    public static let shared = CSToastManager()
    
    
    init() {
        
    }
    
}



