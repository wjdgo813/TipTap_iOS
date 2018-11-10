//
//  TTMyDiaryViewController.swift
//  TipTap
//
//  Created by JHH on 2018. 8. 17..
//  Copyright © 2018년 Tiptap. All rights reserved.
//
import Foundation
import UIKit
import SnapKit


protocol TTMyDiaryViewProtocol:class{
    func startNetworking()
    func stopNetworking(hasData : Bool)
}

class TTMyDiaryViewController: TTBaseViewController, TTCanShowAlert {
    
    @IBOutlet private weak var descriptLabel: UILabel!
    @IBOutlet private weak var calendarButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var intervalSafeView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    private var intervalDateLabel: UILabel = UILabel()
    private var intervalDateView: UIView   = UIView()
    private var deleteView          : UIView   = UIView()
    
    
    fileprivate var isDeletable : Bool = false
    fileprivate var isDeleteInit : Bool = false
    
    var presenter:TTMyDiaryPresenterProtocol?
    var startDate : String?
    var endDate  : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.onViewDidLoad()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    
    override func setupUI() {
        setupIntervalDateView()
        setupDeleteView()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.contentInset   = UIEdgeInsetsMake(7, 0, 7, 0)
        self.tableView.separatorInset = UIEdgeInsetsMake(7, 0, 7, 0)
        self.descriptLabel.isHidden = true

        
        guard let startDate = startDate,
            let endDate = endDate else {
                intervalDateView.isHidden = true
                intervalSafeView.isHidden = true
                cancelButton.isHidden = true
                calendarButton.isHidden = false
                return
        }
        
        intervalDateView.isHidden   = false
        intervalSafeView.isHidden   = false
        cancelButton.isHidden        = false
        calendarButton.isHidden     =  true
        
        intervalDateLabel.text = "\(startDate)  -  \(endDate)"
    }
    
    
    override func setupBinding() {
        self.registerCell()
        self.registerNoti()
    }
    
    
    
    private func setupIntervalDateView(){
        self.view.addSubview(self.intervalDateView)
        self.intervalDateView.addSubview(self.intervalDateLabel)
        
        self.intervalDateView.backgroundColor = UIColor.white
        self.intervalDateView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.height.equalTo(50)
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottomMargin).offset(0)
            } else {
                make.bottom.equalToSuperview().offset(0)
            }
        }
        
        self.intervalDateLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    
    private func setupDeleteView(){
        self.view.addSubview(self.deleteView)
        self.deleteView.isHidden = true
        self.deleteView.backgroundColor = UIColor.black
        self.deleteView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.height.equalTo(50)
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottomMargin).offset(0)
            } else {
                make.bottom.equalToSuperview().offset(0)
            }
        }
        
        
        let deleteCancelButton = UIButton()
        let deleteConfirmButton = UIButton()
        
        self.deleteView.addSubview(deleteCancelButton)
        self.deleteView.addSubview(deleteConfirmButton)
        
        deleteConfirmButton.setTitle("삭제", for: .normal)
        deleteConfirmButton.setTitleColor(UIColor.white, for: .normal)
        deleteConfirmButton.addTarget(self, action: #selector(pressedConfirmDelete), for: .touchUpInside)
        deleteConfirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        deleteCancelButton.setTitle("취소", for: .normal)
        deleteCancelButton.setTitleColor(UIColor.gray, for: .normal)
        deleteCancelButton.addTarget(self, action: #selector(pressedCancelDelete), for: .touchUpInside)
        deleteCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        deleteConfirmButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.centerY.equalToSuperview()
        }
        
        deleteCancelButton.snp.makeConstraints { (make) in
            make.right.equalTo(deleteConfirmButton.snp.left).offset(-27)
            make.centerY.equalToSuperview()
        }
        
        
    }
    
    
    private func registerCell(){
        self.tableView.register(UINib.init(nibName:"TTMyDiaryCell",bundle:nil), forCellReuseIdentifier: "TTMyDiaryCell")
    }
    
    
    private func registerNoti(){
        let gesture = UILongPressGestureRecognizer.init(target: self, action: #selector(pressedLongTouch))
        self.view.addGestureRecognizer(gesture)
    }
    
    
    @objc private func pressedLongTouch(){
        guard !isDeletable else { return }
        self.isDeletable = true
        isDeleteInit = false
        self.tableView.reloadData()

        
        self.deleteView.snp.updateConstraints { (make) in
            make.height.equalTo(0)
        }
        self.deleteView.isHidden = false
        self.deleteView.layoutIfNeeded()
        
        UIView.animate(withDuration: 3, delay: 0, options: .curveEaseInOut, animations: {
            self.deleteView.snp.updateConstraints { (make) in
                make.height.equalTo(50)
            }
        }) { (finish) in
            self.deleteView.snp.updateConstraints { (make) in
                make.height.equalTo(50)
            }
        }
    }
    
    
    @objc private func pressedConfirmDelete(){
        
        presenter?.sumbitDelteItems()
    }
    
    
    @objc private func pressedCancelDelete(){
        isDeletable = false
        isDeleteInit = true
        self.tableView.reloadData()

        
        self.deleteView.snp.updateConstraints { (make) in
            make.height.equalTo(50)
        }
        
        UIView.animate(withDuration: 3, animations: {
            self.deleteView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
        }) { (finish) in
            self.deleteView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            self.deleteView.isHidden = true
        }
    }
    
    
    @IBAction func pressedCalendar(_ sender: Any) {
        let selectVC = SelectCalendarViewController.init(nibName: "SelectCalendarViewController", bundle: nil)
        self.present(selectVC, animated: true, completion: nil)
    }
    
    @IBAction func pressedCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}





extension TTMyDiaryViewController: TTMyDiaryViewProtocol {
    func startNetworking() {
        self.tableView.reloadData()
    }
    
    
    func stopNetworking(hasData : Bool) {
        guard hasData else {
            descriptLabel.isHidden = false
            if startDate != nil {
                descriptLabel.text  = "선택하신 날짜의 일기가 없습니다."
            }else{
                descriptLabel.text = "작성하신 일기가 없습니다."
            }
            return
        }
        
        self.tableView.reloadData()
    }
}


extension TTMyDiaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectTableViewRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 139
    }
}



extension TTMyDiaryViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return (presenter?.numberOfSection())!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (presenter?.numberOfRows(in: section))!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (presenter?.configureCell(tableView,
                                         forRowAt: indexPath,
                                         isDeletable : self.isDeletable,
                                         isInitDelete : self.isDeleteInit))!
    }
}
