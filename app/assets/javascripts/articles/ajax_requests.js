var handsontble_config = {
  "data": {},
  "readOnly": true,
  "fixedRowsTop": 0,
  "colHeaders": [],
  "manualColumnMove": true,
  "outsideClickDeselects": false,
  "contextMenu": false
}
Rumali.newArticleCreate = function () {
  $(".layout_modal_links").on("click", function () {
    $("#core_card_core_card_layout_id").val($(this).data().layout_id)
  });
  $("#core_card_core_datacast_identifier").on("change", function (){
    var datacast_identifier = this.value;
    $("#core_card_datacast_preview").hide();
    $("#core_card_datacast_preview_error").hide()
    getDatacastData(datacast_identifier);
  });

  $("#preview_number_button").on("click", function(){
    $("#label_for_number_value").text($("#label_for_number").val());
    $("#number_input_value").text($("#number_input").val());
    plus_or_minus_value_span = $("#plus_or_minus_value")
    if ($("#enable_difference").prop("checked")){
      plus_or_minus_value_span.removeClass("glyphicon-chevron-up green glyphicon-chevron-down red")
      if($("#diff_for_plus_or_minus").val() !== "") {
        if ($("#plus_or_minus").val() === "+") {
          plus_or_minus_value_span.addClass("glyphicon-chevron-up green");
        } else {
          plus_or_minus_value_span.addClass("glyphicon-chevron-down red");
        }
      }
      plus_or_minus_value_span.show();
      $("#diff_for_plus_or_minus_value").text($("#diff_for_plus_or_minus").val());
    } else {
      plus_or_minus_value_span.hide();
      $("#diff_for_plus_or_minus_value").text("");
    }
  })

  $(".card_submit_button").on("click", function(){
    var card_content = this.dataset.card_type,
    content = "";
    switch (card_content) {
      case "image":
        content = "<div class='image_cards'><img src='$_IMAGE_URL_AFTER_IMAGE_IS_UPLOADED_$'/><div>"+$("#image_content").val().trim()+"</div></div>";
        break;
      case "text":
        content = $("#text_card_preview").html();
        break;
      case "number":
        content = $("#number_preview").parent().html().trim();
        break;
    }
    if(!validate_content(content)) {
      return false
    }
  })

}

var getDatacastData = function(datacast_identifier) {
  $.ajax({
    url: rumi_api_endpoint + "datacast/" + datacast_identifier,
    type: "get",
    success: function (data) {
      handsontble_config.data = JSON.parse(data)
      $("#core_card_datacast_preview").handsontable(handsontble_config);
      $("#core_card_datacast_preview").show();
    },
    error: function (data, textStatus, errorThrown) {
      $("#core_card_datacast_preview_error").css("height:auto")
      $("#core_card_datacast_preview_error").html("<p class='red'>"+errorThrown+"</p>")
      $("#core_card_datacast_preview_error").show()
    }
  });
}

var scrolling = function(opt){
  if(opt=='textarea'){
    $("#text_card_preview").scrollTop($("#input").scrollTop());
  } 
}