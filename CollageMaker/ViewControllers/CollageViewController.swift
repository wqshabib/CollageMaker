//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

protocol CollageViewControllerDelegate: AnyObject {
    func collageViewController(_ controller: CollageViewController, didSelect cell: CollageCell)
}

class CollageViewController: UIViewController {
    
    weak var delegate: CollageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panGestureRecognizer.addTarget(self, action: #selector(changeDimension(with:)))
        
        collageView.delegate = self
        view.addSubview(collageView)
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collageView.frame = view.bounds
    }
    
    func set(collage: Collage) {
        self.collage = collage
        self.collage.delegate = self
        
        DispatchQueue.main.async { [weak self, collage]  in
            self?.collageView.setCollage(collage)
        }
    }
    
    @objc private func changeDimension(with recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: view)
        let translation = recognizer.translation(in: view)
        recognizer.setTranslation(.zero, in: view)
        
        switch recognizer.state {
        case .began:
            let frame = CGRect(x: point.x - 20, y: point.y - 20, width: 40, height: 40)
            selectedGrip = collageView.gripViews.first { $0.frame.intersects(frame) }?.position
            
        case .changed:
            if let grip = selectedGrip {
                let sizeChange = grip.axis == .horizontal ? translation.y / view.bounds.height : translation.x / view.bounds.width
                collage.changeSelectedCellSize(grip: grip, value: sizeChange)
            }
            
        case .ended:
            selectedGrip = nil
            
        default: break
        }
    }
    
    lazy var collage: Collage = Collage(cells: [])
    private let collageView = CollageView()
    private var selectedGrip: GripPosition?
    private var panGestureRecognizer = UIPanGestureRecognizer()
}


extension CollageViewController: CollageViewDelegate {
    
    func collageView(_ collageView: CollageView, tapped point: CGPoint) {
        let relativePoint = CGPoint(x: point.x / collageView.frame.width,
                                    y: point.y / collageView.frame.height)
        
        guard let selectedCell = collage.cell(at: relativePoint) else {
            return
        }
        
        collage.setSelected(cell: selectedCell)
    }
}

extension CollageViewController: CollageDelegate {
    func collage(_ collage: Collage, changed state: Collage.State) {
         DispatchQueue.main.async { [weak self] in
            self?.collageView.changeFrames(from: state)
        }
    }
  
    func collageChanged(to collage: Collage) {
        set(collage: collage)
    }
    
    func collage(_ collage: Collage, didChangeSelected cell: CollageCell) {
        guard let selectedCellView = collageView.cellViews.first(where: { $0.collageCell.id == cell.id }) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.collageView.select(cellView: selectedCellView)
        }
    }
}
