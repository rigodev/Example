//
//  OverlayView.swift
//  OPPU
//
//  Created by rigodev on 06.06.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import UIKit

final class OverlayView: UIView {
    private let backgroundAlpha: CGFloat = 0.6
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(backgroundAlpha)
    }
}
