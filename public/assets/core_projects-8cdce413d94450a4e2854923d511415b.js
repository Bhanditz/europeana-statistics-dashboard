$("#scopejs_projects_new").ready(function(){

  $("#new_project_submit").click(function(){
    active_ref_slug = $(".all_ref_plans.selected").attr("slug")
    $("#core_project_ref_plan_slug").val(active_ref_slug);
  });

  $("#core_project_account_id").on("change",function(){
    $('tr.all_ref_plans').removeClass("selected");
    $("tr.all_ref_plans").hide();
    $("tr.ref_plan_container").hide();
    if($(this)[0].selectedOptions[0].attributes.is_enterprise_organisation.value == "true"){
      $("tr.all_ref_plans.enterprise").show();
      $("tr.ref_plan_container.enterprise").show();
      $("tr.all_ref_plans.enterprise:first").addClass("selected")
    }else{
      $("tr.all_ref_plans.consumer").show();
      $("tr.ref_plan_container.consumer").show();
      $("tr.all_ref_plans.consumer:first").addClass("selected")
    }
  });

  $(".all_ref_plans").on("click", function () {
    $('.all_ref_plans').removeClass("selected");
    $(this).addClass("selected");
  });

})
;
window.onload = function () {      
  $("#loader .centered").slideUp(function(){
    $("#loader").fadeOut(function(){
      $("#loader").remove();
    });
  });
  
  var html_body_id = document.getElementsByTagName("body")[0].id
  switch (html_body_id) {
    case "scopejs_themes_new":
    case "scopejs_themes_create":
    case "scopejs_themes_edit":
    case "scopejs_themes_update":
      Rumali.ConfigThemeSubmitForm();
      Rumali.liveEditor();
      break;
    case "scopejs_vizs_new":
    case "scopejs_vizs_create":
      Rumali.chartView();
    break;
    case "scopejs_vizs_edit":
    case "scopejs_vizs_update":
      if (chart_name !== "Grid") {
        Rumali.liveEditor();
      } else {
        (gon.dataformat == "csv") ? Rumali.showAndEditGridPage() : Rumali.JsonDataPage();
      }
      break;
    case "scopejs_data_stores_new":
    case "scopejs_data_store_pulls_create":
      Rumali.newDataStorePage();
      break;
    case "scopejs_vizs_show":
      if (chart_name !== "Grid") {
        Rumali.showChartPage();
      } else {
        (gon.dataformat == "csv") ? Rumali.showAndEditGridPage() : Rumali.JsonDataPage();
      }
      break;
    case "scopejs_maps_show":
      Rumali.bangaloreGeo();
      break;
    case "scopejs_map_files_show":
      Rumali.showMapFile();
      break;
    default:
  }
};









