import UIKit

import AVFoundation

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
        
        if boardState.pieceSelected != nil {
            boardState.showPossibleMoves()
        }
    }

    override func touchesEnded(touches: NSSet, withEvent event:UIEvent) {
        let touch: UITouch = touches.anyObject() as UITouch
        let touchLocation: CGPoint = touch.locationInView(self)
        
        let squareWidth =  (self.frame.width / 8)
        let squareHeight = (self.frame.height / 8)
        
        let xCoord: Int = Int(touchLocation.x / squareWidth)
        let yCoord: Int = Int(touchLocation.y / squareHeight)
        
        boardState.pieceWasTouched(Position(y: yCoord, x: xCoord))
        
        if !boardState.friendsAllCaptured() {
            if boardState.currentTeam == Team.black {
                userMessage.text = "It is black's turn"
            } else {
                userMessage.text = "It is red's turn"
            }
        } else {
            boardState.turnSwitch()
            userMessage.text = "\(boardState.currentTeam.description) wins!"
        }
        
        self.setNeedsDisplay()
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
        userMessage.text = "It is \(boardState.currentTeam.description)'s turn"
        self.setNeedsDisplay()
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
    
    let selectedPieceImages = [PC.red: UIImage(named: "selectedRed")!, PC.black: UIImage(named: "selectedBlack")!, PC.redKing: UIImage(named: "selectedRedKing")!, PC.blackKing: UIImage(named: "selectedBlackKing")]
    let possibleMove: UIImage = UIImage(named: "selectedSquare")!
    
    
    var pieceSelected: Position?
    
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
    
    func friendsAllCaptured() -> Bool {
        var allFriendsCaptured = true
        
        for y in 0...7 {
            for x in 0...7 {
                let piecePosition = Position(y: y, x: x)
                let nextPiece = gameBoard[piecePosition.y][piecePosition.x]
                if isFriendly(nextPiece) {
                    allFriendsCaptured = false
                }
            }
        }
        
        return allFriendsCaptured
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
                        movePiece(pieceSelected!, to: pieceTouched)
                        activatePieceMovingSound()
                        kingMe(newPosition: pieceTouched)
                        turnIsOver()
                    }
                }
            }
            
            if turnOver {
                    turnSwitch()
                    println("*** it is \(currentTeam.description)'s turn ***")
                    aiTurn()
                    turnSwitch()
                    println("*** it is \(currentTeam.description)'s turn ***")
                    moveAlreadyStarted = false
                
                pieceSelected = nil
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
            let selectedImage: UIImage = selectedPieceImages[piece]!!
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
    
    
    
    func AIThinking(aiMoves: [Position]) -> Position {
        var possibleMoves: [MoveScore] = []
        //set up the moves to be scored
        for move in aiMoves {
            possibleMoves.append(MoveScore(Move: move, Score: 0))
        }
        let priorityPyramid1 = [Position(y: 5, x: 2), Position(y: 5, x: 4), Position(y: 4, x: 3), Position(y: 4, x: 5)]
        //kingme
        var indexMove = 0
        for nextMove in possibleMoves {
            if nextMove.Move.y == 1 && nextMove.Score == 0 {
                possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, Score: 10)
            }
            indexMove++
        }
        
        
        //set pyramid move to centre without setting off a jump
        indexMove = 0
        for nextMove in possibleMoves {
            for priorityMove in priorityPyramid1 {
                if nextMove.Move == priorityMove && nextMove.Score == 0 {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, Score: 9)
                }
                
            }
            indexMove++
        }
        /*
        //move to support
        indexMove = 0
        for nextMove in possibleMoves {
            for priorityMove in priorityPyramid1 {
                if nextMove.Move == priorityMove && nextMove.Score == 0 {
                    possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, Score: 9)
                }
                indexMove++
            }
        }*/
        
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
        indexMove = 0
        
        let U3L3 = Move(y: -3, x: -3)
        let U3L1 = Move(y: -3, x: -1)
        let U3R1 = Move(y: -3, x: 1)
        let U3R3 = Move(y: -3, x: 3)
        let U2L2 = Move(y: -2, x: -2)
        let U2 = Move(y: -2, x: 0)
        let U2R2 = Move(y: -2, x: 2)
        let U1L3 = Move(y: -1, x: -3)
        let U1L1 = Move(y: -1, x: -1)
        let U1R1 = Move(y: -1, x: 1)
        let U1R3 = Move(y: -1, x: 3)
        let L2 = Move(y: 0, x: -2)
        let R2 = Move(y: 0, x: 2)
        let D1L3 = Move(y: 1, x: -3)
        let D1L1 = Move(y: 1, x: -1)
        let D1R1 = Move(y: 1, x: 1)
        let D1R3 = Move(y: 1, x: 3)
        let D2L2 = Move(y: 2, x: -2)
        let D2 = Move(y: 2, x: 0)
        let D2R2 = Move(y: 2, x: 2)
        let D3L3 = Move(y: 3, x: -3)
        let D3L1 = Move(y: 3, x: -1)
        let D3R1 = Move(y: 3, x: 1)
        let D3R3 = Move(y: 3, x: 3)
        let checkLeft = Move(y: -1, x: -1)
        let checkRight = Move(y: -1, x: 1)
        let checkLeftTwoAway = Move(y: -2, x: -2)
        let checkRightTwoAway = Move(y: -2, x: 2)
        let jumpLeftSupport = Move(y: 1, x: 1)
        let jumpRightSupport = Move(y: 1, x: -1)
        
        for nextMove in possibleMoves {
            let leftPosition = movedPosition(nextMove.Move, move: checkLeft)
            let rightPosition = movedPosition(nextMove.Move, move: checkRight)
            let leftPositionTwoAway = movedPosition(nextMove.Move, move: checkLeftTwoAway)
            let rightPositionTwoAway = movedPosition(nextMove.Move, move: checkRightTwoAway)
            let leftJPositionSupport = movedPosition(nextMove.Move, move: jumpLeftSupport)
            let rightJPositionSupport = movedPosition(nextMove.Move, move: jumpRightSupport)
            let U3L3Position = Move(y: -3, x: -3)
            let U3L1Position = Move(y: -3, x: -1)
            let U3R1Position = Move(y: -3, x: 1)
            let U3R3Position = Move(y: -3, x: 3)
            let U2L2Position = Move(y: -2, x: -2)
            let U2Position = Move(y: -2, x: 0)
            let U2R2Position = Move(y: -2, x: 2)
            let U1L3Position = Move(y: -1, x: -3)
            let U1L1Position = Move(y: -1, x: -1)
            let U1R1Position = Move(y: -1, x: 1)
            let U1R3Position = Move(y: -1, x: 3)
            let L2Position = Move(y: 0, x: -2)
            let R2Position = Move(y: 0, x: 2)
            let D1L3Position = Move(y: 1, x: -3)
            let D1L1Position = Move(y: 1, x: -1)
            let D1R1Position = Move(y: 1, x: 1)
            let D1R3Position = Move(y: 1, x: 3)
            let D2L2Position = Move(y: 2, x: -2)
            let D2Position = Move(y: 2, x: 0)
            let D2R2Position = Move(y: 2, x: 2)
            let D3L3Position = Move(y: 3, x: -3)
            let D3L1Position = Move(y: 3, x: -1)
            let D3R1Position = Move(y: 3, x: 1)
            let D3R3Position = Move(y: 3, x: 3)
            
            let setJumpLeft: Bool = isEnemy(gameBoard[leftPosition.y][leftPosition.x]) && gameBoard[leftPositionTwoAway.y][leftPositionTwoAway.x] == PC.none && isFriendly(gameBoard[jumpLeftSupport.y][jumpRightSupport.x])
            let setJumpRight: Bool = isEnemy(gameBoard[rightPosition.y][rightPosition.x]) && gameBoard[rightPositionTwoAway.y][rightPositionTwoAway.x] == PC.none && isFriendly(gameBoard[rightJPositionSupport.y][rightJPositionSupport.x])
            if (setJumpLeft || setJumpRight) && nextMove.Score == 0 {
                possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, Score: 8)
            }
            indexMove++
        }
        
        //move to bate jump
        indexMove = 0
        
        for nextMove in possibleMoves {
            let leftPosition = movedPosition(nextMove.Move, move: checkLeft)
            let rightPosition = movedPosition(nextMove.Move, move: checkRight)
            if (isEnemy(gameBoard[leftPosition.y][leftPosition.x]) || isEnemy(gameBoard[rightPosition.y][rightPosition.x])) && nextMove.Score == 0 {
                possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, Score: 8)
            }
            indexMove++
        }
        
        //move last row
        indexMove = 0
        for nextMove in possibleMoves {
            if nextMove.Move.y == 7 && nextMove.Score == 0 {
                possibleMoves[indexMove] = MoveScore(Move: nextMove.Move, Score: 1)
            }
            indexMove++
        }
        println(possibleMoves)
        
        indexMove = 0
        var indexOfBestMove = 0
        var bestScore = 0
        for nextMove in possibleMoves {
            if nextMove.Score > bestScore {
                indexOfBestMove = indexMove
                bestScore = nextMove.Score
            }
            indexMove++
        }
        
        return possibleMoves[indexOfBestMove].Move
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
                gameBoard[capture_y][capture_x] = PC.none
                kingMe(newPosition: pieceTouched)
                //quick solution, but this only allows double jump max, and piece might jump ever after turning king
                let nextJump = jumpsAllowed(pieceTouched)
                if nextJump.count > 0 {
                    pieceSelected = pieceTouched
                    aiTurn()
                }
            }
            
        } else if aiMove().count > 0 {
            
            pieceSelected = AIThinking(aiMove())
            let aiValidMoves = movesAllowed(pieceSelected!)
            let pieceTouched = aiValidMoves[0]
            if gameBoard[pieceTouched.y][pieceTouched.x] == PC.none {
                movePiece(pieceSelected!, to: pieceTouched)
                kingMe(newPosition: pieceTouched)
            }
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
    let Score: Int
    var description: String {
        return "Position: \(Move) - Score: \(Score)"
    }
}