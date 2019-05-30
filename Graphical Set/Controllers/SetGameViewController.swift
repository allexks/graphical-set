//
//  ViewController.swift
//  Graphical Set
//
//  Created by Aleksandar Ignatov on 27.05.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController, SetGameDelegate {
  // MARK: - Outlets
  @IBOutlet weak var gridView: UIView!
  @IBOutlet weak var dealThreeCardsButton: UIButton!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet var swipeToDealGesture: UISwipeGestureRecognizer!
  
  // MARK: - Properties
  private let startingRows = 4
  private let distanceBetweenCards = CGFloat(10)
  
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
  func foundSet() {
    // TODO
  }
  
  func foundMismatch() {
    // TODO
  }
  
  func deckGotEmpty() {
    deckIsEmpty = true
    dealThreeCardsButton.isHidden = true
  }
  
  func updateScore(with newScore: Int) {
    scoreLabel.text = traitCollection.verticalSizeClass == .compact ? "Score\n\(newScore)" : "Score: \(newScore)"
  }
  
  func updateSelectedCards() {
    // TODO
  }
  
  func gameOver() {
    // TODO
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
      let tag = tagForCard[card] ?? getFirstFreeGridIndex()
      tagForCard[card] = tag
      
      let newFrame = grid[tag]!.insetBy(dx: distanceBetweenCards/2, dy: distanceBetweenCards/2)
      
      if let cardView = view.viewWithTag(tag) {
        cardView.frame = newFrame
      } else {
        let cardView = CardView(frame: newFrame)
        cardView.card = card
        cardView.tag = tag
        gridView.addSubview(cardView)
      }
    }
  }
  
  private func getFirstFreeGridIndex() -> Int {
    return Set(stride(from: 0, to: game.availableCards.count, by: 1)).symmetricDifference(tagForCard.values).min()!
  }
}

