var  that, PYKMODEL, grid, new_column_name, new_column_value_index, data_distribution;

Rumali.pykGrid = function () {
  var that = this
    , custom_context_menu_render_flag = false;
  // function to show gird
  this.appendGrid = function (column_operation,row_operation) {
    Rumali.gridoperation.isChecked = false;
    $container = $("#grid_show");
    $("#grid_show").height(700);
    if (data_store_action_name == "map") {
      $("#grid_show").height(150);
    }
    var read_only_flag = !gon.mode;

    $('#grid_show').handsontable({
      data: self.json_data,
      rowHeaders: true,
      colHeaders: true,
      fixedRowsTop: 1,
      readOnly: true,
      manualColumnMove: true,
      stretchH: 'all',
      outsideClickDeselects: false,
      afterValidate: function(isValid, value, row,
        prop, source) {
          //return true;
      },

      afterSelectionEnd:function (row_start_index,col_start_index,row_end_index,col_end_index) {
        var grid_instance = $container.handsontable('getInstance');
        if (row_start_index == 0 && row_end_index == self.json_data.length - 1) {
          grid_instance.updateSettings({contextMenu:column_operation});
          custom_context_menu_render_flag = true;
        } else if(col_start_index == 0 && col_end_index == self.column_datatype.length - 2) {
          grid_instance.updateSettings({contextMenu:row_operation});
          custom_context_menu_render_flag = true;
        } else if(custom_context_menu_render_flag == true) {
          grid_instance.updateSettings({contextMenu:false});
          custom_context_menu_render_flag = false;
        }
      },

      afterCreateRow: function (row, col) {
        self.json_data[row].push(null);
        },
        contextMenu: false,
        'myPlugin': false,
        cells: function (row, col, prop) {
        return {
          renderer: firstRowRenderer
        }
      }
    });
    var header_select_flag = false;
    Rumali.gridoperation.showFilterCount();
    var grid_instance = $container.handsontable('getInstance');
    grid_instance.addHook('afterOnCellMouseDown', function (event, coords, TD) {
      if (coords.row == -1 && coords.col != -1 && event.button == 0) {
        var column_index = $("#grid_show").handsontable('getSelected')[1]
          , column_name = self.columns_header[column_index + 1];
        new_column_name = column_name;
        new_column_value_index = column_index;
        Rumali.gridoperation.columnHeaderSelected(coords.col);
        Rumali.gridoperation.getAzaxcall();
        header_select_flag = true;
      } else {
        if (header_select_flag) {
          Rumali.gridoperation.columnHeaderDeselected();
        }
      }
    });

    grid_instance.addHook('afterColumnMove', function (oldindex, newindex) {
      var old_column_name = self.columns_header[oldindex +1]
        , column_after = self.columns_header[newindex]
        , api_request_parameters = {};
      api_request_parameters["column_name"] = old_column_name;
      api_request_parameters["after"] = column_after;
      Rumali.api.postAjaxcall(api_request_parameters, "/column/move");
    });

    grid_instance.addHook('beforeChange', function (arr, number) {
      if(arr.length > 1) {
        alert("Multiple cell editing is not allowed");
        return false;
      }
    });

    grid_instance.addHook('afterChange', function (arr, mode) {
      if (arr == null || mode == "loadData" ) return false;
      var row_index = arr[0][0]
        , col_index = arr[0][1]
        , old_value = arr[0][2]
        , new_value =arr[0][3];
      if (old_value != new_value) {
        if (self.json_data[row_index][0] == null) {
          if (new_value == "") return false;
          var api_request_parameters = {}
            , data = self.json_data[row_index]
            , data_len = data.length;
          for (var i = 0; i < data_len; i++) {
            if (data[i] == null)
              data[i] = "";
          }
          console.log(data)
          api_request_parameters["data"] = data;
          api_request_parameters["token"] = gon.token;
          Rumali.api.rowAddApiCall(api_request_parameters,
            function (res) {
              self.json_data[row_index][0] = res.id;
            },
            function () {
              self.json_data[row_index][0] = null;
              self.json_data[row_index][col_index] = null;
            }
          );
        } else {
          var api_request_parameters = {}, endpoint;
          if (row_index == 0) {
            endpoint = "column/change_name";
            api_request_parameters["new_original_column_name"] = new_value;
            api_request_parameters["column_name"] = self.columns_header[col_index];
            //that.getOriginalColumnName();
          } else {
            endpoint = "cell/update";
            api_request_parameters["row_id"] = self.json_data[row_index][0];
            api_request_parameters["value"] = new_value;
            api_request_parameters["column_name"] = self.columns_header[col_index];
          }
          console.log(new_value, 'new');
          console.log(old_value, 'old');
          api_request_parameters["token"] = gon.token;
          Rumali.api.columnAndCellChangeApiCall(api_request_parameters, endpoint,
            function (res) {
              if(row_index == 0) {
                divg1.changeColumnName(old_value,res.column_name)
                self.json_data[row_index][col_index] = res.column_name;
                $container.handsontable('render');
                var metrix_and_dimension = new Rumali.categorizeColumns();
                metrix_and_dimension.init();
              }
            },
            function () {
              self.json_data[row_index][col_index] = old_value;
              if(row_index == 0) { //column_name_change - failed
                $container.handsontable('render');
                $container.handsontable('selectCell', row_index, col_index - 1);
                alert("column name change failed");
                //$container.handsontable('setDataAtCell', 0, col_index, old_value);
              }
            }
          );
        }
      }
    });

    grid_instance.addHook('beforeRemoveRow',function (arr, number) {
      var id = []
        , api_request_parameters = {};
      while (number > 0) {
        id.push(self.json_data[arr][0]);
        number--;
        arr++;
      }
      api_request_parameters["row_id"] = id;
      api_request_parameters["token"] = gon.token;
      Rumali.api.rowDeleteApiCall(api_request_parameters);
    });

    grid_instance.addHook('afterOnCellMouseDown', function (event, obj) {
      if (obj.row != -1) {
        Rumali.gridoperation.columnHeaderDeselected();
      }
    });


    function firstRowRenderer (instance, td, row, col, prop, value,cellProperties) {
      if (self.column_datatype[col+1] == "integer" || self.column_datatype[col+1] == "double" ) {
        Handsontable.NumericCell.renderer.apply(this, arguments);
      } else if (self.column_datatype[col+1] == "boolean") {
        Handsontable.CheckboxCell.renderer.apply(this, arguments);
      } else {
        Handsontable.TextCell.renderer.apply(this, arguments);
      }

      if (row <= 0) {
        cellProperties.format = "";
        Handsontable.TextCell.renderer.apply(this, arguments);
        var original_column_name = self.original_column_names[col + 1];
        //self.json_data[0][col +1] = self.original_column_names[col + 1];
        //$(td).text(self.original_column_names[col+1]);
        $(td).removeClass('htInvalid');
        $(td).addClass('hover-tootip');
        td.style.fontWeight = 'bold';
        td.style.color = '#1B668B';
        td.style.background = '#f0f0f0';
        // if (original_column_name != "null") {
        //   // for tooltip.
        //   td.setAttribute("data-title", self.original_column_names[col + 1]);
        // }
      } else if (row%2 !=0 && $('#highlight-row').hasClass("check")) {
        // for alternate rows highlighting.
        td.style.background = '#A9F5A9';
      }

      if ($('#highlight-cell').hasClass("check")) {
        // for highlight blanks
        if (value == "" || value == null || value == undefined) {
          td.style.background = '#F5A9A9';
        }
      }
    }
    // $("#input-col-cancel").unbind('click');
    // $("#input-col-cancel").click(that.cancelForm);
  }

  this.getShowPage = function() {
    var api_request_parameters = {}
    , both_flag = 0;
    grid_show.executeOnFilter = function(){
      json_data = grid_show.flushToGet();
      if(json_data != undefined) {
        self.json_data = json_data.data;
        set_flag();
      }
    }
    try {
      grid_show.call();
    } catch(err) {
      console.log(err)
    }
    
    try {
      grid_columns.call();
    } catch (err) {
      console.log(err+"error in pagination count not available")
    }

    api_request_parameters["original_names"] = true;
    api_request_parameters["data_types"] = true;
    api_request_parameters["token"] = gon.token;
    api_request_parameters['sub_types'] = true;
    Rumali.api.originalColumnName(api_request_parameters, function (res) {
      self.column_datatype = res;
      set_flag();
    });

    function createGrid () {
      self.column_datatype = Rumali.gridoperation.changeToColumnsType(self.column_datatype)
      var instance = $("#grid_show").handsontable("getInstance");
      columns =Rumali.gridoperation.getColumnsWithType(self.column_datatype);
      instance.updateSettings({data:self.json_data,columns:columns});
      Rumali.gridoperation.getAzaxcall();
    }

    function set_flag () {
      both_flag = both_flag + 1;
      if (both_flag == 2) {
        createGrid();
        both_flag = 0;
      }
    }
  }

}
Rumali.pykgrid = new Rumali.pykGrid();
