Rumali.gridApiCall = function () {
  var that = this;

  this.originalColumnName = function (api_request_parameters, callback) {
    $.ajax({
      url: rumi_api_endpoint  + Rumali.gridoperation.restEndPoint() + "column/all_columns",
      data: api_request_parameters, //return  data
      dataType: 'json',
      type: 'GET',
      success: function(res) {
        callback(res);
      },
      error: function() {
        console.error('Error in fetch data from server');
      }
    });
  }

  this.getDemensionsAndMetricsApiCall = function(obj,callback){
    $.ajax({
      url: rumi_api_endpoint + Rumali.gridoperation.restEndPoint() + "column/dimensions_and_metrics",
      type: "GET",
      data: obj,
      dataType: "json",
      success: function (data) {
        callback(data);
      },
      error: function () {
        console.log("no mertics found: server error")
      }
    })
  }

  this.postAjaxcall = function (api_request_parameters, path) {
    api_request_parameters["token"] = gon.token;
    var postAjaxCallResponse = $.ajax({
      url: rumi_api_endpoint  + Rumali.gridoperation.restEndPoint() + path,
      data: api_request_parameters, //return  data
      dataType: 'json',
      type: 'POST',
      async: false,
      success: function (res) {
        Rumali.pykgrid.getShowPage();
      },
      error: function (res) {
        generate_notify({text:res.responseText,notify:"error",timeout:3000,position:"topCenter"});
      }
    });
    return postAjaxCallResponse;
  }

  this.dataformatterapi = function (path, api_request_parameters) {
    $.ajax({
      url: path,
      data: api_request_parameters,
      dataType: 'json',
      type: 'POST',
      success: function (res) {
        Rumali.pykgrid.getShowPage();
      },
      error: function () {
        console.log('Save error. ');
      }
    });
  }

  this.datatypesApiCall = function (api_request_parameters, callback) {
    $.ajax({
      url: rumi_api_endpoint  + Rumali.gridoperation.restEndPoint() + "column/datatype_distribution",
      data: api_request_parameters, //return  data
      dataType: 'json',
      type: 'Get',
      async: false,
      success: function (res) {
        callback(res.dtd);
      },
      error: function () {
        generate_notify({text:"[rumm-api] datatype distribution failed.",notify:"error",timeout:3000,position:"topCenter"});
      }
    });
  }

  this.rowAddApiCall = function (api_request_parameters, successCallback, errorCallback) {
    $.ajax({
      url: rumi_api_endpoint + Rumali.gridoperation.restEndPoint() + "row/add",
      data: api_request_parameters, //return  data
      dataType: 'json',
      type: 'POST',
      success: function(res) {
        console.log(res, "----");
        successCallback(res);
        console.log("--ROW ADDED--");
      },
      error: function() {
        console.log("--Row add failed--");
        console.error('Server error.');
        errorCallback();
        // $container.handsontable('setDataAtCell', row_index, 0, null);
        // $container.handsontable('setDataAtCell', row_index, col_index-1, null);
      }
    });
  }

  this.columnAndCellChangeApiCall = function (api_request_parameters, endpoint, successCallback, errorCallback) {
    $.ajax({
      url: rumi_api_endpoint  + Rumali.gridoperation.restEndPoint() + endpoint,
      data: api_request_parameters, //return  data
      dataType: 'json',
      type: 'POST',
      success: function(res) {
        console.log(res);
        console.log("Cell updated");
        successCallback(res);
      },
      error: function() {
        console.error('Cell update failed');
        errorCallback();
      }
    });
  }

  this.rowDeleteApiCall = function (api_request_parameters) {
    $.ajax({
      url: rumi_api_endpoint  + Rumali.gridoperation.restEndPoint() + "row/delete",
      data: api_request_parameters, //return  data
      dataType: 'json',
      type: 'POST',
      success: function(res) {
        console.log(res);
      },
      error: function() {
        console.log('Save error');
        alert('Unable to delete rows.')
      }
    });
  }
}
