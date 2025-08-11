---
title: "Google Calendar の当番表を自動で埋める"
description: "今まで手作業で行っていた当番表の更新を Google App Script で半自動化しました。"
date: 2014-12-23 06:20
public: true
tags: developer productivity, automation, kaizenplatform, google app script, javascript, spreadsheets
alternate: false
ogp:
  og:
    image:
      '': 2014-12-23-touban-calendar/screen1.png
      type: image/png
      width: 992
      height: 525
---

![](2014-12-23-touban-calendar/screen1.png)

以前、以下の記事で紹介した様に、自分が働く [Kaizen Platform] のエンジニアチームは、Google Calendar を使って、2つの当番表を管理しています。

&raquo; [Google Calendar に登録している当番表を使って Slack Room のトピックを更新する]

このカレンダーの管理は、言い出しっ屁の手前、今まで、自分が手作業で行っていました。

この作業は、ひたすら、一覧からカレンダーにコピペするという、耐えがたい単純作業なので、[弊社の採用ページ]でも公言している、
***3度同じ事を繰り返す時は自動化する*** というモットーに基づき、[Google App Script] を用いて半自動化しました。

READMORE

## 使い方

**マスター管理シート** で、冒頭のスクリーンショットに表示されている、ドロップダウンから、`Fill in next interval` という項目を選択するだけで、
スプレッドシート上の `B` カラムに新しいインターバルの日付が入力され、カレンダー上の該当の日付に担当者の名前が登録されます。

![](2014-12-23-touban-calendar/screen2.png)

当たり前ですが、土日休日は休めます。

デプロイは週二回で、1日目: 検品環境、2日目: 本番環境にデプロイします。

![](2014-12-23-touban-calendar/screen3.png)

## 設定

![](2014-12-23-touban-calendar/screen4.png)

設定用のシート `_Settings` で上の様な設定表を作り、シート名: `LiveOps`, `Deployment` に対応するカレンダー ID を管理します。

カラム: `Step` は、当番一回につき、担当する日数です。弊社の場合は、LiveOps: 1日、デプロイ: 2日 (検品+本番) です。

シート名: `Holidays` として管理しているカレンダーは、休暇カレンダーです。現時点では、一つの休暇カレンダーに対応しています。

この例では、日本の休日: `en.japanese#holiday@group.v.calendar.google.com` を設定しています。

カレンダー ID は Google Calendar のカレンダー設定画面に表示されています。

![](2014-12-23-touban-calendar/screen5.png)

## スクリプト

![](2014-12-23-touban-calendar/screen6.png)

スプレッドシート画面の `Tools > Script editor` の項目を選択し、スクリプトエディタを起動します。

テンプレートを選択するダイアログが出てきますが、Close ボタンで閉じてください。

以下のコードを貼り付けます。

```js
//
// Utilities
//

function forEachRows(rows, startIndex, callback) {
  if(arguments.length === 2 && typeof startIndex === "function") {
    callback = startIndex;
    startIndex = 0;
  }
  var numRows = rows.getNumRows()
    , values = rows.getValues()
    ;
  for (var i = startIndex; i < numRows; i++) {
    var row = values[i]
      , isLast = i === numRows - 1;
    if (!row[0] || callback(row, i, isLast) === false) break;
  }
  return rows;
};

//
// Accessors
//

function getJapaneseHolidays(startTime) {
  var endTime = getDateByAddingDate(startTime, 365)
    , events =  getCalendarByName("Holidays").getEvents(startTime, endTime)
    , eventsNum = events.length
    , ret = []
    ;
  for (var i = 0; i < eventsNum; i++) {
    ret.push(getYMDFormattedDate(events[i].getStartTime()));
  }
  return ret;
};

function getLastDate(rows) {
  var found = null
    , index = -1
    , isLast = undefined
    ;
  forEachRows(rows, function(row, i, l) {
    if(row[1] instanceof Date) {
      found = row[1];
      index = i;
      isLast = l;
    } else
      return false;
  });
  return { date: found, index: index, isLast: isLast };
};

function getDateByAddingDate(date, offset) {
  return new Date(date.getTime() + offset * 24 * 60 * 60 * 1000);
};

function getYMDFormattedDate(date) {
  var fmt = function(i) { return i < 10 ? "0" + i : i + "" };
  return [
    date.getFullYear(),
    fmt(date.getMonth() + 1),
    fmt(date.getDate())
  ].join("/");
};

function getDatesToFill(rows, step) {
  var lastDate = getLastDate(rows)
    , startDate = lastDate.date
    , isLast = lastDate.isLast
    , startIndex = isLast ? 0 : (lastDate.index + 1)
    , holidays = getJapaneseHolidays(startDate)
    , offset = step
    , dates = []
    ;
  Logger.log(holidays);
  if(step === 2 && startDate.getDay() === 5) {
    offset = 5;
  }
  forEachRows(rows, startIndex, function(row, i, l) {
    for(var day = -1;;) {
      date = getDateByAddingDate(startDate, offset);
      day = date.getDay();
      if(step === 2 && day === 5) {
        if(
          isInHolidays(getDateByAddingDate(date, 3), holidays) ||
          isInHolidays(getDateByAddingDate(date, 4), holidays)
        ) {
          // QA Deploy on Fridays if next Monday or Tuesday is holiday
          offset += 5;
          break;
        } else {
          // Do not deploy on Fridays
          offset += 3;
        }
      } else {
        offset += step;
        if(!isDateToSkip(date, holidays)) break;
      }
    }
    dates.push([date]);
  });
  return dates;
};

function isDateToSkip(date, holidays) {
  var day = date.getDay()
    , month = date.getMonth()
    , dateNum = date.getDate()
    ;
  return day === 0 || day === 6 || isInHolidays(date, holidays) ||
  (month === 11 && dateNum >= 27) || // nenmatsu
  (month === 0 && dateNum <=4) // nenshi
  ;
};

function isInHolidays(date, holidays) {
  return holidays.indexOf(getYMDFormattedDate(date)) !== -1;
};

var settings = null
  , sheetNames = null
  ;

function getSetting(name, key) {
  if(!settings) {
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("_Settings")
      , range = sheet.getRange("A:C")
      ;
    settings = range.getValues();
    sheetNames = [];
    for(var i = 0, n; i < settings.length; i++) {
      n = settings[i][0];
      if(n && !/^_/.test(n)) sheetNames.push(n);
    }
  }
  var legend = settings[0]
    , x = legend.indexOf(key)
    , y = sheetNames.indexOf(name)
    ;
  return x >= 0 && y >= 0 ? settings[y][x] : undefined;
};

function getStepByName(name) {
  return getSetting(name, "Step");
};

function getCalendarByName(name) {
  var id = getSetting(name, "Calendar ID");
  return CalendarApp.getCalendarById(id);
}

//
// Menu actions
//

function fillInNextInterval() {
  var sheet = SpreadsheetApp.getActiveSheet()
    , rows = sheet.getDataRange()
    , lastDate = getLastDate(rows)
    , isLast = lastDate.isLast
    , startIndex = isLast ? 0 : lastDate.index + 1
    , notation = "B" + (startIndex + 1) + ":" + "B" + rows.getNumRows()
    , range = sheet.getRange(notation)
    , values = getDatesToFill(rows, getStepByName(sheet.getName()))
    ;
  if(lastDate.isLast) sheet.insertColumnAfter(1);
  range.setValues(values);
};

function exportToCalendar() {
  var sheet = SpreadsheetApp.getActiveSheet()
    , rows = sheet.getDataRange()
    , name = sheet.getName()
    , step = getStepByName(name)
    , calendar = getCalendarByName(name)
    , holidays = null
    ;
  forEachRows(rows, function(row, i, l) {
    var masterName = row[0]
      , startDate = row[1]
      , date = startDate
      , count = 0
      ;
    if(!(startDate instanceof Date)) return;
    if(!holidays) holidays = getJapaneseHolidays(startDate);
    for(;;) {
      if(!isDateToSkip(date, holidays)) {
        calendar.createAllDayEvent(masterName, date);
        if(++count === step) break;
      }
      date = getDateByAddingDate(date, 1);
    }
  });
};

function fillInNextInterval2Cal() {
  fillInNextInterval();
  exportToCalendar();
}

//
// App Script Handlers
//

function onOpen() {
  var spreadsheet = SpreadsheetApp.getActiveSpreadsheet()
    , entries = [
        {
          name : "Fill in next interval",
          functionName : "fillInNextInterval2Cal"
        }
      ]
    ;
  spreadsheet.addMenu("Masters2Cal", entries);
};
```


初回実行時、認証ダイアログがでてくるので、権限を許可して下さい。

![](2014-12-23-touban-calendar/screen7.png)

## 所感

[Google App Script] を初めて触りましたが、ログがリアルタイムに確認できなかったり、API がサービス全ての機能をカバーしているわけではなく、
使い辛い点もありましたが、Web 画面でサクっと書いたロジックでツールを実装できるのは魅力的だな、と思いました。

## TODOs

- 全自動化をする。 (Hubot から実行？)
- 重複管理に対応する。
- 当番交代に対応する。
- 複数の休暇カレンダーに対応する。(現時点で年末年始がハードコーディングになっている。)

[Google App Script]: https://developers.google.com/apps-script/
[Kaizen Platform]: https://kaizenplatform.com/
[Google Calendar に登録している当番表を使って Slack Room のトピックを更新する]: /2014/09/01/hubot-touban-topic/
[弊社の採用ページ]: https://kaizenplatform.com/hiring/engineer.html
