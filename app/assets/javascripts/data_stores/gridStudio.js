$(document).ready(function() {

  Rumali.gridoperation = new Rumali.gridOperation();
  Rumali.pykqueryInit();
  Rumali.gridtopbar = new Rumali.gridTopMenu();
  Rumali.gridsidebar = new Rumali.sidebarDatatype();
  Rumali.plugin = new Rumali.plugins();
  Rumali.sidebar_unique = Rumali.sidebarUnique();
  Rumali.api = new Rumali.gridApiCall();
  Rumali.sidebarHistogram();
  $("#grid-column-form").hide();
  $("#col-info-panel").hide();
  $("#submit").hide();
  $("#pyk_histogram").append("<div id='histogram-chart'></div>"); //Added Div for histogram
  $("#pyk_statistics").append("<div id='statistics'></div>"); //Added Div for statistics
  //Function for initilized query
  var api_request_parameters = {},both_flag = 0,column_data;
  grid_show.limit = 200;
  grid_show.rumiparams = Rumali.gridoperation.restEndPoint();
  grid_show.dataformat = "array"
  try {
    grid_show.call();
    } catch(err) {
      console.log(err, 'cannot show grid Data');
    }
  grid_show.executeOnFilter = function (){
    json_data = grid_show.flushToGet();
    if(json_data != undefined) {
      self.json_data = json_data.data;
      set_flag();
    }
  }
  grid_columns.metrics ={"id":['count']}
  grid_columns.limit = 2000;
  grid_columns.rumiparams = Rumali.gridoperation.restEndPoint();
  grid_columns.dataformat = 'array'
  try {
      grid_columns.call();
    } catch(err) {
      console.error(err+" error in pagination count not available");
    }
  grid_columns.executeOnFilter = function(){
    var count = grid_columns.flushToGet().data;
    if(count[1][0] != undefined) {
      Rumali.gridoperation.showPagination(count[1][0]);
    } else {
      console.error("error in pagination count not available");
    }
  }
  api_request_parameters["original_names"] = true;
  api_request_parameters["data_types"] = true;
  api_request_parameters["token"] = gon.token;
  api_request_parameters['sub_types'] = true;
  Rumali.api.originalColumnName(api_request_parameters, function (res) {
    column_data = res;
    self.validation_for_map = res;
    set_flag();
  })

  function renderGrid() {
    console.log("----create Grid----");
    self.column_datatype  = Rumali.gridoperation.changeToColumnsType(column_data);
    self.editor_types = Rumali.gridoperation.getAllEditorTypes();
    Rumali.pykgrid.appendGrid(column_operation,row_operation);
    var inst =$("#grid_show").handsontable("getInstance");
    columns =Rumali.gridoperation.getColumnsWithType(self.column_datatype);
    inst.updateSettings({columns:columns});
  }

  function set_flag() {
    both_flag = both_flag + 1;
    if(both_flag == 2) {
      renderGrid();
      both_flag = 0;
    }
  }

  var row_operation = {
      items: {
        "row_above": {
          disabled: function () {
            //if first row, disable this option
            return ($("#grid_show").handsontable('getSelected')[0] <= 0);
          },
        },
        "row_below": {},
        "remove_row": {
          disabled: function () {
            //if first row, disable this option
            return ($("#grid_show").handsontable('getSelected')[0] == 0);
          },
        },
      },
    };

    var column_operation = {
      items: {
        "Add_column": {
          name: 'Insert 1 left',
          callback: function() {
            Rumali.gridoperation.addColumnData("left");
          },
        },
        "Add_column_right": {
          name: 'Insert 1 right',
          callback: function() {
            Rumali.gridoperation.addColumnData("right");
          },
        },
        "deleat_column": {
          name: 'Delete Column',
          callback: function() {
            Rumali.gridoperation.deleteColumnData();
          },
        },
        "sort_ascending": {
          name: 'Sort sheet A -> Z',
          callback: function() {
            Rumali.gridoperation.sortColumnData('asc');
          },
        },
        "sort_descending": {
          name: 'Sort sheet Z -> A',
          callback: function() {
            Rumali.gridoperation.sortColumnData('desc');
          },
        }
      },
    };

  $("#explore_on_map_button").on("click",function(e){
    //console.log(rumi_api_endpoint + PYKMODEL.restEndPoint(),"clicked");
    checklatlng(self.validation_for_map);
    e.preventDefault();
    //return false;
  });

  // $("#save-trigger-btn").click(function() {
  //   $("#submit").trigger("click");
  // });

  // $('#addNewRow').unbind('click').click(function(){
  //   grid.addNewRow();
  // });
  // $('#addNewColumn').unbind('click').click(function(){
  //   grid.addNewColumn();
  // });
  // $('#deleteRow').unbind('click').click(function(){
  //   dataView.deleteItems(selectedRowIds);
  // });
  // $('#deleteColumn').unbind('click').click(function(){
  //   grid.deleteColumn();
  // });
  // $('#editColumn').unbind('click').click(function(){
  //   grid.editColumn();
  // });

    var metrix_and_dimension = new Rumali.categorizeColumns();
    metrix_and_dimension.init();
});

Rumali.executeAfterFilter = function() {
  var col = Rumali.gridoperation.getSelectedColumnIndex();
      grid_show.offset = 0;
      grid_show.executeOnFilter = function(){
        var data = grid_show.flushToGet().data;
        if (Rumali.gridoperation.update_grid_with_new_data(data)) {
          Rumali.gridoperation.reloadGrid();
          generate_notify({text:"Filter Updated",notice:"success",timeout:true});
        } else {
          generate_notify({text:"Failed to filter data",notify:"error",timeout:true});
        }
        Rumali.gridoperation.showFilterCount();
      }
}

Rumali.executeAfterHistogramFilter = function(new_min,new_max){
  if(new_min != undefined && new_max != undefined) {
    global_brush.extent([new_min,new_max]);
    brush.call(global_brush);
  }
  grid_show.offset = 0;
  grid_show.executeOnFilter = function(){
    var data = grid_show.flushToGet().data;
    if (Rumali.gridoperation.update_grid_with_new_data(data)) {
      Rumali.gridoperation.reloadGrid();
      Rumali.gridoperation.showFilterCount();
      generate_notify({text:"Filter Updated",notice:"success",timeout:true});
    } else {
      generate_notify({text:"Failed to filter data",notify:"error",timeout:true});
    }
  }
}

Rumali.executeAfterDeleteFilter = function() {
  var data = grid_show.flushToGet().data;
  if (data != undefined && data != "") {
    self.json_data = data;
    Rumali.gridoperation.reloadGrid();
    Rumali.gridoperation.resetFilterElements();
    generate_notify({text:"Filter Updated",notice:"success",timeout:true});
  } else {
      generate_notify({text:"Failed to filter data",notify:"error",timeout:true});
  }
}

Rumali.executeAfterUniquevalueFilter = function() {
  grid_show.offset = 0;
  grid_show.executeOnFilter = function(){ 
    var data = grid_show.flushToGet().data;
    if (Rumali.gridoperation.update_grid_with_new_data(data)) {
      Rumali.gridoperation.reloadGrid();
      generate_notify({text:"Filter Updated",notice:"success",timeout:true});
    } else {
      generate_notify({text:"Failed to filter data",notify:"error",timeout:true});
    }
    Rumali.gridoperation.showFilterCount();
  }
}

Rumali.executeAfterRangeFilter = function() {
  grid_show.executeOnFilter = function() {
    var data = grid_show.flushToGet().data;
    if (Rumali.gridoperation.update_grid_with_new_data(data)) {
      Rumali.gridoperation.reloadGrid();
      generate_notify({text:"Filter Updated",notice:"success",timeout:true});
    } else {
      generate_notify({text:"Failed to filter data",notify:"error",timeout:true});
    }
    Rumali.gridoperation.resetFilterElements();
    Rumali.gridoperation.showFilterCount();
  }
}

var checklatlng = function(grid_getallcolumns){
  var validation_for_map;
  var api_request_parameters = {};
  api_request_parameters["original_names"] = true;
  api_request_parameters["data_types"] = true;
  api_request_parameters["token"] = gon.token;
  api_request_parameters['sub_types'] = true;
  $.ajax({
    url: rumi_api_endpoint + Rumali.gridoperation.restEndPoint() + "column/all_columns",
    data: api_request_parameters, //return  data
    dataType: 'json',
    type: 'GET',
    //async:false,
    success: function(res) {
      validation_for_map = res;
      var status = take_action_latlng(validation_for_map)
        if(status){
          var map_url = window.location.href;
          map_url = (map_url).replace("edit","map");
          console.log(map_url);
          window.location = map_url;
        }
    },
    error: function() {
      console.error('Error in fetch data from server');
    }
  });

};

var take_action_latlng = function(validation_for_map){
  var sub_types = validation_for_map.columns.sub_types,latflag=false,lngflag=false,column=[];
  for(var i in sub_types){
    if(sub_types[i]==="latitude"){
      latflag=true;
      column.push(i)
    }else if(sub_types[i]==="longitude"){
      lngflag=true;
      column.push(i);
    }
  }
  if(latflag==false && lngflag==true){
    alert("You have set following columns "+ column +" as Longitude, however we could not find any column which is set as Latitude. Please, select a column, go to the Format menu and set the Sub Type as Latitude to continue.");
    return false;
  }else if(lngflag==false && latflag==true){
    alert(" You have set following columns "+ column +" as Latitude, however we could not find any column which is set as Longitude. Please, select a column, go to the Format menu and set the Sub Type as Longitude to continue.");
    return false;
  }else if(lngflag==false && latflag==false){
    alert("The \"Explore on Map\" functionality is only for data sets with latitudes and longitudes. Please, select a column, go to the Format menu and set the Sub Type as Latitude and Longitude to continue.");
    return false;
  }
  return true;
}
