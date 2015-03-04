import UIKit

class BoardView: UIView {
    
    let pieceWidth: Int = 38
    let pieceHeight: Int = 38
    var secondRow = 46
    var seventhRow = 236

    var turnOver = false
    var currentPlayer = Turn.black
    var pieceMoving: PC = PC.none
    var pieceMovingKing: PC = PC.none
    
    let oneLeft = -1
    let twoLeft = -2
    let oneRight = 1
    let twoRight = 2
    let oneUp = -1
    let twoUp = -2
    let oneDown = 1
    let twoDown = 2
    
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
    
    func movePiece(from: (y1: Int, x1: Int), to: (y2: Int, x2: Int)) {
        let pieceToMove = gameBoard[pieceSelected!.y][pieceSelected!.x]
        gameBoard[from.y1][from.x1] = PC.none
        gameBoard[to.y2][to.x2] = pieceToMove
    }
    
    func turnSwitch() {
        if currentPlayer == Turn.red {
            currentPlayer = Turn.black
        } else {
            currentPlayer = Turn.red
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
    
    func moveIsValid(spot: Position) -> Bool {
        var isValid = false
        let spotToMoveTo = gameBoard[spot.y][spot.x]
        
        if spotToMoveTo == PC.none {
            isValid = true
        }
        
        return isValid
    }
    
    func movesAllowed(pieceToCheck: Position) -> [Position] {
        var validMoves: [Position] = []
        let piece = gameBoard[pieceToCheck.y][pieceToCheck.x]
        let moves = validM[piece]!
        for move in moves {

            if moveIsValid(movedPosition(pieceToCheck, move: move)) {
                validMoves.append(movedPosition(pieceToCheck, move: move))
            }
        }
        println("Possible moves: \(validMoves)")
        return validMoves
    }
    /*
    func movesAllowed(piece: Position) -> [Position] {
        var validMoves: [Position] = []
        // Chris changed his mind. Use validMoves <- do this. And make move is valid way smaller!!!
        for x in 0...7 {
            for y in 0...7 {
                if moveIsValid(Position(y: y, x: x)) {
                    validMoves.append(Position(y: y, x: x))
                }
            }
        }
        println("Possible moves: \(validMoves)")
        return validMoves
    }*/
    


 
    func jumpIsValid(spot: Position, jump: Move) -> Bool {
        var isValid = false
        let piece1 = gameBoard[pieceSelected!.y][pieceSelected!.x]
        let spot1 = gameBoard[movedPosition(pieceSelected!.y, move: jump.y/2)][movedPosition(pieceSelected!.x, move: jump.x/2)]
        let spotToMoveTo = gameBoard[spot.y][spot.x]
        
        let blackCond: Bool = piece1 == PC.black && (spot1 == PC.red || spot1 == PC.redKing)
        let redCond: Bool = piece1 == PC.red &&  && (spot1 == PC.black || spot1 == PC.blackKing)
        let blackKingCond: Bool = piece1 == PC.blackKing && (spot1 == PC.red || spot1 == PC.redKing)
        let redKingCond: Bool = piece1 == PC.redKing  && (spot1 == PC.black || spot1 == PC.blackKing)
        
        if blackCond || redCond || blackKingCond || redKingCond {
            if spotToMoveTo == PC.none {
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
            
            if jumpIsValid(movedPosition(pieceToCheck, move: jump), jump: jump) {
                validJumps.append(movedPosition(pieceToCheck, move: jump))
            }
        }
        println("Possible moves: \(validJumps)")
        return validJumps
    }

 
    func validJump(spot: Position, color: PC, color2: PC) -> Bool {
        if spot.y == 0 && spot.x == 5 {
            println("chris smells")
        }
        var isValid = false
        let piece1 = gameBoard[spot.y][spot.x]
        
        if piece1 == color || piece1 == color2 {
        for jump in validJ[piece1]! {
        
            let blackCond: Bool = piece1 == PC.black && jump.y == twoDown  && spot.y < 6
            let redCond: Bool = piece1 == PC.red && jump.y == twoUp && spot.y > 1
            let blackKingCond1: Bool = piece1 == PC.blackKing && jump.y == twoDown && spot.y < 6
            let blackKingCond2: Bool = piece1 == PC.blackKing && jump.y == twoUp && spot.y > 1
            let redKingCond1: Bool = piece1 == PC.redKing && jump.y == twoDown && spot.y < 6
            let redKingCond2: Bool = piece1 == PC.redKing && jump.y == twoUp && spot.y > 1
        
            if blackCond || redCond || blackKingCond1 || redKingCond1 || blackKingCond2 || redKingCond2 {
                if (jump.x == twoLeft && spot.x > 1) || (jump.x == twoRight && spot.x < 6) {
                    let spot1 = gameBoard[spot.y + jump.y/2][spot.x + jump.x/2]
                    let spot2 = gameBoard[spot.y + jump.y][spot.x + jump.x]
                    if spot2 == PC.none && (spot1 == PC.red || spot1 == PC.redKing) && (piece1 == PC.black || piece1 == PC.blackKing) {
                        isValid = true
                    }
                    if spot2 == PC.none && (spot1 == PC.black || spot1 == PC.blackKing) && (piece1 == PC.red || piece1 == PC.redKing) {
                        isValid = true
                    }
                }
            }
        }
        }
        return isValid
    }

    
    func kingMe() {
        //King at the last row
        if moveTo!.y == 0 && pieceMoving == PC.red {
            gameBoard[moveTo!.y][moveTo!.x] = PC.redKing
            turnOver = true
        }
        if moveTo!.y == 7 && pieceMoving == PC.black {
            gameBoard[moveTo!.y][moveTo!.x] = PC.blackKing
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
                pieceMoving = PC.black
                pieceMovingKing = PC.blackKing
            } else {
                pieceMoving = PC.red
                pieceMovingKing = PC.redKing
            }
        
            if piece1 != PC.none {
                let validMoves = movesAllowed(pieceSelected!)
                let validJumps = jumpsAllowed(pieceSelected!)
                let capture_y = pieceSelected!.y + (moveTo!.y - pieceSelected!.y)/2
                let capture_x = pieceSelected!.x + (moveTo!.x - pieceSelected!.x)/2
                
                if validJumps.count > 0 {
                    for move in validJ[piece1]! {
                        println("there is a jump")
                        
                        if moveTo!.y == (pieceSelected!.y + move.y) && moveTo!.x == (pieceSelected!.x + move.x) && gameBoard[pieceSelected!.y + move.y/2][pieceSelected!.x + move.x/2] != PC.none {
                            movePiece((y1: pieceSelected!.y, x1: pieceSelected!.x), to: (y2: moveTo!.y, x2: moveTo!.x))
                            gameBoard[capture_y][capture_x] = PC.none
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
                        
                        if moveTo!.y == (pieceSelected!.y + move.y) && moveTo!.x == (pieceSelected!.x + move.x) && gameBoard[moveTo!.y][moveTo!.x] == PC.none {
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
                if gameBoard[yCoord][xCoord] == PC.black || gameBoard[yCoord][xCoord] == PC.blackKing {
                    pieceSelected = Position(y: yCoord, x: xCoord)
                    //               movesAllowed(pieceSelected!)
                }
            } else {
                if gameBoard[yCoord][xCoord] == PC.red || gameBoard[yCoord][xCoord] == PC.redKing {
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
        if piece != PC.none {
            var selectedPieceImages = [PC.red: "selectedRed", PC.black: "selectedBlack", PC.redKing: "selectedRedKing", PC.blackKing: "selectedBlackKing"]
            var selected: UIImage = UIImage(named: selectedPieceImages[piece]!)!
            var sq: CGRect = CGRect(x: (8 + (pieceWidth * (self.pieceSelected!.x))), y: 8 + (pieceHeight * (self.pieceSelected!.y)), width: pieceWidth, height: pieceHeight)
            selected.drawInRect(sq)
        }
        
        if piece != PC.none {
            let validMoves = movesAllowed(pieceSelected!)
            let validJumps = jumpsAllowed(pieceSelected!)
            var noForceJump: Bool = true
            
            if validJumps.count > 0 {
                
                for jumpMove in validJ[piece]! {
    //            println(jumpMove)
                    var moveByY = pieceSelected!.y + jumpMove.y
                    var moveByX = pieceSelected!.x + jumpMove.x
                    for jump in validJumps {
     //                 println(move)
                
                        if moveByY == jump.y && moveByX == jump.x {
     //                     println("image call")
                            noForceJump = false
                            possibleMoveImages(pieceSelected!, offset: jumpMove)
                        }
                    }
                }
            } else {
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
        currentPlayer = Turn.black
        pieceMoving = PC.none
        pieceMovingKing = PC.none
        pieceSelected = nil
        moveTo = nil
        self.setNeedsDisplay()
    }
}