from datetime import datetime
import qbittorrentapi

qbt = qbittorrentapi.Client(host='localhost', port=8080)

# Retrieve the list of all torrents
try:
    all_torrents = qbt.torrents_info()
except qbittorrentapi.APIError as e:
    print(f"Error retrieving torrents list")
    qb.auth_log_out()
    exit(1)

success_count = 0

for torrent in all_torrents:
    if 'the_name_of_the_tag' in torrent.tags:
        try:
            torrent.add_trackers(urls="https://someTracker.com/trackerURL/announce")
            success_count += 1
        except qbittorrentapi.APIError as e:
            print("Error adding tracker")
            print(torrent)

print(f"Successful adds: {success_count}")
