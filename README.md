## Terraformのインストール手順
### Macの場合

```
$ brew install tfenv
$ tfenv install 0.12.6
$ tfenv use 0.12.6
```


### Windows10の場合

```$xslt
$ git clone https://github.com/tfutils/tfenv.git ~/.tfenv
$ echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
$ tfenv install 0.12.6
$ tfenv use 0.12.6
```

