//
//  SWFileListTableViewController.swift
//  swissTechTest
//
//  Created by Dmitry Suvorov on 15/05/17.
//  Copyright © 2017 ip-suvorov. All rights reserved.
//
import UIKit

protocol SWFileListTableViewControllerDelegate: class {
    func didChoose(path: URL)
}

class SWFileListTableViewController: UITableViewController {
    let fileManager = FileManager.default
    weak var delegate: SWFileListTableViewControllerDelegate?
    var curPath: URL? // путь к текущей директории
    var dirPaths = [URL]() // адреса (полные) директорий в текущей директории
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // если текущая директория не установлена, выбираем корневую директорию приложения
        if curPath == nil {
            curPath = URL(string: NSHomeDirectory())
        }
        
        // получаем директории в текущей директории
        self.dirPaths = getDirPaths()
        
        // добавляем название в navigation bar и кнопку
        if self.curPath == URL(string: NSHomeDirectory()) {
            self.navigationItem.title = "Home directory"
        } else {
            self.navigationItem.title = self.curPath?.lastPathComponent
        }
        
        let chooseBtn = UIBarButtonItem(
            title: "Choose",
            style: .plain,
            target: self,
            action: #selector(SWFileListTableViewController.chooseBtnPressed(sender:))
        )
        self.navigationItem.rightBarButtonItem = chooseBtn
        
        // регистрируем cellReuseIdentifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "swDir")
    }
    
    // возвращает список поддиректорий текущей директории
    func getDirPaths() -> ([URL]) {
        var paths = [URL]()
        var resPaths = [URL]()
        
        // получаем список файлов и поддиректорий
        do  {
            paths = try self.fileManager.contentsOfDirectory(at: self.curPath!, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
        } catch {
            return []
        }
        
        // ищем только директории
        for path in paths {
            // if path is directory (not a file)
            var isDirectory = false
            do {
                var resourceValue: AnyObject?
                try (path as NSURL).getResourceValue(&resourceValue, forKey: URLResourceKey.isDirectoryKey)
                if let number = resourceValue as? NSNumber , number == true {
                    isDirectory = true
                }
            }
            catch { }
            
            if isDirectory {
                resPaths.append(path)
            }
        }
        // сортируем по алфавиту
        resPaths = resPaths.sorted(){$0.lastPathComponent < $1.lastPathComponent}
        
        return resPaths
    }
    
    
    // нажата кнопка "выбрать"
    func chooseBtnPressed(sender: UIBarButtonItem) {
        if self.curPath != nil {
            self.delegate?.didChoose(path: self.curPath!)
            let alert = UIAlertController(title: "Monitoring has been started", message: "Directory '" + self.curPath!.lastPathComponent + "' has been being monitored. Please, press 'Home' button to start getting push-notifications.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dirPaths.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "swDir", for: indexPath)
        cell.textLabel?.text = self.dirPaths[indexPath.row].lastPathComponent
        cell.imageView?.image = UIImage(named: "folder")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newPath = dirPaths[indexPath.row]
        let newVC = SWFileListTableViewController(nibName: "SWFileListTableViewController", bundle: nil)
        newVC.delegate = self.delegate
        newVC.curPath = newPath
        self.navigationController?.pushViewController(newVC, animated: true);
    }

    
}
