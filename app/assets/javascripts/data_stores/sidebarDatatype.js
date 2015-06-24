Rumali.sidebarDatatype = function () {

  this.getDatatypeDistribution = function () {
    var selector = "#grid_datatypes"
      , html_template = ""
      , col = $("#grid_show").handsontable('getSelected')[1]
      , api_request_parameters = {};
    api_request_parameters["column_name"] = new_column_name;
    api_request_parameters["token"] = gon.token;
    Rumali.api.datatypesApiCall(api_request_parameters,function (data) {
      for (i in data) {
        html_template +="<input type='checkbox' data-type='" + i + "' data-id ='"+ i + "'" + "' class='side-bar-data-type'/> &nbsp;";
        html_template += i + " <span class='hint'>(" + data[i] +")</span>&nbsp;";
      }
      html_template +="<br/><br/><hr class='m0p0' style='border-bottom: 1px solid #C6C8CD;'/>";
      $(selector).html(html_template);
      $(selector).show();
    });
  }

  $(document).on('click', '.side-bar-data-type', function () {
    var col = $("#grid_show").handsontable('getSelected')[1]
      , checked_arr = [], datatype_value = []
      , api_request_parameters = {};
    datatype_value.push($(this).attr("data-type"));
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
    grid_datatypes.addFilter([[{"column_name": new_column_name, "condition_type": "datatype", "in": datatype_value, "next": "AND", "selected_dom_id": $(this).attr("data-id")}]], true,true);
  });

  $(document).on('click','.filter_remove',function(){
    Rumali.gridoperation.resetFilterElements();
  })

}
