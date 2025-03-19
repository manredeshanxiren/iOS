//
//  ContentView.swift
//  Memorize
//
//  Created by qingyangmi on 2025/3/10.
//

import SwiftUI
struct ContentView: View {
    let emojis = ["👻", "😼", "🤡", "🐸", "🕷️", "👹", "🍭", "🙀","👻", "😼", "🤡", "🐸", "🕷️", "👹", "🍭", "🙀"]
    
    @State var cardCount: Int = 4
    
    var body: some View {
        VStack {
            ScrollView {
                cards
            }
            Spacer()
            cardCountAdjusters
        }
        .padding()
    }
    
    var cards: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], content: {
            ForEach(0..<cardCount, id: \.self) { index in
                CardView(content: emojis[index])
                    .aspectRatio(2/3, contentMode: .fit)
            }
        })
        .foregroundColor(.blue)
    }
                            
                            
    
    var cardCountAdjusters: some View {
        HStack{
            Adder
            Spacer()
            Remover
        }
        .imageScale(.large)
        .font(.largeTitle)
        .padding()
    }
    
    func cardCountAjdusters(by offset: Int, symbol: String) -> some View {
        Button(action: {
            cardCount += offset
        }, label: {
            Image(systemName: symbol)
        })
        .disabled(cardCount + offset < 1 || cardCount + offset >= emojis.count)
    }
    
    var Adder: some View {
        cardCountAjdusters(by: +1, symbol: "rectangle.stack.badge.plus.fill")
    }
    
    var Remover: some View {
        cardCountAjdusters(by: -1, symbol: "rectangle.stack.badge.minus.fill")
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
