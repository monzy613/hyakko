//
//  RecordListViewController.swift
//  hyakko
//
//  Created by Monzy Zhang on 25/05/2017.
//  Copyright © 2017 MonzyZhang. All rights reserved.
//

import UIKit
import AVFoundation

class RecordListViewController: UITableViewController, AVAudioPlayerDelegate {
    var audioList: [AudioSaveInfo] = []
    var currentPlayingIndexPath: IndexPath?
    var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(VoiceNoteCell.self,
                           forCellReuseIdentifier: NSStringFromClass(VoiceNoteCell.self))
        audioList = CoreDataConnect.shared().fetchAudioList()
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioList.count
    }

    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let player = player {
            if player.isPlaying {
                player.stop()
                self.player = nil
            }
        }
        if let playingIndexPath = currentPlayingIndexPath {
            if indexPath == playingIndexPath {
                currentPlayingIndexPath = nil
                tableView.reloadRows(at: [indexPath], with: .automatic)
                return
            }
        }
        if let fileName = audioList[indexPath.row].fileName {
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory = paths[0] as NSString
            let dataPath = documentsDirectory.appendingPathComponent("save")
            let filePath = (dataPath as NSString).appendingPathComponent(fileName)
            let url = URL(fileURLWithPath: filePath)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.delegate = self
                player?.play()
            } catch {
                fatalError("\(error)")
            }
        }
        currentPlayingIndexPath = indexPath
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(VoiceNoteCell.self), for: indexPath) as! VoiceNoteCell
        let audio = audioList[indexPath.row]
        cell.titleLabel.text = audio.displayName
        if indexPath == currentPlayingIndexPath {
            cell.playing = true
        } else {
            cell.playing = false
        }

        return cell
    }

    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
        if let indexPath = currentPlayingIndexPath {
            currentPlayingIndexPath = nil
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
