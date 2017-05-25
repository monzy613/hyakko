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
        if let filePath = audioList[indexPath.row].filePath {
            let url = URL(fileURLWithPath: filePath)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.delegate = self
                player?.play()
            } catch {
                fatalError("\(error)")
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(VoiceNoteCell.self), for: indexPath) as! VoiceNoteCell
        let audio = audioList[indexPath.row]
        cell.textLabel?.text = audio.displayName

        return cell
    }

    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
    }
}
