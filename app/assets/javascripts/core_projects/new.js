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