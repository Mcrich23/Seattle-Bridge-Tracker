//
//  CarPlaySceneDelegate.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 8/30/24.
//

import Foundation
import UIKit
import SwiftUI
import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    let viewModel = ContentViewModel()
    
    /// 1. CarPlay connected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        
        let rootTemplate = self.makeRootTemplate()
            interfaceController.setRootTemplate(rootTemplate, animated: true,
                completion: nil)
        
        fetchTemplateUpdates(with: interfaceController)
    }
    
    /// 4. Information template
    private func makeRootTemplate() -> CPTemplate {
        // 5 - Setting the content for the template
        let sections: [CPListSection] = [
            .init(items: [
                .init(text: "Hello, CarPlay!", detailText: "This is a test app.")
            ])
        ]
        
        // 6 - Selecting the template
        let infoTemplate = CPListTemplate(title: "Hello World", sections: sections)
        
        // 7 - Setting the information template as the root template
        return infoTemplate
    }
    
    func fetchTemplateUpdates(with interfaceController: CPInterfaceController) {
        viewModel.fetchData(repeatFetch: true) { sortedBridges in
            let sections: [CPListSection] = sortedBridges.map { name, bridges in
                    .init(items: bridges.map({ CPListItem(text: $0.name, detailText: $0.status.rawValue.capitalized) }), header: name.capitalized, sectionIndexTitle: nil)
            }
            
            let template = CPListTemplate(title: "Bridges", sections: sections)
            
            guard let rootTemplate: CPListTemplate = interfaceController.rootTemplate as? CPListTemplate else { return }
            
            let rootSections: [CPListSection] = rootTemplate.sections as [CPListSection]
            let mappedRootSectionItems: [CPListItem] = rootSections.flatMap({ $0.items.compactMap({ $0 as? CPListItem })})
            let mappedSectionItems = sections.flatMap({ $0.items.compactMap({ $0 as? CPListItem })})
            
            if mappedSectionItems != mappedRootSectionItems {
                interfaceController.setRootTemplate(template, animated: true, completion: nil)
            }
        }
    }
}
