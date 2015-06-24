Rumali.gridTopMenu = function () {

  this.showformatterAsperDataType = function (selected_value) {
    var possible_operations = Rumali.plugin.rumiLocales.getPossibleColumnOperations()[selected_value]
      , html_template;
    $(".horizontal-rule").remove();
    $("#convert-value").show();
    if (possible_operations.length > 0) {
      html_template = "<li role='presentation' class='divider format-submenu horizontal-rule'></li>";
    } else {
      html_template = "";
    }
    for (i in possible_operations) {
      if (possible_operations[i].id == "divider") {
        html_template += "<li role='presentation' class='divider format-submenu horizontal-rule'></li>";
      } else {
        html_template +=
          "<li class='format-submenu horizontal-rule'><a href='#' class ='data-formatter' id='" +
          possible_operations[i].id + "'>" + possible_operations[i].name + "</a></li>";
      }
    }
    $("#convert-button").append(html_template);
  }

  this.manuallyCloseTopmenuDropdown = function() {
    $('.dropdown').each(function(){
      $(this).removeClass('open');
    });
  }

  this.set_column_datatype = function () {
    var col = $("#grid_show").handsontable('getSelected')[1]
      , datatype = self.column_datatype[col+1]
      , subdata = self.sub_datatype[col+1]
      , text
      , sub_text;
    $('.column-data-type').each(function (i, obj) {
        text = $(this).text().replace("\u2713",'&nbsp;&nbsp;&nbsp;');
        $(this).html(text);
    });
    $('.sub-data-type').each(function (i, obj) {
        text = $(this).text().replace("\u2713",'&nbsp;&nbsp;&nbsp;');
        $(this).html(text);
    });
    text = $("#"+datatype+"_data_type").text().trim();
    $("#"+datatype+"_data_type").html("&nbsp;\u2713&nbsp;&nbsp;"+text);
    sub_text = $("#"+subdata+"_sub_datatype").text().trim();
    $("#"+subdata+"_sub_datatype").html("&nbsp;\u2713&nbsp;&nbsp;"+sub_text);
  }

  $(document).on('click', '.data-formatter', function (e) {
    var column_index = Rumali.gridoperation.getSelectedColumnIndex()
      , path_obj = {
          uppercase: "column/uppercase",
          lowercase: "column/lowercase",
          titlecase: "column/titleize",
          trim: "column/trim",
          whitespace: "column/trim_inside",
          removechar: "column/remove_character"
        }
      , path = rumi_api_endpoint  + Rumali.gridoperation.restEndPoint() + path_obj[$(this).attr("id")]
      , api_request_parameters = {};
    if ($(this).attr("id") == 'mergetoclean') {
      // open modal window
      $('.bs-example-modal-lg').modal('show');
      return false;
    }
    if ($(this).attr("id") == "removechar") {
      var val = prompt('Enter Character  to remove:');
      if (val != null){
        api_request_parameters['value'] = val;
      } else {
        return true;
      }
    }
    api_request_parameters["column_name"] = new_column_name;
    api_request_parameters["token"] = gon.token;
    Rumali.api.dataformatterapi(path,api_request_parameters);
    Rumali.gridtopbar.showformatterAsperDataType(self.column_datatype[column_index+1]);
    e.preventDefault();
  });

  $(document).on('click', '.modal-check-value', function () {
    var checked_arr = []
      , values_array = [];
    checked_arr.push($(this).val()),
    col_name = new_column_name;
    $('.modal-check-value:checked').each(function (i, obj) {
      values_array.push($(this).val());
    });

    if (values_array.length < 1) {
      $("#replace-values").hide();
    } else {
      $("#replace-values").show();
    }
  });

  $(document).on('click', '#replace-values', function (e) {
    var retval
      , olddatatype
      , col = Rumali.gridoperation.getSelectedColumnIndex()
      , column_name = self.columns_header[col + 1]
      , checked_arr = [];
    $('.modal-check-value:checked').each(function (i, obj) {
      checked_arr.push($(this).val());
    });
    olddatatype = self.column_datatype[col+1];
    if (retval = prompt("Enter new value : ", "value")) {
      if(retval == "value"){
        retval = "";
      }
      var api_request_parameters = {}
        , newdatatype = Rumali.gridoperation.findDataType(retval);
      api_request_parameters["column_name"] = new_column_name;
      api_request_parameters["values"] = checked_arr;
      api_request_parameters["new_value"] = retval;
      Rumali.gridoperation.removeAllFilterColumn(column_name);
      if (olddatatype == "string") {
        Rumali.api.postAjaxcall(api_request_parameters, "/column/merge_to_clean");
      } else if (olddatatype == "integer" && newdatatype == "integer") {
        Rumali.api.postAjaxcall(api_request_parameters, "/column/merge_to_clean");
      } else if (olddatatype == "double" && (newdatatype == "integer" || newdatatype == "double")) {
        Rumali.api.postAjaxcall(api_request_parameters, "/column/merge_to_clean");
      } else {
        generate_notify({text:"You have entered " + newdatatype + " to a" + olddatatype + " column ",notify:"error",timeout:3000,position:"topCenter"});
      }
    }
    e.preventDefault();
  });

  $(document).on('click', '.column-data-type', function (e) {
    var new_data_type = $(this).attr('value')
      , col_index = Rumali.gridoperation.getSelectedColumnIndex()
      , old_data_type = self.column_datatype[col_index + 1]
      , checked_arr = []
      , api_request_parameters = {}
      , _api_res
      , text;

    if (new_data_type == old_data_type) {
      generate_notify({text:new_column_name + " is already " + old_data_type + "." + newdatatype + " to a" + olddatatype + " column ",notify:"error",timeout:3000,position:"topCenter"});
      return false;
    }

    $('.side-bar-data-type').each(function (i, obj) {
      checked_arr.push($(this).attr("data-type"));
    });

    if (new_data_type != "string" && checked_arr.indexOf("string") > -1) {
      generate_notify({text:new_column_name + " cannot be converted to " + new_data_type + " because there are some text values in the column.",notify:"error",timeout:3000,position:"topCenter"});
      return false;
    }

    api_request_parameters["column_name"] = new_column_name;
    api_request_parameters["new_type"] = new_data_type;
    switch (new_data_type) {
      case "date":
        if (checked_arr.indexOf('integer') > -1 || checked_arr.indexOf('double') > -1 || checked_arr.indexOf('boolean') > -1) {
          generate_notify({text:new_column_name + " cannot be converted to " + new_data_type + " because it contains values other than date.",notify:"error",timeout:3000,position:"topCenter"});
          return false;
        }
        _api_res  = Rumali.api.postAjaxcall(api_request_parameters, "/column/change_type");
      break;
      case "boolean":
        if (checked_arr.indexOf('integer') > -1 || checked_arr.indexOf('double') > -1 || checked_arr.indexOf('date') > -1) {
          generate_notify({text:new_column_name + " cannot be converted to " + new_data_type + " because it contains values other than true/false.",notify:"error",timeout:3000,position:"topCenter"});
          return false;
        }
        _api_res  = Rumali.api.postAjaxcall(api_request_parameters, "/column/change_type");
      break;
      case "integer":
      case "double":
        if (checked_arr.indexOf('date') > -1 || checked_arr.indexOf('boolean') > -1) {
          generate_notify({text:new_column_name + " cannot be converted to " + new_data_type + " because it contains values other than " + new_data_type + "." ,notify:"error",timeout:3000,position:"topCenter"});
          return false;
        }
        _api_res  = Rumali.api.postAjaxcall(api_request_parameters, "/column/change_type");
      break;
      case "string":
        _api_res  = Rumali.api.postAjaxcall(api_request_parameters, "/column/change_type");
      break;
      default:
      break;
    }

    if (_api_res.status == 201) {
      $('.column-data-type').each(function (i, obj) {
        text = $(this).text().replace("\u2713 ",'&nbsp;&nbsp;&nbsp;');
        $(this).text(text);
      });
      text = $(this).text().trim();
      $(this).html("&nbsp;\u2713&nbsp;&nbsp;"+text);
    } else {
      generate_notify({text:_api_res.responseText,notify:"error",timeout:3000,position:"topCenter"});
    }
    e.preventDefault();
  });

  $(document).on('click', '.sub-data-type', function (e) {
    var new_sub_type = $(this).attr('value')
      , col_index = $("#grid_show").handsontable('getSelected')[1]
      , old_sub_type = self.sub_datatype[col_index + 1]
      , api_request_parameters = {}
      , checked_arr = []
      , _api_res
      , text;

    if (new_sub_type == old_sub_type) {
      //generate_notify({text:"",notice:"sucess",timeout:true,})
      generate_notify({text:"Cannot convert to same sub data type.",notify:"error",timeout:3000,position:"topCenter"});
      return false;
    }

    api_request_parameters["new_type"] = new_sub_type;
    api_request_parameters["column_name"] = new_column_name;
    if (new_sub_type == "latitude" || new_sub_type == "longitude") {
      $('.side-bar-data-type').each(function (i, obj) {
        checked_arr.push($(this).attr("data-type"));
      });
      if (checked_arr.indexOf('string') > -1 || checked_arr.indexOf('date') > -1 || checked_arr.indexOf('boolean') > -1) {
        generate_notify({text:new_column_name + " sub type cannot be converted to " + new_sub_type + " because it contains non decimal values",notify:"error",timeout:3000,position:"topCenter"});
        return false;
      } else {
        _api_res = Rumali.api.postAjaxcall(api_request_parameters, "/column/change_sub_type");
      }
    } else if (new_sub_type == "none") {
      _api_res = Rumali.api.postAjaxcall(api_request_parameters, "/column/change_sub_type");
    }

    if (_api_res.status == 201) {
      $('.column-data-type').each(function (i, obj) {
        text = $(this).text().replace("\u2713 ",'&nbsp;&nbsp;&nbsp;');
        $(this).html(text);
      });
      text = $(this).text().trim();
      $(this).html("&nbsp;\u2713&nbsp;&nbsp"+text);
    } else {
      abc = (_api_res.responseText == undefined) ? alert("Somthing went wrong. Possibly network error."):alert(_api_res.responseText);
    }
    e.preventDefault();
  });

  $(document).on('click', '.highlight-cell', function (e) {
    var text;
    if ($(this).hasClass('check')) {
      $(this).removeClass("check");
      text = $(this).text().replace("\u2713",'&nbsp;&nbsp;&nbsp;');
      $(this).html(text);
    }else {
      $(this).addClass("check");
      text = $(this).text().trim();
      $(this).html("&nbsp;\u2713&nbsp;&nbsp;"+text);
    }
    $('#grid_show').handsontable('getInstance').render();
    e.preventDefault();
  });

  $(document).on('click', '.highlight-row', function (e) {
    var text;
    if ($(this).hasClass('check')) {
      $(this).removeClass("check");
      text = $(this).text().replace("\u2713",'&nbsp;&nbsp;&nbsp;');
      $(this).html(text);
    }else {
      $(this).addClass("check");
      text = $(this).text().trim();
      $(this).html("&nbsp;\u2713&nbsp;&nbsp;"+text);
    }
    $('#grid_show').handsontable('getInstance').render();
    e.preventDefault();
  });

  $('#freeze-column button').click(function () {
      $(this).addClass('btn-primary').siblings().removeClass('active btn-primary');
      var instance = $('#grid_show').handsontable('getInstance')
        , freeze_value = parseInt($(this).val());
      instance.updateSettings({fixedColumnsLeft: freeze_value})
  });

  $(document).on('click', '.clean_column', function (e) {
    if(Rumali.pykgrid['column_selected_flag'] == true){
      Rumali.gridtopbar.set_column_datatype();
      $('.format-menu').hide();
      $('.format-submenu').show();
    } else{
      // $('#show_when_column_is_selected_2').removeClass("open");
      $('.format-menu').show();
      $('.format-submenu').hide();
    }
  });

  $('#freeze-row button').click(function () {
      $(this).addClass('btn-primary').siblings().removeClass('active btn-primary');
      var instance = $('#grid_show').handsontable('getInstance')
        , freeze_value = parseInt($(this).val())+1;
      instance.updateSettings({fixedRowsTop: freeze_value})
  });

}
