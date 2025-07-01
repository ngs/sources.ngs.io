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
