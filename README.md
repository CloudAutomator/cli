# Cloud Automator CLI
Cloud Automator CLI (`ca`) は、Cloud Automator のトリガージョブと後処理の情報を取得するためのコマンドラインツールです。

- [Cloud Automator](https://cloudautomator.com/)

# インストール
## Linux/macOS
1. インストールスクリプトを実行する

インストールスクリプトは `~/.local/bin`, `~/bin`, `/usr/local/bin` の順番で書き込み可能なディレクトリを探して、最初に見つかったディレクトリにインストールします。

```sh
curl -sSf https://raw.githubusercontent.com/CloudAutomator/cli/main/install.sh | sh -s
```

> [!NOTE]
インストール先を指定したい場合は `BINDIR` 環境変数を設定して実行してください。
> ```sh
> curl -sSf https://raw.githubusercontent.com/CloudAutomator/cli/main/install.sh | BINDIR=~/.cloudautomator/bin sh -s
> ```

2. Cloud Automator CLI が正しくインストールされたことを確認する

```sh
ca version
```

`command not found` と表示される場合、インストール先のディレクトリが `PATH` に含まれているかを確認してください。

## Windows
1. [Releases](https://github.com/CloudAutomator/cli/releases/latest) から、Windows のZIPパッケージをダウンロードします
2. ダウンロードしたパッケージを解凍します
3. スタートメニューを開いて「環境変数」を検索、「システム環境変数の編集」をクリックします
4. 「環境変数」ボタンをクリックします
5. 「<ユーザー名> のユーザー環境変数」ボックス内の `Path` をクリックして選択、「編集」ボタンをクリックします
6. 「新規」ボタンをクリック、(2) で解凍したフォルダのパスを指定します
7. PowerShell、もしくはコマンドプロンプトで Cloud Automator CLI が正しくインストールされたことを確認します

```sh
ca version
```

# 使用方法
## 環境変数の設定
Cloud Automator CLI を利用するには、APIキーを環境変数に設定する必要があります。
APIキーの取得方法については、以下のサービスマニュアルを参照してください。

- [Cloud Automator APIの利用方法](https://support.serverworks.co.jp/hc/ja/articles/6051827207193)

### Linux/macOS

```sh
export CLOUDAUTOMATOR_API_KEY="APIキー"
```

### Windows
#### Command Prompt

```cmd
set CLOUDAUTOMATOR_API_KEY=APIキー
```

#### PowerShell
```ps
$Env:CLOUDAUTOMATOR_API_KEY="APIキー"
```

## ジョブの情報を取得する

すべてのジョブの情報を取得する。

```sh
ca jobs
```

IDを指定してジョブを取得する。

```sh
ca jobs --id <job_id>
```

## 後処理の情報を取得する

すべての後処理の情報を取得する

```sh
ca post-processes
```

IDを指定して後処理の情報を取得する

```sh
ca post-process --id <post_process_id>
```

## オプション
### **--output, -o**

取得した結果の出力形式を指定する。

```sh
# 例: YAML形式で出力する
ca jobs --id 1234 --output yaml

# 例: JSON形式で出力する
ca jobs --id 1234 --output json
```

# アップデート
インストールの手順と同様に、インストールスクリプトを実行してください。<br>
最新のバージョンのバイナリがダウンロードされ、古いバージョンのバイナリが上書きされます。

# アンインストール
バイナリを削除することでアンインストールできます。

## Linux/macOS

```sh
# バイナリがインストールされているディレクトリを確認する
which ca
~/.local/bin/ca

# バイナリを削除する
rm ~/.local/bin/ca
```

## Windows

```cmd
# バイナリがインストールされているディレクトリを確認する
where ca
C:\Users\<ユーザー名>\AppData\Local\Programs\ca\ca.exe

# バイナリを削除する
del C:\Users\<ユーザー名>\AppData\Local\Programs\ca\ca.exe
```
