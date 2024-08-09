//
//  SliderHandleView.swift
//
//  Created by Oğuz Kuzu on 17.07.2023.
//

import SwiftUI
import UIComponents

public struct SliderHandleView: View {
   @ObservedObject var handle: SliderHandle
   
    public var body: some View {
       ZStack {
           Circle()
               .frame(width: 16, height: 16)
               .foregroundColor(.colorPrimaryBase)
               .contentShape(Rectangle())
               .position(x: handle.currentLocation.x, y: handle.currentLocation.y)
               .zIndex(1)
           Circle()
               .frame(width: 24, height: 24)
               .foregroundColor(.customWhite)
               .contentShape(Rectangle())
               .position(x: handle.currentLocation.x, y: handle.currentLocation.y)
       }
   }
}
