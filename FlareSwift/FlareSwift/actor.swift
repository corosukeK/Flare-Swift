//
//  actor.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/11/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public protocol Actor: class {
    var maxTextureIndex: Int { get set }
    var _version: Int { get set }
    var _artboardCount: Int { get set }
    var _artboards: [ActorArtboard?] { get set }
    
    func load(data: Data)
    func copyActor(actor: Actor)
    func readArtboardsBlock(block: StreamReader)
    
    func makeArtboard() -> ActorArtboard
    func makeNode() -> ActorNode
    func makeImageNode() -> ActorImage
    func makeEvent() -> ActorEvent
    func makePathNode() -> ActorPath
    func makeShapeNode() -> ActorShape
    func makeRectangle() -> ActorRectangle
    func makeTriangle() -> ActorTriangle
    func makeStar() -> ActorStar
    func makePolygon() -> ActorPolygon
    func makeEllipse() -> ActorEllipse
    func makeColorFill() -> ColorFill
    func makeColorStroke() -> ColorStroke
    func makeGradientFill() -> GradientFill
    func makeGradientStroke() -> GradientStroke
    func makeRadialFill() -> RadialGradientFill
    func makeRadialStroke() -> RadialGradientStroke
}

public extension Actor {
    public var artboard: ActorArtboard? {
        return (_artboards.count > 0) ? _artboards.first as? ActorArtboard : nil
    }
    
    var version: Int {
        return _version
    }
    var texturesUsed: Int {
        return maxTextureIndex + 1
    }
    
    
    func load(data: Data) {
        guard data.count > 5 else {
            fatalError("NOT A VALID FLARE FILE.")
        }
        if let reader = ReaderFactory.factory(data: data) {
            dump(data)
            _version = reader.readVersion()
            print("JUST GOT VERSION \(self._version)")
            while var block = reader.readNextBlock(blockTypes: BlockTypesMap) {
                switch block.blockType {
                case BlockTypes.Artboards:
                    readArtboardsBlock(block: block)
                    break
                default:
                    print("BlockType \(block.blockType), while reading Actor!")
                    break
                }
            }
        } else {
            fatalError("Cannot initialize reader from data!")
        }
    }
    
    func copyActor(actor: Actor) {
        maxTextureIndex = actor.maxTextureIndex
        _artboardCount = actor._artboardCount
        if _artboardCount > 0 {
            var idx = 0
            _artboards = []
            for artboard in actor._artboards {
                if artboard == nil {
                    _artboards.insert(nil, at: idx)
                    idx += 1
                    continue
                }
                let instanceArtboard = artboard!.makeInstance()
                _artboards.insert(instanceArtboard, at: idx)
                idx += 1
            }
        }
    }
    
    func readArtboardsBlock(block: StreamReader) {
        let abCount = Int(block.readUint16Length())
        _artboards = [ActorArtboard]()
        
        for artboardIndex in 0 ..< abCount {
            if let artboardBlock = block.readNextBlock(blockTypes: BlockTypesMap) {
                switch (artboardBlock.blockType) {
                case BlockTypes.ActorArtboard:
                    let artboard = makeArtboard()
                    artboard.read(artboardBlock)
                    _artboards.insert(artboard, at: artboardIndex)
                    break
                default:
                    break
                }
            }
        }
    }
    func makeArtboard() -> ActorArtboard {
        return ActorArtboard(actor: self)
    }
    
    func makeNode() -> ActorNode {
        return ActorNode()
    }
    
    func makeEvent() -> ActorEvent {
        return ActorEvent()
    }
    
    func makeImageNode() -> ActorImage {
        return ActorImage()
    }
    
    func makePathNode() -> ActorPath {
        return ActorPath()
    }
    
    func makeShapeNode() -> ActorShape {
        return ActorShape()
    }
    
    func makeRectangle() -> ActorRectangle {
        return ActorRectangle()
    }
    
    func makeTriangle() -> ActorTriangle {
        return ActorTriangle()
    }
    
    func makeStar() -> ActorStar {
        return ActorStar()
    }
    
    func makePolygon() -> ActorPolygon {
        return ActorPolygon()
    }
    
    func makeEllipse() -> ActorEllipse {
        return ActorEllipse()
    }
}
