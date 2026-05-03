//
//  MiniMeWidgetBundle.swift
//  MiniMeWidget
//
//  Created by trubigideas on 5/3/26.
//

import WidgetKit
import SwiftUI

@main
struct MiniMeWidgetBundle: WidgetBundle {
    var body: some Widget {
        MiniMeWidget()
        MiniMeWidgetLiveActivity()
        // MiniMeWidgetControl() — v1.1
    }
}
