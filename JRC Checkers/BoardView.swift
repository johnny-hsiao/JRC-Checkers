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
    
    @IBOutlet var userMessage: UILabel!
    
    let pieceSize: Int = 38

    var turnOver = false
    var moveAlreadyStarted = false
    
    var currentTeam = Team.black
    
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
                        var pieceDimension: CGRect = CGRect(x: (8 + (x * pieceSize)), y: (8 + (y * pieceSize)), width: pieceSize,height: pieceSize)
                        pieceImage.drawInRect(pieceDimension)
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
    
    //checks valid moves from validM; the possible moves are the ones where the new position is empty
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
 
    func jumpIsValid(jumpPosition: Position, jump: Move) -> Bool {
        var isValid = false
        //get the position of the obstacle
        var obstacle_position = movedPosition(jumpPosition, move: Move(y: -jump.y/2, x: -jump.x/2))
        let obstacle = gameBoard[obstacle_position.y][obstacle_position.x]
        
        //check that the obstacle of the jump is the enemy
        if (currentTeam == Team.black && isEnemy(obstacle)) || (currentTeam == Team.red && isEnemy(obstacle)) {
            if gameBoard[jumpPosition.y][jumpPosition.x] == PC.none {
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
    
    func isThereForceJump() -> Bool {
        var forceJump = false
        
        for y in 0...7 {
            for x in 0...7 {
                let piecePosition = Position(y: y, x: x)
                let nextPiece = gameBoard[piecePosition.y][piecePosition.x]
                if isFriendly(nextPiece) {
                    if jumpsAllowed(piecePosition).count > 0 {
                        forceJump = true
                    }
                }
            }
        }
        
        return forceJump
    }
    
    func enemyIsAllCaptured() -> Bool {
        var allEnemiesCaptured = true
        
        for y in 0...7 {
            for x in 0...7 {
                let piecePosition = Position(y: y, x: x)
                let nextPiece = gameBoard[piecePosition.y][piecePosition.x]
                if isEnemy(nextPiece) {
                    allEnemiesCaptured = false
                }
            }
        }
        
        return allEnemiesCaptured
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        <#code#>
    }

    override func touchesEnded(touches: NSSet, withEvent event:UIEvent) {
        var touch: UITouch = touches.first as UITouch
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
        let nextPiece = gameBoard[pieceTouched.y][pieceTouched.x]
        println("it is \(currentTeam.description)'s turn")
        println("touched piece: \(gameBoard[pieceTouched.y][pieceTouched.x].description) -- (y: \(pieceTouched.y), x: \(pieceTouched.x))")

        if isFriendly(nextPiece) && !moveAlreadyStarted {
            pieceSelected = pieceTouched
            
        } else if pieceSelected != nil {
            
            let validMoves = movesAllowed(pieceSelected!)
            let validJumps = jumpsAllowed(pieceSelected!)
            let capture_y = pieceSelected!.y + (pieceTouched.y - pieceSelected!.y)/2
            let capture_x = pieceSelected!.x + (pieceTouched.x - pieceSelected!.x)/2
            
            if validJumps.count > 0 {
                for jump in validJumps {
                    if pieceTouched == jump && gameBoard[capture_y][capture_x] != PC.none {
                        movePiece(pieceSelected!, to: pieceTouched)
                        gameBoard[capture_y][capture_x] = PC.none
                        kingMe(newPosition: pieceTouched)
                        let nextJump = jumpsAllowed(pieceTouched)
                        if nextJump.count > 0 {
                            pieceSelected = pieceTouched
                            moveAlreadyStarted = true
                        } else {
                            turnOver = true
                        }
                    }
                }
            } else if !isThereForceJump() {
                for move in validMoves {
                    if pieceTouched == move && gameBoard[pieceTouched.y][pieceTouched.x] == PC.none {
                        movePiece(pieceSelected!, to: pieceTouched)
                        kingMe(newPosition: pieceTouched)
                        turnOver = true
                    }
                }
            }
            
            if turnOver {
                if enemyIsAllCaptured() {
                    userMessage.text = "\(currentTeam.description) wins!"
                } else {
                    turnSwitch()
                    moveAlreadyStarted = false
                    userMessage.text = "It is \(currentTeam.description)'s turn"
                }
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
    
    func isEnemy(pieceInQuestion: PC) -> Bool {
        var isAnEnemy = false
        if currentTeam == Team.black && (pieceInQuestion == PC.red || pieceInQuestion == PC.redKing) {
            isAnEnemy = true
        } else if currentTeam == Team.red && (pieceInQuestion == PC.black || pieceInQuestion == PC.blackKing) {
            isAnEnemy = true
        }
        return isAnEnemy
    }

/*
 * Display possible moves
 */
    
    func possibleMoveImages(pieceSelected: Position, offset: Move) {
        var locationOnBoard: CGRect = CGRect(x: (8 + (pieceSize * (self.pieceSelected!.x + offset.x))), y: 8 + (pieceSize * (self.pieceSelected!.y + offset.y)), width: pieceSize, height: pieceSize)
        possibleMove.drawInRect(locationOnBoard)
    }

    //assume that the front for black is going towards red; and front for red is going towards black
    //assumes that left and right are relative to the user's view
    func showPossibleMoves() {
        let piece = gameBoard[pieceSelected!.y][pieceSelected!.x]
        if piece != PC.none {
            var selectedPieceImages = [PC.red: "selectedRed", PC.black: "selectedBlack", PC.redKing: "selectedRedKing", PC.blackKing: "selectedBlackKing"]
            var selected: UIImage = UIImage(named: selectedPieceImages[piece]!)!
            var sq: CGRect = CGRect(x: (8 + (pieceSize * (self.pieceSelected!.x))), y: 8 + (pieceSize * (self.pieceSelected!.y)), width: pieceSize, height: pieceSize)
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
            } else if !isThereForceJump() {
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
        moveAlreadyStarted = false
        userMessage.text = "It is \(currentTeam.description)'s turn"
        self.setNeedsDisplay()
    }
}