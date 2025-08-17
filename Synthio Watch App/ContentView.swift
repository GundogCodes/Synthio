//
//  ContentView.swift
//  Synthio Watch App
//
//  Created by Gunish Sharma on 2025-08-16.
//

import SwiftUI

struct ContentView: View {
    @State private var display = "0"
      
      let buttons = [
          ["7", "8", "9", "÷"],
          ["4", "5", "6", "×"],
          ["1", "2", "3", "−"],
          ["0", ".", "=", "+"]
      ]
      
      var body: some View {
          VStack {
              // Display
              Text(display)
                  .font(.system(size: 28, weight: .bold, design: .monospaced))
                  .frame(maxWidth: .infinity, alignment: .trailing)
                  .padding()
                  .background(Color.black)
                  .foregroundColor(.green) // retro look
              
              // Buttons
              ForEach(buttons, id: \.self) { row in
                  HStack {
                      ForEach(row, id: \.self) { symbol in
                          Button(action: { buttonTapped(symbol) }) {
                              Text(symbol)
                                  .font(.system(size: 20, weight: .bold, design: .monospaced))
                                  .frame(width: 40, height: 40)
                                  .background(Color.black)
                                  .foregroundColor(.cyan)
                                  .cornerRadius(6)
                                  .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.cyan, lineWidth: 2))
                          }
                      }
                  }
              }
          }
          .padding()
          .background(Color.black)
      }
      
      func buttonTapped(_ symbol: String) {
          // TODO: Add logic for numbers & operators
          display = symbol
      }
}

#Preview {
    ContentView()
}
