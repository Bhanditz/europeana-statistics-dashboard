var config_data = {
  "data": {},
  "readOnly": true,
  "fixedRowsTop": 0,
  "colHeaders": [],
  "manualColumnMove": true,
  "outsideClickDeselects": false,
  "contextMenu": false
}, execute_flag = false
Rumali.dataCastNewPage = function(){
  Rumali.plugin = new Rumali.plugins();
  $("#core_datacast_preview").click(function( ) {
    var query = $("#core_datacast_query").val(),
    core_db_connection_id = $("#core_datacast_core_db_connection_id").val()
    , format = $("#core_datacast_format").val() || "2darray"
    , obj = {};
    if (!validateQuery(query)) {
      generate_notify({text: "Please write a proper select query", notify:"error"});
      return false
    }
    obj['query'] = query;
    obj['core_db_connection_id'] = core_db_connection_id;
    obj['data_format'] = format;

    $.ajax({
      url: url,
      type: "post",
      data: obj,
      dataType: "json",
      success: function (data) {
        $("#datacast_display").hide();
        $("#preview_output_grid").hide();
        $("#datacast_display").text("");
        execute_flag = data.execute_flag;
        $("#preview_output_error").hide();
        $("#core_datacast_submit").removeClass("grey-disabled");
        $(".enable_it_on_change_query_click").prop("disabled", true);
        $("#core_datacast_submit").prop("disabled", false);
        $("#core_datacast_query").prop("disabled", true)
        $("#change_query_text_button").show();
        $("#core_datacast_preview").prop("disabled", true);
        if (data.query_output){
          if (format == "xml"){
            $("#datacast_display").show();
            $("#datacast_display").text(data["query_output"]);
          }
          else if (format == "json") {
            $("#datacast_display").show();
            $("#datacast_display").text(JSON.stringify(JSON.parse(data["query_output"]),null,"\t"));
          } else {
            $("#preview_output_grid").show();
            config_data.data = data["query_output"]
            $("#preview_output_grid").handsontable(config_data);
          }
        } else {
          $("#preview_output_error").val("The query ran successfully and 0 rows returned")
          $("#preview_output_error").show();
        }
      },
      error: function (data, textStatus, errorThrown) {
        // $("#datacast_preview_loader").hide();
        execute_flag = data.execute_flag;
        $("#preview_output_grid").hide();
        $("#preview_output_error").show();
        $("#preview_output_error").val(JSON.parse(data.responseText).query_output);
        $("#core_datacast_submit").addClass("grey-disabled");
        $("#core_datacast_submit").prop("disabled", true);
        $("#core_datacast_query").focus()
        $("#change_query_text_button").hide();
        $("#core_datacast_preview").prop("disabled", true);
        $("#datacast_display").hide();
      }
    });
  });

  $("#core_datacast_submit").click(function () {
    $("#core_datacast_query").prop("disabled", false);
    $("#core_datacast_format").prop("disabled",false)
    var query = $("#core_datacast_query").val(),
    core_db_connection_id = $("#core_datacast_core_db_connection_id").val();
    if (!validateQuery(query) || !execute_flag) {
      generate_notify({text: "Query does not match the requirements", notify:"error"});
      $("#core_datacast_query").prop("disabled", true)
      $("#core_datacast_format").prop("disabled",true)
      return false;
    }
  });

  $("#core_datacast_query").on("blur",function(){
    if($(this).val() !== ""){
      $("#core_datacast_preview").removeClass("grey-disabled");
      $("#core_datacast_preview").prop("disabled", false);
    } else {
      $("#core_datacast_preview").addClass("grey-disabled");
      $("#core_datacast_preview").prop("disabled", true);
    }
  });

  $("#change_query_text_button").on("click", function() {
    $(".enable_it_on_change_query_click").prop("disabled", false);
    $("#core_datacast_preview").prop("disabled", false);
    $(this).hide()
  });

  $("#core_datacast_refresh_frequency").on("change", function(){
    if($("#core_datacast_query").val() !== "" && execute_flag) {
      $("#core_datacast_submit").prop("disabled",false)
    }
  })
}

var validateQuery = function (query) {
  if (query.length <= 0) {
    return false;
  } else if (query.indexOf("update") >= 0) {
    return false;
  } else if (query.indexOf("drop") >= 0) {
    return false;
  } else if (query.indexOf('truncate') >= 0) {
    return false;
  } else if (query.indexOf("insert") >= 0){
    return false;
  } else if (query.toLowerCase().indexOf("select") !== 0){
    return false
  }
  return true;
} 