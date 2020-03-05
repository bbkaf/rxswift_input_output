//
//  ViewController.swift
//  rxswift_input_output
//
//  Created by HankTseng on 2020/3/5.
//  Copyright © 2020 hyersesign. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxDataSources
import RxGesture

class ViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private var viewModel = ViewModel()
    private let cellTitleLabelTap = PublishSubject<IndexPath>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        autoLayout()
        bindViewModel()
    }

    func setupUI() {
        view.addSubview(buttonRight)
        view.addSubview(centerLabel)
        view.addSubview(topTableView)
    }

    func autoLayout() {
        buttonRight.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(60)
            make.width.equalTo(120)
        }

        centerLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(60)
        }

        topTableView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(320)
        }
    }

    func bindViewModel() {
        let viewDidAppear = Driver<Void>.just(())
        let input = ViewModel.Input(viewDidAppear: viewDidAppear, rightBtnAction: buttonRight.rx.tap.asDriver(), cellTitleLabelTap: cellTitleLabelTap.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input: input)
        output.rightBtnAction
        .drive(centerLabel.rx.text)
        .disposed(by: disposeBag)

        let items = Observable.just([
            SectionModel(model: "基本控件", items: [
                "UILable的用法",
                "UIText的用法",
                "UIButton的用法"
                ]),
            SectionModel(model: "高级控件", items: [
                "UITableView的用法",
                "UICollectionViews的用法"
                ])
            ])
//        items
//            .bind(to: topTableView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
        output.dataSource.drive(topTableView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
    }

    

    // MARK: - setter and getter

    private lazy var buttonRight: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("右邊按鈕", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor.blue
        return button
    }()

    private lazy var centerLabel: UILabel = {
        let centerLabel = UILabel()
        centerLabel.backgroundColor = UIColor.red
        return centerLabel
    }()

    private lazy var topTableView: UITableView = {
        let topTableView = UITableView()
        topTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        topTableView.delegate = self
        return topTableView
    }()

//    let dataSource = RxTableViewSectionedReloadDataSource
//        <SectionModel<String, String>>(configureCell: {
//            (dataSource, tv, indexPath, element) in
//            let cell = tv.dequeueReusableCell(withIdentifier: "cell")!
//            cell.textLabel?.text = "\(indexPath.row)：\(element)"
//            return cell
//        })

    private lazy var dataSource: RxTableViewSectionedReloadDataSource<CellSectionModel> = {
        return RxTableViewSectionedReloadDataSource<CellSectionModel>(configureCell: { [weak self] (_, tableView, indexPath, item) -> UITableViewCell in
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = item.name
            cell.textLabel?.rx.tapGesture()
                .subscribe( onNext: { [weak self] _ in
                    print("cell titlelabel tap")
                    self?.cellTitleLabelTap.onNext(indexPath)
                }).disposed(by: DisposeBag())
            return cell
        })
    }()
    /*
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<CellSectionModel> = {
        return RxTableViewSectionedReloadDataSource<CellSectionModel>(configureCell: { [weak self](_, tableView, indexPath, item) -> UITableViewCell in
            let cell: LabelButtonCell = tableView.dequeueReusableCell(withIdentifier: "LabelButtonCell") as! LabelButtonCell
            cell.data = (item.name ?? "", "", "删除", "重命名")
            cell.rightButton1.rx.tap
                .subscribe(onNext: { [weak self] (_) in
                    self?.cellDeleteButtonTap.onNext(indexPath)
                })
                .disposed(by: cell.disposeBag)
            cell.rightButton2.rx.tap
                .subscribe(onNext: { [weak self] (_) in
                    self?.cellRenameButtonTap.onNext(indexPath)
                })
                .disposed(by: cell.disposeBag)
            return cell
        })
    }()
 */
}

extension ViewController: UITableViewDelegate {

}

extension ViewController {
    struct CellSectionModel {
        var items: [Item]
    }
}

extension ViewController.CellSectionModel: SectionModelType {
    typealias Item = GroupModel
    init(original: ViewController.CellSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

public struct GroupModel {
    var name: String
}

extension ObservableConvertibleType {
    func asDriverOnErrorJustComplete() -> Driver<E> {
        return asDriver { _ in
            return Driver.empty()
        }
    }
}
