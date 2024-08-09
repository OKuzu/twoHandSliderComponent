//
//  TwoHandleRangeSlider.swift
//
//  Created by Oğuz Kuzu on 12.07.2023.
//

import Combine
import SwiftUI
import UIComponents

// SliderValue to restrict double range: 0.0 to 1.0
@propertyWrapper
public struct SliderValue {
    public var value: Double
    
    public init(wrappedValue: Double) {
        self.value = wrappedValue
    }
    
    public var wrappedValue: Double {
        get { value }
        set { value = min(max(0.0, newValue), 1.0) }
    }
}

public class SliderHandle: ObservableObject, Equatable {
    
    public static func == (lhs: SliderHandle, rhs: SliderHandle) -> Bool {
        lhs.dragLocation == rhs.dragLocation
    }
    
    // Slider Size
    public let sliderWidth: CGFloat
    public let sliderHeight: CGFloat
    
    // Slider Range
    public let sliderValueStart: Double
    public let sliderValueRange: Double
    
    // Slider Handle
    public var diameter: CGFloat = 40
    public var startLocation: CGPoint
    public var otherHandle: SliderHandle? = nil
    public let isLowHandle: Bool
    public var dragLocation: CGPoint
    
    // Current Value
    @Published public var currentPercentage: SliderValue
    
    // Slider Button Location
    @Published public var onDrag: Bool
    @Published public var currentLocation: CGPoint
        
    public init(sliderWidth: CGFloat, sliderHeight: CGFloat, sliderValueStart: Double, sliderValueEnd: Double, startPercentage: SliderValue, isLowHandle: Bool) {
        self.sliderWidth = sliderWidth
        self.sliderHeight = sliderHeight
        
        self.sliderValueStart = sliderValueStart
        self.sliderValueRange = sliderValueEnd - sliderValueStart
        
        let startLocation = CGPoint(x: (CGFloat(startPercentage.wrappedValue) / 1.0) * sliderWidth, y: sliderHeight / 2)
        
        self.startLocation = startLocation
        self.currentLocation = startLocation
        self.currentPercentage = startPercentage
        self.isLowHandle = isLowHandle
        self.dragLocation = CGPoint()
        
        self.onDrag = false
    }
    
    public func setOtherHandle(otherHandle: SliderHandle) {
        self.otherHandle = otherHandle
        
    }
    
    public lazy var sliderDragGesture: _EndedGesture<_ChangedGesture<DragGesture>> = DragGesture()
        .onChanged { value in
            self.onDrag = true
            
            self.dragLocation = value.location
            
            // Restrict possible drag area
            self.restrictSliderBtnLocation(self.dragLocation)
            
            // Get current value
            self.currentPercentage.wrappedValue = Double(self.currentLocation.x / self.sliderWidth)
            
        }.onEnded { _ in
            self.onDrag = false
        }
        
    public func restrictSliderBtnLocation(_ dragLocation: CGPoint) {
        // On Slider Width
        if dragLocation.x >= CGPoint.zero.x && dragLocation.x <= sliderWidth  {
            if isLowHandle ? (self.otherHandle?.currentLocation.x)! >= dragLocation.x : (self.otherHandle?.currentLocation.x)! <= dragLocation.x {
                calcSliderBtnLocation(dragLocation)
            }
        }
    }
    
    public func setSliderLocation(x: Double) {
        self.dragLocation.x = ((x - self.sliderValueStart) / sliderValueRange) * self.sliderWidth
        
        // Restrict possible drag area
        self.restrictSliderBtnLocation(self.dragLocation)
        
        // Get current value
        self.currentPercentage.wrappedValue = Double(self.currentLocation.x / self.sliderWidth)
    }
    
    public func calcSliderBtnLocation(_ dragLocation: CGPoint) {
        if dragLocation.y != sliderHeight / 2 {
            currentLocation = CGPoint(x: dragLocation.x, y: sliderHeight / 2)
        } else {
            currentLocation = dragLocation
        }
    }
    
    // Current Value
    public var currentValue: Double {
        return sliderValueStart + currentPercentage.wrappedValue * sliderValueRange
    }
}

public class CustomSlider: ObservableObject {
    
    // Slider Size
//    public let width: CGFloat
    public let width: CGFloat
    public let lineWidth: CGFloat = 2
    
    // Slider value range from valueStart to valueEnd
    public let valueStart: Double
    public let valueEnd: Double
    
    // Slider Handle
    @Published public var highHandle: SliderHandle
    @Published public var lowHandle: SliderHandle
    
    // Handle start percentage (also for starting point)
    @SliderValue public var highHandleStartPercentage = 1.0
    @SliderValue public var lowHandleStartPercentage = 0.0

    public var anyCancellableHigh: AnyCancellable?
    public var anyCancellableLow: AnyCancellable?
    
    public init(width: CGFloat = UIScreen.main.bounds.size.width - 44, start: Double, end: Double, lowCurrentValue: Double? = nil, highCurrentValue: Double? = nil) {
        valueStart = start
        valueEnd = end
        self.width = width
        
        if let lowCurrentValue, let highCurrentValue {
            _lowHandleStartPercentage = SliderValue(wrappedValue: ((lowCurrentValue - valueStart) / (valueEnd - valueStart)))
            _highHandleStartPercentage = SliderValue(wrappedValue: ((highCurrentValue - valueStart) / (valueEnd - valueStart)))
        }
       
        highHandle = SliderHandle(sliderWidth: width,
                                  sliderHeight: lineWidth,
                                  sliderValueStart: valueStart,
                                  sliderValueEnd: valueEnd,
                                  startPercentage: _highHandleStartPercentage,
                                  isLowHandle: false
                                )
        
        lowHandle = SliderHandle(sliderWidth: width,
                                  sliderHeight: lineWidth,
                                  sliderValueStart: valueStart,
                                  sliderValueEnd: valueEnd,
                                  startPercentage: _lowHandleStartPercentage,
                                  isLowHandle: true
                                )
        
        highHandle.setOtherHandle(otherHandle: lowHandle)
        lowHandle.setOtherHandle(otherHandle: highHandle)
        
        anyCancellableHigh = highHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        anyCancellableLow = lowHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
    }
    
    // Percentages between high and low handle
    public var percentagesBetween: String {
        return String(format: "%.00f", highHandle.currentPercentage.wrappedValue - lowHandle.currentPercentage.wrappedValue)
    }
    
    // Value between high and low handle
    public var valueBetween: String {
        return String(format: "%.0f", highHandle.currentValue - lowHandle.currentValue)
    }
}
