//
//  EmojiMemorizeGame.swift
//  Memorize
//
//  Created by qingyangmi on 2025/4/1.
//

import SwiftUI


class EmojiMemorizeGame: ObservableObject {
    
    private static let emojis = ["👻", "😼", "🤡", "🐸", "🕷️", "👹", "🍭", "🙀","👻", "😼", "🤡", "🐸", "🕷️", "👹", "🍭", "🙀"]
    
    private static func creatMemorizeGame() -> MemorizeGame<String> {
        return MemorizeGame(numberOfPairOfCards: 16) { pairIndex in
            if emojis.indices.contains(pairIndex) {
                return emojis[pairIndex]
            } else {
                return "⁉️"
            }
        }
    }
    
    @Published private var model = creatMemorizeGame()
    
    var cards: Array<MemorizeGame<String>.Card> {
        return model.cards
    }
    
    func shuffle() {
        model.shuffle()
    }
    
    func choose(_ card: MemorizeGame<String>.Card) {
        model.choose(card)
    }
}

