Rumali.dataTypeUtils = function () {

  this.isBoolean = function (value) {
    bool_data_type = ['t', 'f', "true", "false", 'y', 'n', 'yes', 'no'];
    if (value != null) {
      value = value.toLocaleString();
      value = value.toLowerCase();
      if (bool_data_type.indexOf(value) >= 0) {
        return "boolean";
      } else {
        return false;
      }
    }
  }


  this.isDate = function (value) {
    var date = Date.parse(value);
    if (date == null) {
      return false;
    } else {
      return "date";
    }
  }

  this.isNumber = function (value) {
    if (typeof(value) == "string") value.trim();
    if (!isNaN(value) && value != "" && value != null) {
      if (value.toString()
        .indexOf('.') != -1) {
        return "double";
      } else {
        return "integer";
      }
    } else {
      return false;
    }
  }

  this.isBlank = function (value) {
    if (typeof(value) == "string") value.trim();
    return (value == "") ? "blank" : false;
  }

  this.toFloat = function (value) {
    if (typeof(value) == "string") value.trim();
    if (!isNaN(value) && value.toString()
      .indexOf('.') == -1) {
      return parseFloat(value)
        .toFixed(2);
    } else {
      return value;
    }
  }

  this.toLetters = function (num) {
    "use strict";
    var mod = num % 26,
      pow = num / 26 | 0,
      out = mod ? String.fromCharCode(64 + mod) : (--pow, 'Z');
    return pow ? toLetters(pow) + out : out;
  }

  this.toTitleCase = function (str) {
    if (isNaN(str) && str !== undefined) str = str.toLowerCase();
    if (str != undefined && str != "" && typeof(str) == "string") {
      return str.replace(/\w\S*/g, function (txt) {
        return txt.charAt(0)
          .toUpperCase() + txt.substr(1)
          .toLowerCase();
      });
    }
  }

  this.toWhiteSpace = function (value) {
    if (value != undefined && value != "") {
      value.toString();
      return value.replace(/\s+/g, " ");
    }
  }

  this.toIsoCode = function (value) {
    if (typeof(value) != "string") value = value.toString();
    var query_text = value.toLowerCase()
      , iso2_codes = []
      , states = ["Andaman", "Andhra",
          "Arunachal", "Assam", "Bihar", "Chandigarh", "Chhattisgarh",
          "Dadra", "Daman", "Delhi", "Goa", "Gujarat",
          "Haryana", "Himachal Pradesh", "Jammu", "Jharkhand",
          "Karnataka", "Kerala", "Lakshadweep", "Madhya", "Maharashtra",
          "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Orissa", "Puducherry",
          "Punjab", "Rajasthan", "Sikkim", "Tamil", "Tripura", "Uttarakhand",
          "Uttar", "West Bengal"
        ]
      , states_short = ["AN", "AP", "AR", "AS", "BR", "CH", "CT",
          "DN", "DD",
          "DL",
          "GA", "GJ", "HR", "HP", "JK", "JH", "KA", "KL", "LD", "MP", "MH", "MN",
          "ML", "MZ", "NL", "OR", "PY", "PB", "RJ", "SK", "TN", "TR", "UT", "UP",
          "WB"
        ]
      , lent = states.length;
    for (var i = 0; i < lent; i++) {
      if (query_text.indexOf(states[i].toLowerCase()) > -1) {
        return "IN_" + states_short[i];
      }
    }
    return value;
  }

  this.random_name = function () {
    var text = "undefined_column_"
      , possible = "abcdefghijklmnopqrstuvwxyz0123456789";
    // var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (var i = 0; i < 5; i++) {
      text += possible.charAt(Math.floor(Math.random() * possible.length));
    }
    return text;
  }
};

Rumali.datatype_utils =  new Rumali.dataTypeUtils();
