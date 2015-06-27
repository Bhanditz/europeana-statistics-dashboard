//render unique values on the sidebar
Rumali.sidebarUnique = function () {
  $(document).on('click', '.sort-unique', function (e) {
    var sort_value = $(this).attr("id");
    $('#dropdownsortvalue').html("Sort Value by "+Rumali.plugin.toTitleCase(sort_value)+" <span class='caret'></span>");
    Rumali.countUniqueValues(data_distribution, sort_value);
    Rumali.gridoperation.resetFilterElements();
    e.preventDefault();
  });

  $(document).on('click', '.sort-unique-modal', function (e) {
    var sort_value = $(this).attr("id");
    $('#dropdownsortvalue_modal').html("Sort Value by "+Rumali.plugin.toTitleCase(sort_value)+" <span class='caret'></span>");
    Rumali.countUniqueValuesOnModal(data_distribution, sort_value);
    Rumali.gridoperation.resetFilterElements();
    e.preventDefault();
  });
  Rumali.countUniqueValues = function (obj, sort_order,col_name,data_type) {
    if(Rumali.gridoperation.getSelectedColumnIndex() !== false){
      var col = Rumali.gridoperation.getSelectedColumnIndex()
      , datatype = self.column_datatype[col+1]
      , column_name = new_column_name;
    }  else {
      var datatype = data_type
      , column_name = col_name;
      new_column_name = col_name
    }
    var arr_count = []
      , temp_label = "<table class='table table-condensed' id ='unique_values' >"
      , boolean_value;
    Rumali.countUniqueValuesOnModal(obj, sort_order);
    if (sort_order == "name") {
      arr_count = Object.keys(obj).sort();
    } else {
      arr_count = Object.keys(obj).sort(function (a, b) {
        return obj[b] - obj[a];
      });
    }
    $("#grid_unique_values").empty();
    $("#unique-values").empty();
    for (i in arr_count) {
      boolean_value = arr_count[i];
      if(boolean_value == 't') {
         boolean_value = "true";
      }else if(boolean_value == 'f'){
        boolean_value = 'false';
      }
      temp_label += "<tr>";
      temp_label += "<td style='border: none; padding-top: 0px; padding-bottom: 0px; width: 10px;'>";
      temp_label += "<input type='checkbox'  data-id ='"+column_name+arr_count[i]+"' class='check-value' value='" + arr_count[i] + "' /></td>";
      temp_label += "<td style='font-size: 12px; border: none; padding-top: 0px; padding-bottom: 0px;'>" + boolean_value
      temp_label += "</td><td style='font-weight: bold; border: none; padding-top: 0px; padding-bottom: 0px;'>" + obj[arr_count[i]] + "</td></tr>";
    }
    temp_label += "</table>";
    $("#unique-values").append(Object.keys(obj).length + " Unique value");
    $("#unique-values").show();
    $("#grid_unique_values").append(temp_label);
    if(datatype == 'string' || datatype == 'date'){
      $('#merge').show();
    }
  }

  Rumali.countUniqueValuesOnModal = function (obj, sort_order) {
    var arr_count = []
      , column_name = new_column_name
      , temp_label = "<table class='table table-condensed' id='unique-values-modal'>";
    if (sort_order == "name") {
      arr_count = Object.keys(obj).sort();
    } else {
      arr_count = Object.keys(obj).sort(function (a, b) {
        return obj[b] - obj[a];
      });
    }
    $("#unique_value_formodal").empty();
    for (i in arr_count) {
      temp_label += "<tr>";
      temp_label += "<td style='border: none; padding-top: 0px; padding-bottom: 0px; width: 10px;'>";
      temp_label += "<input type='checkbox'  data-id ='"+column_name+arr_count[i]+"' class='modal-check-value' value='" + arr_count[i] + "' /></td>";
      temp_label += "<td style='font-size: 12px; border: none; padding-top: 0px; padding-bottom: 0px;'>" + arr_count[i]
      temp_label += "</td><td style='font-weight: bold; border: none; padding-top: 0px; padding-bottom: 0px;'>" + obj[arr_count[i]] + "</td></tr>";
    }
    temp_label += "</table>";
    $("#unique_value_formodal").append(temp_label);
  }

  $(document).on('click', '.check-value', function () {
    var checked_arr = []
      , values_array = []
      , toggle_val = $("#filter_toggle :checked").val();
    checked_arr.push($(this).val()),
    col_name = new_column_name;
    $('.check-value:checked').each(function (i, obj) {
      values_array.push($(this).val());
    });
    Rumali.executeAfterUniquevalueFilter();
    if (toggle_val == "in") {
      column_values_filter.addFilter([[{"column_name": col_name, "condition_type": "values", "in": checked_arr, "next": "AND", "selected_dom_id": $(this).attr("data-id")}]], true,true);
    } else {
      column_values_filter.addFilter([[{"column_name": col_name, "condition_type": "values", "not_in": checked_arr, "next": "AND", "selected_dom_id": $(this).attr("data-id")}]], true,true);
    }
  });
  
  $('#search_box').keyup(function() {
    searchTable($(this).val(),"unique_values");
  });

  $('#search_box_modal').keyup(function() {
    searchTable($(this).val(),"unique-values-modal");
  });
  function searchTable(inputVal,table_id) {
    var table = $('#'+table_id);
    table.find('tr').each( function(index, row) {
      var allCells = $(row).find('td');
      if(allCells.length > 0) {
        var found = false;
        allCells.each(function(index, td) {
          var regExp = new RegExp(inputVal, 'i');
          if(regExp.test($(td).text())) {
            found = true;
            return false;
          }
        });
        if(found == true) {
          row.style.display = "block";
        } else {
          row.style.display = "none";
        }
      }
    });
  }
}
