//
//  MemorizeGame.swift
//  Memorize
//
//  Created by qingyangmi on 2025/4/1.
//


import Foundation


struct MemorizeGame<CardContent> where CardContent: Equatable {
    
    private(set) var cards: Array<Card>
    
    init(numberOfPairOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = []
        //add numberOfPairOfCards x 2 cards
        for pairOfIndex in 0..<max(2, numberOfPairOfCards) {
            let cardContent = cardContentFactory(pairOfIndex)
            cards.append(Card(content: cardContent, id: "\(pairOfIndex + 1)a"))
            cards.append(Card(content: cardContent, id: "\(pairOfIndex + 1)b"))
        }
    }
    
    var indexOfOneAndOnlyFaceUpCard:Int? {
        get { cards.indices.filter { index in cards[index].isFaceUp}.only }
        set { cards.indices.forEach { cards[$0].isFaceUp = (newValue == $0)}}
    }
    
    mutating func choose(_ card: Card) {
        if let choosenIndex = cards.firstIndex(where: { $0.id == card.id }) {
            if !cards[choosenIndex].isFaceUp && !cards[choosenIndex].isMatched {
                if let potentialMatchIndex = indexOfOneAndOnlyFaceUpCard {
                    if cards[potentialMatchIndex].content == cards[choosenIndex].content {
                        cards[potentialMatchIndex].isMatched = true
                        cards[choosenIndex].isMatched = true
                    }
                    cards[choosenIndex].isFaceUp = true
                } else {
                    indexOfOneAndOnlyFaceUpCard = choosenIndex
                }

            }
        }
    }
    
    mutating func shuffle() {
        cards.shuffle()
        print(cards)
    }
    
    struct Card : Equatable, Identifiable, CustomDebugStringConvertible {
        var isFaceUp = false
        var isMatched = false
        var content: CardContent
        
        var id: String
        
        var debugDescription: String {
            "\(id):\(content):\(isFaceUp ? "up" : "down"):isMatched:\(isMatched)"
        }
    }
}

extension Array {
    var only: Element? {
        return count == 1 ? first : nil;
    }
}
