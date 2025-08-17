//  ContentView.swift
//  Synthio Watch App
//
//  Created by Gunish Sharma on 2025-08-16.
//

import SwiftUI

struct ContentView: View {
    @State private var display = "0"
    @State private var previousValue: Double = 0
    @State private var currentOperation: String? = nil
    @State private var waitingForInput = false
    @State private var hasDecimal = false
    @State private var isAnimating = false
    
    let buttons = [
        ["C", "±", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 2) {
                // Header Section
                HStack {
                    Text("Synthio")
                        .foregroundStyle(.white).bold()
                        .font(.system(size: 15))
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Text("Water Resistant")
                        Text("Alarm Chronos")
                    }
                    .font(.system(size: 8))
                    .foregroundStyle(.blue)
                    Spacer()
                    
                    Text("GS")
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .foregroundColor(.yellow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous) // softer corners
                                .stroke(Color.yellow, lineWidth: 1.8) )
                }
                .frame(maxWidth: 170)
                .font(.system(size: 10))
                .padding(.horizontal, 8)
                .padding(.top, 16)
                
                // Calculator Display
                Rectangle()
                    .frame(height: 1)

                HStack(spacing: 4) {
                    // Display with blinking cursor
                    HStack {
                        Text(display)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        // blinking block cursor
                        BlinkingCursor()
                    }
                    .frame(height: geometry.size.height * 0.15)
                    .frame(maxWidth: .infinity, alignment: .leading) // 🔥 left align
                    .padding(.leading, 6)
                    .background(Color.gray.opacity(0.3).mix(with: .green, by: 0.2))
                    .cornerRadius(0)

                    // Vertical text on the right
                    VStack(spacing: 1) {
                        Text("A")
                        Text("D")
                        Text("J")
                        Text("□")
                        Text("□")
                        Text("M")
                        Text("O")
                        Text("D")
                        Text("E")
                        Text("/")
                        Text("C")
                    }
                    .font(.system(size: 2, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 14)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(2)
                    .frame(height: geometry.size.height * 0.15)
                }
                .padding(.horizontal, 4)

                Rectangle()
                    .frame(height: 1)

                // Button Grid
                VStack(spacing: 2) {
                    ForEach(Array(buttons.enumerated()), id: \.offset) { rowIndex, row in
                        HStack(spacing: 2) {
                            ForEach(Array(row.enumerated()), id: \.offset) { colIndex, symbol in
                                CalculatorButton(
                                    symbol: symbol,
                                    buttonType: getButtonType(symbol),
                                    isSpecialWidth: symbol == "0" && rowIndex == 4,
                                    availableHeight: (geometry.size.height * 0.65 - 10) / 5
                                ) {
                                    buttonTapped(symbol)
                                }
                            }
                        }
                    }
                    Rectangle()
                        .frame(height: 1)

                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
                
                Spacer(minLength: 0)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea(.all)
        .edgesIgnoringSafeArea(.all)
    }
    
    func getButtonType(_ symbol: String) -> ButtonType {
        switch symbol {
        case "C":
            return .clear
        case "÷", "×", "−", "+", "=":
            return .operation
        case "±", "%":
            return .function
        default:
            return .number
        }
    }
    
    func buttonTapped(_ symbol: String) {
        // Animation feedback
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = false
        }
        
        switch symbol {
        case "C":
            clear()
            
        case "±":
            toggleSign()
            
        case "%":
            percentage()
            
        case "÷", "×", "−", "+":
            performOperation(symbol)
            
        case "=":
            calculateResult()
            
        case ".":
            addDecimal()
            
        default:
            inputNumber(symbol)
        }
    }
    
    func clear() {
        display = "0"
        previousValue = 0
        currentOperation = nil
        waitingForInput = false
        hasDecimal = false
    }
    
    func toggleSign() {
        if display != "0" {
            if display.hasPrefix("-") {
                display = String(display.dropFirst())
            } else {
                display = "-" + display
            }
        }
    }
    
    func percentage() {
        if let value = Double(display) {
            let result = value / 100
            display = formatResult(result)
            waitingForInput = true
            hasDecimal = display.contains(".")
        }
    }
    
    func performOperation(_ operation: String) {
        if let currentValue = Double(display) {
            if let previousOp = currentOperation, !waitingForInput {
                // Perform pending operation first
                let result = calculate(previousValue, currentValue, previousOp)
                display = formatResult(result)
                previousValue = result
            } else {
                previousValue = currentValue
            }
        }
        
        currentOperation = operation
        waitingForInput = true
        hasDecimal = false
    }
    
    func calculateResult() {
        guard let operation = currentOperation,
              let currentValue = Double(display) else { return }
        
        let result = calculate(previousValue, currentValue, operation)
        display = formatResult(result)
        
        previousValue = result
        currentOperation = nil
        waitingForInput = true
        hasDecimal = display.contains(".")
    }
    
    func calculate(_ first: Double, _ second: Double, _ operation: String) -> Double {
        switch operation {
        case "+":
            return first + second
        case "−":
            return first - second
        case "×":
            return first * second
        case "÷":
            return second != 0 ? first / second : 0
        default:
            return second
        }
    }
    
    func addDecimal() {
        if waitingForInput {
            display = "0."
            waitingForInput = false
            hasDecimal = true
        } else if !hasDecimal {
            display += "."
            hasDecimal = true
        }
    }
    
    func inputNumber(_ number: String) {
        if waitingForInput {
            display = number
            waitingForInput = false
            hasDecimal = false
        } else {
            if display == "0" {
                display = number
            } else {
                // Limit display length for watch screen
                if display.count < 12 {
                    display += number
                }
            }
        }
    }
    
    func formatResult(_ value: Double) -> String {
        // Handle very large or very small numbers
        if abs(value) >= 1e9 || (abs(value) < 1e-6 && value != 0) {
            return String(format: "%.2e", value)
        }
        
        // Remove unnecessary decimal places
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            let formatted = String(format: "%.6f", value)
            return formatted.trimmingCharacters(in: CharacterSet(charactersIn: "0")).trimmingCharacters(in: CharacterSet(charactersIn: "."))
        }
    }
}

enum ButtonType {
    case number, operation, function, clear
}

struct CalculatorButton: View {
    let symbol: String
    let buttonType: ButtonType
    let isSpecialWidth: Bool
    let availableHeight: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                action()
            }) {
                Text(symbol)
                    .foregroundColor(foregroundColor(for: buttonType)) // 🔥 set color here
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(height: max(24, availableHeight - 2))
    }
    
    // Helper to assign colors
    func foregroundColor(for type: ButtonType) -> Color {
        switch type {
        case .operation:
            return Color(red: 1.0, green: 0.27, blue: 0.0) // orangish red
        default:
            return .white
        }
    }
}
struct BlinkingCursor: View {
    @State private var isVisible = true
    var body: some View {
        Rectangle()
            .fill(Color.black)
            .frame(width: 2, height: 14)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.6).repeatForever()) {
                    isVisible.toggle()
                }
            }
            .padding(.leading, 2)
    }
}


#Preview {
    ContentView()
}
