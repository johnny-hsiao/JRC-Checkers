import UIKit

class BoardView: UIView {
    
    let pieceWidth: Int = 38
    let pieceHeight: Int = 38
    var secondRow = 46
    var seventhRow = 236

    var turnOver = false
    var currentPlayer = Turn.black
    var pieceMoving: PlayerColor = PlayerColor.none
    var pieceMovingKing: PlayerColor = PlayerColor.none
    
    let oneLeft = -1
    let twoLeft = -2
    let oneRight = 1
    let twoRight = 2
    let oneUp = -1
    let twoUp = -2
    let oneDown = 1
    let twoDown = 2
    
    var possibleMove: UIImage = UIImage(named: "selectedSquare")!

    enum PlayerColor: String {
        case red = "red", black = "black", none = "none", redKing = "redKing", blackKing = "blackKing"
        
        static let allValues = [red, black, redKing, blackKing]
        
        var description: String {
            get {
                return self.rawValue
            }
        }
    }
    
    enum Turn: String {
        case red = "red", black = "black"
        var description: String {
            get {
                return self.rawValue
            }
        }
    }
    
    struct Move: Printable {
        let y: Int
        let x: Int
        var description: String {
            return "(\(y), \(x))"
        }
    }
    
    struct Position: Printable {
        let y: Int
        let x: Int
        var description: String {
            return "(\(y), \(x))"
        }
    }
    
    let validM = [
        PlayerColor.black: [Move(y: 1, x: -1), Move(y: 1, x: 1)],
        PlayerColor.red: [Move(y: -1, x: -1), Move(y: -1, x: 1)],
        PlayerColor.blackKing: [Move(y: 1, x: -1), Move(y: 1, x: 1), Move(y: -1, x: -1), Move(y: -1, x: 1)],
        PlayerColor.redKing: [Move(y: 1, x: -1), Move(y: 1, x: 1), Move(y: -1, x: -1), Move(y: -1, x: 1)]
    ]
    
    let validJumps = [
        PlayerColor.black: [Move(y: 2, x: -2), Move( y: 2, x: 2)],
        PlayerColor.red: [Move(y: -2, x: -2), Move(y: -2, x: 2)],
        PlayerColor.blackKing: [Move(y: 2, x: -2), Move( y: 2, x: 2), Move(y: -2, x: -2), Move(y: -2, x: 2)],
        PlayerColor.redKing: [Move(y: 2, x: -2), Move( y: 2, x: 2), Move(y: -2, x: -2), Move(y: -2, x: 2)]
    ]
    
    /*
     * Game State
     */
    
    var pieceSelected: Position?
    var moveTo: Position?
    
    var gameBoard: [[PlayerColor]] = [
        [PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black],
        [PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none],
        [PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black],
        [PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none],
        [PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none],
        [PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none],
        [PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red],
        [PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none],
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
                for color in PlayerColor.allValues {
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
    
    func movePiece(from: (y1: Int, x1: Int), to: (y2: Int, x2: Int)) {
        let pieceToMove = gameBoard[pieceSelected!.y][pieceSelected!.x]
        gameBoard[from.y1][from.x1] = PlayerColor.none
        gameBoard[to.y2][to.x2] = pieceToMove
    }
    
    func turnSwitch() {
        if currentPlayer == Turn.red {
            currentPlayer = Turn.black
        } else {
            currentPlayer = Turn.red
        }
    }
    

    func moveIsValid(spot: Position) -> Bool {
        var isValid = false
        let y_diff = spot.y - self.pieceSelected!.y
        let x_diff = spot.x - self.pieceSelected!.x
        let piece1 = gameBoard[pieceSelected!.y][pieceSelected!.x]
        let spot1 = gameBoard[pieceSelected!.y + y_diff/2][pieceSelected!.x + x_diff/2]
        let spot2 = gameBoard[spot.y][spot.x]

        let blackCond: Bool = piece1 == PlayerColor.black && y_diff == twoDown && (spot1 == PlayerColor.red || spot1 == PlayerColor.redKing) && spot.y < 8
        let redCond: Bool = piece1 == PlayerColor.red && y_diff == twoUp && (spot1 == PlayerColor.black || spot1 == PlayerColor.blackKing) && spot.y >= 0
        let blackKingCond: Bool = piece1 == PlayerColor.blackKing && (y_diff == twoDown || y_diff == twoUp) && (spot1 == PlayerColor.red || spot1 == PlayerColor.redKing) && spot.y < 8 && spot.y >= 0
        let redKingCond: Bool = piece1 == PlayerColor.redKing && (y_diff == twoDown || y_diff == twoUp) && (spot1 == PlayerColor.black || spot1 == PlayerColor.blackKing) && spot.y < 8 && spot.y >= 0
        
        if blackCond || redCond || blackKingCond || redKingCond {
            if (x_diff == twoLeft && spot.x >= 0) || (x_diff == twoRight && spot.x < 8) {
                if spot2 == PlayerColor.none {
                    isValid = true
                }
            }
        }
        
        if y_diff == oneDown && (x_diff == oneLeft || x_diff == oneRight) && piece1 == PlayerColor.black && spot2 == PlayerColor.none {
            isValid = true
        }
        if y_diff == oneUp && (x_diff == oneLeft || x_diff == oneRight) && piece1 == PlayerColor.red && spot2 == PlayerColor.none {
            isValid = true
        }
        if (y_diff == oneUp || y_diff == oneDown) && (x_diff == oneLeft || x_diff == oneRight) && (piece1 == PlayerColor.blackKing || piece1 == PlayerColor.redKing) && spot2 == PlayerColor.none {
            isValid = true
        }
        
        return isValid
    }
    
    func movesAllowed(piece: Position) -> [Position] {
        var validMoves: [Position] = []
        // Chris changed his mind. Use validMoves
        for x in 0...7 {
            for y in 0...7 {
                if moveIsValid(Position(y: y, x: x)) {
                    validMoves.append(Position(y: y, x: x))
                }
            }
        }
        println("Possible moves: \(validMoves)")
        return validMoves
    }
    
    func validJump(spot: Position, color: PlayerColor, color2: PlayerColor) -> Bool {
        if spot.y == 2 && spot.x == 3 {
            println("chris smells")
        }
        var isValid = false
        let piece1 = gameBoard[spot.y][spot.x]
        
        if piece1 == color || piece1 == color2 {
        for jump in validJumps[piece1]! {
        
            let blackCond: Bool = piece1 == PlayerColor.black && jump.y == twoDown  && spot.y < 6
            let redCond: Bool = piece1 == PlayerColor.red && jump.y == twoUp && spot.y > 1
            let blackKingCond: Bool = piece1 == PlayerColor.blackKing && (jump.y == twoDown || jump.y == twoUp) && spot.y < 6 && spot.y > 1
            let redKingCond: Bool = piece1 == PlayerColor.redKing && (jump.y == twoDown || jump.y == twoUp) && spot.y < 6 && spot.y > 1
        
            if blackCond || redCond || blackKingCond || redKingCond {
                if (jump.x == twoLeft && spot.x > 1) || (jump.x == twoRight && spot.x < 6) {
                    let spot1 = gameBoard[spot.y + jump.y/2][spot.x + jump.x/2]
                    let spot2 = gameBoard[spot.y + jump.y][spot.x + jump.x]
                    if spot2 == PlayerColor.none && (spot1 == PlayerColor.red || spot1 == PlayerColor.redKing) && (piece1 == PlayerColor.black || piece1 == PlayerColor.blackKing) {
                        isValid = true
                    }
                    if spot2 == PlayerColor.none && (spot1 == PlayerColor.black || spot1 == PlayerColor.blackKing) && (piece1 == PlayerColor.red || piece1 == PlayerColor.redKing) {
                        isValid = true
                    }
                }
            }
        }
        }
        return isValid
    }
    
    func thereIsAJump(player: Turn) -> Bool {
        var jump = false
        var piece1 = PlayerColor.none     //reg piece
        var piece2 = PlayerColor.none     //king piece
        if player == Turn.black {
            piece1 = PlayerColor.black
            piece2 = PlayerColor.blackKing
        } else {
            piece1 = PlayerColor.red
            piece2 = PlayerColor.redKing
        }
        
        for (var y = 0; y < 8; y++) {
            for (var x = 0; x < 8; x++) {
                for color in PlayerColor.allValues {
   //                 let pieceToCheck = gameBoard[y][x]
                    let piecePosition = Position(y: y, x: x)
                    if validJump(piecePosition, color: piece1, color2: piece2) {
                        jump = true
                    }
                }
            }
        }
        return jump
    }
    
    func kingMe() {
        //King at the last row
        if moveTo!.y == 0 && pieceMoving == PlayerColor.red {
            gameBoard[moveTo!.y][moveTo!.x] = PlayerColor.redKing
            turnOver = true
        }
        if moveTo!.y == 7 && pieceMoving == PlayerColor.black {
            gameBoard[moveTo!.y][moveTo!.x] = PlayerColor.blackKing
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
        turnOver = false
        println("it is \(currentPlayer.description)'s turn")
        
        println("touched piece: \(gameBoard[yCoord][xCoord].description) -- (y: \(yCoord), x: \(xCoord))")
        if pieceSelected != nil {
            moveTo = Position(y: yCoord, x: xCoord)
            let piece1 = gameBoard[pieceSelected!.y][pieceSelected!.x]
        
            if currentPlayer == Turn.black {
                pieceMoving = PlayerColor.black
                pieceMovingKing = PlayerColor.blackKing
            } else {
                pieceMoving = PlayerColor.red
                pieceMovingKing = PlayerColor.redKing
            }
        
            if piece1 != PlayerColor.none {
                let validMoves = movesAllowed(pieceSelected!)
                var noForceJump: Bool = true
                let capture_y = pieceSelected!.y + (moveTo!.y - pieceSelected!.y)/2
                let capture_x = pieceSelected!.x + (moveTo!.x - pieceSelected!.x)/2
                
                if thereIsAJump(currentPlayer) {
                    for move in validJumps[piece1]! {
                        println("there is a jump")
                        
                        if moveTo!.y == (pieceSelected!.y + move.y) && moveTo!.x == (pieceSelected!.x + move.x) && gameBoard[pieceSelected!.y + move.y/2][pieceSelected!.x + move.x/2] != PlayerColor.none {
                            noForceJump = false
                            movePiece((y1: pieceSelected!.y, x1: pieceSelected!.x), to: (y2: moveTo!.y, x2: moveTo!.x))
                            gameBoard[capture_y][capture_x] = PlayerColor.none
                            kingMe()
                            if validJump(moveTo!, color: pieceMoving, color2: pieceMovingKing) {
                                pieceSelected = moveTo
                            } else {
                            turnOver = true
                            }
                        }
                    }
                } else {
                    for move in validM[piece1]! {
                        
                        if moveTo!.y == (pieceSelected!.y + move.y) && moveTo!.x == (pieceSelected!.x + move.x) && gameBoard[moveTo!.y][moveTo!.x] == PlayerColor.none {
                            movePiece((y1: pieceSelected!.y, x1: pieceSelected!.x), to: (y2: moveTo!.y, x2: moveTo!.x))
                            kingMe()
                            turnOver = true
                        }
                    }
                }
                
                
                if turnOver {
                    turnSwitch()
                }
                pieceSelected = nil
            }
        }
        
        if  (pieceSelected == nil) {
            if currentPlayer == Turn.black {
                if gameBoard[yCoord][xCoord] == PlayerColor.black || gameBoard[yCoord][xCoord] == PlayerColor.blackKing {
                    pieceSelected = Position(y: yCoord, x: xCoord)
                    //               movesAllowed(pieceSelected!)
                }
            } else {
                if gameBoard[yCoord][xCoord] == PlayerColor.red || gameBoard[yCoord][xCoord] == PlayerColor.redKing {
                    pieceSelected = Position(y: yCoord, x: xCoord)
                    //               movesAllowed(pieceSelected!)
                }
            }
        }
        
        self.setNeedsDisplay()
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
        if piece != PlayerColor.none {
            var selectedPieceImages = [PlayerColor.red: "selectedRed", PlayerColor.black: "selectedBlack", PlayerColor.redKing: "selectedRedKing", PlayerColor.blackKing: "selectedBlackKing"]
            var selected: UIImage = UIImage(named: selectedPieceImages[piece]!)!
            var sq: CGRect = CGRect(x: (8 + (pieceWidth * (self.pieceSelected!.x))), y: 8 + (pieceHeight * (self.pieceSelected!.y)), width: pieceWidth, height: pieceHeight)
            selected.drawInRect(sq)
        }
        
        if piece != PlayerColor.none {
            let validMoves = movesAllowed(pieceSelected!)
            var noForceJump: Bool = true
            
            if thereIsAJump(currentPlayer) {
                
                for jumpMove in validJumps[piece]! {
    //            println(jumpMove)
                    var moveByY = pieceSelected!.y + jumpMove.y
                    var moveByX = pieceSelected!.x + jumpMove.x
                    for move in validMoves {
     //               println(move)
                
                    if moveByY == move.y && moveByX == move.x {
     //                   println("image call")
                        noForceJump = false
                        possibleMoveImages(pieceSelected!, offset: jumpMove)
                    }
                }
            }
            }else {
                for regMove in validM[piece]! {
       //             println(regMove)
                    var moveByY = pieceSelected!.y + regMove.y
                    var moveByX = pieceSelected!.x + regMove.x
                    
                    for move in validMoves {
        //                println(move)
                
                        if moveByY == move.y && moveByX == move.x {
      //                      println("image call")
                            possibleMoveImages(pieceSelected!, offset: regMove)
                        }
                    }
                }
            }
        }
    }
    
    func resetGame() {
        gameBoard = [
        [PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black],
        [PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none],
        [PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black, PlayerColor.none, PlayerColor.black],
        [PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none],
        [PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none, PlayerColor.none],
        [PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none],
        [PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red],
        [PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none, PlayerColor.red, PlayerColor.none],
        ]
        turnOver = false
        currentPlayer = Turn.black
        pieceMoving = PlayerColor.none
        pieceMovingKing = PlayerColor.none
        pieceSelected = nil
        moveTo = nil
        self.setNeedsDisplay()
    }
}