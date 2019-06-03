//
//  ViewController.swift
//  Graphical Set
//
//  Created by Aleksandar Ignatov on 27.05.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController, SetGameDelegate, CardViewDelegate {
  
  // MARK: - Outlets
  @IBOutlet weak var gridView: UIView!
  @IBOutlet weak var dealThreeCardsButton: UIButton!
  @IBOutlet weak var scoreLabel: UILabel!
  
  // MARK: - Properties
  private let startingRows = 4
  private let distanceBetweenCards = CGFloat(10)
  private let selectedCardOutlineColor: UIColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
  private let matchedCardOutlineColor: UIColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
  private let mismatchedCardOutlineColor: UIColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
  
  private var game: SetGame! {
    didSet {
      game.delegate = self
    }
  }
  private var deckIsEmpty = false
  private var grid: Grid!
  private var tagForCard: [Card : Int] = [:]
  
  // MARK: - View Controller Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    grid = Grid(layout: .dimensions(rowCount: startingRows, columnCount: 3),
                frame: gridView.bounds)
    
    game = SetGame()
    startingRows.repetitions {
      dealThree()
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    grid.frame = gridView.bounds
    populateGrid()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    updateScore(with: game.score)
  }
    
  // MARK: - Actions
  @IBAction func onTapDealThreeCardsButton(_ sender: UIButton) {
    dealThree()
  }
  
  @IBAction func onSwipe(_ sender: UISwipeGestureRecognizer) {
    if !deckIsEmpty {
      dealThree()
    }
  }
  
  // MARK: - Set Game Delegate
  func updateSelectedCards() {
    fixOutlinesAndRemovedCards()
  }
  
  func foundSet() {
    fixOutlinesAndRemovedCards()
    for card in game.selectedCards {
      setOutlineColorForCardView(for: card, color: matchedCardOutlineColor)
    }
  }
  
  func foundMismatch() {
    fixOutlinesAndRemovedCards()
    for card in game.selectedCards {
      setOutlineColorForCardView(for: card,
                                 color: mismatchedCardOutlineColor)
    }
  }
  
  func deckGotEmpty() {
    deckIsEmpty = true
    dealThreeCardsButton.isHidden = true
  }
  
  func updateScore(with newScore: Int) {
    scoreLabel.text = traitCollection.verticalSizeClass == .compact ? "Score\n\(newScore)" : "Score: \(newScore)"
  }
  
  func gameOver() {
    fixOutlinesAndRemovedCards()
  }
  
  // MARK: - Card View Delegate
  func onTap(_ cardView: CardView) {
    if let card = cardView.card {
      game.selectCard(card)
    }
  }
  
  // MARK: - Helpers
  private func dealThree() {
    game.dealThreeCards()
    populateGrid()
  }
  
  private func populateGrid() {
    let gridLen = game.availableCards.count / 3
    grid.layout = traitCollection.verticalSizeClass == .compact ? .dimensions(rowCount: 3, columnCount: gridLen) : .dimensions(rowCount: gridLen, columnCount: 3)
    
    for card in game.availableCards {
      if let oldTag = tagForCard[card], grid[oldTag] == nil {
        // match was found and the grid got smaller => rearrange
        let newTag = getFirstFreeGridIndex()
        let cardView = view.viewWithTag(oldTag)
        cardView?.tag = newTag
        tagForCard[card] = newTag
      } else if tagForCard[card] == nil {
        // new cards have been added
        tagForCard[card] = getFirstFreeGridIndex()
      }
      
      let tag = tagForCard[card]!
      let newFrame = grid[tag]!.insetBy(dx: distanceBetweenCards/2,
                                        dy: distanceBetweenCards/2)
      
      if let cardView = view.viewWithTag(tag) {
        cardView.frame = newFrame
      } else {
        let cardView = CardView(frame: newFrame)
        cardView.card = card
        cardView.tag = tag
        cardView.delegate = self
        gridView.addSubview(cardView)
      }
    }
  }
  
  private func fixOutlinesAndRemovedCards() {
    // removed cards
    let removedCards = tagForCard.keys.filter({ !game.availableCards.contains($0) })
    for card in removedCards {
      view.viewWithTag(tagForCard[card]!)?.removeFromSuperview()
      tagForCard[card] = nil
    }
    // outlines
    for card in game.availableCards {
      if game.selectedCards.contains(card) {
        setOutlineColorForCardView(for: card,
                                   color: selectedCardOutlineColor)
      } else {
        setOutlineColorForCardView(for: card)
      }
    }
    
    populateGrid()
  }
  
  private func setOutlineColorForCardView(for card: Card, color: UIColor = .clear) {
    if let tag = tagForCard[card],
      let cardView = view.viewWithTag(tag) {
      cardView.layer.borderColor = color.cgColor
    }
  }
  
  private func getFirstFreeGridIndex() -> Int {
    return Set(stride(from: 0, to: game.availableCards.count, by: 1)).symmetricDifference(tagForCard.values).min()!
  }
}
