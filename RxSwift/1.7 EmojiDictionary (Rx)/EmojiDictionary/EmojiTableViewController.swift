import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class EmojiTableViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var buttonNewEmoji: UIBarButtonItem!
    
    let disposeBag = DisposeBag()
    
    let dataSource = EmojiTableViewController.configureDataSource()
    
    var emojis: [Emoji] = [
        Emoji(symbol: "😀", name: "Grinning Face", description: "A typical smiley face.", usage: "happiness"),
        Emoji(symbol: "😕", name: "Confused Face", description: "A confused, puzzled face.", usage: "unsure what to think; displeasure"),
        Emoji(symbol: "😍", name: "Heart Eyes", description: "A smiley face with hearts for eyes.", usage: "love of something; attractive"),
        Emoji(symbol: "🧑‍💻", name: "Developer", description: "A person working on a MacBook (probably using Xcode to write iOS apps in Swift).", usage: "apps, software, programming"),
        Emoji(symbol: "🐢", name: "Turtle", description: "A cute turtle.", usage: "Something slow"),
        Emoji(symbol: "🐘", name: "Elephant", description: "A gray elephant.", usage: "good memory"),
        Emoji(symbol: "🍝", name: "Spaghetti", description: "A plate of spaghetti.", usage: "spaghetti"),
        Emoji(symbol: "🎲", name: "Die", description: "A single die.", usage: "taking a risk, chance; game"),
        Emoji(symbol: "⛺️", name: "Tent", description: "A small tent.", usage: "camping"),
        Emoji(symbol: "📚", name: "Stack of Books", description: "Three colored books stacked on each other.", usage: "homework, studying"),
        Emoji(symbol: "💔", name: "Broken Heart", description: "A red, broken heart.", usage: "extreme sadness"),
        Emoji(symbol: "💤", name: "Snore", description: "Three blue \'z\'s.", usage: "tired, sleepiness"),
        Emoji(symbol: "🏁", name: "Checkered Flag", description: "A black-and-white checkered flag.", usage: "completion")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        
        bindTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        tableView.reloadData()
    }
    
    func bindTableView() {
        let emoji = Observable.from([emojis])
                
        emoji
            .bind(to: tableView.rx.items) {
                (tableView: UITableView, index: Int, element: Emoji) in
                let indexPath = IndexPath(item: index, section: 0)
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmojiCell", for: indexPath) as! EmojiTableViewCell
                cell.update(with: element)
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx
                 .setDelegate(self)
                 .disposed(by: disposeBag)
        
        tableView.rx
          .modelSelected(Emoji.self)
          .subscribe(onNext: { emoji in
            self.showDetailsForEmoji(emoji)
          })
          .disposed(by: disposeBag)
        
        buttonNewEmoji.rx.tap
            .bind { [weak self] _ -> Void in
                self?.showDetailsForEmoji(nil)
            }
            .disposed(by: disposeBag)
        
    }
    
    func showDetailsForEmoji(_ emoji: Emoji?) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(identifier: "com.example.EmojiDictionary"))
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddEditEmojiTableViewController") as! AddEditEmojiTableViewController
        viewController.emoji = emoji
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
//    @IBSegueAction func addEditEmoji(_ coder: NSCoder, sender: Any?) -> AddEditEmojiTableViewController? {
//        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
//            // Editing Emoji
//            let emojiToEdit = emojis[indexPath.row]
//            return AddEditEmojiTableViewController(coder: coder, emoji: emojiToEdit)
//        } else {
//            // Adding Emoji
//            return AddEditEmojiTableViewController(coder: coder, emoji: nil)
//        }
//    }

    @IBAction func unwindToEmojiTableView(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind",
            let sourceViewController = segue.source as? AddEditEmojiTableViewController,
            let emoji = sourceViewController.emoji else { return }

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            emojis[selectedIndexPath.row] = emoji
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        } else {
            let newIndexPath = IndexPath(row: emojis.count, section: 0)
            emojis.append(emoji)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }

//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return emojis.count
//        } else {
//            return 0
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        //Step 1: Dequeue cell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "EmojiCell", for: indexPath) as! EmojiTableViewCell
//
//        //Step 2: Fetch model object to display
//        let emoji = emojis[indexPath.row]
//
//        //Step 3: Configure cell
//        cell.update(with: emoji)
//        cell.showsReorderControl = true
//
//        //Step 4: Return cell
//        return cell
//    }
//
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            emojis.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
//
//    // Override to support rearranging the table view.
//    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//        let movedEmoji = emojis.remove(at: fromIndexPath.row)
//        emojis.insert(movedEmoji, at: to.row)
//    }
//
//
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
    
    // MARK: Work over Variable

    static func configureDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<String, Emoji>> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Emoji>>(
            configureCell: { (_, tb, ip: Int, element: Emoji) in
                let indexPath = IndexPath(item: ip, section: 0)
                let cell = tb.dequeueReusableCell(withIdentifier: "EmojiCell", for: indexPath) as! EmojiTableViewCell
                cell.update(with: element)
                return cell
            },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model
            },
            canEditRowAtIndexPath: { (ds, ip) in
                return true
            },
            canMoveRowAtIndexPath: { _, _ in
                return true
            }
        )

        return dataSource
    }


}
