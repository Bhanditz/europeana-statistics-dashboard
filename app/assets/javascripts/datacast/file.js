Rumali.newDataStorePage = function () {
  $("#upload-step").click(function () {
    clicked_on_upload_step();
  });

  $("#upload_through_ftp").click(function () {
    clicked_on_upload_through_ftp();
  });

};

var clicked_on_upload_step = function () {
  $("#data-menu").show();
  $("#next-step").show();
  $("#upload_through_ftp-box").hide();
  $(".well-highlighted").removeClass("well-highlighted");
  $("#upload-step").addClass("well-highlighted");
};

var clicked_on_upload_through_ftp = function () {
  $("#data-menu").hide();
  $("#next-step").hide();
  $("#upload_through_ftp-box").show();
  $(".well-highlighted").removeClass("well-highlighted");
  $("#upload_through_ftp").addClass("well-highlighted");
}