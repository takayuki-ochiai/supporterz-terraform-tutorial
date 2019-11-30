## Terraformのインストール手順
### Macの場合
- tfenvを使ってインストールした方が後々のバージョン変更とかもスムーズにできるのでおすすめです

```
$ brew install tfenv
$ tfenv install 0.12.6
$ tfenv use 0.12.6
```


### Windows10の場合
- 下記のURLからTerraformのzipアーカイブをダウンロード下記のURLからTerraformのzipアーカイブをダウンロード
  - 64bitの場合
    - https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_windows_amd64.zip
  - 32bitの場合
    - https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_windows_386.zip
- C:\hashicorp\terraform\0.12.6  というディレクトリを作っておきzipファイルの中身をC:\hashicorp\terraform\0.12.6 に展開
  - C:\hashicorp\terraform\0.12.6\terraform.exe ができればOK
  - [![Image from Gyazo](https://i.gyazo.com/8ebe8b19c62a2e279de613578f9394e9.png)](https://gyazo.com/8ebe8b19c62a2e279de613578f9394e9)
- C:\hashicorp\terraform\0.12.6 にPATHを通す
  - [![Image from Gyazo](https://i.gyazo.com/b25097d5cda945f66b6b42f82f3bc0e1.png)](https://gyazo.com/b25097d5cda945f66b6b42f82f3bc0e1)
- PowerShellなどからterraform -vなどが呼べれば成功！
  - [![Image from Gyazo](https://i.gyazo.com/4062a4a2fe2f15c75d514708ec60babb.jpg)](https://gyazo.com/4062a4a2fe2f15c75d514708ec60babb)
