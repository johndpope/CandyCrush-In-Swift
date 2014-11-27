//
//  GameScene.swift
//  CookieCrunch
//
//  Created by Cecilia Humlelu on 26/11/14.
//  Copyright (c) 2014 HU. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene {
    
    var swipeHandler:((Swap)->())?

    var level : Level!
    
    let TileWidth : CGFloat = 32.0
    let TileHeight : CGFloat = 36.0
    
    let gameLayer = SKNode()
    let tilesLayer = SKNode()
    let cookiesLayer = SKNode()
    
    
    
    var  swipeFromColumn: Int?
    var swipeFromRow: Int?
    
    let swapSound = SKAction.playSoundFileNamed("Chomp.wav",waitForCompletion:false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
    

    
    

    override init(size:CGSize) {
        super.init(size:size)
        anchorPoint = CGPoint(x:0.5,y:0.5)
        swipeFromColumn = nil
        swipeFromRow = nil
        
        
        let background = SKSpriteNode(imageNamed:"Background")
        addChild(background)
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2
        )
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        cookiesLayer.position = layerPosition
        gameLayer.addChild(cookiesLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let tile = level.tileAtColumn(column, row: row) {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForColumn(column,row:row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }

    }
    
    func addSpritesForCookies(cookies:Set<Cookie>){
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed:cookie.cookieType.spriteName)
            sprite.position = pointForColumn(cookie.column,row:cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
        }
    }
    
    
    func pointForColumn(column:Int, row:Int) -> CGPoint {
        return CGPoint(
            x:CGFloat(column)*TileWidth + TileWidth/2,
            y:CGFloat(row)*TileHeight + TileHeight/2
        )
    }
    
    
    func convertPoint(point:CGPoint)->(success: Bool, column:Int,row:Int){
        if(point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight) {
            return (true, Int(point.x/TileWidth), Int(point.y/TileHeight))
        }else{
            return (false, 0 , 0)
        }
    }
    
    func trySwapHorizontal(horzDelta:Int, vertical verDelta:Int){
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + verDelta
        
        if toColumn < 0  || toColumn >= NumColumns {return}
        if toRow < 0 || toRow >= NumRows { return }
        if let toCookie = level.cookieAtColumn(toColumn, row: toRow){
            if let fromCookie = level.cookieAtColumn(swipeFromColumn!, row: swipeFromRow!){
                if let handler = swipeHandler {
                    let swap = Swap(cookieA: fromCookie, cookieB:toCookie)
                    handler(swap)
                }
            }
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            if let cookie = level.cookieAtColumn(column, row: row){
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
        
    }
    
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if swipeFromColumn == nil  {return}
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn! {
                horzDelta = -1
            } else if column > swipeFromColumn!{
                horzDelta = 1
            } else if row < swipeFromRow!{
                vertDelta = -1
            } else if row > swipeFromRow!{
                vertDelta = 1
            }
            
            if horzDelta != 0  || vertDelta != 0 {
                trySwapHorizontal(horzDelta, vertical: vertDelta)
                swipeFromColumn = nil
            }
        }
    }
    

    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        touchesEnded(touches, withEvent: event)
    }
    
    
    
    func animateSwap(swap:Swap, completion:()->()){
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        
        let Duration:NSTimeInterval = 0.3
        
        
        let moveA = SKAction.moveTo(spriteB.position, duration:Duration)
        moveA.timingMode = .EaseOut
        spriteA.runAction(moveA, completion:completion)
        
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB)
        runAction(swapSound)
        
    }
    
    
    func animateInvalidSwap(swap:Swap, completion:()->()){
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        
        let Duration:NSTimeInterval = 0.2
        
        let moveA = SKAction.moveTo(spriteB.position, duration:Duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        
        
        spriteA.runAction(SKAction.sequence([moveA,moveB]),completion:completion)
        spriteB.runAction(SKAction.sequence([moveB, moveA]))
        runAction(invalidSwapSound)
    }


}