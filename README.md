# 台灣運動中心場地租用狀況查詢器

## 安裝

```
gem install gym_finder
```

軟體需求：

- imagemagick v7+
- tesseract v3+

### Ubuntu

```
apt-get install -Y imagemagick tesseract
gem install gym_finder
```

### OSX

```
brew install imagemagick tesseract
gem install gym_finder
```

## 使用

請先至運動中心註冊，以設定 `GYM_FINDER_USERNAME` 與 `GYM_FINDER_PASSWORD` 環境變數。

```
Usage: env GYM_FINDER_USERNAME=USR GYM_FINDER_PASSWORD=PWD gym_finder [options]
    -g, --gyms name1,name2,name3     gym name filter
    -c, --court name1,name2,name3    court name filter
        --[no-]weekend
        --[no-]weekday
        --[no-]only-available        show only available slots
    -u, --username USERNAME          username, defaults to env GYM_FINDER_USERNAME
    -p, --password PASSWORD          password, defaults to env GYM_FINDER_PASSWORD
    -t, --hours hour1-hour2,hour3    hours
    -h, --help                       prints this help
```

## 使用範例

取得中山與內湖運動中心的週末 08:00 尚未租用的羽球場地：

```
$ gym_finder -g 中山,內湖 -c 羽球 -t 8 --weekend | ruby -r json -e 'puts JSON.pretty_generate JSON.parse $stdin.read'
[
  {
    "gym": "內湖運動中心",
    "type": "羽球",
    "court": "羽 1",
    "price": 300,
    "status": "available",
    "time": "2018-11-10T08:00:00+08:00",
    "gym_homepage": "https://nhsc.cyc.org.tw/",
    "reservation_link": "https://scr.cyc.org.tw/tp12.aspx?module=net_booking&files=booking_place&StepFlag=25&QPid=83&QTime=8&PT=1&D=2018/11/10"
  },
  {
    "gym": "內湖運動中心",
    "type": "羽球",
    "court": "羽5",
    "price": 300,
    "status": "available",
    "time": "2018-11-10T08:00:00+08:00",
    "gym_homepage": "https://nhsc.cyc.org.tw/",
    "reservation_link": "https://scr.cyc.org.tw/tp12.aspx?module=net_booking&files=booking_place&StepFlag=25&QPid=87&QTime=8&PT=1&D=2018/11/10"
  }
]
```

取得南港運動中心 10:00 至 12:00 或 15:00 尚未租用的桌球場地：

```
$ gym_finder -g 南港 -c 桌球 -t 10-12,15 | ruby -r json -e 'puts JSON.pretty_generate JSON.parse($stdin.read).first(2)'
[
  {
    "gym": "南港運動中心",
    "type": "桌球",
    "court": "桌 A",
    "price": 100,
    "status": "available",
    "time": "2018-11-04T10:00:00+08:00",
    "gym_homepage": "https://ngsc.cyc.org.tw/",
    "reservation_link": "https://scr.cyc.org.tw/tp02.aspx?module=net_booking&files=booking_place&StepFlag=25&QPid=89&QTime=10&PT=3&D=2018/11/04"
  },
  {
    "gym": "南港運動中心",
    "type": "桌球",
    "court": "桌 B",
    "price": 100,
    "status": "available",
    "time": "2018-11-04T10:00:00+08:00",
    "gym_homepage": "https://ngsc.cyc.org.tw/",
    "reservation_link": "https://scr.cyc.org.tw/tp02.aspx?module=net_booking&files=booking_place&StepFlag=25&QPid=90&QTime=10&PT=3&D=2018/11/04"
  }
]
```

## 輸出格式

`gym_finder` 輸出格式為 JSON，格式如下：

```json
[
  {
    "gym": "內湖運動中心",
    "type": "羽球",
    "court": "羽2",
    "price": 300,
    "status": "available",
    "time": "2018-11-04T08:00:00+08:00",
    "gym_homepage": "https://nhsc.cyc.org.tw/",
    "reservation_link": "https://scr.cyc.org.tw/tp12.aspx?module=net_booking&files=booking_place&StepFlag=25&QPid=84&QTime=8&PT=1&D=2018/11/04"
  }
]
```

## 支援的運動中心

- [中山運動中心](http://cssc.cyc.org.tw/)
- [南港運動中心](https://ngsc.cyc.org.tw/)
- [信義運動中心](https://xysc.cyc.org.tw/)
- [大安運動中心](https://dasc.cyc.org.tw/)
- [文山運動中心](http://wssc.cyc.org.tw/)
- [內湖運動中心](https://nhsc.cyc.org.tw/)
- [蘆洲國民運動中心](http://lzcsc.cyc.org.tw/)
- [土城國民運動中心](https://tccsc.cyc.org.tw/)
- [汐止國民運動中心](http://xzcsc.cyc.org.tw/)
- [永和國民運動中心](https://yhcsc.cyc.org.tw/)
- [中壢國民運動中心](https://zlcsc.cyc.org.tw/)
- [桃園國民運動中心](https://tycsc.cyc.org.tw/)
