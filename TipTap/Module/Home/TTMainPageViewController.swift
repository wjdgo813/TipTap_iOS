//
//  TTMainPageViewController.swift
//  TipTap
//
//  Created by Haehyeon Jeong on 2018. 8. 15..
//  Copyright © 2018년 Tiptap. All rights reserved.
//

import UIKit
import UserNotifications

class TTMainPageViewController: UIPageViewController, TTCanSetupNavigation {
    
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newTipTapViewController(index:0),
                self.newTipTapViewController(index:1),
                self.newTipTapViewController(index:2)]
    }()
    
    private func newTipTapViewController(index: Int) -> UIViewController {
        switch index {
        case 0:
            return UINavigationController(rootViewController:TTMyDiaryWireFrame.createModule())
        case 1:
            return UINavigationController(rootViewController:(UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier:"second") as? TTTodayDiaryViewController)!)
        case 2:
            return UINavigationController(rootViewController:(UIStoryboard(name: "SharedDiary", bundle: nil) .instantiateViewController(withIdentifier:"TTSharedViewController") as? TTSharedViewController)!)
        default:
            return UIStoryboard(name: "Main", bundle: nil) .
                instantiateViewController(withIdentifier: "first")
        }
    }
    
    private var didScratch = false
    fileprivate var isAbleScrollPage = false
    var titleLabel : UILabel? = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 100, height: 44.0))
    var rightBarButtonItem : UIBarButtonItem?  = UIBarButtonItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIBinding()
        setPageViewController(index: 1,direct: .forward)
        addObserver()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }

    
    private func UIBinding(){
        dataSource = self
        delegate   = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: { (didAllow, error) in
        })
    }
    
    

    
    private func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(isAblePaging), name: Notification.Name.ablePaging.changedAblePaging, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disablePaging), name: Notification.Name.ablePaging.changedDisablePaging, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSharedDiary), name: NSNotification.Name.refreshPage.sharedDiary, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didScratching), name: NSNotification.Name.ablePaging.changedDidScratch, object: nil)
    }

    
    private func setPageViewController(index : Int,direct : NavigationDirection){
        guard index < orderedViewControllers.count else { return }
        let mainViewController = orderedViewControllers[index]
        DispatchQueue.main.async {
            self.setViewControllers([mainViewController],
                                                       direction: direct,
                                                       animated: true,
                                                       completion: nil)
        }
    }
    
    
    @objc private func isAblePaging(){
        self.isAbleScrollPage  = true
        self.isPagingEnabled = true
    }
    
    
    @objc private func disablePaging(){
        self.isAbleScrollPage  = false
        self.isPagingEnabled = false
    }
    
    @objc private func didScratching(){
        self.didScratch = true
    }
    
    
    @objc private func refreshSharedDiary(){
        self.isPagingEnabled = true
        self.isAbleScrollPage = false
        self.didScratch = false
        orderedViewControllers[2] = self.newTipTapViewController(index:2)
        setPageViewController(index: 1,direct: .reverse)
    }
}



extension TTMainPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of:viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        guard orderedViewControllers.count > previousIndex else { return nil }
        

        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of:viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else { return nil }
        guard orderedViewControllersCount > nextIndex else { return nil }
        
        
        
        return orderedViewControllers[nextIndex]
    }
}

extension TTMainPageViewController : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let vc = pageViewController.viewControllers?.first else { return }
        guard let viewControllerIndex = orderedViewControllers.index(of:vc) else { return }
        
        switch viewControllerIndex {
        case 0:
            break
        case 1:
            break
        case 2:
            guard let firstVC = vc.childViewControllers.first else { return }
            pageViewController.isPagingEnabled = didScratch
            if firstVC is TTSharedViewController{
                let sharedVC = firstVC as? TTSharedViewController
                guard let count = sharedVC?.moduleDatas?.diaryDataList?.count else {
                    sharedVC?.requestSharedDiary()
                    return
                }
                
                if count == 0 {
                    sharedVC?.requestSharedDiary()
                }
            }
            
            
            break
        default:
            break
        }
    }
}



