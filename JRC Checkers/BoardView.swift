import UIKit

import AVFoundation
import Foundation

class BoardView: UIView {
    @IBOutlet var userMessage: UILabel!
    
    let boardState = BoardState()
    
    let pieceSize: Int = 38
    
    let board: UIImage = UIImage(named: "board")!
    let pieceImage = [PC.red: UIImage(named: "red")!, PC.black: UIImage(named: "black")!, PC.redKing: UIImage(named: "redKing")!, PC.blackKing: UIImage(named: "blackKing")]

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        let boardSize: CGRect = CGRect(x: 0, y: 0, width: 320, height: 320)
        board.drawInRect(boardSize)
        
        for (var y = 0; y < 8; y++) {
            for (var x = 0; x < 8; x++) {
                if boardState.gameBoard[y][x] != PC.none {
                    let nextPiece = pieceImage[boardState.gameBoard[y][x]]!!
                    let pieceDimension: CGRect = CGRect(x: (8 + (x * pieceSize)), y: (8 + (y * pieceSize)), width: pieceSize,height: pieceSize)
                    nextPiece.drawInRect(pieceDimension)
                }
            }
        }
        boardState.showAILastMove()
        
        if boardState.pieceSelected != nil {
            boardState.showPossibleMoves()
        }
    }
    
    func gameIsOver() {
        if boardState.enemyAllCaptured() {
            boardState.aiLastMoveFrom = nil
            boardState.aiLastMoveTo = nil
            userMessage.text = "\(boardState.currentTeam.description) wins!"
        }
    }

    override func touchesEnded(touches: NSSet, withEvent event:UIEvent) {
        if boardState.currentTeam == Team.black {
            let touch: UITouch = touches.anyObject() as! UITouch
            let touchLocation: CGPoint = touch.locationInView(self)
            
            let squareWidth =  (self.frame.width / 8)
            let squareHeight = (self.frame.height / 8)
            
            let xCoord: Int = Int(touchLocation.x / squareWidth)
            let yCoord: Int = Int(touchLocation.y / squareHeight)
            
            boardState.pieceWasTouched(Position(y: yCoord, x: xCoord))
            self.setNeedsDisplay()
            if boardState.turnOver && !boardState.enemyAllCaptured() {

                boardState.turnSwitch()
                println("*** it is \(boardState.currentTeam.description)'s turn ***")
                userMessage.text = "It is red's turn"
                //  boardState.waitThenDoStuff()
                boardState.aiTurn()
                boardState.turnSwitch()
                println("*** it is \(boardState.currentTeam.description)'s turn ***")
                boardState.moveAlreadyStarted = false
                
                boardState.pieceSelected = nil
                userMessage.text = "It is black's turn"
            } else {
                gameIsOver()
            }
        }
    }
    
    func resetGame() {
        boardState.gameBoard = [
            [PC.none, PC.black, PC.none, PC.black, PC.none, PC.black, PC.none, PC.black],
            [PC.black, PC.none, PC.black, PC.none, PC.black, PC.none, PC.black, PC.none],
            [PC.none, PC.black, PC.none, PC.black, PC.none, PC.black, PC.none, PC.black],
            [PC.none, PC.none, PC.none, PC.none, PC.none, PC.none, PC.none, PC.none],
            [PC.none, PC.none, PC.none, PC.none, PC.none, PC.none, PC.none, PC.none],
            [PC.red, PC.none, PC.red, PC.none, PC.red, PC.none, PC.red, PC.none],
            [PC.none, PC.red, PC.none, PC.red, PC.none, PC.red, PC.none, PC.red],
            [PC.red, PC.none, PC.red, PC.none, PC.red, PC.none, PC.red, PC.none],
        ]
        boardState.turnOver = false
        boardState.currentTeam = Team.black
        boardState.pieceSelected = nil
        boardState.moveAlreadyStarted = false
        boardState.aiLastMoveTo = nil
        boardState.aiLastMoveFrom = nil
        userMessage.text = "It is \(boardState.currentTeam.description)'s turn"
        self.setNeedsDisplay()
    }
    
    func undoMove() {
        
        if boardState.moveHistory.count > 0 {
            boardState.gameBoard = boardState.moveHistory.last!
            boardState.currentTeam = Team.black
            boardState.aiLastMoveTo = nil
            boardState.aiLastMoveFrom = nil
            boardState.moveAlreadyStarted = false
            userMessage.text = "It is \(boardState.currentTeam.description)'s turn"
            boardState.moveHistory.removeLast()
            self.setNeedsDisplay()
        }
    }
}


    


/*
 * Display possible moves
 */
    

/*

}*/

class BoardState {
    /*
    * Game State
    */
    
    let pieceSize: Int = 38
    var turnOver = false
    var moveAlreadyStarted = false
    
    var currentTeam = Team.black
    
    var audioPlayer = AVAudioPlayer()
    var moveHistory: [[[PC]]] = []

    
    let selectedPieceImages = [PC.red: UIImage(named: "selectedRed")!, PC.black: UIImage(named: "selectedBlack")!, PC.redKing: UIImage(named: "selectedRedKing")!, PC.blackKing: UIImage(named: "selectedBlackKing")!]
    let possibleMove: UIImage = UIImage(named: "selectedSquare")!
    let lastMovePieceImages = [PC.red: UIImage(named: "lastMoveRed")!, PC.redKing: UIImage(named: "lastMoveRedKing")!]
    let lastMoveImage: UIImage = UIImage(named: "lastMove")!
    
    var pieceSelected: Position?
    var aiLastMoveFrom: Position?
    var aiLastMoveTo: Position?
    
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
    init() {
        
    }
    
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
    
    
    func movePiece(from: Position, to: Position) {
        let pieceToMove = gameBoard[from.y][from.x]
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
        let oldPosition = Position(y: position.y, x: position.x)
        let newPosition = Position(y: oldPosition.y + move.y, x: oldPosition.x + move.x)
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
        
        return validMoves
    }
    
    func jumpIsValid(jumpPosition: Position, jump: Move) -> Bool {
        var isValid = false
        //get the position of the obstacle
        let obstacle_position = movedPosition(jumpPosition, move: Move(y: -jump.y/2, x: -jump.x/2))
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
        
        return validJumps
    }
    
    func kingMe(#newPosition: Position) {
        //King at the last row
        if newPosition.y == 0 && gameBoard[newPosition.y][newPosition.x] == PC.red {
            gameBoard[newPosition.y][newPosition.x] = PC.redKing
            turnIsOver()
        }
        if newPosition.y == 7 && gameBoard[newPosition.y][newPosition.x] == PC.black {
            gameBoard[newPosition.y][newPosition.x] = PC.blackKing
            turnIsOver()
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
    
    func enemyInLast3Rows() -> Bool {
        var enemyPresent = false
        
        for y in 5...7 {
            for x in 0...7 {
                let piecePosition = Position(y: y, x: x)
                let nextPiece = gameBoard[piecePosition.y][piecePosition.x]
                if isEnemy(nextPiece) {
                    enemyPresent = true
                }
            }
        }
        
        return enemyPresent
    }
    
    func enemyAllCaptured() -> Bool {
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
    
    func isFriendlyKing(pieceInQuestion: PC) -> Bool {
        var friendly = false
        if currentTeam == Team.black && pieceInQuestion == PC.blackKing {
            friendly = true
        } else if currentTeam == Team.red && pieceInQuestion == PC.redKing {
            friendly = true
        }
        return friendly
    }
    
    func turnIsOver() -> Bool {
        if !turnOver {
            turnOver = true
        }
        return turnOver
    }
    
    func activatePieceMovingSound() {
        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pieceMoveSound", ofType: "wav")!)
    //    println(alertSound)
        
        // Removed deprecated use of AVAudioSessionDelegate protocol
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        audioPlayer.prepareToPlay()
        
        audioPlayer.play()

    }
    
    func pieceWasTouched(pieceTouched: Position) {
        turnOver = false
        let nextPiece = gameBoard[pieceTouched.y][pieceTouched.x]
        println("touched piece: \(gameBoard[pieceTouched.y][pieceTouched.x].description) -- (y: \(pieceTouched.y), x: \(pieceTouched.x))")
        
        if isFriendly(nextPiece) && !moveAlreadyStarted {
            pieceSelected = pieceTouched
            
        } else if pieceSelected != nil {
            let validMoves = movesAllowed(pieceSelected!)
            let validJumps = jumpsAllowed(pieceSelected!)
            println("Moves: \(validMoves)")
            println("Jumps: \(validJumps)")
            let capture_y = pieceSelected!.y + (pieceTouched.y - pieceSelected!.y)/2
            let capture_x = pieceSelected!.x + (pieceTouched.x - pieceSelected!.x)/2
            
            if validJumps.count > 0 {
                for jump in validJumps {
                    if pieceTouched == jump && gameBoard[capture_y][capture_x] != PC.none {
                        moveHistory.append(gameBoard)
                        movePiece(pieceSelected!, to: pieceTouched)
                        activatePieceMovingSound()
                        gameBoard[capture_y][capture_x] = PC.none
                        kingMe(newPosition: pieceTouched)
                        let nextJump = jumpsAllowed(pieceTouched)
                        if nextJump.count > 0 {
                            pieceSelected = pieceTouched
                            moveAlreadyStarted = true
                        } else {
                            turnIsOver()
                        }
                    }
                }
            } else if !isThereForceJump() {
                for move in validMoves {
                    if pieceTouched == move && gameBoard[pieceTouched.y][pieceTouched.x] == PC.none {
                        moveHistory.append(gameBoard)
                        movePiece(pieceSelected!, to: pieceTouched)
                        activatePieceMovingSound()
                        kingMe(newPosition: pieceTouched)
                        turnIsOver()
                        
                    }
                }
            }
            
            
        }
        
    }
    
    func possibleMoveImages(pieceSelected: Position, offset: Move) {
        let locationOnBoard: CGRect = CGRect(x: (8 + (pieceSize * (self.pieceSelected!.x + offset.x))), y: 8 + (pieceSize * (self.pieceSelected!.y + offset.y)), width: pieceSize, height: pieceSize)
        possibleMove.drawInRect(locationOnBoard)
    }
    
    //assume that the front for black is going towards red; and front for red is going towards black
    //assumes that left and right are relative to the user's view
    func showPossibleMoves() {
        let piece = gameBoard[pieceSelected!.y][pieceSelected!.x]
        if piece != PC.none {
            
            let sq: CGRect = CGRect(x: (8 + (pieceSize * (self.pieceSelected!.x))), y: 8 + (pieceSize * (self.pieceSelected!.y)), width: pieceSize, height: pieceSize)
            let selectedImage: UIImage = selectedPieceImages[piece]!
            selectedImage.drawInRect(sq)
            
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
    
    func showAILastMove() {
        if aiLastMoveTo != nil && aiLastMoveFrom != nil {
            let piece = gameBoard[aiLastMoveTo!.y][aiLastMoveTo!.x]
            if piece != PC.none {
                let sqTo: CGRect = CGRect(x: (8 + (pieceSize * (self.aiLastMoveTo!.x))), y: 8 + (pieceSize * (self.aiLastMoveTo!.y)), width: pieceSize, height: pieceSize)
                let lastMovePieceImage: UIImage = lastMovePieceImages[piece]!
                lastMovePieceImage.drawInRect(sqTo)
            }
            
            let sqFrom: CGRect = CGRect(x: (8 + (pieceSize * (self.aiLastMoveFrom!.x))), y: 8 + (pieceSize * (self.aiLastMoveFrom!.y)), width: pieceSize, height: pieceSize)
            lastMoveImage.drawInRect(sqFrom)
        }
    }
    
    
    func aiForceJump() -> [Position] {
        var piecesToJump: [Position] = []
        for y in 0...7 {
            for x in 0...7 {
                let piecePosition = Position(y: y, x: x)
                let nextPiece = gameBoard[piecePosition.y][piecePosition.x]
                if isFriendly(nextPiece) {
                    if jumpsAllowed(piecePosition).count > 0 {
                        piecesToJump.append(piecePosition)
                    }
                }
            }
        }
        
        return piecesToJump
    }
    
    func aiMove() -> [Position] {
        var piecesToMove: [Position] = []
        for y in 0...7 {
            for x in 0...7 {
                let piecePosition = Position(y: y, x: x)
                let nextPiece = gameBoard[piecePosition.y][piecePosition.x]
                if isFriendly(nextPiece) {
                    if movesAllowed(piecePosition).count > 0 {
                        piecesToMove.append(piecePosition)
                    }
                }
            }
        }
        
        return piecesToMove
    }
  /*
    //keeps track of the score of both teams
    func scoring(board: [[PC]]) -> (black: Int, red: Int) {
        var teamBlackScore = 0
        var teamRedScore = 0
        for y in 0...7 {
            for x in 0...7 {
                if board[y][x] == PC.black {
                    if y == 0 || y == 6 {
                        teamBlackScore++
                    }
                    teamBlackScore++
                } else if board[y][x] == PC.blackKing {
                    teamBlackScore += 2
                } else if board[y][x] == PC.red {
                    if y == 7 || y == 1{
                        teamRedScore++
                    }
                    teamRedScore++
                } else if board[y][x] == PC.redKing {
                    teamRedScore += 2
                }
            }
        }
        return (teamBlackScore, teamRedScore)
    }
*/
    
    
    func AIThinking(aiMoves: [Position]) -> MoveScore {

        
        var possibleMoves: [MoveScore] = []
        
        
        //set up the moves to be scored
        for move in aiMoves {
            let validMs = movesAllowed(move)
            for validM in validMs {
                possibleMoves.append(MoveScore(Move: move, To: validM, Score: 0))
            }
        }
        let pseudoBoard = gameBoard
        
        let randomNum = arc4random_uniform(3)
        //     println("x: \(x)")
        
        /*    __   __   __   __   __   __   __
        |U3L3||||||U3L1||||||U3R1||||||U3R3|
        __   __   __   __   __   __   __
        ||||||U2L2|||||| U2 ||||||U2R2||||||
        __   __   __   __   __   __   __
        |U1L3||||||U1L1||||||U1R1||||||U1R3|
        __   __   __   __   __   __   __
        |||||| L2 |||||| PC |||||| R2 ||||||
        __   __   __   __   __   __   __
        |D1L3||||||D1L1||||||D1R1||||||D1R3|
        __   __   __   __   __   __   __
        ||||||D2L2|||||| D2 ||||||D2R2||||||
        __   __   __   __   __   __   __
        |D3L3||||||D3L1||||||D3R1||||||D3R3|
        __   __   __   __   __   __   __
        
        */
        
        //move to set jump
        var indexMove = 0
        
        for nextMove in possibleMoves {
            let U3L3Position = movedPosition(nextMove.Move, move: Move(y: -3, x: -3))
            let U3L1Position = movedPosition(nextMove.Move, move: Move(y: -3, x: -1))
            let U3R1Position = movedPosition(nextMove.Move, move: Move(y: -3, x: 1))
            let U3R3Position = movedPosition(nextMove.Move, move: Move(y: -3, x: 3))
            let U2L2Position = movedPosition(nextMove.Move, move: Move(y: -2, x: -2))
            let U2Position = movedPosition(nextMove.Move, move: Move(y: -2, x: 0))
            let U2R2Position = movedPosition(nextMove.Move, move: Move(y: -2, x: 2))
            let U1L3Position = movedPosition(nextMove.Move, move: Move(y: -1, x: -3))
            let U1L1Position = movedPosition(nextMove.Move, move: Move(y: -1, x: -1))
            let U1R1Position = movedPosition(nextMove.Move, move: Move(y: -1, x: 1))
            let U1R3Position = movedPosition(nextMove.Move, move: Move(y: -1, x: 3))
            let L2Position = movedPosition(nextMove.Move, move: Move(y: 0, x: -2))
            let R2Position = movedPosition(nextMove.Move, move: Move(y: 0, x: 2))
            let D1L3Position = movedPosition(nextMove.Move, move: Move(y: 1, x: -3))
            let D1L1Position = movedPosition(nextMove.Move, move: Move(y: 1, x: -1))
            let D1R1Position = movedPosition(nextMove.Move, move: Move(y: 1, x: 1))
            let D1R3Position = movedPosition(nextMove.Move, move: Move(y: 1, x: 3))
            let D2L2Position = movedPosition(nextMove.Move, move: Move(y: 2, x: -2))
            let D2Position = movedPosition(nextMove.Move, move: Move(y: 2, x: 0))
            let D2R2Position = movedPosition(nextMove.Move, move: Move(y: 2, x: 2))
            let D3L3Position = movedPosition(nextMove.Move, move: Move(y: 3, x: -3))
            let D3L1Position = movedPosition(nextMove.Move, move: Move(y: 3, x: -1))
            let D3R1Position = movedPosition(nextMove.Move, move: Move(y: 3, x: 1))
            let D3R3Position = movedPosition(nextMove.Move, move: Move(y: 3, x: 3))
            
            let U3L3 = gameBoard[U3L3Position.y][U3L3Position.x]
            let U3L1 = gameBoard[U3L1Position.y][U3L1Position.x]
            let U3R1 = gameBoard[U3R1Position.y][U3R1Position.x]
            let U3R3 = gameBoard[U3R3Position.y][U3R3Position.x]
            let U2L2 = gameBoard[U2L2Position.y][U2L2Position.x]
            let U2 = gameBoard[U2Position.y][U2Position.x]
            let U2R2 = gameBoard[U2R2Position.y][U2R2Position.x]
            let U1L3 = gameBoard[U1L3Position.y][U1L3Position.x]
            let U1L1 = gameBoard[U1L1Position.y][U1L1Position.x]
            let U1R1 = gameBoard[U1R1Position.y][U1R1Position.x]
            let U1R3 = gameBoard[U1R3Position.y][U1R3Position.x]
            let L2 = gameBoard[L2Position.y][L2Position.x]
            let R2 = gameBoard[R2Position.y][R2Position.x]
            let D1L3 = gameBoard[D1L3Position.y][D1L3Position.x]
            let D1L1 = gameBoard[D1L1Position.y][D1L1Position.x]
            let D1R1 = gameBoard[D1R1Position.y][D1R1Position.x]
            let D1R3 = gameBoard[D1R3Position.y][D1R3Position.x]
            let D2L2 = gameBoard[D2L2Position.y][D2L2Position.x]
            let D2 = gameBoard[D2Position.y][D2Position.x]
            let D2R2 = gameBoard[D2R2Position.y][D2R2Position.x]
            let D3L3 = gameBoard[D3L3Position.y][D3L3Position.x]
            let D3L1 = gameBoard[D3L1Position.y][D3L1Position.x]
            let D3R1 = gameBoard[D3R1Position.y][D3R1Position.x]
            let D3R3 = gameBoard[D3R3Position.y][D3R3Position.x]
            let piece = gameBoard[nextMove.Move.y][nextMove.Move.x]
            
            
            //kingme
            if nextMove.Move.y == 1 && possibleMoves[indexMove].Score == 0 {
                if U1L1 == PC.none {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 20)
                } else {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 20)
                }
            }
            
            //king set up next jump
            let kingJumpL = U1L1 == PC.none && isEnemy(L2) && U2L2 == PC.none && D1L3 == PC.none && isEnemy(U2)
            let kingJumpR = U1R1 == PC.none && isEnemy(R2) && U2R2 == PC.none && D1R3 == PC.none && isEnemy(U2)
            if possibleMoves[indexMove].Score == 0 {
                if kingJumpL {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 19)
                } else if kingJumpR {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 19)
                }
            }
            
            //king move between two pieces
            let kingFork1 = isFriendlyKing(piece) && U1L1 == PC.none && isEnemy(L2) && isEnemy(U2) && U2L2 == PC.none && (D1L3 == PC.none || U3R1 == PC.none)
            let kingFork2 = isFriendlyKing(piece) && U1R1 == PC.none && isEnemy(R2) && isEnemy(U2) && U2R2 == PC.none && (D1R3 == PC.none || U3L1 == PC.none)
            let kingFork3 = isFriendlyKing(piece) && D1L1 == PC.none && isEnemy(L2) && isEnemy(D2) && D2L2 == PC.none && (U1L3 == PC.none || D3R1 == PC.none)
            let kingFork4 = isFriendlyKing(piece) && D1R1 == PC.none && isEnemy(R2) && isEnemy(D2) && D2R2 == PC.none && (U1R3 == PC.none || D3L1 == PC.none)
            if possibleMoves[indexMove].Score == 0 {
                if kingFork1 {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 18)
                } else if kingFork2 {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 18)
                } else if kingFork3 {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: D1L1Position, Score: 18)
                } else if kingFork4 {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: D1R1Position, Score: 18)
                }
            }
            
            //king set up next risker jump
            let kingRiskierJumpL = isFriendlyKing(piece) && U1L1 == PC.none && isEnemy(L2) && U2L2 == PC.none && D1L3 == PC.none
            let kingRiskierJumpR = isFriendlyKing(piece) && U1R1 == PC.none && isEnemy(R2) && U2R2 == PC.none && D1R3 == PC.none
            if possibleMoves[indexMove].Score == 0 {
                if kingRiskierJumpL {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 17)
                } else if kingRiskierJumpR {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 17)
                }
            }
            
            //friendly move between two pieces
            let forkMove1 = isFriendly(piece) && U1L1 == PC.none && isEnemy(L2) && isEnemy(U2) && U2L2 == PC.none && (D1L3 == PC.none || U3R1 == PC.none)
            let forkMove2 = isFriendly(piece) && U1R1 == PC.none && isEnemy(R2) && isEnemy(U2) && U2R2 == PC.none && (D1R3 == PC.none || U3L1 == PC.none)
            
            if possibleMoves[indexMove].Score == 0 {
                if forkMove1 {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 16)
                } else if forkMove2 {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 16)
                }
            }
            
            //move king closer to enemy
            let kingRegMove = isFriendlyKing(piece) && !isEnemy(U2) && !isEnemy(U2L2)
            let kingRegMove2 = isFriendlyKing(piece) && !isEnemy(U2) && !isEnemy(U2R2)
            let kingRegMove3 = isFriendlyKing(piece) && !isEnemy(D2) && !isEnemy(D2L2)
            let kingRegMove4 = isFriendlyKing(piece) && !isEnemy(D2) && !isEnemy(D2R2)
            
            if possibleMoves[indexMove].Score == 0 {
                if kingRegMove4 && D1R1 == PC.none && enemyInLast3Rows() {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: D1R1Position, Score: 13)
                } else if kingRegMove3 && D1L1 == PC.none && enemyInLast3Rows() {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: D1L1Position, Score: 13)
                } else if kingRegMove2 && U1R1 == PC.none {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 13)
                } else if kingRegMove && U1L1 == PC.none {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 13)
                }
            }
            
            
            //move out of danger if possible (attack from the front)
            let attackFromRight = isEnemy(U1R1) && isEnemy(U2R2) && U1L1 == PC.none && !isEnemy(U2L2) && !isEnemy(U2) && L2 != PC.none
            let attackFromLeft = isEnemy(U1L1) && isEnemy(U2L2) && U1R1 == PC.none && !isEnemy(U2R2) && !isEnemy(U2) && R2 != PC.none
            if possibleMoves[indexMove].Score == 0 {
                if attackFromRight {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 12)
                } else if attackFromLeft {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 12)
                }
            }
            
            //move out of danger if possible (from behind right, by king)
            let leftIsSafe = !isEnemy(U2L2) && U1L1 == PC.none
            let rightIsSafe = !isEnemy(U2R2) && U1R1 == PC.none
            if possibleMoves[indexMove].Score == 0 && !isEnemy(U2) && D1R1 == PC.blackKing {
                if leftIsSafe {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 11)
                } else if rightIsSafe {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 11)
                }
            }
            //move out of danger if possible (from behind left, by king)
            if possibleMoves[indexMove].Score == 0 && !isEnemy(U2) && D1L1 == PC.blackKing{
                if leftIsSafe {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 10)
                } else if rightIsSafe {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 10)
                }
            }
            
            //side pressure
            let leftSide = U1L1 == PC.none && U3R1 == PC.none && nextMove.Move.y == 1
            let rightSide = U1R1 == PC.none && U3L1 == PC.none && nextMove.Move.y == 6
            if possibleMoves[indexMove].Score == 0 && isEnemy(U2) {
                if leftSide {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 9)
                } else if rightSide {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 9)
                }
            }
            
            
            //set pyramid move to centre without setting off a jump
            let priorityPyramid1 = [Position(y: 5, x: 2), Position(y: 5, x: 4), Position(y: 4, x: 3), Position(y: 4, x: 5)]
            for priorityMove in priorityPyramid1 {
                if nextMove.Move == priorityMove && !isEnemy(U2) && possibleMoves[indexMove].Score == 0 {
                    
                    if U1L1 == PC.none && !isEnemy(U2L2) {
                        possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 8)
                    } else if U1R1 == PC.none && !isEnemy(U2R2) {
                        possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 8)
                    }
                    
                }
            }
            
            //set up support for pyramid
            let priorityPyramid2 = [Position(y: 5, x: 2), Position(y: 5, x: 4), Position(y: 5, x: 6), Position(y: 6, x: 1), Position(y: 6, x: 3), Position(y: 6, x: 5)]
            for priorityMove in priorityPyramid2 {
                if nextMove.Move == priorityMove && possibleMoves[indexMove].Score == 0 {
                    if isFriendly(U2R2) && U1R1 == PC.none {
                        possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 7)
                    } else if (isFriendly(U2L2) || isFriendly(U2)) && U1L1 == PC.none {
                        possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 7)
                    }
                }
            }
            
            //move piece to defend
            let defendCond = isFriendly(L2) && isFriendly(R2)
            if possibleMoves[indexMove].Score == 0 {
                
                if U1L1 == PC.none && defendCond && isEnemy(U2){
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 6)
                } else if U1R1 == PC.none && isFriendly(R2) && isEnemy(U2) {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 6)
                } else if U1L1 == PC.none && isFriendly(L2) && isEnemy(U2){
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 6)
                }
                
            }
            
            //move side piece
            let sidePieceMoves = [Position(y: 4, x: 7), Position(y: 5, x: 0), Position(y: 6, x: 7)]
            for sidePieceMove in sidePieceMoves {
                if nextMove.Move == sidePieceMove && !isEnemy(U2) && possibleMoves[indexMove].Score == 0 {
                    if U1R1 == PC.none && !isEnemy(U2R2) {
                        possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 5)
                    } else if U1L1 == PC.none && !isEnemy(U2L2) {
                        possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 5)
                    }
                }
            }
            
            
            //move any piece
            if possibleMoves[indexMove].Score == 0 {
                if nextMove.Move.y < 7 {
                    if U1L1 == PC.none {
                        possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 4)
                    } else if U1R1 == PC.none {
                        possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 4)
                    }
                }
            }
            
            //set up jump -- possible trade
            let setJumpLeft = U1R1 == PC.none && isFriendly(R2) && isEnemy(U2) && U3L1 == PC.none
            let setJumpRight = U1L1 == PC.none && isFriendly(L2) && isEnemy(U2) && U3R1 == PC.none
            if possibleMoves[indexMove].Score == 0 {
                if setJumpLeft {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 3)
                } else if setJumpRight {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 3)
                }
            }
            
            //move to bate jump
            if possibleMoves[indexMove].Score == 0 {
                if isEnemy(U2L2) && U1L1 == PC.none {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 2)
                } else if isEnemy(U2R2) && U1R1 == PC.none {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 2)
                }
            }
            
            //move last row
            if nextMove.Move.y == 7 && possibleMoves[indexMove].Score == 0 && U1L1 == PC.none {
                possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1L1Position, Score: 1)
            } else if nextMove.Move.y == 7 && possibleMoves[indexMove].Score == 0 && U1R1 == PC.none {
                possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, To: U1R1Position, Score: 1)
            }
            
            indexMove++
        }

        println(possibleMoves)
        
        //choose the move with the highest score
        indexMove = 0
        var indexOfBestMove = 0
        var bestScore = 0

        for nextMove in possibleMoves {
            let validMoves = movesAllowed(nextMove.Move)
            for validMove in validMoves {
                if nextMove.Score > bestScore && nextMove.Move != nextMove.To && validMove == nextMove.To {
                    indexOfBestMove = indexMove
                    bestScore = nextMove.Score
                }
            }
            indexMove++
        }
        
        return possibleMoves[indexOfBestMove]
    }
    
    func aiTurn() {
        
        println("Moves: \(aiMove())")
        println("Jumps: \(aiForceJump())")
        
        if isThereForceJump() {
            pieceSelected = aiForceJump()[0]
            let aiValidJumps = jumpsAllowed(pieceSelected!)
            let pieceTouched = aiValidJumps[0]
            
            let capture_y = pieceSelected!.y + (pieceTouched.y - pieceSelected!.y)/2
            let capture_x = pieceSelected!.x + (pieceTouched.x - pieceSelected!.x)/2
            if gameBoard[capture_y][capture_x] != PC.none {
                movePiece(pieceSelected!, to: pieceTouched)
                aiLastMoveTo = pieceTouched
                aiLastMoveFrom = pieceSelected
                gameBoard[capture_y][capture_x] = PC.none
                //quick solution, but this only allows double jump max, and piece might jump ever after turning king
                let nextJump = jumpsAllowed(pieceTouched)
                if nextJump.count > 0 {
                    pieceSelected = pieceTouched
                    aiTurn()
                }
                kingMe(newPosition: pieceTouched)
            }
            
        } else if aiMove().count > 0 {
            let AIThink = AIThinking(aiMove())
            println("Move: \(AIThink.Move), To: \(AIThink.To) -- Score: \(AIThink.Score)")
//            pieceSelected = AIThink.Move
  //          let aiValidMoves = movesAllowed(pieceSelected!)
   //         for pieceTouched in aiValidMoves {

      //          if gameBoard[AIThink.To.y][AIThink.To.x] == PC.none {
                    
                    movePiece(AIThink.Move, to: AIThink.To)
                    aiLastMoveTo = AIThink.To
                    aiLastMoveFrom = AIThink.Move
                    kingMe(newPosition: AIThink.To)
      //          }
     //       }
        }
    }
    
}

    
    
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

struct MoveScore: Printable {
    let Move: Position
    let To: Position
    let Score: Int
    var description: String {
        return "Position: \(Move) To: \(To) - Score: \(Score)"
    }
}