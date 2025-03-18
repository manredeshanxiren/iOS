//
//  ContentView.swift
//  Memorize
//
//  Created by qingyangmi on 2025/3/10.
//

import SwiftUI
struct ContentView: View {
    var body: some View {
        HStack {
            CardView(content: "👻",isFaceUp: true)
            CardView(content: "😼")
            CardView(content: "🤡")
            CardView(content: "🐸")
        }
    }
}


struct CardView: View {
    let content: String
    @State var isFaceUp: Bool = false
    var body: some View {
        ZStack(alignment: .center) {
            let base = Circle()
            if isFaceUp {
                base.foregroundColor(.white)
                base.strokeBorder(lineWidth: 2)
                Text(content)
                    .font(.largeTitle)
            } else {
                base.fill()
            }
        }
        .onTapGesture {
            isFaceUp.toggle()
        }
        .foregroundColor(.blue)
        .padding()
    }
}



#Preview {
    ContentView()
}
