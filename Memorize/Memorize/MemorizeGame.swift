//
//  MemorizeGame.swift
//  Memorize
//
//  Created by qingyangmi on 2025/4/1.
//


import Foundation


struct MemorizeGame<CardContent> {
    
    var cards: Array<Card>
    
    func choose(card: Card) {
        
    }
    
    struct Card {
        var isFaceUp: Bool
        var isMatched: Bool
        var content: CardContent
    }
}
