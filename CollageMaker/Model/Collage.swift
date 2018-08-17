//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

enum Axis {
    case horizontal
    case vertical
}

protocol CollageDelegate: AnyObject {
    func collage(_ collage: Collage, didChangeSelected cell: CollageCell)
    func collageChanged(to collage: Collage)
}

class Collage {
    
    weak var delegate: CollageDelegate?
    
    init(cells: [CollageCell]) {
        if cells.count < 1 {
            let initialCell = CollageCell(color: .random, image: nil, relativePosition: RelativePosition(x: 0, y: 0, width: 1, height: 1))
            
            self.cells = [initialCell]
            self.selectedCell = initialCell
        } else {
            self.cells = cells
            self.selectedCell = cells.first
        }
        
        self.initialStateCells = cells
    }
    
    func setSelected(cell: CollageCell) {
        selectedCell = cell
    }
    
    func add(cell: CollageCell) {
        if !cells.contains(cell) {
            cells.append(cell)
        }
    }
    
    func remove(cell: CollageCell) {
        guard cells.count > 1 else {
            return
        }
        
        recentlyDeleted = cell
        
        cells = cells.filter { $0.id != cell.id }
    }
    
    func splitSelectedCell(by axis: Axis) {
        guard let cell = selectedCell else {
            return
        }
        
        let (firstPosition, secondPosition) = cell.relativePosition.split(axis: axis)
        
        let firstCell =  CollageCell(color: cell.color, image: cell.image, relativePosition: firstPosition)
        let secondCell = CollageCell(color: .random, image: nil, relativePosition: secondPosition)
        
        add(cell: firstCell)
        add(cell: secondCell)
        
        remove(cell: cell)
        
        setSelected(cell: secondCell)
        
        delegate?.collageChanged(to: self)
    }
    
    func cell(at point: CGPoint, in rect: CGRect) -> CollageCell? {
        let relativePoint = CGPoint(x: point.x / rect.width,
                                    y: point.y / rect.height)
        
        return cells.first(where: { $0.relativePosition.contains(relativePoint) })
    }
    
    func reset() {
        cells = initialStateCells
        delegate?.collageChanged(to: self)
    }
    
    private(set) var selectedCell: CollageCell? {
        didSet {
            if let cell = selectedCell {
                delegate?.collage(self, didChangeSelected: cell)
            }
        }
    }
    
    private let initialStateCells: [CollageCell]
    private var recentlyDeleted: CollageCell?
    private(set) var cells: [CollageCell] = []
}

extension Collage {
    static func ==(lhs: Collage, rhs: Collage) -> Bool {
        return lhs.cells == rhs.cells
    }
}
