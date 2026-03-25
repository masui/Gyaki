# Gyaki

ブラウザでお絵描きしてGyazoにアップロードするサービス。

## 構成

- Sinatra アプリ (`gyaki.rb`)
- フロントエンド: CoffeeScript (`public/javascripts/draw.coffee`) → JS にコンパイル
- テンプレート: ERB (`views/draw.erb`)

## ローカル実行

```
make run
```

CoffeeScript のコンパイル後、`http://localhost:4567` で起動。

## デプロイ

gyaki.org はさくらインターネットのサーバーで稼働。自動デプロイは無い。

1. `make push` (GitHub にpush)
2. Gyaki.org(さくらのサーバー)にSSH
3. `cd /home/masui/Gyaki && git pull`
4. `gyaki.rb` を変更した場合: `sudo systemctl restart gyaki`
5. JS/静的ファイルのみの変更なら再起動不要（ブラウザキャッシュに注意）

### サーバー構成

- nginx (`/etc/nginx/conf.d/gyaki.conf`) → localhost:3001 にリバースプロキシ
- systemd サービス (`/usr/lib/systemd/system/gyaki.service`)
- アプリ配置先: `/home/masui/Gyaki/`
