PykAce.urlGenerator = function() {
    
  this.execute = function() {
    var that = this;

    that.new_url = "";
    that.var_val_pair = [];
    that.var_id = 0;
    that.var_count = 0;
    that.render();
  };

  this.render = function() {
    var that = this;
    
    // Adding var/val pair
    $(".add-btn").click(function () {
      alert("ssssssssssss")
      if($(this).val() === "+"){
        that.appendURLVar();
      }
      else if($(this).val() === "-"){
        that.removeURLVar($(this).parent());
      }
    });

    $("#submit-vars-btn").click(function(){
      $("#url-text").val(that.new_url);
    });
  };

  this.removeURLVar = function (div_delete) {
    var that = this;
    var id = $(div_delete).attr("id");
    var custom_var_delete = $("#cus-var-"+id).val();
    var value_delete = $("#val-"+id).val();

    // Removing from URL string
    if($("#"+id).is(":first-child") === true){ // First string
      // Removing from the array of var/val pair
      that.var_val_pair.pop();
      if($("#list-of-var").children().size() > 2){
        that.new_url = that.new_url.replace(custom_var_delete+"="+value_delete+"&","");
      }
      else if($("#list-of-var").children().size() <= 2){
        that.new_url = that.new_url.replace("?"+custom_var_delete+"="+value_delete,"");
      }      
    }
    else if($("#"+id).is(":first-child") === false){
      // Removing from the array of var/val pair
      var j;
      j = _.find(that.var_val_pair, function(d,i){ return d.id === id ? i : "not found"; });      
      that.var_val_pair.splice(j,1);
      that.new_url = that.new_url.replace("&"+custom_var_delete+"="+value_delete,"");        
    }
    that.var_count--;

    // Removing the var/val pair container
    $("#list-of-var div").remove("#"+id);
  };

  this.appendURLVar = function(){
    var that = this;
    var custom_var = $("#cus-var-"+that.var_id).val();
    var value = $("#val-"+that.var_id).val();

    // Saving the entered variable/value pair
    if(custom_var !== "" && value !== ""){
      if(that.var_count === 0){ // First variable/value pair
        // Adding to URL string
        that.new_url = $("#url-text").val()+"?"+custom_var+"="+value;
        
        // Pushing the var/val pair into the array
        that.var_val_pair.push({
          "id":that.var_id,
          "var":custom_var,
          "val":value
        });

        // Make the value from '+' to '-'
        $("#add-var-btn-"+that.var_id).val("-");        

        that.var_id++;
        that.var_count++;

        // Displaying next empty var/val pair container
        $("#list-of-var").append("<div id='"+that.var_id+"'></div>");
        $("#"+that.var_id).append("<input id='cus-var-"+that.var_id+"' placeholder='custom variable'>");
        $("#cus-var-"+that.var_id).focus();
        $("#"+that.var_id).append("<input id='val-"+that.var_id+"' placeholder='value'>");
        $("#"+that.var_id).append("<input type='button' id='add-var-btn-"+that.var_id+"' value='+'>");
      }
      else{
        that.new_url = that.new_url+"&"+custom_var+"="+value;
        
        // Pushing the var/val pair into the array
        that.var_val_pair.push({
          "id":that.var_id,
          "var":custom_var,
          "val":value
        });
        
        // Make the value from '+' to '-'
        $("#add-var-btn-"+that.var_id).val("-");

        that.var_id++;
        that.var_count++;

        // Displaying next empty var/val pair container
        $("#list-of-var").append("<div id='"+that.var_id+"'></div>");
        $("#"+that.var_id).append("<input id='cus-var-"+that.var_id+"' placeholder='custom variable'>");
        $("#cus-var-"+that.var_id).focus();
        $("#"+that.var_id).append("<input id='val-"+that.var_id+"' placeholder='value'>");
        $("#"+that.var_id).append("<input type='button' id='add-var-btn-"+that.var_id+"' class='add-btn' value='+'>");
      }      
      
      $("#add-var-btn-"+that.var_id).click(function () {
        if($(this).val() === "+"){
          that.appendURLVar();
        }
        else if($(this).val() === "-"){
          that.removeURLVar($(this).parent());
        }
      });
    }
  };
}