//
//  SliderPathBetweenView.swift
//
//  Created by Oğuz Kuzu on 17.07.2023.
//

import SwiftUI
import UIComponents

public struct SliderPathBetweenView: View {
   @ObservedObject var slider: CustomSlider
   
   public var body: some View {
       Path { path in
           path.move(to: slider.lowHandle.currentLocation)
           path.addLine(to: slider.highHandle.currentLocation)
       }
       .stroke(Color.colorPrimaryBase, lineWidth: slider.lineWidth)
   }
}
