//
//  TwoHandSliderViewComponent.swift
//
//  Created by Oğuz Kuzu on 17.07.2023.
//

import SwiftUI
import UIComponents

/// THIS VIEW SHOULD BE USED IF YOU NEED TO USE TWO-HANDED SLIDER

public enum TwoHandSliderType {
    case time
    case number
    case duration
}

public struct TwoHandSliderViewComponent: View {
    @ObservedObject var slider: CustomSlider
    @State var lowCurrentValueText: String
    @State var highCurrentValueText: String
    let onChangeAction: (String, String) -> Void
    let width: CGFloat
    var sliderType: TwoHandSliderType?
    var isInputTextsEditable: Bool = true
    @Injected(\.localizer) private var localizer: Localizer
    
    public init(
        startValue: Double,
        endValue: Double,
        lowCurrentValue: Double? = nil,
        highCurrentValue: Double? = nil,
        minTime: String? = nil,
        maxTime: String? = nil,
        sliderType: TwoHandSliderType? = nil,
        isInputTextsEditable: Bool = true,
        onChangeAction: @escaping (String, String) -> Void
    ) {
        switch UIDevice.sizeOfScreen {
        case .small:
            self.width = UIScreen.main.bounds.size.width - 44
        case .medium:
            self.width = UIScreen.main.bounds.size.width - 44
        case .large:
            self.width = UIScreen.main.bounds.size.width / 1.30
        case .xLarge:
            self.width = UIScreen.main.bounds.size.width / 1.55
        }
        self.onChangeAction = onChangeAction
        self.sliderType = sliderType
        self._lowCurrentValueText = State(initialValue: String(format: "%.0f", lowCurrentValue ?? 0.0))
        self._highCurrentValueText = State(initialValue: String(format: "%.0f", highCurrentValue ?? 0.0))
        self._slider = ObservedObject(wrappedValue: CustomSlider(width: self.width, start: startValue, end: endValue, lowCurrentValue: lowCurrentValue, highCurrentValue: highCurrentValue))
        switch sliderType ?? .number {
        case .time:
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let dateMin = formatter.date(from: minTime ?? "") ?? Date()
            let components = Calendar.current.dateComponents([.hour, .minute], from: dateMin )
            let hours = components.hour ?? 0
            let minutes = components.minute ?? 0
            let convertedStart = Double(hours * 60 + minutes)
            let dateMax = formatter.date(from: maxTime ?? "") ?? Date()
            let componentsEnd = Calendar.current.dateComponents([.hour, .minute], from: dateMax)
            let hoursEnd = componentsEnd.hour ?? 0
            let minutesEnd = componentsEnd.minute ?? 0
            let convertedEnd = Double(hoursEnd * 60 + minutesEnd)
            self._lowCurrentValueText = State(initialValue: minTime ?? ":")
            self._highCurrentValueText = State(initialValue: maxTime ?? ":")
            self._slider = ObservedObject(wrappedValue: CustomSlider(width: self.width, start: convertedStart, end: convertedEnd, lowCurrentValue: convertedStart, highCurrentValue: convertedEnd))
        case .number:
            self._lowCurrentValueText = State(initialValue: String(format: "%.0f", lowCurrentValue ?? 0.0))
            self._highCurrentValueText = State(initialValue: String(format: "%.0f", highCurrentValue ?? 0.0))
            self._slider = ObservedObject(wrappedValue: CustomSlider(width: self.width, start: startValue, end: endValue, lowCurrentValue: lowCurrentValue, highCurrentValue: highCurrentValue))
        case .duration:
            self._lowCurrentValueText = State(initialValue: self.convertDoubleToDuration(lowCurrentValue ?? 0.0))
            self._highCurrentValueText = State(initialValue: self.convertDoubleToDuration(highCurrentValue ?? 0.0))
            self._slider = ObservedObject(wrappedValue: CustomSlider(width: self.width, start: startValue, end: endValue, lowCurrentValue: lowCurrentValue, highCurrentValue: highCurrentValue))
        }
    }

    private func convertDoubleToTime(_ value: Double) -> String {
        let hours = Int(value) / 60
        let minutes = Int(value) % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    private func convertDoubleToDuration(_ value: Double) -> String {
        let hours = Int(value) / 60
        let minutes = Int(value) % 60
        switch (hours, minutes) {
        case let (h, m) where h > 0 && m > 0:
            return String(format: "%d\(localizer.localize(key: .commonHourShort)) %d\(localizer.localize(key: .commonMinuteShortest))", h, m)
        case let (h, _) where h > 0:
            return String(format: "%d\(localizer.localize(key: .commonHourShort))", h)
        case let (_, m) where m > 0:
            return String(format: "%d\(localizer.localize(key: .commonMinuteShortest))", m)
        default:
            return ""
        }
    }
 
    public var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: slider.lineWidth)
                .fill(Color.colorTextPlaceholder)
                .frame(width: slider.width, height: slider.lineWidth)
                .overlay(
                    ZStack {
                        // Path between both handles
                        SliderPathBetweenView(slider: slider)
                        
                        // Low Handle
                        SliderHandleView(handle: slider.lowHandle)
                            .highPriorityGesture(slider.lowHandle.sliderDragGesture)
         
                        // High Handle
                        SliderHandleView(handle: slider.highHandle)
                            .highPriorityGesture(slider.highHandle.sliderDragGesture)
                    }
                )
            HStack {
                SliderInputComponent(input: $lowCurrentValueText, placeholder: localizer.localize(key: .commonCapitalFrom), itemAccessibilityIdentifier: IdProvider.activationCodeText, isEditable: self.isInputTextsEditable) { value in
                    slider.lowHandle.setSliderLocation(x: Double(value) ?? 0)
                }
                .onChange(of: slider.lowHandle.currentValue) { newValue in
                    switch sliderType ?? .number {
                    case .time:
                        lowCurrentValueText = convertDoubleToTime(newValue)
                    case .number:
                        lowCurrentValueText = String(format: "%.0f", newValue)
                    case .duration:
                        lowCurrentValueText = convertDoubleToDuration(newValue)
                    }
                    onChangeAction(lowCurrentValueText, highCurrentValueText)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                Circle()
                    .frame(width: 4, height: 4)
                    .foregroundColor(.colorTextLabel)
                SliderInputComponent(input: $highCurrentValueText, placeholder: localizer.localize(key: .commonTo), itemAccessibilityIdentifier: IdProvider.activationCodeText, isEditable: self.isInputTextsEditable) { value in
                    slider.highHandle.setSliderLocation(x: Double(value) ?? 0)
                }
                .onChange(of: slider.highHandle.currentValue) { newValue in
                    switch sliderType ?? .number {
                    case .time:
                        highCurrentValueText = convertDoubleToTime(newValue)
                    case .number:
                        highCurrentValueText = String(format: "%.0f", newValue)
                    case .duration:
                        highCurrentValueText = convertDoubleToDuration(newValue)
                    }
                    onChangeAction(lowCurrentValueText, highCurrentValueText)
                }
                .frame(minWidth: 0, maxWidth: .infinity)

            }
            .frame(minWidth: 100, maxWidth: .infinity)
            .padding(.top, 16)
        }
    }
}

public struct TwoHandSliderView_Previews: PreviewProvider {
    public static var previews: some View {
        TwoHandSliderViewComponent(startValue: 0, endValue: 100, onChangeAction: {_, _ in})
        
    }
}
