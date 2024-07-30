# Sync spotify playlists with spotdl

## Setup

### Install python and spotdl

```bash
python3 -m pip install spotdl==4.2.4
spotdl --download-ffmpeg
```

### Configure spotdl

Create an app here <https://developer.spotify.com/dashboard>

Configure spotdl with generated client id and secret values from the Spotify app.

```bash
spotdl --generate-config
```

> In the client library source code, we may have to change backoff_factor=0.3 -> 1 to prevent 429 errors.

## Sync songs

Populate config.csv with `<spotify_url>`,`<folder_name>` rows.

> Remove any query parameters, e.g. `https://open.spotify.com/playlist/7yk2GXh3gR4jCYtTk8H44v?si=f851cade20934307` -> `https://open.spotify.com/playlist/7yk2GXh3gR4jCYtTk8H44v`

Run:

```bash
bash sync.sh
```
