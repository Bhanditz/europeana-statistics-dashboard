Rumali.ConfigThemeSubmitForm = function(){
  $("#theme_submit").click(function(){
    var config_string = JSON.stringify(obj);
    $("#core_theme_config").val(config_string);
  })
}
;
var chart
  , current_config = {}
  ,chart_html_tag
  ,parsed_data
  ,org_data;

Rumali.liveEditor = function(){
  var datacast_identifier,
    url;

  var onDataLoad = function(json_data){
    var original_width;

    data["data"] = parsed_data;

    if (chart_name !== "Grid") {
      dataFinding(data);
    }

    //loading the Default theme
    //when user selects any theme

    $(".theme_configuration").click(function(){
      $(".execute1").attr("checked",false);
      var config = JSON.parse($(this).attr("config"));
      dataFinding(config)
    });

    //
    $("#expandCollapse").click(function(e){
      e.preventDefault();
      expandAndCollapseAllPanels();
    });
    //swatch mode
    $(":input.execute1").on("click",function(){
      if(this.type == "radio"){
        if(this.id != "chart_color"){
          var id = this.id;
          if(!(final_config[id] === $(this).val() || final_config[id] === parseFloat($(this).val()))) {
            current_config[id] = $(this).val();
          }
          obj[this.id]= this.value;
          final_config[this.id] = this.value;
        }
        initializeTheChart("true");
      }
    });
    //checkboxes for swatch mode
    $(":input.execute2").on("click",function(){
      var i = this.id
        , color_arr = [];
      if (i==="chart_color_boolean0") {
        colorRepetation=$("[id1='array_text']").val();
        $("[id1='array_text']").attr('value',colorRepetation);
        obj["chart_color"] = colorRepetation.split(";");
        final_config["chart_color"] = obj['chart_color'];
        $(".identity1").attr("disabled",true);
        $(".identity2").attr("disabled",false);
      } else {
        var chart_color_checked = $('.execute3:checked');
        if(!chart_color_checked.length){
          color_arr.push(obj["chart_color"][0]);
        }
        else{
          for (var j = 0; j<chart_color_checked.length; j++) {
            color_arr.push(chart_color_checked[j].value);
          }
        }
        obj["chart_color"] = color_arr;
        final_config["chart_color"] = color_arr;
        $(".identity1").attr("disabled",false);
        $(".identity2").attr("disabled",true);
      }
      initializeTheChart("true");
    });
    //radio buttons for swatch mode
    $(".execute3").on("click",function(){
      if ($("#chart_color_boolean1").attr('checked') === "checked") {
        var i = this.id
          , color_arr = [];
        var chart_color_checked = $('.execute3:checked');
        for (var j = 0; j<chart_color_checked.length; j++) {
          color_arr.push(chart_color_checked[j].value);
        }
        obj[i] = color_arr;
        final_config[i] = color_arr;
        initializeTheChart("true");
      }
    });
    //any other value changed
    $(":input.execute").on("blur",function(){
      var i = this.id;
      obj[i]=$('#'+this.id).val();
      if(!(final_config[i] === $(this).val() || final_config[i] === parseFloat($(this).val()))) {
        if(i!="chart_color") {
          current_config[i] = $(this).val();
        }
      }

      final_config[i]=$('#'+this.id).val();
      if (i==="chart_color") {
        if ($("#chart_color_boolean0").attr('checked') === "checked") {
          var arr=[];
          obj[i] = this.value.split(";");
          final_config[i] = obj[i];
        }
      }else if(this.type == "select-one")
      {
        if($('#'+this.id).val() == "fixed"){
          $("."+$(this).attr("disableinputs1")).each(function(){
            $(this).attr("disabled",false);
          });
        }else if($('#'+this.id).val() == "moving"){
          $("."+$(this).attr("disableinputs1")).each(function(){
            $(this).attr("disabled",true);
          });
        }else if($('#'+this.id).val() == "color"){
          $("."+$(this).attr("disableinputs1")).each(function(){
            $(this).attr("disabled",true);
          });
        }else{
          $("."+$(this).attr("disableinputs1")).each(function(){
            $(this).attr("disabled",false);
          });
        }
      }else if(this.type == "checkbox") {
        if(this.checked) {
          $("."+$(this).attr("disableinputs")).each(function(){
            $(this).attr("disabled",false);
          });
          obj[i] = "yes";
          final_config[i] = "yes";
          current_config[this.id] = "yes";
        } else {
          $("."+$(this).attr("disableinputs")).each(function(){
            $(this).attr("disabled",true);
          });
          obj[i] = "no";
          current_config[this.id] = "no";
          final_config[i] = "no";
        }
      }
      if(obj[i] !== "" && !isNaN(obj[i])){
        obj[i] = parseInt(obj[i]);
        final_config[i] = parseInt(obj[i]);
      }

      if (i==="axis_x_pointer_values" || i==="axis_y_pointer_values" || i==="clubdata_always_include_data_points") {
        obj[i] = obj[i].toString().split(";");
        final_config[i] = obj[i];
      }

      if (PykCharts.interval){
        clearInterval(PykCharts.interval);
      }

      if(i=="palette_color"){
        obj.saturation_color="";
        final_config.saturation_color="";
      }
      initializeTheChart("true");
    });
    //
    $("#color_mode").change(function(){
      if(this.value == "color"){
        $("#color_group").show();
        $("#saturation_group").hide();
      }else{
        $("#color_group").hide();
        $("#saturation_group").show();
      }
    });
    //
    $("#zoom_enable").click(function(){
      if(this.checked){
        $("#zoom_level").attr("disabled",false)
      }
      else{
        $("#zoom_level").attr("disabled",true)
      }
    });
    //
    $('.color').colorpicker().on("hide",function (e,d) {
      if($(this).children()[1].checked){
        if ($(this).has(".execute3").length > 0) {
          if ($(selector).attr('checked') === "checked") {
            var i = $(this).find(".execute3")[0].id
              , color_arr = [];
            var chart_color_checked = $('.execute3:checked');
            for (var j = 0; j<chart_color_checked.length; j++) {
              var color = $($(chart_color_checked[j])[0].previousElementSibling.childNodes[1]).css("background-color");
              color_arr.push(color);
            }
            obj[i] = color_arr;
            final_config[i] = color_arr;
            initializeTheChart("true");
          }
        } else if ($(this).has(".execute1").length > 0) {
          if($(this).find(".execute1")[0].type == "radio"){
            $(selector).empty();
            var i = $(this).find(".execute1")[0].id;
            if(i != "chart_color"){
              var color = $(this).find(".circle").css("background-color");
              obj[i]= color;
              final_config[this.id] = color;
            }
            initializeTheChart("true");
          }
        }
      }
    });

    $("#core_viz_update").click(function(){
      var final_obj_to_save = obj;
      if(final_obj_to_save.title_text.trim().replace(/ /g,"").toLowerCase() == "[entertitlehere]" || final_obj_to_save.title_text.trim().replace(/ /g,"").toLowerCase() == "") final_obj_to_save.title_text = "";
      if(final_obj_to_save.subtitle_text.trim().replace(/ /g,"").toLowerCase() == "[entersubtitlehere]" || final_obj_to_save.subtitle_text.replace(/ /g,"").toLowerCase() == "" ) final_obj_to_save.subtitle_text = "";
      final_obj_to_save.data = "";
      $("#core_viz_config").val(JSON.stringify(final_obj_to_save));
    });
  }

  var saveOrgData = function(json_data){
    org_data = json_data;
    loadChartFilters();
    onDataLoad(org_data);
  }

  var loadChartFilters = function(){
    var filter_val;
    if(chart_html_tag.dataset.filter_present === 'true'){
     
      $('#filter_container').show();
      unique_filter_html = renderFilter(org_data,chart_html_tag.dataset.filter_column_name,'filter_show');
      $('#filter_container').html(unique_filter_html); 

      $('#filter_show').change(function(){
        filter_val = $('#filter_show option:selected').val();
        parsed_data = filterChart(org_data,chart_html_tag.dataset.filter_column_name,filter_val);
        onDataLoad(parsed_data);
      }); 

      $("select#filter_show").prop('selectedIndex', 0);
      filter_val = $('#filter_show option:selected').val();
      parsed_data = filterChart(org_data,chart_html_tag.dataset.filter_column_name,filter_val);
    }
    else{
      $('#filter_container').hide(); 
      parsed_data = org_data; 
    }
    // $('#filter_show').show();
    // 
    //
  }


  chart_html_tag = $('#chart_container')[0];

  datacast_identifier = chart_html_tag.dataset.datacast_identifier;
  url = Rumali.object.datacast_url + datacast_identifier;
  getJSON(url,saveOrgData); 
}


function dataFinding(data) {

  if (genre == "One Dimensional Charts") {
    data["color_mode"] = "shade";
  }

  var count = 0;
  config_data = data;
  final_config = {};
  var configtype = $(".cstm-form-control:input"),types_config = [];
  colorRepetation=[];
  countgroup=1;
  // original_width = config_data["chart_width"];
  // if(chart_name ==="Panel of Scatters") {
  //   config_data["chart_width"] = 200;
  //   config_data["chart_height"] = 200;
  // }

  for(var i in current_config) {
    config_data[i] = current_config[i];
  }

  for(i=0;i<configtype.length;i++) {
    if (configtype[i].id == "core_theme_name") continue;
    types_config.push(configtype[i].type);
    if(configtype[i].type.toLowerCase() === "number") {
      configtype[i].value = config_data[$(configtype)[i].id];
      final_config[$(configtype)[i].id] = config_data[$(configtype)[i].id]
    } else if(configtype[i].type.toLowerCase() === "textbox") {
      $(configtype)[i].value = config_data[$(configtype)[i].id] || "";
      final_config[$(configtype)[i].id] = config_data[$(configtype)[i].id]
    } else if(configtype[i].type.toLowerCase() === "text") {
      $(configtype)[i].value = config_data[$(configtype)[i].id] || "";
      final_config[$(configtype)[i].id] = config_data[$(configtype)[i].id]
    }else if(configtype[i].type.toLowerCase() === "color") {
      $(configtype)[i].value = config_data[$(configtype)[i].id] || "";
      final_config[$(configtype)[i].id] = config_data[$(configtype)[i].id]
    }
    else if($(configtype[i]).attr("reference") === "color1") {
      if (count===1) {
        count = 0;
      }
      count+=0.2;
      var c = config_data[configtype[i].id];
      if (configtype[i].id === "chart_color") {
        c = c[0];
      }
      var rgb = hex2rgb(c);
      var rgba = "rgba("+rgb[0]+","+rgb[1]+","+rgb[2]+","+count+")";
      var middlecolor =(RGBAtoRGB(rgb[0],rgb[1],rgb[2],count,255,255,255));
      var final = rgbToHex(middlecolor);
      configtype[i].value = final;
      $($(configtype[i])[0].parentElement).attr("data-color",final);
      $($(configtype[i])[0].previousElementSibling.childNodes[1]).css("background-color",final);
      if(configtype[i].id==="chart_color" && countgroup<=5){
        if(countgroup===5){
          colorRepetation+=final
        }else{
          colorRepetation+=final+";";
        }
        countgroup++;
      }

    } else if(configtype[i].type.toLowerCase() === "checkbox") {
      $(configtype)[i].value = config_data[$(configtype)[i].id];
      if(config_data[$(configtype)[i].id] === "yes") {
        $(configtype)[i].checked = true;
      } else {
        $(configtype)[i].checked = false;
      }
      final_config[$(configtype)[i].id] = config_data[$(configtype)[i].id]
    } else if(configtype[i].type.toLowerCase() === "select-one") {
      $(configtype)[i].value = config_data[$(configtype)[i].id];
      final_config[$(configtype)[i].id] = config_data[$(configtype)[i].id]
    }
  }
  config_data['data'] = parsed_data;

  config_data['selector']  = selector;
  init();
}

function init(){
  if(obj){
    config_data.title_text = obj.title_text.toString().trim() != "" ?  obj.title_text : config_data.title_text;
    config_data.subtitle_text = obj.subtitle_text.toString().trim() != "" ?  obj.subtitle_text : config_data.subtitle_text;
  }
  obj=config_data;

  $(selector).empty();
  config_data["map_code"] = map_code;
  final_config["map_code"] = map_code;
  if(obj.title_text && (obj.title_text).trim().replace(/ /g,"").toLowerCase() == "[entertitlehere]"){
    $("#title_text").val("");
  }
  if(obj.subtitle_text &&(obj.subtitle_text).trim().replace(/ /g,"").toLowerCase() == "[entersubtitlehere]"){
    $("#subtitle_text").val("");
  }
  var groups;
  var str = '';
  str = colorRepetation;
  if(chart_name!="Pictograph" && chart_name !== "Grid"){
    config_data["chart_color"] = colorRepetation.split(";").reverse();
    $("[id1='array_text']").attr('value',str.split(";").reverse().join(";"));
  }
  colorRepetation=[],
  str="",
  countgroup=1,
  initializeTheChart("true");
}

function hex2rgb(hex) {
  return ['0x' + hex[1] + hex[2] | 0, '0x' + hex[3] + hex[4] | 0, '0x' + hex[5] + hex[6] | 0];
}

function RGBAtoRGB(r, g, b, a, r2,g2,b2){
  var r3 = Math.round(((1 - a) * r2) + (a * r))
  var g3 = Math.round(((1 - a) * g2) + (a * g))
  var b3 = Math.round(((1 - a) * b2) + (a * b))
  return "rgb("+r3+","+g3+","+b3+")";
}


function rgbToHex(color) {
  if (color.substr(0, 1) === "#") {
    return color;
  }
  var nums = /(.*?)rgb\((\d+),\s*(\d+),\s*(\d+)\)/i.exec(color),
  r = parseInt(nums[2], 10).toString(16),
  g = parseInt(nums[3], 10).toString(16),
  b = parseInt(nums[4], 10).toString(16);
  return "#"+ (
    (r.length == 1 ? "0"+ r : r) +
    (g.length == 1 ? "0"+ g : g) +
    (b.length == 1 ? "0"+ b : b)
  );
}

function expandAndCollapseAllPanels(){
  if($(".panel-body").hasClass("in")){
    $(".panel-body").removeClass("in");
  }else{
    $(".panel-body").addClass("in").css("height","auto");
    $(".in").prev().removeClass("collapsed");
  }
}
var initializeTheChart = function (is_content_editable){
  if (chart_name !== "Grid") {
    $("#title").remove();
    $("#subtitle").remove();
    if (is_content_editable == "true"){
      if(obj.title_text == "") obj.title_text = "[ Enter Title Here ]"
      if(obj.subtitle_text == "") obj.subtitle_text = "[ Enter Subtitle Here ]"
    }
    if(chart && chart.interval) {
      clearInterval(chart.interval)
    }
    chart = new initializer(obj);
    d3.selectAll(".pyk-tooltip").remove();
    $(selector).empty();
    chart.execute();
    if (is_content_editable == "true") giveTitleProperties();
  }
}

var giveTitleProperties = function(){
  $("#title").ready(function(){

    $("#title").attr("contenteditable","true");

    $("#title").blur(function(){
      var title_text = this.innerText.trim();
      $(this).attr("contenteditable","true");
      $("#title_text").val(title_text);
      obj.title_text = title_text;
      if(title_text == "") initializeTheChart("true");
    });

    $("#title").keydown(function(e){
      if(e.keyCode === 13) $(this).attr("contenteditable", "false");
    })
  });

  $("#sub-title").ready(function(){

    $("#sub-title").attr("contenteditable","true");

    $("#sub-title").blur(function(){
      var subtitle_text = this.innerText.trim();
      $(this).attr("contenteditable","true")
      $("#subtitle_text").val(subtitle_text);
      obj.subtitle_text = subtitle_text;
      if(subtitle_text == "") initializeTheChart("true");
    });

    $("#sub-title").keydown(function(e){
      if(e.keyCode === 13) $(this).attr("contenteditable", "false");
    });
  });
}

;
var getApiFromString = function(api){
  api = api.split(".");
  return PykCharts[api[1]][api[2]];
}

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
      if (chart_name !== "Grid" && chart_name !== "One Number indicators") {
        Rumali.liveEditor();
      } else if(chart_name !== "One Number indicators"){
        Rumali.showAndEditGridPage();
      }else{
         Rumali.showAndEditBoxPage();
      }
      break;
    case "scopejs_datacast_pulls_create":
    case "scopejs_datacasts_file":
    case "scopejs_datacasts_upload":
      Rumali.newDataStorePage();
      break;
    case "scopejs_vizs_show":
      if (chart_name !== "Grid") {
        Rumali.showChartPage();
      } else{

        Rumali.showAndEditGridPage();
      }
      break;
    case "scopejs_datacasts_new":
    case "scopejs_datacasts_create":
      Rumali.dataCastNewPage();
      break;
    case "scopejs_datacasts_edit":
    case "scopejs_datacasts_update":
      Rumali.dataCastNewPage();
      Rumali.initDataCastGrid();
      break;
    case "scopejs_articles_edit":
    case "scopejs_articles_update":
      Rumali.newArticleCreate();
    case "scopejs_reports_show": //need to break it into 2 switch cases
      Rumali.buildCharts.loadReportChart();
    default:
  }
};










