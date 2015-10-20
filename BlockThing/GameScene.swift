//
//  GameScene.swift
//  BlockThing
//
//  Created by Bliss Watchaye on 2015-10-12.
//  Copyright (c) 2015 confusians. All rights reserved.
//

import SpriteKit
//import UIKit

enum BodyType:UInt32 {
    
    case hero = 1
    case ground = 2
    case monster = 4
    case emptyness = 9
    case wall = 5
}

let TileWidth: CGFloat = 80.0
let TileHeight: CGFloat = 80.0

class GameScene: SKScene,SKPhysicsContactDelegate {
    var hero: Hero!
    var justMove = false;
    var fingerPosition:CGPoint?
    var velo: CGVector!
    
    var levelIs = "Level_1"
    
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = UIColor.whiteColor()
        
        startGame()
    }
    
    func startGame(){
        
        var cover:SKSpriteNode = SKSpriteNode(color: UIColor.blackColor(), size: self.size)
        cover.zPosition = 5
        addChild(cover)
        cover.anchorPoint = CGPointMake(0.0, 0.0)
        cover.runAction(SKAction.fadeAlphaTo(0.0, duration: 0.32)) { () -> Void in
            cover.removeFromParent()
        }
        
        /* Setup your scene here */
        myMap = Map(filename: levelIs)
        addTiles()
        self.addChild(tilesLayer);
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        fingerPosition = touches.first?.locationInNode(self)
        justMove = false;
        for touch in touches {
//            let location = touch.locationInNode(self)
//            
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
            
            
//            let circleMonster = CircleMonster(imageNamed: "mon", inX: 1, inY: 1)
//                        let location = touch.locationInNode(self)
//                        circleMonster.position = location
//            self.addChild(circleMonster)
        }
    }
    
//    override func keyUp(theEvent: NSEvent) {
//        let s: String = String(self.returnChar(theEvent)!)
//        switch(s){
//        case "w":
//            if(myMap.canMoveToTile(hero.xCoor, row: hero.yCoor+1)){
//                hero.goUp()
//                tilesLayer.goUp()
//                checkTile()
//            }
//            break
//        case "s":
//            if(myMap.canMoveToTile(hero.xCoor, row: hero.yCoor-1)){
//                hero.goDown()
//                tilesLayer.goDown()
//                checkTile()
//            }
//            break
//        case "d":
//            if(myMap.canMoveToTile(hero.xCoor+1, row: hero.yCoor)){
//                hero.goRight()
//                tilesLayer.goRight()
//                checkTile()
//            }
//            break
//        case "a":
//            if(myMap.canMoveToTile(hero.xCoor-1, row: hero.yCoor)){
//                hero.goLeft()
//                tilesLayer.goLeft()
//                checkTile()
//            }
//            break
//            
//            
//        default:
//            print("default")
//        }
//    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(justMove){return;}
        if(touches.first?.locationInNode(self).x > (fingerPosition?.x)!+10){
            if(myMap.canMoveToTile(hero.xCoor+1, row: hero.yCoor)){
                hero.goRight()
                tilesLayer.goRight()
                checkTile()
            }
        }else if(touches.first?.locationInNode(self).x < (fingerPosition?.x)!-10){
            if(myMap.canMoveToTile(hero.xCoor-1, row: hero.yCoor)){
                hero.goLeft()
                tilesLayer.goLeft()
                checkTile()
            }
        }else if(touches.first?.locationInNode(self).y > (fingerPosition?.y)!+10){
            if(myMap.canMoveToTile(hero.xCoor, row: hero.yCoor+1)){
                hero.goUp()
                tilesLayer.goUp()
                checkTile()
            }
        }else if(touches.first?.locationInNode(self).y < (fingerPosition?.y)!-10){
            if(myMap.canMoveToTile(hero.xCoor, row: hero.yCoor-1)){
                hero.goDown()
                tilesLayer.goDown()
                checkTile()
            }
        }
        
        justMove = true;
    }
   
    func checkTile(){
        if let tile = myMap.tileAtColumn(hero.xCoor, row: hero.yCoor) {
            if(tile.tileType == TileType.Lava){
                print("Fall in lava")
                gameOver()
            }else if(tile.tileType == TileType.Exit){
                clearLevel()
            }else if(tile.tileType == TileType.Button && (tile as? Switch)?.tag != 0){
                (tile as? Switch)?.flip()
                for row in 0..<NumRows {
                    for column in 0..<NumColumns {
                        if let tiles = myMap.tileAtColumn(column, row: row) as? Door {
                            if(tiles.tileType == TileType.Door && tiles.tag == (tile as? Switch)?.tag){
                                tiles.flip(((tile as? Switch)?.close)!)
                            }
                        }
                    }
                }
            }
        }
    }

    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        //checkWall()
        
        
        
    }
    
    let tilesLayer = MoveMap()
    
    func addTiles() {
        var centerTile:Tile!
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let tile = myMap.tileAtColumn(column, row: row) {
                    if(tile.tileType == TileType.Birth){
                        centerTile = tile
                    }else if(tile.tileType == TileType.Monster){
                        let triangleMonster = TriangleMonster(imageNamed: "triangle", inX: tile.column, inY: tile.row)
                        triangleMonster.zPosition = 2;
                        triangleMonster.position = pointForColumn(triangleMonster.xCoor, row: triangleMonster.yCoor)
                        tilesLayer.addChild(triangleMonster)
                    }else if(tile.tileType == TileType.CircleMon){
                        let circleMonster = CircleMonster(imageNamed: "mon", inX: tile.column, inY: tile.row, horizontal: tile.tag, inv: true)
                        circleMonster.zPosition = 2;
                        circleMonster.position = pointForColumn(circleMonster.xCoor, row: circleMonster.yCoor)
                        tilesLayer.addChild(circleMonster)
                    }else if(tile.tileType == TileType.Button){
                        for row in 0..<NumRows {
                            for column in 0..<NumColumns {
                                if let tileIn = myMap.tileAtColumn(column, row: row) {
                                    if(tileIn.tileType == TileType.Door && (tileIn as? Door)?.tag == (tile as? Switch)!.tag){
                                        (tileIn as? Door)?.life += 1
                                    }
                                }
                            }
                        }
                    }
                    tile.texture = SKTexture(imageNamed: tile.tileType.spriteName)
                    tile.position = pointForColumn(column, row: row)
                    tile.size = CGSize(width: TileWidth, height: TileHeight)
                    tile.zPosition = -1
                    tilesLayer.addChild(tile)
                }
            }
        }
        
        spawnPlayer(centerTile.column, inY: centerTile.row)
//        tilesLayer.size = CGSizeMake(TileWidth*CGFloat(NumColumns), TileHeight*CGFloat(NumRows))
//        tilesLayer.anchorPoint = CGPointMake(CGFloat(centerTile.column/NumColumns), CGFloat(centerTile.row/NumRows))
        tilesLayer.position = CGPointMake(self.size.width/2 - (pointForColumn(centerTile.column, row: centerTile.row)).x, self.size.height/2 - (pointForColumn(centerTile.column, row: centerTile.row)).y)
    }
    
    func spawnPlayer(inX : Int, inY: Int){
        hero = Hero(xd: inX, yd: inY)
        hero.anchorPoint = CGPointMake(0.5, 0.5)
        hero.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(hero)
    }
    
    var myMap : Map!
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    
    func gameOver(){
        var cover:SKSpriteNode = SKSpriteNode(color: UIColor.blackColor(), size: self.size)
        cover.anchorPoint = CGPointMake(0.0, 0.0)
        cover.alpha = 0.0
        cover.zPosition = 5
        addChild(cover)
        
        hero.dieAnimation()
        
        var path = NSBundle.mainBundle().pathForResource("DeathParticle", ofType: "sks")
        var rainParticle = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as! SKEmitterNode
        
        rainParticle.position = CGPointMake(hero.position.x,hero.position.y)
        rainParticle.name = "death"
        rainParticle.targetNode = self
        addChild(rainParticle)
        
        self.tilesLayer.runAction(SKAction.shake(0.57, amplitudeX: 40, amplitudeY: 40)) { () -> Void in
            self.myMap.remove()
            self.hero.remove()
            self.tilesLayer.removeAllActions()
            self.tilesLayer.removeAllChildren()
            self.tilesLayer.removeFromParent()
            self.removeAllActions()
            self.removeAllChildren()
            self.startGame()
        }
//        cover.runAction(SKAction.fadeAlphaTo(0.95, duration: 0.4))
    }
    
    func clearLevel(){
        var cover:SKSpriteNode = SKSpriteNode(color: UIColor.whiteColor(), size: self.size)
        cover.anchorPoint = CGPointMake(0.0, 0.0)
        cover.alpha = 0.0
        cover.zPosition = 5
        addChild(cover)
        
        hero.dieAnimation()

//        self.tilesLayer.runAction(SKAction.shake(0.57, amplitudeX: 40, amplitudeY: 40)) { () -> Void in
//            self.myMap.remove()
//            self.hero.remove()
//            self.tilesLayer.removeAllActions()
//            self.tilesLayer.removeAllChildren()
//            self.tilesLayer.removeFromParent()
//            self.removeAllActions()
//            self.removeAllChildren()
////            self.startGame()
//        }
                cover.runAction(SKAction.fadeAlphaTo(0.70, duration: 0.4))
    }
    func didBeginContact(contact: SKPhysicsContact) {
        
        //this gets called automatically when two objects begin contact with each other
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if (contact.bodyA.categoryBitMask == BodyType.hero.rawValue && contact.bodyB.categoryBitMask == BodyType.monster.rawValue )  {
            
            gameOver()
            print("bodyA was our Bro hero, bodyB was the monster")
        } else if (contact.bodyA.categoryBitMask == BodyType.hero.rawValue && contact.bodyB.categoryBitMask == BodyType.monster.rawValue )  {
            
            gameOver()
            print("bodyB was our Bro hero, bodyA was the monster")
        } else if (contact.bodyA.categoryBitMask == BodyType.monster.rawValue && contact.bodyB.categoryBitMask == BodyType.wall.rawValue) {
            print("Contact Wall")
            let circleMon = contact.bodyA.node as! CircleMonster
            circleMon.changeDirection()
        } else if (contact.bodyA.categoryBitMask == BodyType.wall.rawValue && contact.bodyB.categoryBitMask == BodyType.monster.rawValue) {
            let circleMon = contact.bodyB.node as! CircleMonster
            circleMon.changeDirection()
            print("Wall contact")
        }
    }
}


