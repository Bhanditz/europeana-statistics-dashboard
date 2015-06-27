$(document).ready(function() {
  //Activating Best In Place 
  if($(".best_in_place").length > 0){
    jQuery(".best_in_place").best_in_place();
    $('.best_in_place').bind("ajax:success", function (e) {generate_notify({text: "Description Updated Successfully", notify: "success", timeout: true})});
    $('.best_in_place').bind("ajax:error", function (e) {
      generate_notify({text: "Failed to update", notify: "error", timeout: true});
    });
  } 
});