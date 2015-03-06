import UIKit


struct Position: Printable, Equatable {
    let y: Int
    let x: Int
    var description: String {
        return "(\(y), \(x))"
    }
}

func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

struct Move: Printable {
    let y: Int
    let x: Int
    var description: String {
        return "(\(y), \(x))"
    }
}

class BoardView: UIView {
    
    let pieceWidth: Int = 38
    let pieceHeight: Int = 38

    var turnOver = false
    var currentTeam = Team.black
    var moveAlreadyStarted = false
    
    var possibleMove: UIImage = UIImage(named: "selectedSquare")!

    enum PC: String {
        case red = "red", black = "black", none = "none", redKing = "redKing", blackKing = "blackKing"
        
        static let allValues = [red, black, redKing, blackKing]
        
        var description: String {
            get {
                return self.rawValue
            }
        }
    }
    
    enum Team: String {
        case red = "red", black = "black"
        var description: String {
            get {
                return self.rawValue
            }
        }
    }
    
    let validM = [
        PC.black: [Move(y: 1, x: -1), Move(y: 1, x: 1)],
        PC.red: [Move(y: -1, x: -1), Move(y: -1, x: 1)],
        PC.blackKing: [Move(y: 1, x: -1), Move(y: 1, x: 1), Move(y: -1, x: -1), Move(y: -1, x: 1)],
        PC.redKing: [Move(y: 1, x: -1), Move(y: 1, x: 1), Move(y: -1, x: -1), Move(y: -1, x: 1)]
    ]
    
    let validJ = [
        PC.black: [Move(y: 2, x: -2), Move( y: 2, x: 2)],
        PC.red: [Move(y: -2, x: -2), Move(y: -2, x: 2)],
        PC.blackKing: [Move(y: 2, x: -2), Move( y: 2, x: 2), Move(y: -2, x: -2), Move(y: -2, x: 2)],
        PC.redKing: [Move(y: 2, x: -2), Move( y: 2, x: 2), Move(y: -2, x: -2), Move(y: -2, x: 2)]
    ]
    
    /*
     * Game State
     */
    
    var pieceSelected: Position?
    var moveTo: Position?
    
    var gameBoard: [[PC]] = [
        [PC.none, PC.black, PC.none, PC.black, PC.none, PC.black, PC.none, PC.black],
        [PC.black, PC.none, PC.black, PC.none, PC.black, PC.none, PC.black, PC.none],
        [PC.none, PC.black, PC.none, PC.black, PC.none, PC.black, PC.none, PC.black],
        [PC.none, PC.none, PC.none, PC.none, PC.none, PC.none, PC.none, PC.none],
        [PC.none, PC.none, PC.none, PC.none, PC.none, PC.none, PC.none, PC.none],
        [PC.red, PC.none, PC.red, PC.none, PC.red, PC.none, PC.red, PC.none],
        [PC.none, PC.red, PC.none, PC.red, PC.none, PC.red, PC.none, PC.red],
        [PC.red, PC.none, PC.red, PC.none, PC.red, PC.none, PC.red, PC.none],
    ]
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        var board: UIImage = UIImage(named: "board")!
        var boardSize: CGRect = CGRect(x: 0, y: 0, width: 320, height: 320)
        board.drawInRect(boardSize)
        
        for (var y = 0; y < 8; y++) {
            for (var x = 0; x < 8; x++) {
                for color in PC.allValues {
                    if gameBoard[y][x] == color {
                        var pieceImage: UIImage = UIImage(named: color.description)!
                        var pieceSize: CGRect = CGRect(x: (8 + (x * pieceWidth)), y: (8 + (y * pieceHeight)), width: pieceWidth,height: pieceHeight)
                        pieceImage.drawInRect(pieceSize)
                    }
                }
            }
        }
        if pieceSelected != nil {
            showPossibleMoves()
        }
    }
    
    func movePiece(from: Position, to: Position) {
        let pieceToMove = gameBoard[pieceSelected!.y][pieceSelected!.x]
        gameBoard[from.y][from.x] = PC.none
        gameBoard[to.y][to.x] = pieceToMove
    }
    
    func turnSwitch() {
        if currentTeam == Team.red {
            currentTeam = Team.black
        } else {
            currentTeam = Team.red
        }
        
    }
    
    func movedPosition(position: Position, move: Move) -> Position {
        // add the move to the position and return it
        var oldPosition = Position(y: position.y, x: position.x)
        var newPosition = Position(y: oldPosition.y + move.y, x: oldPosition.x + move.x)
        let withinBounds_y1 = (position.y + move.y) >= 0
        let withinBounds_y2 = (position.y + move.y) < 8
        let withinBounds_x1 = (position.x + move.x) >= 0
        let withinBounds_x2 = (position.x + move.x) < 8
        
        if withinBounds_y1 && withinBounds_y2 && withinBounds_x1 && withinBounds_x2 {
            return newPosition
        } else {
            return position
        }
    }
    
    func movesAllowed(pieceToCheck: Position) -> [Position] {
        var validMoves: [Position] = []
        let piece = gameBoard[pieceToCheck.y][pieceToCheck.x]
        
        let moves = validM[piece]!
        for move in moves {
            let spot = movedPosition(pieceToCheck, move: move)
            if gameBoard[spot.y][spot.x] == PC.none {
                validMoves.append(movedPosition(pieceToCheck, move: move))
            }
        }
        println("Possible moves: \(validMoves)")
        return validMoves
    }
 
    func jumpIsValid(spot: Position, jump: Move) -> Bool {
        var isValid = false
        //get the position of the obstacle
        var spot1_position = movedPosition(spot, move: Move(y: -jump.y/2, x: -jump.x/2))
        let spot1 = gameBoard[spot1_position.y][spot1_position.x]
        
        //check that the obstacle of the jump is the enemy
        if (currentTeam == Team.black && (spot1 == PC.red || spot1 == PC.redKing)) || (currentTeam == Team.red && (spot1 == PC.black || spot1 == PC.blackKing)) {
            if gameBoard[spot.y][spot.x] == PC.none {
                isValid = true
            }
        }
        return isValid
    }
    
    func jumpsAllowed(pieceToCheck: Position) -> [Position] {
        var validJumps: [Position] = []
        let piece = gameBoard[pieceToCheck.y][pieceToCheck.x]
        let jumps = validJ[piece]!
        for jump in jumps {
            let jumpPosition = movedPosition(pieceToCheck, move: jump)
            if jumpIsValid(jumpPosition, jump: jump) {
                validJumps.append(jumpPosition)
            }
        }
        println("Possible jumps: \(validJumps)")
        return validJumps
    }

    func kingMe(#newPosition: Position) {
        //King at the last row
        if newPosition.y == 0 && gameBoard[newPosition.y][newPosition.x] == PC.red {
            gameBoard[newPosition.y][newPosition.x] = PC.redKing
            turnOver = true
        }
        if newPosition.y == 7 && gameBoard[newPosition.y][newPosition.x] == PC.black {
            gameBoard[newPosition.y][newPosition.x] = PC.blackKing
            turnOver = true
        }
    }

    override func touchesEnded(touches: NSSet, withEvent event:UIEvent) {
        var touch: UITouch = touches.anyObject() as UITouch
        var touchLocation: CGPoint = touch.locationInView(self)
        
        var squareWidth =  (self.frame.width / 8)
        var squareHeight = (self.frame.height / 8)
        
        var xCoord: Int = Int(touchLocation.x / squareWidth)
        var yCoord: Int = Int(touchLocation.y / squareHeight)
        
        pieceWasTouched(Position(y: yCoord, x: xCoord))
        
        self.setNeedsDisplay()
    }
    
    func pieceWasTouched(pieceTouched: Position) {
        turnOver = false
        moveTo = pieceTouched
        let nextPiece = gameBoard[moveTo!.y][moveTo!.x]
        println("it is \(currentTeam.description)'s turn")
        println("touched piece: \(gameBoard[pieceTouched.y][pieceTouched.x].description) -- (y: \(pieceTouched.y), x: \(pieceTouched.x))")

        if isFriendly(nextPiece) {
            pieceSelected = pieceTouched
            
        } else if pieceSelected != nil {
            
            let validMoves = movesAllowed(pieceSelected!)
            let validJumps = jumpsAllowed(pieceSelected!)
            let capture_y = pieceSelected!.y + (moveTo!.y - pieceSelected!.y)/2
            let capture_x = pieceSelected!.x + (moveTo!.x - pieceSelected!.x)/2
            
            if validJumps.count > 0 {
                for jump in validJumps {
                    if moveTo! == jump && gameBoard[capture_y][capture_x] != PC.none {
                        movePiece(pieceSelected!, to: moveTo!)
                        gameBoard[capture_y][capture_x] = PC.none
                        kingMe(newPosition: moveTo!)
                        let nextJump = jumpsAllowed(moveTo!)
                        if nextJump.count > 0 {
                            pieceSelected = moveTo
                        } else {
                            turnOver = true
                        }
                    }
                }
            } else {
                for move in validMoves {
                    if moveTo! == move && gameBoard[moveTo!.y][moveTo!.x] == PC.none {
                        movePiece(pieceSelected!, to: moveTo!)
                        kingMe(newPosition: moveTo!)
                        turnOver = true
                    }
                }
            }
            
            if turnOver {
                turnSwitch()
                pieceSelected = nil
            }
        }
    }
    
    func isFriendly(pieceInQuestion: PC) -> Bool {
        var friendly = false
        if currentTeam == Team.black && (pieceInQuestion == PC.black || pieceInQuestion == PC.blackKing) {
            friendly = true
        } else if currentTeam == Team.red && (pieceInQuestion == PC.red || pieceInQuestion == PC.redKing) {
            friendly = true
        }
        return friendly
    }
    


/*
 * Display possible moves
 */
    
    func possibleMoveImages(pieceSelected: Position, offset: Move) {
        var locationOnBoard: CGRect = CGRect(x: (8 + (pieceWidth * (self.pieceSelected!.x + offset.x))), y: 8 + (pieceHeight * (self.pieceSelected!.y + offset.y)), width: pieceWidth, height: pieceHeight)
        possibleMove.drawInRect(locationOnBoard)
    }

    //assume that the front for black is going towards red; and front for red is going towards black
    //assumes that left and right are relative to the user's view
    func showPossibleMoves() {
        let piece = gameBoard[pieceSelected!.y][pieceSelected!.x]
        if piece != PC.none {
            var selectedPieceImages = [PC.red: "selectedRed", PC.black: "selectedBlack", PC.redKing: "selectedRedKing", PC.blackKing: "selectedBlackKing"]
            var selected: UIImage = UIImage(named: selectedPieceImages[piece]!)!
            var sq: CGRect = CGRect(x: (8 + (pieceWidth * (self.pieceSelected!.x))), y: 8 + (pieceHeight * (self.pieceSelected!.y)), width: pieceWidth, height: pieceHeight)
            selected.drawInRect(sq)

            
            let validMoves = movesAllowed(pieceSelected!)
            let validJumps = jumpsAllowed(pieceSelected!)
            
            if validJumps.count > 0 {
                for jump in validJumps {
                    if gameBoard[jump.y][jump.x] == PC.none {
                        let jumpMove = Move(y: jump.y - pieceSelected!.y, x: jump.x - pieceSelected!.x)
                        possibleMoveImages(pieceSelected!, offset: jumpMove)
                    }
                }
            } else {
                for move in validMoves {
                    if gameBoard[move.y][move.x] == PC.none {
                        let regMove = Move(y: move.y - pieceSelected!.y, x: move.x - pieceSelected!.x)
                        possibleMoveImages(pieceSelected!, offset: regMove)
                    }
                }
            }
        }
    }
    
    func resetGame() {
        gameBoard = [
        [PC.none, PC.black, PC.none, PC.black, PC.none, PC.black, PC.none, PC.black],
        [PC.black, PC.none, PC.black, PC.none, PC.black, PC.none, PC.black, PC.none],
        [PC.none, PC.black, PC.none, PC.black, PC.none, PC.black, PC.none, PC.black],
        [PC.none, PC.none, PC.none, PC.none, PC.none, PC.none, PC.none, PC.none],
        [PC.none, PC.none, PC.none, PC.none, PC.none, PC.none, PC.none, PC.none],
        [PC.red, PC.none, PC.red, PC.none, PC.red, PC.none, PC.red, PC.none],
        [PC.none, PC.red, PC.none, PC.red, PC.none, PC.red, PC.none, PC.red],
        [PC.red, PC.none, PC.red, PC.none, PC.red, PC.none, PC.red, PC.none],
        ]
        turnOver = false
        currentTeam = Team.black
        pieceSelected = nil
        moveTo = nil
        self.setNeedsDisplay()
    }
    

    /*
    
    // If a jump was made yet, so the player is stuck with that piece
    let moveStartedAlready = false
    
    func pieceWasTouched2(pieceTouched: Position) {
        
        if moveAlreadyStarted() {
            // You can't unselect if you already jumped
            tryToMovePiece(to: pieceTouched)
        } else {
            
            // If it's the start of your turn, you can select different pieces
            
            if isFriendly(pieceTouched) {
                // Piece touched is friendly
                pieceSelected = pieceTouched
            } else if isEnemy(pieceTouched) {
                // Piece touched is enemy
                pieceSelected = nil
            } else if pieceSelected {
                // Empty space was touched and we have a piece already selected
                tryToMovePiece(to: pieceTouched)
            }
        }
    }
    
    func tryToMovePiece(to newPosition: Position) {
        let attemptedMove: Move = moveBetween(from: pieceSelected to: newPosition)
        
        let pieceType = PieceType(pieceSelected) // This is just "normal" or "king". No black or red
        let validMovess: [Move] = validMovesFor(pieceType: pieceType, team: currentPlayer)
        
        if contains(validMovess, attemptedMove) {
            movePiece(from: selectedPiece, to: newPosition)
            selectedPiece = nil
            nextTurn()
        }
        
        // Sort of the same for valid jumps, but you need to find out the jumped piece as well
        // Remember you can just use isEnemy() to find out it's an enemy
    }
    
    func moveBetween(from: Position, to: Position) -> Move {
        // Find out what move will take you from "from" to "to"
        return Move(y: to.y - from.y, x: to.x - from.x)
    }
    
    func validMovesFor(pieceType: PieceType, team: Team) {
        if team == Team.black {
            return validM2[team]
        } else {
            let flippedMoves = []
            for move in validM2[team] {
                moves.append(Move(y: -move.y, x: move.x))
            }
            
            return moves
        }
    }
    
    let validM2 = [
        PT.normal: [Move(y: 1, x: -1), Move(y: 1, x: 1)],
        PT.king: [Move(y: 1, x: -1), Move(y: 1, x: 1), Move(y: -1, x: -1), Move(y: -1, x: 1)],
    ]
    
    */
}