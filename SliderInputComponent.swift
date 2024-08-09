//
//  SliderInputComponent.swift
//
//  Created by Oğuz Kuzu on 12.07.2023.
//

import SwiftUI
import UIComponents


public struct SliderInputComponent: View {
    @Binding var input: String
    let itemAccessibilityIdentifier: String
    var placeholder: String
    let action: (String) -> Void
    var isEditable: Bool = true
    
    public init(input: Binding<String>,
                placeholder: String,
                itemAccessibilityIdentifier: String = "",
                isEditable: Bool = true,
                action: @escaping (String) -> Void) {
        self._input = input
        self.placeholder = placeholder
        self.itemAccessibilityIdentifier = itemAccessibilityIdentifier
        self.isEditable = isEditable
        self.action = action
    }
    
    public var body: some View {
        VStack{
                TextField(placeholder, text: $input)
                    .keyboardType(.decimalPad)
                    .fontTemplate(Default.Medium.Footnote)
                    .onChange(of: input) { newValue in
                        action(newValue)
                    }
                    .disabled(self.isEditable)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .inset(by: 0.25)
                        .stroke(Color.colorTextDescription,
                                lineWidth: 0.5)
                )
        }
        .frame(minWidth: 100, maxWidth: .infinity, alignment: .leading)
      
    }
}

struct SliderInputComponent_Previews: PreviewProvider {
    static var previews: some View {
        SliderInputComponent(input: .constant(""), placeholder: "Description") {_ in
        }
    }
}
