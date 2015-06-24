Rumali.categorizeColumns = function(options){
  var metrics = []
    , dimensions =[]
    , dimensions_color = '#A2DED0'
    , metrics_color = '#C5EFF7'
    , colname_for_setting_aggregation_method
    , metrics_with_aggregation_method = [];
  traverse_of_alias = {};
  var getDimenionsAndMetrics = function (callback) {
    var obj = {};
    obj['token'] = gon.token;
    $.ajax({
      url: rumi_api_endpoint + Rumali.gridoperation.restEndPoint() + "column/dimensions_and_metrics",
      type: "GET",
      data: obj,
      dataType: "json",
      success: function (data) {
        $.ajax({
          url: rumi_api_endpoint + Rumali.gridoperation.restEndPoint() + "column/all_columns?data_types=true&original_names=true&token=" + gon.token,
          type: "GET",
          data: obj,
          dataType: "json",
          success: function (data1) {
            self.datatype_column = data1.columns.column_types;
            Rumali.original_column_names = data1.columns.original_column_names;
            callback(data,data1);
          }
        });
      }
    });
  };
  var draggableMapping = function () {
    $( ".categorize_columns-draggable" ).draggable({
      addClasses: false,
      appendTo: "body",
      revert: "invalid",
      helper: "clone",
      zIndex: 100,
      start: function (event,ui) {
        var $target = $(event.target);
        ui.helper.width($target.width());
        ui.helper.addClass("drag-helper");
        $(".ui-droppable").addClass("drop-here");
      },
      stop: function () {
        $(".ui-droppable").removeClass("drop-here");
      }
    });
  };
  var showRemoveButton = function (col_type) {
    var show = false
      , selector = "";
    if (col_type === "metrics") {
      if (metrics.length > 0) {
        show = true;
      }
      selector = ".metrics-reset"
    } else if (col_type === "dimensions") {
      if (dimensions.length > 0) {
        show = true;
      }
      selector = ".dimensions-reset"
    }
    if (show) {
      $(selector).show();
    } else {
      $(selector).hide();
    }
  };

  jQuery.fn.highlight = function() {
     $(this).each(function() {
          var el = $(this);
          el.before("<div/>")
          el.prev()
              .width(el.width())
              .height(el.height())
              .css({
                  "position": "absolute",
                  "background-color": "#ffff99",
                  "opacity": ".9"
              })
              .fadeOut(1000);
      });
  }

  var toggleResetButton = function () {
    if (dimensions.length > 0 || metrics.length > 0) {
      $("#reset_all").show();
      $("#first_time_load").hide();
      showHintForChartEligibility();
    } else {
      $("#reset_all").hide();
      $("#dimension_metrics_container").highlight();
      $("#first_time_load").show();
    }
  }

  var clickedOnCancel = function (event) {
    if ($("#chart_show").css("display") === "block") {
      $(".is_selected_chart").removeClass("is_selected_chart");
      $("#chart_show").hide();
    }
    var parentNode = $(this.parentNode.parentNode)
      , col_type = $(parentNode[0]).data("coltype")
      , col_name = $(parentNode[0]).data("colname")
      , col_datatype = $(parentNode[0]).data("datatype")
      , col_aggregations = $(parentNode[0]).data("aggregation")
      , selector
      , color
      , index_from_dimensions = dimensions.indexOf(col_name)
      , table_data = {}
      , json_table_data
      , original_column_name_to_set = Rumali.original_column_names[col_name]
      , i;

    if (index_from_dimensions > -1) {
      dimensions.splice(index_from_dimensions, 1);
      table_show.removeDimensions([col_name]);
      showRemoveButton("dimensions");
    } else if (table_show.metrics[col_name] !== undefined) {
      metrics.splice(metrics.indexOf(col_name), 1);
      table_show.removeMetrics([col_name]);
      showRemoveButton("metrics");
    }
    if (col_type === "dimensions") {
      selector = "#ref_dimensions_list";
      color = dimensions_color;
    } else if (col_type === "metrics") {
      if (typeof col_aggregations === "string") {
        index_to_remove = metrics_with_aggregation_method.indexOf(original_column_name_to_set+"_"+col_aggregations);
        if ( index_to_remove >= 0 ) {
          metrics_with_aggregation_method.splice(index_to_remove,1)
        };
      } else {
        col_aggregations_length = col_aggregations.length;
        for(i = 0;i<=col_aggregations_length; i++){
          index_to_remove = metrics_with_aggregation_method.indexOf(original_column_name_to_set+"_"+col_aggregations[i]);
          if ( index_to_remove >= 0 ) {
            metrics_with_aggregation_method.splice(index_to_remove,1)
          };
        }
      }
      selector = "#ref_metrics_list";
      color = metrics_color;
    }
    removeIndividualMetricsFromSortSelectBox(event, col_name);
    table_show.executeOnFilter = function(){
      table_data = table_show.flushToGet().data;
      json_table_data = d3.csv.parse(table_data);
      refreshTableData(json_table_data);
      appendAliasToColumnHeader(user_entered_column_names);
      enableCharts(table_data,dimensions,metrics_with_aggregation_method);
      $(selector).append("<li class='categorize_columns-draggable' data-datatype='"+ col_datatype +"' data-colname='"+ col_name +"' data-coltype='" + col_type + "' style='background:"+color+"'>"+ original_column_name_to_set +"</li>");
      parentNode.remove();
      draggableMapping();
      toggleResetButton();
    }
    if (table_show.dimensions.length > 0 || !($.isEmptyObject(table_show.metrics))) {
      $("#table_show").show();
      table_show.call();
    } else {
      $("#table_show").hide();
      json_table_data = [{"":""}];
      refreshTableData(json_table_data);
      appendAliasToColumnHeader(user_entered_column_names);
      enableCharts(table_data,dimensions,metrics_with_aggregation_method);
      $(selector).append("<li class='categorize_columns-draggable' data-datatype='"+ col_datatype +"' data-colname='"+ col_name +"' data-coltype='" + col_type + "' style='background:"+color+"'>"+ original_column_name_to_set +"</li>");
      parentNode.remove();
      draggableMapping();
      toggleResetButton();
    }
  }

  var openAggregationSelectionDropdown = function (event) {
    var node = $(this.parentNode.parentNode)
      , colaggregation = node.data("aggregation");
    colname_for_setting_aggregation_method = node.data("colname");

    $("#select_metrics").select2("val",colaggregation);

    $("#aggregation_selection_list")
    .show()
    .css({
      top: event.clientY - $("#aggregation_selection_list")[0].getBoundingClientRect().height - 15,
      left: event.clientX
    });
  }

  var setAggregationMethod = function (that,e) {
    var pykquery_alias_obj = {}
      , table_data = {}
      , aggregation_method = that.val()
      , original_column_name_to_set = Rumali.original_column_names[colname_for_setting_aggregation_method]
      , index_to_remove;
    $("#Metrics .query-list[data-colname='"+colname_for_setting_aggregation_method+"']")
      .attr("data-aggregation",aggregation_method)
      .data("aggregation",aggregation_method);

    $("#Metrics .query-list[data-colname='"+colname_for_setting_aggregation_method+"'] .list-of-metrics")
      .html(aggregation_method.join(", ")+" - ");

    var aggregation_method_length = aggregation_method.length;
    for (var i = 0; i < aggregation_method_length; i++) {
      pykquery_alias_obj[aggregation_method[i]] = original_column_name_to_set+"_"+aggregation_method[i];
      traverse_of_alias[original_column_name_to_set+"_"+aggregation_method[i]] = [aggregation_method[i],colname_for_setting_aggregation_method];
    }
    table_show.metrics[colname_for_setting_aggregation_method] = aggregation_method;
    table_show.alias[colname_for_setting_aggregation_method] = pykquery_alias_obj;
    column_name_alias  = JSON.parse(JSON.stringify(table_show.alias));
    if (e.added) {
      original_column_name_to_set += "_"+e.added.id;
      Rumali.original_column_names[original_column_name_to_set] = original_column_name_to_set;
      metrics_with_aggregation_method.push(original_column_name_to_set);
      addColumnToSortSelectBox(original_column_name_to_set, original_column_name_to_set, colname_for_setting_aggregation_method,"metrics");
    } else if (e.removed) {
      original_column_name_to_set += "_"+e.removed.id;
      index_to_remove = metrics_with_aggregation_method.indexOf(original_column_name_to_set);
      if ( index_to_remove >= 0 ) metrics_with_aggregation_method.splice(index_to_remove,1);
      removeIndividualMetricsFromSortSelectBox(event,original_column_name_to_set);
    }
    table_show.executeOnFilter = function(){
      var table_data = table_show.flushToGet().data;
      refreshTableData(d3.csv.parse(table_data));
      appendAliasToColumnHeader(user_entered_column_names);
      enableCharts(table_data,dimensions,metrics_with_aggregation_method);
      $("#show_grid_and_hide_the_chart").trigger("click");
      $("#select_metrics").select2("close");
    }
    table_show.call();
  }

  var addColumnToSortSelectBox = function (original_column_name_to_set, original_column_value_to_set, col_name, col_type) {
    var select = document.getElementById("sort_by_column")
      , option = select.options[select.options.length] = new Option(original_column_name_to_set, original_column_value_to_set);
    option.setAttribute("data-col_name",col_name)
    option.setAttribute("data-col_type",col_type)
  }

  Rumali.refreshChartAfterFilter = function() {
    var table_data = table_show.flushToGet().data;
      refreshTableData(d3.csv.parse(table_data));
      appendAliasToColumnHeader(user_entered_column_names);
      enableCharts(table_data,dimensions,metrics_with_aggregation_method);
      $(".is_selected_chart").trigger('click');
  }

  var removeIndividualMetricsFromSortSelectBox = function(event,col_name,col_type){
    var selected_sort_value = $("#sort_by_column").val();
    if (col_type) {
      $("#sort_by_column option[data-col_type='"+col_type+"']").remove();
    } else {
      $("#sort_by_column option[data-col_name='"+col_name+"']").remove();
      $("#sort_by_column option[value='"+col_name+"']").remove();
    }
    if (dimensions.indexOf(selected_sort_value) === -1 && metrics_with_aggregation_method.indexOf(selected_sort_value) === -1) {
      $("#sort_by_column").val("");
      table_show.sort.shift();
    }

    event.stopPropagation();
  }

  var sortDataByColumn = function (that) {
    var sort_column_name = $("#sort_by_column").val();
    if (sort_column_name) {
      if ($(that).data("sort")) {
        $("#Sort .btn").removeClass("active");
        $(that).addClass("active");
      }
      var sort_obj = {}
        , table_data;
      sort_obj[$("#sort_by_column").val()] = $("#Sort .active").data("sort");
      table_show.sort[0] = sort_obj;
    } else {
      table_show.sort[0] = {};
    }
    table_show.executeOnFilter = function(){
      table_data = table_show.flushToGet().data;
      refreshTableData(d3.csv.parse(table_data));
      appendAliasToColumnHeader(user_entered_column_names);
      enableCharts(table_data,dimensions,metrics_with_aggregation_method);
      $("#show_grid_and_hide_the_chart").trigger("click");
    }
    table_show.call();
  }

  var setRowLimit = function (that) {
    table_show.executeOnFilter = function(){
      table_data = table_show.flushToGet().data;
      refreshTableData(d3.csv.parse(table_data));
      enableCharts(table_data,dimensions,metrics_with_aggregation_method);
      if ($(".is_selected_chart").length > 0) {
        $(".is_selected_chart.enabled").trigger("click");
      } else {
        $("#show_grid_and_hide_the_chart").trigger("click");
      }
    }
    var limit_value = $(that).val()
      , table_data;
    if (limit_value && limit_value > 0) {
      table_show.limit = limit_value;
    } else {
      table_show.limit = 200;
    }
    table_show.call();
    
  }

  var droppableMapping = function () {
    $(".categorize_columns-droppable").droppable({
      activeClass: "ui-state-hover",
      hoverClass: "ui-state-active",
      accept: ":not(.ui-sortable-helper)",
      drop: function( event, ui ) {
        if (this.id === "data_container") {
          if ($("#table_show").css("display") === "none") {
            $("#table_show").show();
          }
          if ($("#chart_show").css("display") === "block") {
            $(".is_selected_chart").removeClass("is_selected_chart");
            $("#chart_show").hide();
          }
        }
        ui.draggable.appendTo(this);
        var col_type = ui.draggable[0].parentNode.id
          , col_name = $(ui.draggable[0]).data("colname")
          , col_datatype = $(ui.draggable[0]).data("datatype")
          , new_col_type = ""
          , original_column_name_to_set  = Rumali.original_column_names[col_name]
          , color = ""
          , unchagned_column_name;

        if (col_type === "ref_dimensions_list") {
          new_col_type = "dimensions";
          color = dimensions_color;
        } else if (col_type === "ref_metrics_list") {
          new_col_type = "metrics";
          color = metrics_color;
        } else {
          var div_for_auto_scroll;
          ui.draggable.remove();
          col_type = $(ui.draggable[0]).data("coltype");
          if(col_type === "metrics") {
            var query_metric = {}
              , alias = {}
              , alias_obj = {}
              , aggregate_function
              , aggregate_select_box;

            if (col_datatype === "integer" || col_datatype === "double") {
              aggregate_function = "sum";
              aggregate_select_box = "<span class='glyphicon glyphicon-chevron-down show-aggregation-list'></span>";
            } else {
              aggregate_function = "count";
              aggregate_select_box = "";
            }
            query_metric[col_name] = [aggregate_function];
            original_column_name_to_set += "_"+aggregate_function;
            unchagned_column_name = original_column_name_to_set;
            Rumali.original_column_names[original_column_name_to_set] = original_column_name_to_set;
            alias_obj[aggregate_function] = original_column_name_to_set;
            alias[col_name] = alias_obj;
            table_show.metrics = query_metric;
            user_entered_column_names[col_name] = col_name+"_"+aggregate_function;
            table_show.alias   = alias;
            column_name_alias  = JSON.parse(JSON.stringify(table_show.alias));
            traverse_of_alias[original_column_name_to_set] = [aggregate_function,col_name];

            metrics.push(col_name);
            metrics_with_aggregation_method.push(original_column_name_to_set);
            $( "<li class='query-list' data-colname='"+col_name+"' data-datatype='" + col_datatype + "' data-aggregation="+[aggregate_function]+" data-coltype='metrics' style='background:" + metrics_color + "'><div class='dropdown'><span class='alias'></span><span class='list-of-metrics'>"+aggregate_function+" - </span>"+ui.draggable.text()+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+aggregate_select_box+"<span class='glyphicon glyphicon-remove-circle remove-from-query'></span></div></li>" ).appendTo($(this).find("#Metrics"));
            showRemoveButton("metrics");
            div_for_auto_scroll = document.getElementById("Metrics");
          } else if (col_type === "dimensions"){
            table_show.dimensions = [col_name];
            dimensions.push(col_name);
            $( "<li class='query-list' data-colname='"+col_name+"' data-datatype='" + col_datatype + "' data-coltype='dimensions' style='background:" + dimensions_color + "'><div class='dropdown'><span class='alias'></span>"+ui.draggable.text()+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class='glyphicon glyphicon-remove-circle remove-from-query'></span></div></li>").appendTo($(this).find("#Dimensions"));
            showRemoveButton("dimensions");
            div_for_auto_scroll = document.getElementById("Dimensions");
            unchagned_column_name = col_name;
          }
          div_for_auto_scroll.scrollLeft = div_for_auto_scroll.scrollWidth;
          toggleResetButton();
          addColumnToSortSelectBox(original_column_name_to_set,unchagned_column_name,col_name,col_type);
          table_show.executeOnFilter = function(){
            var table_data = table_show.flushToGet().data;
            refreshTableData(d3.csv.parse(table_data));
            appendAliasToColumnHeader(user_entered_column_names);
            enableCharts(table_data,dimensions,metrics_with_aggregation_method);
          }
          table_show.call();
        }
        ui.draggable.attr("data-coltype",new_col_type)
          .css('background',color);
        if (this.id == "ref_dimensions_list" || this.id == "ref_metrics_list") {
          setDimensionsAndMetrics(event);
        }
      }
    }).sortable({
      item:"li",
      sort: function() {
        $( this ).removeClass( "ui-state-default" );
      }
    });
    $( ".query-droppable" ).sortable({
      disabled: true
    });
  };

  var dimensionsReset = function (event) {
    if ($("#chart_show").css("display") === "block") {
      $(".is_selected_chart").removeClass("is_selected_chart");
      $("#chart_show").hide();
    }
    var dimensions_array = $("#Dimensions .query-list")
      , dimensions_length =  dimensions_array.length
      , html=""
      , table_data = {};
    for (var i=0; i<dimensions_length; i++) {
      var name = $($(dimensions_array[i])[0]).data("colname")
        , original_column_name_to_set = Rumali.original_column_names[name]
        , datatype = $($(dimensions_array[i])[0]).data("datatype");
      html += "<li class='categorize_columns-draggable' data-datatype='" + datatype + "' data-colname='"+ name +"' data-coltype='dimensions' style='background:" + dimensions_color + "'>"+ original_column_name_to_set +"</li>";
    }
    $("#ref_dimensions_list").append(html);
    $("#Dimensions .query-list").remove();
    table_show.resetDimensions();
    while (dimensions.length > 0) {
      dimensions.pop();
    }
    removeIndividualMetricsFromSortSelectBox(event,"","dimensions")
    table_show.executeOnFilter = function(){
      table_data = table_show.flushToGet().data;
      json_table_data = d3.csv.parse(table_data);
      refreshTableData(json_table_data);
      appendAliasToColumnHeader(user_entered_column_names);
      enableCharts(table_data,dimensions,metrics_with_aggregation_method);
      draggableMapping();
      showRemoveButton("dimensions");
      toggleResetButton();
    }
    if (!($.isEmptyObject(table_show.metrics))) {
      $("#table_show").show();
      table_show.call();
    } else {
      $("#table_show").hide();
      json_table_data = [{"":""}];
      refreshTableData(json_table_data);
      appendAliasToColumnHeader(user_entered_column_names);
      enableCharts(table_data,dimensions,metrics_with_aggregation_method);
      draggableMapping();
      showRemoveButton("dimensions");
      toggleResetButton();
    }
  };

  var metricsReset = function (event) {
    if ($("#chart_show").css("display") === "block") {
      $(".is_selected_chart").removeClass("is_selected_chart");
      $("#chart_show").hide();
    }
    var dimensions_length =  $("#Metrics .query-list").length
      , dimensions_array = $("#Metrics .query-list")
      , html=""
      , table_data = {};
    for (var i=0; i<dimensions_length; i++) {
      var name = $($(dimensions_array[i])[0]).data("colname")
        , original_column_name_to_set = Rumali.original_column_names[name]
        , datatype = $($(dimensions_array[i])[0]).data("datatype");
      html += "<li class='categorize_columns-draggable' data-datatype='" + datatype + "' data-colname='"+ name +"' data-coltype='metrics' style='background:" + metrics_color + "'>"+ original_column_name_to_set +"</li>";
    }
    $("#ref_metrics_list").append(html);
    $("#Metrics .query-list").remove();
    table_show.resetMetrics();
    while (metrics.length > 0) {
      metrics.pop();
    }
    while (metrics_with_aggregation_method.length > 0) {
      metrics_with_aggregation_method.pop();
    }
    removeIndividualMetricsFromSortSelectBox(event,"","metrics")
    table_show.executeOnFilter = function(){
      table_data = table_show.flushToGet().data;
      json_table_data = d3.csv.parse(table_data);
      refreshTableData(json_table_data);
      appendAliasToColumnHeader(user_entered_column_names);
      enableCharts(table_data,dimensions,metrics);
      draggableMapping();
      showRemoveButton("metrics")
      toggleResetButton();
    }
    if (table_show.dimensions.length > 0) {
      $("#table_show").show();
      table_show.call();
    } else {
      $("#table_show").hide();
      json_table_data = [{"":""}];
      refreshTableData(json_table_data);
      appendAliasToColumnHeader(user_entered_column_names);
      enableCharts(table_data,dimensions,metrics);
      draggableMapping();
      showRemoveButton("metrics")
      toggleResetButton();
    }
  };

  var activateMapping = function () {
    var removed
      , json_table_data;

    draggableMapping();
    droppableMapping();

    if ($("body").is("#scopejs_vizs_new")) {
      $(".query-ul").unbind("click");
      $(".query-ul").on("click",".remove-from-query", clickedOnCancel);
      $(".dimensions-reset").unbind("click");
      $(".dimensions-reset").on("click", dimensionsReset);
      $(".metrics-reset").unbind("click");
      $(".metrics-reset").on("click", metricsReset);
      $("#select_metrics").unbind("change");
      $(".query-ul").on("click",".show-aggregation-list", openAggregationSelectionDropdown);

      $(".close-aggregation-list").click(function () {
        $("#aggregation_selection_list").hide();
      });

      $("body").click(function (event) {
        if (!$(event.target).hasClass("show-aggregation-list") && !$(event.target).is("#select2-drop")) {
          $("#aggregation_selection_list").hide();
        }
      })

      $("#select_metrics").select2({
        width: 200,
        closeOnSelect: false,
        dropdownCss: {"z-index":10001}
      });

      $("#select_metrics")
        .on("change", function (event) {
          setAggregationMethod($(this),event);
        })
        .on("select2-removing", function (event) {
          if ($(this).val().length === 1) {
            console.warn("Cannot remove all the aggregation functions from a metric");
            event.preventDefault();
          }
        });

      $("#Sort .btn").click(function () {
        sortDataByColumn(this);
      });

      $("#sort_by_column").change(function () {
        sortDataByColumn(this);
      });

      $("#limit_rows").blur(function () {
        setRowLimit(this);
      });
    }
  };

  var showDimenionsAndMetrics = function (data,data1) {
    var dimensions = data.dimensions
      , metrics = data.metrics
      , html = ""
      , dimlen = dimensions.length
      , metlen = metrics.length;
    for (var i = 0; i < dimlen; i++) {
      html += "<li class='categorize_columns-draggable' data-datatype='"+data1.columns.column_types[dimensions[i]]+"' data-colname='"+dimensions[i]+"' data-coltype='dimensions' style='background:" + dimensions_color + "'>"+data1.columns.original_column_names[dimensions[i]]+"</li>";
    }
    html += "</ul>"
    $("#ref_dimensions_list").html(html);
    html = "";
    for (var i = 0; i < metlen; i++) {
      html += "<li class='categorize_columns-draggable' data-datatype='"+data1.columns.column_types[metrics[i]]+"' data-colname='"+metrics[i]+"' data-coltype='metrics' style='background:" + metrics_color + "'>"+data1.columns.original_column_names[metrics[i]]+"</li>";
    }
    html += "</ul>"
    $("#ref_metrics_list").html(html);
    activateMapping();
    var table_header_instance = $('#table_header').handsontable("getInstance");
    if(table_header_instance != undefined) {
      table_header_instance.updateSettings({data:Rumali.original_column_names});
    }
  };

  var setDimensionsAndMetrics = function (event) {
    var column_name = $(event.originalEvent.target).data("colname")
      , old_value = $(event.originalEvent.target).data("coltype").slice(0,-1)
      , data = {};
    value = event.target.id.split("_")[1].slice(0,-1);
    if (old_value !== value) {
      data = {
        column_name: column_name,
        value: value
      };
      data['token'] = gon.token;
      $.ajax({
        url: rumi_api_endpoint + Rumali.gridoperation.restEndPoint() + "column/set_column_dimension_and_metrics",
        type: "POST",
        data: data,
        contentType: "application/x-www-form-urlencoded",
        success: function(res) {
          $("#flash_categorize_columns-save").html("<p style='width: 70px; background: yellow;  padding: 5px;'>Saved</p>");
          setTimeout(function(){ $("#flash_categorize_columns-save").html(""); }, 1000);
        },
        error: function(res) {
          //alert(res.responseText);
        }
      });
    }
  };
  this.init = function (d) {
    var callback = function (data,data1) {
      showDimenionsAndMetrics(data,data1);
    }
    var columns = getDimenionsAndMetrics(callback);
  }
};
