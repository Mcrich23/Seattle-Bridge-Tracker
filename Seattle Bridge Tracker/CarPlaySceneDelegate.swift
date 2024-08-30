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
    
    /// 1. CarPlay connected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        
        let rootTemplate = self.makeRootTemplate()
            interfaceController.setRootTemplate(rootTemplate, animated: true,
                completion: nil)
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
}
