Rumali.renderStatistics = function (stats, dataType) {
  $("#statistics").empty();
  // console.log(stats + '-----------------' + dataType);
  $("#statistics").html("");
  $("#grid-count").empty();
  $("#grid-count").append("<table class='table table-condensed'><tr><td style='color: gray;'>COUNT:</td><td style='color: black; font-weight: bold;'>"+stats['count']+"</td></tr></table>");
  if (dataType == "integer" || dataType == "double") {
    $("#statistics").append("<table class='table table-condensed'><tr><td style='color: gray;'>AVG:</td><td style='color: black; font-weight: bold;'>"+parseFloat(stats['avg']).toFixed(2)
      +"</td><td style='color: gray;'>MIN:</td><td style='color: black; font-weight: bold;'>"+parseFloat(stats['min']).toFixed(2)
      +"</td><td style='color: gray;'>MAX:</td><td style='color: black; font-weight: bold;'>" +parseFloat(stats['max']).toFixed(2)
      + "</td><td style='color: gray;'>MEDIAN:</td><td style='color: black; font-weight: bold;'>" +parseFloat(stats['median']).toFixed(2)
      +"</td><td style='color: gray;'>SUM:</td><td style='color: black; font-weight: bold;'>" +parseFloat(stats['sum']).toFixed(2)
      + "</td></tr></table>");
  } else {
    $("#grid-count").append("<table class='table table-condensed'><tr><td style='color: gray;'>COUNT:</td><td style='color: black; font-weight: bold;'>"+stats['count']+"</td></tr></table>");
  }
}

Rumali.showStatistics = function (column_name, type) {
  var api_request_parameters = {};
  if (type == "integer" || type == "double") {
    api_request_parameters[column_name] = ['count','min','max','median','avg','sum'];
  } else {
    api_request_parameters[column_name] = ['count'];
  }
  pyk_statistics.resetMetrics();
  pyk_statistics.metrics = api_request_parameters;
  pyk_statistics.dataformat = 'json';
  try {
    pyk_statistics.call();
  } catch (err) {
    console.error(err, "error in statistics api call");
  }
  pyk_statistics.executeOnFilter = function(){
    var aggregate_values = JSON.parse(pyk_statistics.flushToGet().data)[0];
    Rumali.renderStatistics(aggregate_values, type);
    total_rows_count = aggregate_values.count;
    Rumali.gridoperation.showPagination(total_rows_count);
  }

}

Rumali.refreshStatistics = function () {
  var column_index = Rumali.gridoperation.getSelectedColumnIndex()
    , datatype , total_rows_count
    , aggregate_values = JSON.parse(pyk_statistics.flushToGet().data)[0];
  if (column_index == false) {
    datatype = "string";
  } else {
    datatype = self.column_datatype[column_index+1];
  }
  total_rows_count = aggregate_values.count;
  Rumali.gridoperation.showPagination(total_rows_count);
  if (total_rows_count > 0) {
    Rumali.renderStatistics(aggregate_values,datatype);
  } else {
    Rumali.renderStatistics({"count": 0}, "");
  }
}
