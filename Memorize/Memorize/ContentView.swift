//
//  ContentView.swift
//  Memorize
//
//  Created by qingyangmi on 2025/3/10.
//

import SwiftUI
struct ContentView: View {
    let emojis = ["👻", "😼", "🤡", "🐸", "🕷️", "👹", "🍭", "🙀","👻", "😼", "🤡", "🐸", "🕷️", "👹", "🍭", "🙀"]
    
    
    var body: some View {
        ScrollView {
            cards
        }
    }
    
    var cards: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], content: {
            ForEach(emojis.indices, id: \.self) { index in
                CardView(content: emojis[index])
                    .aspectRatio(2/3, contentMode: .fit)
            }
        })
        .foregroundColor(.blue)
    }
                            
}


struct CardView: View {
    let content: String
    @State var isFaceUp: Bool = true
    var body: some View {
        ZStack(alignment: .center) {
            let base = RoundedRectangle(cornerRadius: 12)
            Group {
                base.foregroundColor(.white)
                base.strokeBorder(lineWidth: 2)
                Text(content)
                    .font(.largeTitle)
            }
            .opacity(isFaceUp ? 1 : 0)
            base.opacity(isFaceUp ? 0 : 1)
        }
        .onTapGesture {
            isFaceUp.toggle()
        }
    }
}



#Preview {
    ContentView()
}
