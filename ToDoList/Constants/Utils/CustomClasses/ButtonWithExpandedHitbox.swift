//
//  ButtonWithExpandedHitbox.swift
//  ToDoList
//
//  Created by Владислав Головачев on 04.09.2024.
//

import UIKit

final class ButtonWithExpandedHitbox: UIButton {
    override func point(inside point: CGPoint,
                        with event: UIEvent?) -> Bool {
        return bounds
            .insetBy(dx: -10, dy: -10)
            .contains(point)
    }
}
