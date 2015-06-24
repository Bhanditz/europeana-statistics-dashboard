Rumali.gridOperation = function(){
 var that = this;
  this.getAllEditorTypes = function () { // function to set datatype of columns
    return {
      boolean: 'checkbox',
      date: 'date',
      integer: 'numeric',
      double: 'numeric',
      string: 'text',
    };
  }

  this.deleteColumnData = function () {
    var col = $("#grid_show").handsontable('getSelected')[1]
      , column_name = self.columns_header[col+1]
      , api_request_parameters = {};
    api_request_parameters["column_name"] = column_name;
    pyk_statistics.resetMetrics();
    pyk_statistics.resetDimensions();
    grid_unique_values.resetDimensions();
    grid_unique_values.resetMetrics();
    //that.removeAllFilterColumn(column_name);
    divg1.destroyColumn(column_name);
    new_column_name = self.columns_header[col];
    Rumali.api.postAjaxcall(api_request_parameters, "/column/delete");
    Rumali.gridoperation.showFilterCount()
    var metrix_and_dimension = new Rumali.categorizeColumns();
    metrix_and_dimension.init();
  }

  this.addColumnData = function (column_side) {
    var col_arr = [], after
      , col = $("#grid_show").handsontable('getSelected')[1]
      , api_request_parameters = {};
    if (column_side == "left") {
      col += 1;
      after = self.columns_header[col - 1];
    } else {
      col += 2;
      after = self.columns_header[col - 1];
    }
    api_request_parameters["column_name"] = Rumali.datatype_utils.random_name();
    api_request_parameters["after"] = after;
    Rumali.api.postAjaxcall(api_request_parameters, "/column/add");
  }


  this.getOriginalColumnName = function () {
    var api_request_parameters = {};
    api_request_parameters["original_names"] = true;
    api_request_parameters["data_types"] = true;
    api_request_parameters["token"] = gon.token;
    api_request_parameters['sub_types'] = true;
    Rumali.api.originalColumnName(api_request_parameters, function (res) {
      self.column_datatype = res;
      self.column_datatype = that.changeToColumnsType(self.column_datatype);
    });

  }

  this.changeToColumnsType = function (column_response) {
    self.original_column_names = [];
    self.sub_datatype = [];
    self.columns_header =[];
      var column_array =[]
        , temp_column_object = column_response.columns.column_types
        , first_row = self.json_data[0]
        , len = first_row.length;
      for (var i = 0; i < len; i++) {
        if (column_response.columns.sub_types[first_row[i]] == null) {
          self.sub_datatype.push("nil")
        } else {
          self.sub_datatype.push(column_response.columns.sub_types[first_row[i]])
        }

        if (column_response.columns.original_column_names[first_row[i]] == null) {
          self.original_column_names.push('null');
        } else {
          self.original_column_names.push(column_response.columns.original_column_names[first_row[i]]);
        }
        column_array.push(temp_column_object[first_row[i]]);
      }
      self.columns_header = self.json_data[0];
      self.json_data[0] = self.original_column_names;
      return column_array;
  }

  this.getAzaxcall = function () {
    var column_index = that.getSelectedColumnIndex()
      , col_name , count_obj
      , datatype , aggregate_values
      , api_request_parameters ={};
      if (column_index !== false) {
        col_name = self.columns_header[column_index + 1];
        datatype = self.column_datatype[column_index + 1];
        api_request_parameters[col_name] = ['count'];
        grid_unique_values.resetDimensions();
        grid_unique_values.resetMetrics();
        grid_unique_values.dimensions = [new_column_name];
        grid_unique_values.metrics = api_request_parameters;
        grid_unique_values.executeOnFilter = function(){
          aggregate_values = JSON.parse(grid_unique_values.flushToGet().data)
          data_distribution = that.changeToJsonData(aggregate_values,col_name);
          if (datatype == "integer" || datatype == "double") { 
            Rumali.histogram(col_name,datatype,data_distribution);
          } else {
            $('#histogram-chart').hide();
            $('#histogram_min_max').hide();
            Rumali.countUniqueValues(data_distribution);
          }
          Rumali.showStatistics(col_name, datatype);
          that.resetFilterElements();
          that.toggleReplaceButton();
          console.log()
          Rumali.gridtopbar.showformatterAsperDataType(self.column_datatype[column_index+1]);
        }
        try {
          grid_unique_values.dataformat = 'json'
          grid_unique_values.call();
        } catch(err) {
          console.log(err,"error in data distribution")
        }
        
      } 
  }

  this.changeToJsonData = function (aggregate_values, col_name) {
    var count_obj = {}
      , aggregate_values_len = aggregate_values.length;
    for(var i = 0; i < aggregate_values_len; i++) {
      var value_object = aggregate_values[i];
      count_obj[value_object[col_name]] = value_object["count"];
    }
    return count_obj;
  }

  this.restEndPoint = function () {
    var arr = window.document.URL.split("/")
      , index = arr.indexOf("data")
      , filename = arr[index + 1]
      , projectname = arr[--index]
      , username = arr[--index];
    if (filename.indexOf("?") > -1)
      filename = $("#data_store_name").val();
    return username + "/" + projectname + "/" + filename + "/";
  }

  this.getColumnsWithType = function (column_data) {
    function floatValidate (value,callback) {
      if (value == 0) {
        callback(false);
      } else {
        callback(true);
      }
    }
    var columns = []
      , start_index
      column_data_length = column_data.length;

    if (self.json_data[0][0] == "id") {
      start_index = 1;
    } else {
      start_index = 0;
    }
    for (var i = start_index; i < column_data_length; i++) {
      //var data_types = column_types[i];
      var type = column_data[i]
        , format_style = '';
      if (type == 'double') {
        format_style = '0.0[0000]';
        columns.push({
          type: editor_types[type],
          data: i,
          format: format_style,
          validator: floatValidate,
          allowInvalid: true,
          // renderer: that.customRenderer,
        });
      } else {
          columns.push({
            type: editor_types[type],
            data: i,
            checkedTemplate: 't',
            uncheckedTemplate: 'f',
            // renderer: that.customRenderer,
          });
      }
    }
    return columns;
  }

  this.returnContentColumnNames = function (content_headers) {
    var tmp_arr = [];
    $.each(content_headers, function (column) {
      tmp_arr.push(content_headers[column].column_name);
    })
    return tmp_arr;
  }

  this.showrules = function () {
    var len = that.rules_array.length;
    $("#rules-div").empty();
    for (var i = 0; i < len; i++) {
      $("#rules-div").append(that.rules_array[i] +
        "<td><span class='update-rule' id ='" + i +
        "'>Edit</span></td><td><span class='glyphicon glyphicon-remove delete-rule' id ='" +
        i + "'></span></td></tr>");
    }
    $("#rules-div").append("</table>");
  }

  this.columnHeaderSelected = function (column_id) {
    Rumali.pykgrid['column_selected_flag'] = true;
    Rumali.gridtopbar.manuallyCloseTopmenuDropdown();
    $("#histogram_min_max").hide();
    $("#input-col-cancel").hide();
    $("#col-info-panel").hide();
    $("#grid-count").show();
    that.editColumn(column_id);
    Rumali.gridtopbar.showformatterAsperDataType(self.column_datatype[column_id+1]);
    Rumali.gridsidebar.getDatatypeDistribution();
    $("#column").addClass("active")
    $("#column2").removeClass("active")
    $("#table").removeClass("active")
    $("#table1").removeClass("active")
    $("#show_when_column_is_selected_3").addClass("active");
    $("#mapConfigure").removeClass("active");
    $("#map_options").removeClass("active");
    $("#col-info-panel").show();
    $("#grid_datatypes").show();
    $("#pyk_statistics").show();
    $("#filter_toggle").hide();
    //$("#hide_when_column_is_selected_1").hide();
    $("#hide_when_column_is_selected_2").removeClass("active");
    $("#show_when_column_is_selected_1").show();
    //$("#convert-button").show();
    //$("#show_when_column_is_selected_2").show();
    $("#show_when_column_is_selected_3").show();
    $("#sorting-value").show();
    $("#convert-value").show();
  }

  this.columnHeaderDeselected = function () {
    that.showHideListForm(true);
    Rumali.pykgrid['column_selected_flag'] = false;
    $("#table").addClass("active")
    $("#column").removeClass("active")
    $("#show_when_column_is_selected_3").removeClass("active");
    $("#hide_when_column_is_selected_2").removeClass("active");
    $("#mapConfigure").removeClass("active");
    $("#map_options").removeClass("active");
    $("#table1").addClass("active")
    //$("#hide_when_column_is_selected_1").show();
    // if(divg1.filters.length > 0) {
    //   $("#hide_when_column_is_selected_2").show();
    // }
    $("#show_when_column_is_selected_1").hide();
    //$("#show_when_column_is_selected_2").hide();
    $("#show_when_column_is_selected_3").hide();
    $("#input-col-name").hide();
    $("#grid_datatypes").hide();
    $("#pyk_statistics").hide();
    $("#sorting-value").hide();
    $("#merge").hide();
    $("#histogram_min_max").hide();
  }

  this.showPagination = function (count) {
    var limit = grid_show.limit
      , page = Math.ceil(count/limit);
    Rumali.renderStatistics({"count": count}, ""); //datatype = blank or string to show only count
    $("#page-count").empty();
    if ( count > limit) {
      $("#page-count").pagination({
        pages:page,
        displayedPages: 2,
        onPageClick: function (pageNumber, e) {
          pageNumber = pageNumber-1;
          var api_request_parameters = {};
          grid_show.offset = limit * pageNumber;
          grid_show.dataformat = 'array';
          grid_show.executeOnFilter = function(){
            var json_data = grid_show.flushToGet();
            if(json_data != undefined) {
              self.json_data = json_data.data;
            }
            that.reloadGrid();
          }
          try {
            grid_show.call();
          } catch(err) {
            console.log(err);
          }
          e.preventDefault();
        },
        cssStyle: 'light-theme',
        edges:1,});
    }
  }


  this.toggleReplaceButton = function () {
    var count_array =[];
    $('.check-value:checked').each(function (i, obj) {
      count_array.push($(this).val());
    });

    if (count_array.length < 1) {
      $("#replace-values").hide();
    } else {
      $("#replace-values").show();
    }
  }

  this.getSelectedColumnIndex = function(){
    var array = $("#grid_show").handsontable('getSelected');
    if (array == undefined ) {
      return false;
    } else {
      var column_index = array[1];
      return column_index;
    }
  }

  this.reloadGrid = function () {
    var len = self.json_data.length - 1;
    self.columns_header = self.json_data[0];
    self.json_data[0] = self.original_column_names;
    $("#grid_show").handsontable("loadData",self.json_data);
    $container.handsontable("selectCell", len, new_column_value_index, 0, new_column_value_index);
    Rumali.gridoperation.showFilterCount();
  }

  this.removeAllFilterColumn = function (column_name) {
    var divg1_filters = divg1.filters.slice(0)
      , len = divg1_filters.length;
    for (var i = 0; i < len; i++) {
      var divg1_filters_i = divg1_filters[i]
        , divg1_filters_i_len = divg1_filters_i.length
        , removed_filter_count = 0;
      for (var j = 0; j < divg1_filters_i_len; j++) {
        // console.log(divg1.filters[i]["column_name"]);
        if (divg1_filters_i[j]["column_name"] === column_name) {
          divg1.filters.splice(i - removed_filter_count);
          removed_filter_count++;
          break;
        }
      }
    }
    Rumali.gridoperation.showFilterCount();
  }

  this.showFilterCount = function () {
    var divg1_filters_length = divg1.filters.length
      , text = "";
    $("#applied_filters_tab_count").text(divg1_filters_length);
    if (divg1_filters_length === 0) {
      text = "No filters applied yet. To apply a filter, select a column and apply from the available list.";
    }
    $("#hide_when_column_is_selected_1 .hint").html(text);
  }

  this.resetFilterElements = function () {
    var filter_arr = divg1.filters
      , len = filter_arr.length;

    $('.check-value:checkbox')
      .removeClass('pykquery-selected')
      .prop('checked',false);
    $('.side-bar-data-type:checkbox')
      .removeClass('pykquery-selected')
      .prop('checked',false);
    d3.select("rect.extent")
      .attr("x", 0)
      .attr("width", 0);
    d3.selectAll("g.resize")
      .style("display", "none");
    for (var i = 0; i < len; i++){
      var filter_arr_i = filter_arr[i]
        , filter_arr_i_len = filter_arr_i.length;
      for (var j = 0; j < filter_arr_i_len; j++) {
        var filter_object = filter_arr_i[j];
        if (new_column_name == filter_object["column_name"]) {
          switch (filter_object["condition_type"]) {
            case "values":
              var value_arr = filter_object['in']
                , value_arr_len = value_arr.length;
              for (var j = 0; j < value_arr_len; j++) {
                var value = value_arr[j];
                $("input:checkbox[value='"+value+"']").addClass('pykquery-selected');
                $("input:checkbox[value='"+value+"']").prop('checked',true);
              }
            break;
            case "datatype":
              var value_arr = filter_object['in']
                , value_arr_len = value_arr.length;
              for (var j =0; j < value_arr_len; j++) {
               var value = value_arr[j];
                $("input:checkbox[data-type='"+value+"']").addClass('pykquery-selected')
                $("input:checkbox[data-type='"+value+"']").prop('checked',true);
              }
            break;
            case "range":
              var col_name = filter_object.column_name
                , min = filter_object.condition['min']
                , max = filter_object.condition['max'];
              if (filter_object.condition['not'] == false) {
                $("input[type='radio'][value='in']").parent().addClass("active");
                $("input[type='radio'][value='notin']").parent().removeClass("active")
              } else {
                $("input[type='radio'][value='in']").parent().removeClass("active");
                $("input[type='radio'][value='notin']").parent().addClass("active")
              }
              global_brush.extent([min,max]);
              brush.call(global_brush);
              // Rumali.histogram(col_name, "integer", data_distribution, min, max);
            break;
          }
        }
      }
    }
  }

  this.sortColumnData = function (sort_order) {
    var col = $("#grid_show").handsontable('getSelected')[1]
      , api_request_parameters = {};
    api_request_parameters[new_column_name] = sort_order;
    //api_request_parameters["sort_order"] = $(this).attr("id");
    grid_show.sort = [api_request_parameters];
    grid_show.executeOnFilter = function(){
      var data = grid_show.flushToGet().data;
      if(data != "" && data != undefined){
        self.json_data = data;
        that.reloadGrid();
        $container.handsontable("selectCell", 0, 0, 0, 0);
      }  
    }
    try {
      grid_show.call();
    } catch (error) {
      console.error("error in  data for sorting")
    }
  }

  this.findDataType = function (value) {
    var data_type = Rumali.datatype_utils.isBoolean(value) || Rumali.datatype_utils.isNumber(value) || Rumali.datatype_utils.isDate(value) || Rumali.datatype_utils.isBlank(value) || "string";
    return data_type;
  }

  this.editColumn = function (id) {
    $("#input-data-type").val(self.column_datatype[id + 1]);
    $("#sub-data-type").val(self.sub_datatype[id + 1]);
    that.showHideListForm(false);
    $("#grid_datatypes").show();
    $("#input-col-name").show();
    $("#merge").show();
  }

  this.showHideListForm = function (display_list) {
    if (display_list) {
      $("#column-list").show();
      $("#grid-column-form").hide();
      document.getElementById("input-col-form").reset();
    } else {
      $("#column-list").hide();
      $("#grid-column-form").show();
    }
  }

  this.update_grid_with_new_data = function (data) {
    if (data == undefined) {
      return false;
    } else if (data.length > 0) {
      self.json_data =  data;
      return true;
    } else if (data.length == 0) {
      var columns_data = self.json_data[0];
      self.json_data = [];
      self.json_data[0] = columns_data;
      return true;
    }
  }

  $(document).ready(function() {
    $(document).on('click', '.filter_remove', function(e) {
      Rumali.executeAfterDeleteFilter();
      e.preventDefault();
    });
    // $(document).on('hover', '.hover-tootip', function(e) {
    //   $('#tooltip').show();
    //   var name = $(this).attr("data-title");
    //   $('#tooltip').text(name);

    // });
    // $(document).on('mousemove', '.hover-tootip', function(e) {
    //   $('#tooltip').css('top',e.clientY-40)
    //   $('#tooltip').css('left',e.clientX-10)
    // });
    // $(document).on('mouseout', '.hover-tootip', function(e) {
    //   $('#tooltip').hide();
    // });
  });
}
