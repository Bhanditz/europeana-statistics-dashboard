Rumali.plugins = function () {
  var previous_val;
  var loadingOverlay = function () {
    var loading_overlay = document.createElement("div");
    loading_overlay.setAttribute("id", "rumali_loading_overlay");
    document.body.appendChild(loading_overlay);
    var loading_text = document.createElement("div");
    loading_text.className = "rumali-loading-text";
    loading_text.innerHTML = "Loading..";
    document.getElementById("rumali_loading_overlay").appendChild(loading_text);
    $(document).ajaxStart(function(pe) {
      loading_overlay.style.opacity = 1;
      loading_overlay.style.display = "block";
    });

    $(document).ajaxStop(function(pe) {
      loading_overlay.style.opacity = 0;
      setTimeout(function () {
        loading_overlay.style.display = "none";
      }, 250);
    });
  }
  loadingOverlay();

  this.rumiLocales = {
    getPossibleColumnOperations: function () {
      var data_obj = {
        string: [
          {
            name: "Change to Uppercase",
            id: "uppercase"
          },
          {
            name: "Change to Lowercase",
            id: "lowercase"
          },
          {
            name: "Capitalize first letter",
            id: "titlecase"
          },
          {
            name: "divider",
            id: "divider"
          },
          {
            name: "Remove spaces before and after data",
            id: "trim"
          },
          {
            name: "Collapse consecutive white spaces",
            id: "whitespace"
          },
          {
            name: "divider",
            id: "divider"
          },
          {
            name: "Remove Character",
            id: "removechar"
          },
          {
            name: "Replace",
            id: "mergetoclean"
          }
        ],
        boolean: [],
        integer: [],
        double: [],
        date: []
      };
      return data_obj;
    }

  };
  $(document).on('click', '#filter_toggle', function () {
    //console.log($("#filter_toggle :not(:checked)").attr("activate"),$(this).attr("id"));
    var current_value = $("#filter_toggle :checked").attr("value");
    if (current_value == previous_val) {
      return false;
    } else {
      previous_val = current_value;
    }
    if(Rumali.gridoperation.getSelectedColumnIndex() !== false){
      var col_index = Rumali.gridoperation.getSelectedColumnIndex()
      , datatype = self.column_datatype[col_index+1]
      , type;
    }  else {
      var datatype = selected_datatype
      , column_name = new_column_name;
    }
    
    if (datatype == "integer" || datatype == "double") {
      type = "range";
    } else{
      type = "value";
    }
    switch (type) {
      case "value":
        // $('.check-value:checked').each(function(i, obj) {
        //   var values_array =[];
        //   values_array.push($(this).val());
        //   var toggle_val = $("#filter_toggle :checked").val();
        //   if(toggle_val == "in"){
        //     console.log(toggle_val);
        //     column_values_filter.addFilter({"column_name": new_column_name, "condition_type": "values", "in": values_array, "next": "AND", "override_filter" : true, "selected_dom_id": $(this).attr("data-id")}, true);
        //   } else {
        //     console.log(toggle_val,"--------------");
        //     column_values_filter.addFilter({"column_name": new_column_name, "condition_type": "values", "not_in": values_array, "next": "AND", "override_filter" : true, "selected_dom_id": $(this).attr("data-id")}, true);
        //   }
        // });
        // var data = grid_show.flushToGet().data;
        // console.log(data)
        // if(data != undefined && data.length > 0){
        //   console.log("gooooooooooo")
        //   self.json_data =  data;
        //   PYKMODEL.reloadGrid();
        //   PYKMODEL.refreshStatistics();
        // } else {
        //   console.error("error in Histogram filter")
        // }
      break;
      case "range":
        var new_min = parseFloat($("#min_value").val())
          , new_max = parseFloat($("#max_value").val())
          , toggle_val = $("#filter_toggle :checked").val();
        Rumali.executeAfterRangeFilter()
        global_brush.extent([new_min,new_max]);
        brush.call(global_brush);
        if (toggle_val == "in") {
          pyk_histogram.addFilter([[{"column_name": new_column_name, "condition_type": "range", "condition": {"min": new_min, "max": new_max, "not": false}, "override_filter" : true,"next": "AND"}]], true ,true);
        } else {
          pyk_histogram.addFilter([[{"column_name": new_column_name, "condition_type": "range", "condition": {"min": new_min, "max": new_max, "not": true}, "override_filter" : true,"next": "AND"}]], true,true );
        }
      break;
    }
  });

  this.toTitleCase = function (string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }
}
