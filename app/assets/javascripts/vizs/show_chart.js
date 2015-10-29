var showHintForChartEligibility = function (data, api) {
  var text = "";
  data_length = data.length;
  switch (api) {
    case "PykCharts.oneD.pie":
    case "PykCharts.oneD.donut":
    case "PykCharts.oneD.electionPie":
    case "PykCharts.oneD.electionDonut":
    case "PykCharts.oneD.pyramid":
    case "PykCharts.oneD.funnel":
    case "PykCharts.oneD.bubble":
    case "PykCharts.oneD.treemap":
    case "PykCharts.oneD.percentageBar":
    case "PykCharts.oneD.percentageColumn":
      if (data_length > 6) {
        text = "Ideally, this chart should not have more than 6 partitions. You may check the other charts too, to get the best match.";
      }
      break;
    case "PykCharts.multiD.multiSeriesLine":
      var unique_group = [];
      for (var i = 0; i < data_length; i++) {
        var name = data[i].name;
        if (unique_group.indexOf(name) === -1) {
          unique_group.push(name);
        }
      }
      if (unique_group.length > 5) {
        text = "Ideally, this chart should not have more than 5 lines. You may check the other charts too, to get the best match.";
      }
      break;
    case "PykCharts.multiD.panelsOfLine":
      var unique_group = [];
      for (var i = 0; i < data_length; i++) {
        var name = data[i].name;
        if (unique_group.indexOf(name) === -1) {
          unique_group.push(name);
        }
      }
      if (unique_group.length > 9) {
        text = "Ideally, this chart should not have more than 9 panels. You may check the other charts too, to get the best match.";
      }
      break;
    case "PykCharts.multiD.stackedArea":
      var unique_group = [];
      for (var i = 0; i < data_length; i++) {
        var name = data[i].name;
        if (unique_group.indexOf(name) === -1) {
          unique_group.push(name);
        }
      }
      if (unique_group.length > 4) {
        text = "Ideally, this chart should not have more than 4 stacks. You may check the other charts too, to get the best match.";
      }
      break;
    case "PykCharts.multiD.bar":
    case "PykCharts.multiD.column":
      if (data_length > 20) {
        text = "Ideally, this chart should not have more than 20 bars. You may check the other charts too, to get the best match.";
      }
      break;
    case "PykCharts.multiD.groupedBar":
      var unique_group = [];
      for (var i = 0; i < data_length; i++) {
        var name = data[i].group;
        if (unique_group.indexOf(name) === -1) {
          unique_group.push(name);
        }
      }
      if (unique_group.length > 4 || data.length > 24) {
        text = "Ideally, this chart should not have more than 4 groups and more than 24 bars. You may check the other charts too, to get the best match.";
      }
      break;
    case "PykCharts.multiD.groupedColumn":
      var unique_group = [];
      for (var i = 0; i < data_length; i++) {
        var name = data[i].group;
        if (unique_group.indexOf(name) === -1) {
          unique_group.push(name);
        }
      }
      if (unique_group.length > 4 || data.length > 24) {
        text = "Ideally, this chart should not have more than 4 groups and more than 24 bars. You may check the other charts too, to get the best match.";
      }
      break;
    case "PykCharts.multiD.scatter":
      var unique_group = [];
      for (var i = 0; i < data_length; i++) {
        var name = data[i].group;
        if (unique_group.indexOf(name) === -1) {
          unique_group.push(name);
        }
      }
      if (unique_group.length > 6 || data.length > 50) {
        text = "Ideally, this chart should not have more than 50 bubbles and 6 groups. You may check the other charts too, to get the best match.";
      }
      break;
    case "PykCharts.multiD.panelsOfScatter":
      var unique_group = [];
      for (var i = 0; i < data_length; i++) {
        var name = data[i].group;
        if (unique_group.indexOf(name) === -1) {
          unique_group.push(name);
        }
      }
      if (unique_group.length > 9 || data.length > 50) {
        text = "Ideally, this chart should not have more than 50 bubbles and 9 panels. You may check the other charts too, to get the best match.";
      }
      break;
    case "PykCharts.multiD.pulse":
      var unique_group = []
        , unique_x = []
        , unique_y = [];
      for (var i = 0; i < data_length; i++) {
        var name = data[i].group
          , x = data[i].x
          , y = data[i].y;
        if (unique_group.indexOf(name) === -1) {
          unique_group.push(name);
        }
        if (unique_x.indexOf(x) === -1) {
          unique_x.push(x);
        }
        if (unique_y.indexOf(y) === -1) {
          unique_y.push(y);
        }
      }
      if (unique_group.length > 6 || unique_x.length > 30 || unique_y.length > 10) {
        text = "Ideally, this chart should not have more than 6 groups and 30 points in x-axis and 10 points on y-axis. You may check the other charts too, to get the best match.";
      }
      break;
    case "PykCharts.multiD.spiderWeb":
      var unique_group = [];
      for (var i = 0; i < data_length; i++) {
        var name = data[i].group;
        if (unique_group.indexOf(name) === -1) {
          unique_group.push(name);
        }
      }
      if (unique_group.length > 4) {
        text = "Ideally, this chart should not have more than 4 groups and 32 data points. You may check the other charts too, to get the best match.";
      }
      break;
  }
  document.getElementById("chart_eligibility").innerHTML = text;
}

var enableCharts = function(data, dimensions_array, metrics_array,dataTypeOfDimensions){
  var dimensions = table_show.dimensions
  , metrics = table_show.metrics
  , dimsensions_length = dimensions.length
  , metrics_length = calCulateMetricLength(metrics);

  checkConditionAndEnable(dimsensions_length,metrics_length);
  showChart(data, dimensions_array, metrics_array,dataTypeOfDimensions);
}

var checkConditionAndEnable = function(dimensions_required,metrics_required){
  $("#core_viz_submit").show();
  disableAllChartsAndGrid();
  if (dimensions_required > 0 || metrics_required > 0){
    $("#show_grid_and_hide_the_chart").removeClass("disabled").addClass("enabled");
  } else{
      $("#core_viz_submit").hide();
  }
  var all_charts = document.getElementsByClassName("charts");
  var all_charts_length = all_charts.length;
  for(var i=0;i<all_charts_length;i++){
    var chart = all_charts[i];
    if (parseInt($(chart).data("dimensions_required"),10) == dimensions_required && parseInt($(chart).data("metrics_required"),10) == metrics_required) {
      $(chart).removeClass("disabled");
      $(chart).addClass("enabled");
    }
  }
}

var showChart = function(data, dimensions_array, metrics_array,dataTypeOfDimensions){
  $(".charts.enabled").unbind("click");
  $(".charts.enabled").click(function(event){
    $(".is_selected_chart").removeClass("is_selected_chart");
    $("#table_show").hide();
    $("#chart_show").empty();
    $(this).addClass("is_selected_chart");
    var dataset = $(this).data();
    var api = dataset.api;
    callTheChart(api, data, dimensions_array, metrics_array, dataset.dimensions_alias, dataset.metrics_alias,dataTypeOfDimensions);
    $("#chart_show").show();
    event.preventDefault();
  });
}

var callTheChart = function(api, data, dimensions_array, metrics_array, dimensions_alias, metrics_alias, dataTypeOfDimensions){
  data = convertColumnToAlias(data, dimensions_array, dimensions_alias);
  data = convertColumnToAlias(data, metrics_array, metrics_alias);
  chart_api = getApiFromString(api);
  showHintForChartEligibility(data, api);
  time_value = findTimeValue(data);
  var config = JSON.parse(gon.default_theme);
  config.title_text = "";
  config.subtitle_text = "";
  config.legends_enable = "no";
  config.axis_x_time_value_datatype = time_value[0];
  config.axis_x_time_value_interval = time_value[1];
  config.data = data;
  if (api ===  "PykCharts.multiD.panelsOfLine") { 
    config.chart_width = 250
    config.chart_height = 250
  } else {
    config.chart_width = 575
    config.chart_height = 400
  }
  config.selector = "#chart_show";
  $(".pyk-tooltip").remove();
  var k = new chart_api(config);
  k.execute();
}

var disableAllChartsAndGrid = function(){
  $(".options").removeClass("enabled");
  $(".options").addClass("disabled");
  $(".charts").unbind("click");
}
var findTimeValue = function (data) {
  new_data = d3.csv.parse(data);
  if (!(isNaN(new Date(new_data[0].x).getTime()))) {
    var extent = d3.extent(new_data, function (d) {
      return new Date(d.x);
    });
    var timeDiff = Math.abs(extent[1].getTime() - extent[0].getTime());
    var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
    if (diffDays > 30) {
      return ["month", 1];
    } else {
      return ["date",3];
    }
  }
  return [];
}
