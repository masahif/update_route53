# Update Route53 Record

EC2内から自IPでroute53のレコードを更新する。
EC2のインスタンスにsshアクセスするときにホスト名を調べるのが面倒なので、dynamic dnsのようにDNSレコードを更新します。


## 使い方

EC2のNameタグに短ホスト名、HostZoneNameにRoute53に登録されているドメイン名（.で終わってる必要あり)を登録してください。

```
update-route53.sh
```

上記を実行することでEC2からタグを取得してRoute53をアップデートします。


### Amazon Linux2の起動時に更新する

systemdに登録する
```
sudo bash setup.sh
```

再起動すると更新される。


### ログの見かた
sudo journalctl -u update-route53


### 一定時間ごとに更新する

EC2での運用の場合は、起動時のみの更新で十分だが、必要であれば update-route53.timer を /etc/systemd/systemに

