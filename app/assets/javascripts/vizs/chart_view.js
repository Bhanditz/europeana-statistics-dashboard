Rumali.chartView = function () {
  var createQueryObject = function () {
    Rumali.gridoperation = new Rumali.gridOperation();
    table_show = new PykQuery.init("aggregation", "local", "table_show", "rumi");
    table_show.limit = 200;
    table_show.rumiparams = Rumali.gridoperation.restEndPoint();
    table_show.dataformat = "csv"
  }
  $("#reset_all").click(function() {
    $("#Dimensions").empty();
    $("#Metrics").empty();
    $("#table_show").hide();
    $("#chart_show").empty();
    $("#sort_by_column").html("<option value''>Select a column</option>");
    $(".remove-all").hide();
    $("#reset_all").hide();
    $("#first_time_load").show();
    $("#dimension_metrics_container").highlight();
    table_show.resetDimensions();
    table_show.resetMetrics();
    table_show.sort.shift();
    disableAllChartsAndGrid();
    createDragDrop();
    showHintForChartEligibility();
  });
  var createDragDrop = function () {
    var k = new Rumali.categorizeColumns();
    k.init();
    $("#dimension_metrics_container").highlight();
  }
  createQueryObject();
  createDragDrop();
  showTable();

  $("#core_viz_submit").click(function(){
    // $("#new_core_viz").submit(function (evt) {
    //   evt.preventDefault();
    // })
    var select_chart = $(".is_selected_chart").length > 0 ? $(".is_selected_chart") : $("#show_grid_and_hide_the_chart")
    var  dataset = select_chart.data()
    , chart_combination_code = dataset.combination_code
    , pykquery_object = {}
    , sort_key
    , sort_value
    , new_sort_key
    , alias_key
    , alias_agg_key
    , config;
    if (chart_combination_code){
      $("#core_viz_ref_chart_combination_code").val(chart_combination_code);
      pykquery_object.dimensions = table_show.dimensions;
      pykquery_object.metrics = table_show.metrics;
      if (chart_combination_code === "e91b52") {
        for (var key in table_show.alias) {
          delete table_show.alias[key];
        }
        table_show.alias = column_name_alias;
        pykquery_object.alias = table_show.alias;
      } else {
        pykquery_object.alias = getChartAlias(dataset.dimensions_alias, dataset.metrics_alias)
      }
      if(table_show.sort && table_show.sort.length > 0) {
        pykquery_object.sort = [];
        sort_key = Object.keys(table_show.sort[0])[0];
        if (traverse_of_alias[sort_key]) {
          sort_value = table_show.sort[0][sort_key];
          alias_agg_key = traverse_of_alias[sort_key][0];
          alias_key = traverse_of_alias[sort_key][1];
          new_sort_key = pykquery_object.alias[alias_key][alias_agg_key];
          var new_sort_obj = {};
          new_sort_obj[new_sort_key] = sort_value;
          pykquery_object.sort.push(new_sort_obj);
        } else {
          pykquery_object.sort = table_show.sort;
        }
      }
      if(table_show.limit) {
        pykquery_object.limit = table_show.limit;
      }
      if (divg1.filters.length > 0) {
        pykquery_object.filters = divg1.filters;
      }
      pykquery_object.dataformat = table_show.dataformat
      pykquery_object.mode = table_show.mode
      config = JSON.parse(gon.default_theme)
      if (dataset.api == "PykCharts.multiD.panelsOfLine") { 
        config.chart_width = 250
        config.chart_height = 250
      } else {
        config.chart_width = 575
        config.chart_height = 400
      }
      $("#core_viz_pykquery_object").val(JSON.stringify(pykquery_object));
      $("#core_viz_config").val(JSON.stringify(config));
    }
  });
  var getChartAlias = function(dimensions_alias, metrics_alias){
    var alias_to_store = {}
      , query_object_dimension_array = table_show.dimensions
      , query_object_metrics_array = Object.keys(table_show.metrics)
      , i
      , dimensions_length = dimensions_alias.length
      , metrics_length = metrics_alias.length;
    for(var i = 0;i<dimensions_length;i++){
      alias_to_store[query_object_dimension_array[i]] =  dimensions_alias[i];
    }

    for(var i = 0; i < metrics_length; i++){
      var alias_obj = query_object_metrics_array[i]
        , metric_functions = alias_obj ? Object.keys(table_show.alias[alias_obj]) : Object.keys(table_show.alias[query_object_metrics_array[0]])
        , metric_functions_length = metric_functions.length;
      if (metric_functions[i]) { // If multiple metric functions are there on the same column
        metric_function = metric_functions[i];
      } else {
        metric_function = metric_functions[0];
      }
      if (alias_obj && typeof alias_to_store[alias_obj] !== "object") {
        alias_to_store[alias_obj] = {};
      }
      if (alias_obj) {
        alias_to_store[alias_obj][metric_function] = metrics_alias[i];
      } else {
        alias_to_store[query_object_metrics_array[0]][metric_function] = metrics_alias[i];
      }
    }
    return alias_to_store;
  }

  $("#show_grid_and_hide_the_chart").click(function(){
    if(!$(this).hasClass("disabled")){
      $(".is_selected_chart").removeClass("is_selected_chart");
      $("#table_show").show();
      $("#chart_show").hide();
      showHintForChartEligibility();
    }
  });
}
