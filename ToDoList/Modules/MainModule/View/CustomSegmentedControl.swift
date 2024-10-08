//
//  CustomSegmentedControl.swift
//  ToDoList
//
//  Created by Владислав Головачев on 06.09.2024.
//

import UIKit

final class CustomSegmentedControl: UISegmentedControl {
    //MARK: Properties
    private lazy var segmentLabels = {
        var array = [UILabel]()
        for index in 0...2 {
            array.append(constructLabel(forSegment: index))
        }
        return array
    }()
    
    //MARK: Inits
    init() {
        super.init(frame: CGRectZero)
        
        backgroundColor = MainViewConstants.Color.background
        setTitleTextAttributes([.foregroundColor: ColorConstants.notSelected, .font: SegmentConstants.font],
                                for: .normal)
        setTitleTextAttributes([.foregroundColor: ColorConstants.selected, .font: SegmentConstants.font],
                                for: .selected)
        
        for (index, title) in SegmentConstants.names.enumerated() {
            insertSegment(withTitle: title, at: index, animated: false)
            setWidth(SegmentConstants.width[index], forSegmentAt: index)
            setOffset(SegmentConstants.offset[index], forSegment: index)
        }
        selectedSegmentIndex = SegmentConstants.selectedIndex
        
        setBackgroundAndDividerImages()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        reselectSegment()
    }
}

//MARK: Public Functions
extension CustomSegmentedControl {
    func setRemindersAmount(_ amount: String, forSegment index: Int) {
        segmentLabels[index].text = amount
    }
}

//MARK: Private Functions
extension CustomSegmentedControl {
    private func reselectSegment() {
        segmentLabels.forEach {
            $0.backgroundColor = ColorConstants.notSelected
        }
        segmentLabels[selectedSegmentIndex].backgroundColor = ColorConstants.selected
    }
    
    private func addSubviews() {
        for label in segmentLabels {
            addSubview(label)
        }
    }
    
    private func setupConstraints() {
        for (index, label) in segmentLabels.enumerated() {
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let constant = labelLeadingConstant(forSegment: index)
            NSLayoutConstraint.activate([
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constant)
            ])
        }
    }
    
    private func constructLabel(forSegment index: Int) -> UILabel {
        let padding = SegmentConstants.Label.contentPadding
        let label = PaddingLabel(top: 0, 
                                 left: padding,
                                 bottom: 0,
                                 right: padding)

        label.layer.cornerRadius = SegmentConstants.Label.cornerRadius
        label.layer.masksToBounds = true
        
        switch index {
        case SegmentConstants.selectedIndex:
            label.backgroundColor = ColorConstants.selected
        default:
            label.backgroundColor = ColorConstants.notSelected
        }
        
        label.font = SegmentConstants.font
        label.textColor = ColorConstants.segmentLabelText
        
        return label
    }
    
    private func setOffset(_ offset: Double, forSegment index: Int) {
        var segmentType = UISegmentedControl.Segment.any
        let uiOffset = UIOffset(horizontal: offset, vertical: 0)
        
        switch index {
        case 0:
            segmentType = .left
        case 1:
            segmentType = .center
        case 2:
            segmentType = .right
        default: break
        }
        
        setContentPositionAdjustment(uiOffset, forSegmentType: segmentType, barMetrics: .default)
    }
    
    private func setBackgroundAndDividerImages() {
        let blankImage = UIImage.filled(with: MainViewConstants.Color.background)
        let separatorImage = UIImage.filled(with: ColorConstants.notSelected)
        
        setBackgroundImage(blankImage, for: .normal, barMetrics: .default)
        setDividerImage(blankImage, 
                        forLeftSegmentState: .normal,
                        rightSegmentState: .normal, 
                        barMetrics: .default)
        setDividerImage(separatorImage,
                        forLeftSegmentState: .selected,
                        rightSegmentState: .normal, 
                        barMetrics: .default)
        setDividerImage(separatorImage,
                        forLeftSegmentState: .selected,
                        rightSegmentState: .highlighted, 
                        barMetrics: .default)
        setDividerImage(separatorImage,
                        forLeftSegmentState: .normal,
                        rightSegmentState: .selected, 
                        barMetrics: .default)
        setDividerImage(separatorImage,
                        forLeftSegmentState: .highlighted,
                        rightSegmentState: .selected, 
                        barMetrics: .default)
    }
    
    private func labelLeadingConstant(forSegment index: Int) -> Double {
        let titleWidth = SegmentConstants.names[index].size(withAttributes: titleTextAttributes(for: .normal)).width
        let segmentWidth = SegmentConstants.width[index]
        let segmentTitleOffset = SegmentConstants.offset[index]
        
        var offset = (titleWidth + segmentWidth) / 2
        for i in 0..<index {
            offset += SegmentConstants.width[i]
        }
        offset += segmentTitleOffset + SegmentConstants.Label.padding
        
        ///For the second and third segments offset is more, because of DividerImages (each has CGSize(width: 1, height: 1)).
        ///So it needs to remember
        offset += Double(index)
        
        return offset
    }
}

//MARK: Local Constants
extension CustomSegmentedControl {
    private enum SegmentConstants {
        static let names = ["All", "Opened", "Closed"]
        static let selectedIndex = 0
        
        static let width: [Double] = [60, 110, 110]
        static let offset: [Double] = [-20, -10, -15]
        static let font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        enum Label {
            static let padding: Double = 6
            static let contentPadding: Double = 4
            static let cornerRadius: Double = 7
        }
    }
    private enum ColorConstants {
        static let selected = UIColor.systemBlue
        static let notSelected = UIColor.lightGray
        static let segmentLabelText = UIColor.white
    }
}
