var config_data = {
  "data": {},
  "readOnly": true,
  "fixedRowsTop": 0,
  "colHeaders": [],
  "manualColumnMove": true,
  "outsideClickDeselects": false,
  "contextMenu": false
}
Rumali.dataCastNewPage = function(){
  $("#core_datacast_preview").click(function( ) {
    var query = $("#core_datacast_query").val(),
    core_db_connection_id = $("#core_datacast_core_db_connection_id").val()
    , obj = {};
    if (!validateQuery(query)) {
      generate_notify({text: "Please write a proper query", notify:"error"});
      return false
    }
    obj['query'] = query;
    obj['core_db_connection_id'] = core_db_connection_id;

    $.ajax({
      url: url,
      type: "post",
      data: obj,
      dataType: "json",
      success: function (data) {
        execute_flag = data.execute_flag;
        $("#preview_output_error").hide();
        $("#preview_output_grid").show();
        config_data.data = data["query_output"];
        $("#preview_output_grid").handsontable(config_data);
        $("#core_datacast_submit").removeClass("grey-disabled");
        $("#core_datacast_submit").prop("disabled", false);
      },
      error: function (data, textStatus, errorThrown) {
        execute_flag = data.execute_flag;
        $("#preview_output_grid").hide();
        $("#preview_output_error").show();
        $("#preview_output_error").val(JSON.parse(data.responseText).query_output);
        $("#core_datacast_submit").addClass("grey-disabled");
        $("#core_datacast_submit").prop("disabled", true);
      }
    });
  });

  $("#core_datacast_submit").click(function () {
    var query = $("#core_datacast_query").val(),
    core_db_connection_id = $("#core_datacast_core_db_connection_id").val();
    if (!validateQuery(query) || !execute_flag) {
      generate_notify({text: "Query does not match the requirements", notify:"error"});
      return false;
    }
  });

  $("#core_datacast_query").on("change",function(){
    if($(this).val() !== ""){
      $("#core_datacast_preview").removeClass("grey-disabled");
      $("#core_datacast_preview").prop("disabled", false);
    } else {
      $("#core_datacast_preview").addClass("grey-disabled");
      $("#core_datacast_preview").prop("disabled", true);
    }
  });
}

var validateQuery = function (query) {
  if (query.length <= 0) {
    return false;
  } else if (query.indexOf("update") > 0) {
    return false;
  } else if (query.indexOf("drop") > 0) {
    return false;
  } else if (query.indexOf('truncate') > 0) {
    return false;
  }
  return true;
} 