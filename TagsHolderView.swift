//
//  TagsHolderView.swift
//  Parentoo
//
//  Created by coyote on 10/12/15.
//  Copyright © 2015 coyote. All rights reserved.
//

import UIKit
protocol MinimumTagsAllowed {
    func getMinimumTagsAllowed()->Int
    func notifyForMinimumTagsReached()
    func notifyForMinimumTagsUnReached()
}
@IBDesignable
class TagsHolderView: UIScrollView {
    let marginX:CGFloat = 8
    let marginY:CGFloat = 8
    let viewsHeight:CGFloat = 35
    var calculatedXMargin:CGFloat = 0
    var calculatedYMargin:CGFloat = 4
    var tags = [UIButton]()
    var selectedTags = [UIButton]()
    var selectedTagsValue = [String]()
    var initialContentSize:CGFloat = 0.0
    var minimumTagsAllowed = 3
    var minimumTagsAllowedDelegate : MinimumTagsAllowed? {
        didSet{
            if let minimumTagsAllowedNewValue = minimumTagsAllowedDelegate{
                minimumTagsAllowed = minimumTagsAllowedNewValue.getMinimumTagsAllowed()
            }
        }
    }
    var tagsFont:UIFont = UIFont(name: "SourceSansPro-Regular", size: 15)!
    @IBInspectable var tagsFontSize:CGFloat = 15.0 {
        didSet{
            tagsFont = UIFont(name: "SourceSansPro-Regular", size: tagsFontSize)!
        }
    }
    @IBInspectable var tagViewBorderWidth:CGFloat = 1.0
    @IBInspectable var tagViewBorderColor:UIColor = UIColor.whiteColor()
    @IBInspectable var tagsTextColor:UIColor = UIColor.whiteColor()
    @IBInspectable var tagsBackgroundColor:UIColor = UIColor.brownColor()
    @IBInspectable var tagSelectedUIImage:UIImage = UIImage()
    @IBInspectable var tagUnSelectedUIImage:UIImage = UIImage()
    @IBInspectable var tagsSelectedBackgroundColor : UIColor = UIColor.blueColor()
    
    //Initialisation
    convenience init(){
        self.init(frame : CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height))
    }
    override init(frame: CGRect) {
        tagsTextColor = UIColor.whiteColor()
        tagsBackgroundColor = UIColor.brownColor()
        tagSelectedUIImage = UIImage()
        tagUnSelectedUIImage = UIImage()
        super.init(frame: frame)
        setupTagHolderView()
    }

    required init(coder aDecoder: NSCoder) {
        tagsTextColor = UIColor.whiteColor()
        tagsBackgroundColor = UIColor.brownColor()
        tagSelectedUIImage = UIImage()
        tagUnSelectedUIImage = UIImage()
        super.init(coder: aDecoder)!
        setupTagHolderView()
    }
    func setupTagHolderView(){
        self.clipsToBounds = true
        self.initialContentSize = self.contentSize.height
    }
    func removeAllTags(){
        selectedTags.removeAll()
        self.subviews.forEach { (view) -> () in
            if(view is UIButton){
                view.removeFromSuperview()
            }
        }
        self.contentSize = CGSize(width: self.frame.width, height: initialContentSize)
    }
    func addTag(tag:NSString){
        let attributes = [
            NSFontAttributeName : tagsFont]
        let stringSize = tag.sizeWithAttributes(attributes)
        if((calculatedXMargin + stringSize.width + 48) > self.frame.width){
            //View cannot fit in width do \n
            calculatedYMargin += (marginY + viewsHeight)
            calculatedXMargin = marginX
        }else{
            calculatedXMargin += marginX
        }
        let tagView = UIButton(frame: CGRect(x: calculatedXMargin, y: calculatedYMargin, width: stringSize.width + 40, height: viewsHeight))
        tagView.layer.borderWidth = tagViewBorderWidth
        tagView.layer.borderColor = tagViewBorderColor.CGColor
        
        tagView.setUpAsTag(title: tag as String, image: tagUnSelectedUIImage, spacing: 5, bgColor: tagsBackgroundColor, textFont: tagsFont, textColor: tagsTextColor)
        tagView.addTarget(self, action: Selector("toggleTag:"), forControlEvents:.TouchUpInside)
        self.tags.append(tagView)
        tagView.alpha = 0
        self.addSubview(tagView)
        UIView.animateWithDuration(0.5, animations: {
            tagView.alpha = 1
        })
        calculatedXMargin += tagView.frame.width
        self.contentSize = CGSize(width: self.frame.width, height: calculatedYMargin + 35)
    }
    
    func addSelectedAnimationToView(viewToAnimate: UIView) {
        let easeInTiming = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        let easeOutTiming = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let labelScaleXAnimation = CAKeyframeAnimation(keyPath: "transform.scale.x")
        labelScaleXAnimation.duration = 0.200
        labelScaleXAnimation.values = [1.000 as Float, 1.050 as Float, 1.000 as Float]
        labelScaleXAnimation.keyTimes = [0.000 as Float, 0.500 as Float, 1.000 as Float]
        labelScaleXAnimation.timingFunctions = [easeOutTiming, easeInTiming]
        viewToAnimate.layer.addAnimation(labelScaleXAnimation, forKey:"selected_ScaleX")
        
        let labelScaleYAnimation = CAKeyframeAnimation(keyPath: "transform.scale.y")
        labelScaleYAnimation.duration = 0.200
        labelScaleYAnimation.values = [1.000 as Float, 1.050 as Float, 1.000 as Float]
        labelScaleYAnimation.keyTimes = [0.000 as Float, 0.500 as Float, 1.000 as Float]
        labelScaleYAnimation.timingFunctions = [easeOutTiming, easeInTiming]
        viewToAnimate.layer.addAnimation(labelScaleYAnimation, forKey:"selected_ScaleY")
    }
    func addUnselectedAnimationToView(viewToAnimate: UIView) {
        let easeInTiming = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        let easeOutTiming = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let labelScaleXAnimation = CAKeyframeAnimation(keyPath: "transform.scale.x")
        labelScaleXAnimation.duration = 0.200
        labelScaleXAnimation.values = [1.000 as Float, 0.950 as Float, 1.000 as Float]
        labelScaleXAnimation.keyTimes = [0.000 as Float, 0.500 as Float, 1.000 as Float]
        labelScaleXAnimation.timingFunctions = [easeOutTiming, easeInTiming]
        viewToAnimate.layer.addAnimation(labelScaleXAnimation, forKey:"unselected_ScaleX")
        
        let labelScaleYAnimation = CAKeyframeAnimation(keyPath: "transform.scale.y")
        labelScaleYAnimation.duration = 0.200
        labelScaleYAnimation.values = [1.000 as Float, 0.950 as Float, 1.000 as Float]
        labelScaleYAnimation.keyTimes = [0.000 as Float, 0.500 as Float, 1.000 as Float]
        labelScaleYAnimation.timingFunctions = [easeOutTiming, easeInTiming]
        viewToAnimate.layer.addAnimation(labelScaleYAnimation, forKey:"unselected_ScaleY")
    }
    func toggleTag(sender:UIButton){
        
        if(selectedTags.contains(sender)){
            print("untag")
            addUnselectedAnimationToView(sender)
            selectedTags.removeAtIndex(selectedTags.indexOf(sender)!)
            selectedTagsValue.removeAtIndex(selectedTagsValue.indexOf((sender.titleLabel?.text)!)!)
            sender.backgroundColor = tagsBackgroundColor
            sender.setImage(tagUnSelectedUIImage, forState: .Normal)
            if(selectedTags.count < minimumTagsAllowed){
                if let delegateToNotif = minimumTagsAllowedDelegate{
                    delegateToNotif.notifyForMinimumTagsUnReached()
                }
            }
        }else{
            print("tag")
            addSelectedAnimationToView(sender)
            selectedTags.append(sender)
            selectedTagsValue.append((sender.titleLabel?.text)!)
            sender.backgroundColor = tagsSelectedBackgroundColor
            sender.setImage(tagSelectedUIImage, forState: .Normal)
            if(selectedTags.count >= minimumTagsAllowed){
                if let delegateToNotif = minimumTagsAllowedDelegate{
                    delegateToNotif.notifyForMinimumTagsReached()
                }
            }
        }
    }

}
