//
//  PaddingLabel.swift
//  ToDoList
//
//  Created by Владислав Головачев on 06.09.2024.
//

import UIKit

class PaddingLabel: UILabel {
    private var topInset: CGFloat = 0
    private var leftInset: CGFloat = 0
    private var bottomInset: CGFloat = 0
    private var rightInset: CGFloat = 0
    
    convenience init(top: CGFloat, 
                     left: CGFloat,
                     bottom: CGFloat, 
                     right: CGFloat) {
        self.init()
        self.topInset = top
        self.leftInset = left
        self.bottomInset = bottom
        self.rightInset = right
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset,
                                  bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
      get {
         var contentSize = super.intrinsicContentSize
         contentSize.height += topInset + bottomInset
         contentSize.width += leftInset + rightInset
         return contentSize
      }
    }
}
