import UIKit
import RxSwift
import RxDataSources
import SnapKit

class ViewController: UIViewController, UITableViewDelegate {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        return tableView
    }()
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfCustomData>!
    let d = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.rx.setDelegate(self).disposed(by: d)
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ListTableViewCell.self))
        setupDataSource()
        bindModels()
    }

    func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>(configureCell: {
            (ds: TableViewSectionedDataSource<SectionOfCustomData>, tableView: UITableView, indexPath: IndexPath, model: CustomData) -> UITableViewCell in

            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ListTableViewCell.self), for: indexPath) as? ListTableViewCell else {
                fatalError("The dequeued cell is not instance of MealTableViewCell.")
            }
            cell.nameLabel.text = model.str
            return cell
        })
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
    }

    //Modelsに
    func bindModels() {
        let sections = [
            SectionOfCustomData(header: "First section",
                                items: [CustomData(str: "zero"),
                                        CustomData(str: "one") ]),
            SectionOfCustomData(header: "Second section",
                                items: [CustomData(str: "two"),
                                        CustomData(str: "three") ])
        ]
            //just単一の要素を含む観測可能なシーケンスを返します。 .bind カスタムバインダー関数を使用して観測可能なシーケンスをサブスクライブします。
            //変換を実行するために使用されるカスタムの反応データを使用して、要素のシーケンスをテーブルビューの行にバインドします。
            Observable.just(sections)
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: d)
    }

    override func viewDidAppear(_ animated: Bool) {

    }
}

struct CustomData {
    var str: String
}

struct SectionOfCustomData {
    var header: String
    var items: [Item]
}

extension SectionOfCustomData: SectionModelType {
    typealias Item = CustomData

    init(original: SectionOfCustomData, items: [SectionOfCustomData.Item]) {
        self = original
        self.items = items
    }
}

class ListTableViewCell: UITableViewCell {
    //MARK: Properties
    var nameLabel: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(self).inset(20)
            make.right.equalTo(self).inset(20)
            make.height.equalTo(20)
        }
    }

    //MARK : method
    private func commonInit() {
        self.createNameLabel()
    }
    private func createNameLabel() {
        nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.textAlignment = .left
        nameLabel.font = UIFont.systemFont(ofSize: 20)
    }
}
