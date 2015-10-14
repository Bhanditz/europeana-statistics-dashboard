var column_name_alias = {}
  , user_entered_column_names = {};
var showTable = function () {
  chart_view_filter = new PykQuery.init("aggregation", "local", "chart_view_filter", "rumi");
  chart_view_filter.rumiparams = Rumali.gridoperation.restEndPoint();
  divg1 = new PykQuery.init("aggregation", "global", "divg1", "rumi");
  pyk_histogram = new PykQuery.init("aggregation", "local", "pyk_histogram", "rumi");
  pyk_histogram.rumiparams = Rumali.gridoperation.restEndPoint();
  column_values_filter = new PykQuery.init("aggregation", "local", "column_values_filter", "rumi");
  column_values_filter.addImpacts(["divg1"],false);
  pyk_histogram.addImpacts(["divg1"],false);
  divg1.addImpacts(["table_show"],false);
  divg1.listFilters("list_applied_filters");
  Rumali.gridoperation.showFilterCount();
  Rumali.sidebarUnique();
  Rumali.plugin = new Rumali.plugins();
  $cont = $('#table_show');
  $('#table_show').handsontable({
    data: {},
    // data: data,
    readOnly:true,
    fixedRowsTop: 1,
    colHeaders: true,
    manualColumnMove: true,
    outsideClickDeselects: false,
    contextMenu: false,
    cells: function(row, col, prop) {
      return {
        renderer: firstRowRenderer
      }
    }
  });
  $('#table_header').handsontable({
    data: {},
    readOnly:true,
    colHeaders: true,
    manualColumnMove: true,
    outsideClickDeselects: false,
    contextMenu: false,
    cells: function(row, col, prop) {
      return {
        renderer: columnRowRenderer
      }
    }
  });

  var table_is = $cont.handsontable("getInstance");
  var table_header = $('#table_header').handsontable("getInstance");
  table_header.addHook('afterOnCellMouseDown', function (event, coords, TD) {
      if (coords.row == -1 && coords.col != -1 && event.button == 0) {
        columnHeaderSelected(coords);
      } else {
          // Rumali.gridoperation.columnHeaderDeselected();
        
      }
  });
  table_is.addHook('afterChange', function(array, mode) {
    if(mode == "edit"){
      var new_name = array[0][3] , old_name = array[0][1],row_index = array[0][0],old_value =array[0][2];
      if(old_value != new_name){
        setAlias(old_name,new_name);
        showAliasInColumnHeader(old_name,new_name ,row_index);
      }
    }
  });

  var columnHeaderSelected = function(index){
    var column_header = Object.keys(Rumali.original_column_names);
    var column_index = index.col
      , col_name = column_header[column_index]
      , datatype , aggregate_values
      , api_request_parameters ={};
    $('#table1').show();
    $('#table1').addClass('active');
    $('#all_charts').removeClass('active');
    $('#show_filter_tab').addClass('active');
    $('#chart_selector_list').removeClass('active');
    datatype = self.datatype_column[col_name];
    selected_datatype = datatype;
    new_column_name = col_name;
    chart_view_filter.dataformat = 'json'
    api_request_parameters[col_name] = ['count'];
    chart_view_filter.resetDimensions();
    chart_view_filter.resetMetrics();
    chart_view_filter.dimensions = [col_name];
    chart_view_filter.metrics = api_request_parameters;
    chart_view_filter.executeOnFilter = function(){
      aggregate_values = JSON.parse(chart_view_filter.flushToGet().data)
      data_distribution = Rumali.gridoperation.changeToJsonData(aggregate_values,column_header[column_index]);
      // Rumali.countUniqueValues(data_distribution,"asce",col_name);
      if (datatype == "integer" || datatype == "double") { 
        $('#merge').hide();
        $('#grid_unique_values').hide();
        Rumali.histogram(col_name,datatype,data_distribution);
      } else {
        $('#histogram-chart').hide();
        $('#histogram_min_max').hide();
        $('#grid_unique_values').show();
        Rumali.countUniqueValues(data_distribution,"asce",col_name);
      } 
      Rumali.gridoperation.resetFilterElements(); 
    }
    chart_view_filter.call();
  }

  var showAliasInColumnHeader = function (old_colname,new_colname,row_index) {
    if(old_colname != new_colname){
      var value = new_colname+" ("+ Rumali.original_column_names[old_colname]+")";
      self.table_data[row_index][old_colname] = value;
    }else{
      var value = old_colname;
      self.table_data[row_index][old_colname] = value;
    }
    table_is.render();
  }

  var setAlias = function (old_colname,new_colname) {
    var all_metric_functions = ['sum','count','min','max','avg','median']
      , colsplit = old_colname.split("_")
      , colsplit_len = colsplit.length;

    if (all_metric_functions.indexOf(colsplit[colsplit_len-1]) > -1) {
      var old_metric = colsplit.pop()
        , prev_colname
        , colname;
      original_colname = colsplit.join("_");
      for (var key in Rumali.original_column_names) {
        if (Rumali.original_column_names[key] === original_colname) {
          colname = key;
          break;
        }
      }

      if (table_show.alias[colname][old_metric]) {
        prev_colname = table_show.alias[colname][old_metric];
      } else {
        prev_colname = old_colname;
      }
      user_entered_column_names[prev_colname] = new_colname;
      column_name_alias[colname][old_metric] = new_colname;
    } else {
      user_entered_column_names[old_colname] = new_colname;
      var alias = column_name_alias[old_colname];
      if (alias && alias[old_colname]) {
        column_name_alias[old_colname][old_colname] = new_colname;
      } else {
        column_name_alias[old_colname] = new_colname;
      }
    }
  }

  function firstRowRenderer(instance, td, row, col, prop, value,cellProperties) {
    Handsontable.TextCell.renderer.apply(this, arguments);
    if (row <= 0) {
      cellProperties.readOnly = false;
      td.style.fontWeight = 'bold';
      td.style.color = '#1B668B';
      td.style.background = '#f0f0f0';
    }
  }
  function columnRowRenderer(instance, td, row, col, prop, value,cellProperties) {
    Handsontable.TextCell.renderer.apply(this, arguments);
    if (row <= 0) {
      td.style.fontWeight = 'bold';
      td.style.color = '#1B668B';
      td.style.background = '#f0f0f0';
    }
  }

}

var appendAliasToColumnHeader = function(column_obj){
  for(var prop in column_obj){
    if(self.table_data[0][prop] != undefined && self.table_data[0][prop] != column_obj[prop]){
      self.table_data[0][prop] = column_obj[prop] +" ("+self.table_data[0][prop]+")";
      $('#table_show').handsontable("render");
    }
  }
}

Rumali.refreshAfterFilter = function() {
  table_show.executeOnFilter = function() {
    if($("#table_show").css("display") == 'block') {
      var data = table_show.flushToGet().data
      if(data != undefined && data != "") {
        json_table_data = d3.csv.parse(data);
        refreshTableData(json_table_data);
        generate_notify({text:"Filter Updated",notice:"success",timeout:true});
      } else {
        generate_notify({text:"No data For this filter",notify:"error",timeout:true});
      }  
    } else if($("#chart_show").css("display") == 'block') {
      Rumali.refreshChartAfterFilter();
    }
    Rumali.gridoperation.resetFilterElements();
    Rumali.gridoperation.showFilterCount();
  }
}

Rumali.executeAfterHistogramFilter = function(new_min,new_max) {
  if(new_min != undefined && new_max != undefined) {
    global_brush.extent([new_min,new_max]);
    brush.call(global_brush);
  }
  Rumali.refreshAfterFilter();
}

Rumali.executeAfterUniquevalueFilter = function() {
  Rumali.refreshAfterFilter();
}

Rumali.executeAfterDeleteFilter = function() {
  Rumali.refreshAfterFilter();
}

Rumali.executeAfterRangeFilter = function(){
  Rumali.refreshAfterFilter();
}

var refreshTableData = function(data){
  self.table_data = data;
  var column_header = [],obj = {},columns = [];
  var CustomTextEditor = Handsontable.editors.TextEditor.prototype.extend();
  CustomTextEditor.prototype.prepare = function(row, col, prop, td, originalValue, cellProperties){
    var show_value = originalValue.replace("("+Rumali.original_column_names[self.column_header[col]]+")","");
    originalValue = show_value;
     //Invoke the original method...
    Handsontable.editors.BaseEditor.prototype.prepare.apply(this, arguments);
  };
  if(self.table_data[0] != undefined){
    self.column_header = Object.keys(self.table_data[0]);
    for(var a=0;a<self.column_header.length;a++){
      columns.push({editor:CustomTextEditor,
                    data:self.column_header[a]});
      obj[self.column_header[a]] = Rumali.original_column_names[self.column_header[a]];
    }
  }else{
    console.error("No Column Header in data Or no data is present For this filter")
  }
  data.splice(0, 0, obj);
  var table_instance = $('#table_show').handsontable("getInstance");
  table_instance.updateSettings({data:self.table_data,columns:columns});
}
