var calCulateMetricLength = function(metrics){
  var metrics_length = 0;
  for(i in metrics){
    metrics_length += metrics[i].length;
  }
  return metrics_length;
}

var convertColumnToAlias = function (data, columns, alias) {
  var len = alias.length
    , new_data = data;
  for (var i = 0; i < len; i++) {
    var pykquery_alias = table_show.alias[columns[i]];
    if (typeof(pykquery_alias) === "string") {
      new_data = new_data.replace(pykquery_alias, alias[i]);
    } else if (typeof(pykquery_alias) === "object") {
      var keys = Object.keys(pykquery_alias)
        , keys_length = keys.length;
      for (var j = 0; j < keys_length; j++) {
        new_data = new_data.replace(pykquery_alias[keys[j]], alias[i]);
      }
    }
    new_data = new_data.replace(columns[i], alias[i]);
  }
  return new_data;
}

var CSVparse = function (csv) {
  var lines = csv.split("\n")
    , result = []
    , headers = lines[0].split(",")
    , len = lines.length;
  for (var i = 1; i < len; i++) {
    var obj = {}
      , currentline = lines[i].split(",")
      , len1 = headers.length;
    for (var j = 0; j < len1; j++) {
      obj[headers[j]] = currentline[j];
    }
    result.push(obj);
  }
  return result;
}