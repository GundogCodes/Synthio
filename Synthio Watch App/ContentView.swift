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
            // The main VStack now aligns its content to the top
            VStack(spacing: 2) {
                // Header Section
                HStack {
                    Text("Synthio")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Text("Water Resistant")
                            .font(.system(size: 6, weight: .medium))
                            .foregroundColor(.blue)
                        Text("Alarm Chronos")
                            .font(.system(size: 6, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("GS")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 8)
                .padding(.top, 16) // Even more padding to prevent clipping
                
                // Calculator Display
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    LinearGradient(
                                        colors: [.green.opacity(0.8), .cyan.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 0)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(display)
                            .font(.system(size: min(20, geometry.size.height / 10), weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                            .shadow(color: .green.opacity(0.5), radius: 1, x: 0, y: 0)
                            .scaleEffect(isAnimating ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: isAnimating)
                    }
                    .padding(.horizontal, 6)
                }
                .frame(height: geometry.size.height * 0.15)
                .padding(.horizontal, 4)
                
                // Button Grid
                VStack(spacing: 2) {
                    ForEach(Array(buttons.enumerated()), id: \.offset) { rowIndex, row in
                        HStack(spacing: 2) {
                            ForEach(Array(row.enumerated()), id: \.offset) { colIndex, symbol in
                                CalculatorButton(
                                    symbol: symbol,
                                    buttonType: getButtonType(symbol),
                                    isSpecialWidth: symbol == "0" && rowIndex == 4,
                                    availableHeight: (geometry.size.height * 0.65 - 10) / 5 // Further reduced space for buttons
                                ) {
                                    buttonTapped(symbol)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
                
                // Add a Spacer here to push all content to the top
                Spacer(minLength: 0) // Use minLength to allow it to shrink if needed
            }
            .background(
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            // Ensure the VStack takes up all available vertical space and aligns content to the top
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea(.all) // This ignores all safe areas including top
        .edgesIgnoringSafeArea(.all) // Fallback for older iOS versions
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
                    .font(.system(size: min(14, availableHeight * 0.4), weight: .bold, design: .monospaced))
                    .foregroundColor(foregroundColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundGradient)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(borderColor, lineWidth: 1.0)
                            .shadow(color: glowColor.opacity(0.3), radius: isPressed ? 2 : 1, x: 0, y: 0)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .shadow(color: glowColor.opacity(0.2), radius: 2, x: 0, y: 0)
            }
            .buttonStyle(PlainButtonStyle())
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            }, perform: {})
        }
        .frame(height: max(24, availableHeight - 2)) // Slightly smaller button height
    }
    
    var backgroundGradient: LinearGradient {
        switch buttonType {
        case .clear:
            return LinearGradient(
                colors: [Color.black, Color.red.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .operation:
            return LinearGradient(
                colors: [Color.black, Color.orange.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .function:
            return LinearGradient(
                colors: [Color.black, Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [Color.black, Color.cyan.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var foregroundColor: Color {
        switch buttonType {
        case .clear:
            return .red
        case .operation:
            return .orange
        case .function:
            return .purple
        default:
            return .cyan
        }
    }
    
    var borderColor: Color {
        foregroundColor
    }
    
    var glowColor: Color {
        foregroundColor
    }
}

#Preview {
    ContentView()
}
