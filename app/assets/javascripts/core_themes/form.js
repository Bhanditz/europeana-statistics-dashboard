Rumali.ConfigThemeSubmitForm = function(){
  $("#theme_submit").click(function(){
    var config_string = JSON.stringify(obj);
    $("#core_theme_config").val(config_string);
  })
}