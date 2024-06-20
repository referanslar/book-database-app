import UIKit

class MainTabController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }
    
    func configureViewControllers() {
        view.backgroundColor = .systemBackground
        
        let search = SearchController()
        let searchNavigation = templateNavigationController(title: "Search", image: UIImage(systemName: "magnifyingglass"), rootViewController: search)
        
        let favorites = FavoritesController()
        let favoritesNavigation = templateNavigationController(title: "Favorites", image: UIImage(systemName: "star"), rootViewController: favorites)
        
        viewControllers = [searchNavigation, favoritesNavigation]
    }
    
    func templateNavigationController(title: String, image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        let appearance = UITabBar.appearance()
        
        nav.title = title
        nav.view.backgroundColor = .systemBackground
        nav.tabBarItem.image = image
        nav.tabBarItem.selectedImage?.withTintColor(UIColor.red)
        appearance.tintColor = .systemRed
        
        return nav
    }
}
