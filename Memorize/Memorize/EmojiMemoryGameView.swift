//
//  ContentView.swift
//  Memorize
//
//  Created by qingyangmi on 2025/3/10.
//

import SwiftUI
struct EmojiMemoryGameView: View {
    
    @ObservedObject var viewModel: EmojiMemorizeGame
    
    let emojis = ["👻", "😼", "🤡", "🐸", "🕷️", "👹", "🍭", "🙀", "🐔", "🐧", "🐯", "🐻‍❄️", "🦊"]
    
    
    var body: some View {
        VStack {
            ScrollView {
                cards
            }
            Button("洗牌") {
                viewModel.shuffle()
            }
        }
        .padding()
    }
    
    var cards: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 85), spacing: 0)], spacing: 0) {
            ForEach(viewModel.cards.indices, id: \.self) { index in
                CardView(viewModel.cards[index])
                    .aspectRatio(2/3, contentMode: .fit)
                    .padding(4)
            }
        }
        .foregroundColor(.blue)
    }
                            
}


struct CardView: View {
    let card: MemorizeGame<String>.Card
    
    init(_ card: MemorizeGame<String>.Card) {
        self.card = card
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            let base = RoundedRectangle(cornerRadius: 12)
            Group {
                base.foregroundColor(.white)
                base.strokeBorder(lineWidth: 2)
                Text(card.content)
                    .font(.system(size: 200))
                    .minimumScaleFactor(0.01)
                    .aspectRatio(1, contentMode: .fit)
            }
            .opacity(card.isFaceUp ? 1 : 0)
            base.opacity(card.isFaceUp ? 0 : 1)
        }
    }
}



#Preview {
    EmojiMemoryGameView(viewModel: EmojiMemorizeGame())
}
