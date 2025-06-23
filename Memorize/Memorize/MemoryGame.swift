//
//  MemorizeGame.swift
//  Memorize
//
//  Created by qingyangmi on 2025/4/1.
//


import Foundation


struct MemorizeGame<CardContent> {
    
    private(set) var cards: Array<Card>
    
    init(numberOfPairOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = []
        //add numberOfPairOfCards x 2 cards
        for pairOfIndex in 0..<max(2, numberOfPairOfCards) {
            let cardContent = cardContentFactory(pairOfIndex)
            cards.append(Card(content: cardContent))
            cards.append(Card(content: cardContent))
        }
    }
    
    func choose(_ card: Card) {
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    struct Card {
        var isFaceUp = true
        var isMatched = false
        var content: CardContent
    }
}
