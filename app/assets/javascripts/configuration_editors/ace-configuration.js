var PykAce = {};
PykAce.element = function() {
    this.execute = function() {
        //console.log(window.data)
        var that = this;
        that.i = window.data.length;
        that.flag = false;
        that.render();
        that.displayFormElements();
     };

    this.render = function() {
        var that = this;
        that.createFormElement();
        $("#chkReqd").change(function() {
            if ($("#chkReqd").is(":checked")) {
                $("#default").val("");
                $("#default").prop("disabled", true);
            }
            else {
                $("#default").val("");
                $("#default").prop("disabled", false);
            }
        });

        $("#slugValue").keyup(function(e) {
            var textValue = $(this).val();
            
            if(e.which === 32){
                $(this).val(textValue.replace(/ /g,""));
                $(this).next("span").remove();
                $(this).after("<span class='PykAce-valid'>Space are not allowed</span>");
            }else {
                $(this).next("span").remove();
            }
            
        });

        //code for creating elements
        that.createElements = {
            text: function () {
                window.data.push({
                    id: that.i,
                    label: $("#labeltext").val(),
                    slug: $("#slugValue").val(),
                    hint: $("#helpText").val(),
                    type: $("#select1").val(),
                    subtype: $("#textproperty").val(),
                    required: $('input[type="checkbox"]:checked').val(),
                    'default': $("#default").val(),
                    'max-length': $("#maximum").val(),
                    'min-length': $("#minimum").val(),
                    'noOfRows': "",
                    'noOfCols': "",
                    'optiontext': "",
                    'optionvalue': "",
                    'value': ""
                });
            that.i++;
            return this;
            },
            textarea: function () {
                window.data.push({
                      id: that.i,
                      label: $("#labeltext").val(),
                      slug: $("#slugValue").val(),
                      hint: $("#helpText").val(),
                      type: $("#select1").val(),
                      subtype: "",
                      required: $('input[type="checkbox"]:checked').val(),
                      'default': $("#default").val(),
                      'max-length': $("#maximum").val(),
                      'min-length': $("#minimum").val(),
                      'noOfRows': $("#noOfRows").val(),
                      'noOfCols': $("#noOfCols").val(),
                      'optiontext': "",
                      'optionvalue': "",
                      'value': ""
                });
                that.i++;
                return this;
            },
            booleandata: function () {
                window.data.push({
                            id: that.i,
                            label: $("#labeltext").val(),
                            slug: $("#slugValue").val(),
                            hint: $("#helpText").val(),
                            type: $("#select1").val(),
                            subtype: "",
                            required: $('input[type="checkbox"]:checked').val(),
                            'default': $("#default").val(),
                            'max-length': "",
                            'min-length': "",
                            'noOfRows': "",
                            'noOfCols': "",
                            'optiontext': "",
                            'optionvalue': "",
                            'value': $("#yesnovalue").val()
                        });
                that.i++;
                return this;
            },
            option: function () {
                window.data.push({
                            id: that.i,
                            label: $("#labeltext").val(),
                            slug: $("#slugValue").val(),
                            hint: $("#helpText").val(),
                            type: $("#select1").val(),
                            subtype: "",
                            required: $('input[type="checkbox"]:checked').val(),
                            'default': $("#default").val(),
                            'max-length': "",
                            'min-length': "",
                            'noOfRows': "",
                            'noOfCols': "",
                            'optiontext': _.unique(abc),
                            'optionvalue':xyz,
                            'value': ""
                        });
                that.i++;
                return this;
            }
            }
            $("#save").unbind("click");
            $("#save").click( function(e) {
                that.push_data = { 
                    textarea: function() { 
                        var check = [];
                        check.push(that.validate_value("noOfRows"));
                        check.push(that.validate_value("noOfCols"));
                        check.push(that.validate_value("minimum"));
                        check.push(that.validate_value("maximum"));
                        check.push(that.validate_empty("labeltext"));
                        check.push(that.validate_unique("label","labeltext"));
                        check.push(that.validate_empty("slugValue"));
                        check.push(that.validate_unique("slug","slugValue"));
                        that.noOfRows_error();   
                        that.noOfCols_error();  
                        that.maximum_error();  
                        that.minimum_error();   
                        that.labeltext_error(); 
                        that.slugValue_error(); 
                        //console.log(check);
                        if(_.every(check,_.identity) === true){
                            that.createElements.textarea();
                            $("#display-form-elements").empty();
                            $("#displaystring").html(JSON.stringify(window.data));
                            $("#data1").html("");
                            that.displayFormElements();
                        }
                        else{
                            $("#data1").html("Invalid Form Element");
                        }

                        },
                    text: function () {
                        var check = [];
                        check.push(that.validate_value("minimum"));
                        check.push(that.validate_value("maximum"));
                        check.push(that.validate_empty("labeltext"));
                        check.push(that.validate_unique("label","labeltext"));
                        check.push(that.validate_empty("slugValue"));
                        check.push(that.validate_unique("slug","slugValue"));
                        that.maximum_error(); 
                        that.minimum_error();   
                        that.labeltext_error(); 
                        that.slugValue_error(); 
                        if(_.every(check,_.identity) === true) {
                            that.createElements.text();
                            $("#display-form-elements").empty();
                            $("#displaystring").html(JSON.stringify(window.data));
                            $("#data1").html("");
                            that.displayFormElements();
                            that.clearcache();
                            
                        }
                        else{
                            $("#data1").html("Invalid Form Element");
                        }
                        },
                    boolean: function () {
                            var check = [];
                        check.push(that.validate_value("minimum"));
                        check.push(that.validate_value("maximum"));
                        check.push(that.validate_empty("labeltext"));
                        check.push(that.validate_unique("label","labeltext"));
                        check.push(that.validate_empty("slugValue"));
                        //console.log(check); 
                        that.maximum_error(); 
                        that.minimum_error(); 
                        that.labeltext_error(); 
                        that.slugValue_error(); 
                        if(_.every(check,_.identity) === true){
                            that.createElements.booleandata();
                            $("#display-form-elements").empty();
                            $("#displaystring").html(JSON.stringify(window.data));
                            $("#data1").html("");
                            that.displayFormElements();
                            that.clearcache();
                        }
                        else{
                            $("#data1").html("Invalid Form Element");
                        }
                    },        
                }
                   that.push_data[$("#select1").val()]();  
                $("#displaystring").html(JSON.stringify(window.data));
            });        
    }

    this.clearcache = function () {
        // Clear cache of "Add form"
            $("#labeltext").val("");
            $("#helpText").val("");
            $("#slugValue").val("");
            $("#select1 option[value='text']").attr("selected", "selected");
            $("#textproperty option[value='string']").attr("selected", "selected");
            $("#noOfRows").val("");
            $("#noOfCols").val("");
            $("#default").val("");
            $("#minimum").val("");
            $("#maximum").val("");
            $("#optiontext").val("");
            $("#optionvalue").val("");

    }

    this.labeltext_error = function (id) {
        var that = this;
        if(id == undefined)
         {
            id = that.i;
         }
       // console.log(validate_unique("label","labeltext")+" "+validate_empty("labeltext"));
        if(that.validate_empty("labeltext") == false) {
            $("#labeltext").next("span").remove();
            $("#labeltext").after("<span class='PykAce-valid'>Field can't be empty</span>");
            
        } else if(that.validate_unique("label","labeltext",id) == false) {
            $("#labeltext").next("span").remove();
            $("#labeltext").after("<span class='PykAce-valid'>Field should be unique</span>");
        } else {
            $("#labeltext").next("span").remove();
        }
    };

    this.minimum_error = function () {
        var that =this;
        if(that.validate_value("minimum") == false) {
            $("#minimum").next("span").remove();
            $("#minimum").after("<span class='PykAce-valid'>Values can't be negative</span>");
            
        } else {
            $("#minimum").next("span").remove();
        }
    };

    this.maximum_error = function () {
        var that =this;
        if(that.validate_value("maximum") == false) {
            $("#maximum").next("span").remove();
            $("#maximum").after("<span class='PykAce-valid'>Values can't be negative</span>");
            
        } else {
            $("#maximum").next("span").remove();
        }
    };

    this.noOfRows_error = function () {
        
        var that = this;
        if(that.validate_value("noOfRows") == false) {
            $("#noOfRows").next("span").remove();
            $("#noOfRows").after("<span class='PykAce-valid'>Values can't be negative</span>");
            
        } else {
            $("#noOfRows").next("span").remove();
        }
    };

    this.noOfCols_error = function () {
        var that =this;
        if(that.validate_value("noOfCols") == false) {
            $("#noOfCols").next("span").remove();
            $("#noOfCols").after("<span class='PykAce-valid'>Values can't be negative</span>");
            
        } else {
            $("#noOfCols").next("span").remove();
            }
    };

    this.slugValue_error = function (id) {
        var that =this;
         if(id == undefined)
         {
            id = that.i;
         }
        if($("#select1").val() !== "boolean") {
            if(that.validate_empty("slugValue") == false) {
                //console.log(1);
                $("#slugValue").next("span").remove();
                $("#slugValue").after("<span class='PykAce-valid'>Field can't be empty</span>");
                
            } else if(that.validate_unique("slug","slugValue",id) == false) {
                //console.log(2);
                $("#slugValue").next("span").remove();
                $("#slugValue").after("<span class='PykAce-valid'>Field should be unique</span>");
            } else {
                //console.log(3);
                $("#slugValue").next("span").remove();
            }
        } else {
            if(that.validate_empty("slugValue") == false) {
                $("#slugValue").next("span").remove();
                $("#slugValue").after("<span class='PykAce-valid'>Field can't be empty</span>");
                
            }else if(that.validate_value("slugValue") == false) {
                $("#slugValue").next("span").remove();
                $("#slugValue").after("<span class='PykAce-valid'>Values can't be negative</span>");
            } else {
                $("#slugValue").next("span").remove();
            }    
        }   
    };


    this.validate_empty = function (id) {
        
        if($.trim($("#"+id).val()) == "") {
            return false;
        } else {
            return true;
        }
    }

    this.validate_unique = function (attribute,id,current_element) {
        var that = this;
        that.flag = true;
       // console.log("cur"+current_element+"---"+"id"+id)
        if(current_element === undefined) {
            if(window.data.length > 0) {
                var j = -1;
                _.each(window.data,function(a,i) {
                    //console.log(a[attribute]+"  "+$("#"+id).val());
                    if(a[attribute] == $("#"+id).val()) {
                        that.flag = false;
                        j = i;
                    }
                    else{
                        if(j == -1){ 
                            that.flag = true;
                        }
                    }
                });
            }
        } else {
            if(window.data.length > 0 ) {
                var j = -1;
                _.each(window.data,function(a,i) {
                    // console.log("current "+current_element+"i--"+i);
                    if(a[attribute] == $("#"+id).val() && current_element != i) {
                        that.flag = false;
                        j = i;
                    }
                    else{
                        if(j == -1){ 
                            that.flag = true;
                        }
                    }
                });
            }
        }
        return that.flag;
    }

    this.validate_value = function (id) {
      if($("#"+id).val() < 0) {
        return false;
      }
      else {
        return true;
      }
    };

    this.createFormElement = function(){
        var that = this;
        $("#noOfRows").blur( function() {   
         that.noOfRows_error(); 
        });
        $("#noOfCols").blur( function() {   
         that.noOfCols_error(); 
            });
        $("#maximum").blur( function() {   
         that.maximum_error(); 
        });
        $("#minimum").blur( function() {   
         that.minimum_error(); 
        });
        $("#labeltext").blur( function() {   
         that.labeltext_error(); 
        });
        $("#slugValue").blur( function() {   
         that.slugValue_error(); 
        });

        $("#select1").change(function (e) {
            $("#defaultTextDiv").css("display","none");
            $("#valueDiv").css("display","none");
            $("#textDiv").css("display","none");
            $("#noOfRowsDiv").css("display","none");
            $("#noOfColsDiv").css("display","none");
            $("#minLenDiv").css("display","none");
            $("#maxLenDiv").css("display","none");
            $("#optionValueDiv").css("display","none");
            $("#optionTextDiv").css("display","none");
            $("#yesNoDiv").css("display","none");
            if ($("#select1").val() === "text") { // Text Input
                $("#defaultTextDiv").css("display","block");
                $("#textproperty").prop("disabled",false);
                $("#minLenDiv").css("display","block");
                $("#maxLenDiv").css("display","block");
                
            }
            else {
                $("#textproperty option[value='string']").attr("selected",true);
                $("#textproperty").prop("disabled",true);
            }

            if ($("#select1").val() === "option") { // Select-Option Dropdown
                $("#optiontext").prop("placeholder","eg: abc;xyx");
                $("#optionValueDiv").css("display","block");
                $("#optionTextDiv").css("display","block");
                
            }

            if($("#select1").val() === "textarea") { // TextArea Input
                $("#defaultTextDiv").css("display","block");
                $("#noOfRowsDiv").css("display","block");
                $("#noOfColsDiv").css("display","block");
                $("#minLenDiv").css("display","block");
                $("#maxLenDiv").css("display","block");
                
            }
            else{
                $("#noOfRowsDiv").css("display","none");
                $("#noOfColsDiv").css("display","none");
            }
            
            if($("#select1").val() === "boolean") { // Radio-button Boolean
                $("#defaultTextDiv").css("display","none");
                $("#yesNoDiv").css("display","block");
            }
        });
    }

    // this.displayElements = {
    //     div:function(element,id,class,value) { 
    //         $("#display-form-elements")
    //         .append("<div id='div"+id+"' class='form-group'></div>");
    //         },
    //     label:function(element,id,class,value) {
    //         $("#div"+i)
    //         .append("<label id='label"+id+"' class='col-sm-2 control-label' value='"+d.label+"'>"+d.label+"</label>");    
    //         },
    //     text: function(element,id,class,value) {
    //         $("#indiv"+i)
    //         .append("<input type='"+d.subtype+"' id='"+d.id+"' name='"+d.slug+"' value='"+d.value+"' class='form-control' placeholder='"+d.hint+"' maxlength='"+d["max-length"]+"' minlength='"+d["min-length"]+"' required >");
    //     },
    // }
    

    this.displayFormElements = function() {
        //console.log("yeeep");
        var that = this;
        that.boolSlugArr = [];
        that.obj = window.data;
        $("#display-form-elements").empty();
        // Displaying elements
        _.each(that.obj, function (d, i) {
        that.str = "";
        $("#display-form-elements").append("<div id='div"+i+"' class='form-group'></div>");
        $("#div"+i).append("<label id='label"+i+"' class='col-sm-2 control-label' value='"+d.label+"'>"+d.label+"</label>");
        $("#div"+i).append("<div id='indiv"+i+"' class='col-sm-7'></div>");
            
        if(d.type === "text") {

            $("#indiv"+i).append("<input type='"+d.subtype+"' id='"+d.id+"' name='"+d.slug+"' value='"+d.value+"' class='form-control' placeholder='"+d.hint+"' maxlength='"+d["max-length"]+"' minlength='"+d["min-length"]+"'readonly >");
            }
        else if (d.type === "textarea") {
            $("#indiv"+i).append("<textarea id='"+d.id+"' name='"+d.slug+"' class='form-control' placeholder='"+d.hint+"' maxlength='"+d["max-length"]+"' minlength='"+d["min-length"]+"' rows='"+d.noOfRows+"' cols='"+d.noOfCols+"'readonly></textarea>");
        } else if (d.type === "option") {

            $("#indiv"+i).append("<select id='"+d.id+"' class='form-control' name='"+d.slug+"'></div>");

            _.each(d.optiontext,function (p,j) {
              if(d.default === d.optionvalue[j]){
                $("#"+d.id).append("<option value='"+d.optionvalue[j]+"' selected='selected'>"+p+"</option>");
              }
              else{
                $("#"+d.id).append("<option value='"+d.optionvalue[j]+"'>"+p+"</option>");
              }
            });
        } else if (d.type === "boolean") {
                if(d.value === "yes") {
                    $("#indiv"+i).append("<input type=radio id='"+d.id+"'checked ='"+"true"+"'value ='"+"yes"+"'disabled = true>"+"YES");
                    $("#indiv"+i).append("<input type=radio id='"+d.id+"'value ='"+"no"+"'disabled = true>"+'NO');
                } else {
                    $("#indiv"+i).append("<input type=radio id='"+d.id+"'value ='"+"yes"+"'disabled = true>"+"YES");
                    $("#indiv"+i).append("<input type=radio id='"+d.id+"'checked ='"+"true"+"'value ='"+"no"+"'disabled = true>"+'NO');
                }
            
        }
        $("#div"+i).append("<span id='editbtn-"+i+"' class='glyphicon glyphicon-pencil edit-config'/> &nbsp &nbsp");
        $("#div"+i).append("<span id='deletebtn-"+i+"' class='glyphicon glyphicon-remove'/> "); 
        
      
    });

        $(".edit-config").unbind("click");
        $(".edit-config").click(function() {
            var id = $(this).attr("id").split("-")[1];
            that.editFormElement(id);
            $("#save").css("display","none");
            $("#edit").css("display","block");
        });
        $(".glyphicon-remove").unbind("click");
        $(".glyphicon-remove").click(function() {
            var id = $(this).attr("id").split("-")[1];
            that.removeFormElement(id);
        });
    };
    this.removeFormElement = function(deleteId){
        that=this;
            window.data.splice(deleteId,1);
            that.displayFormElements();
            that.clearcache();
    }

    this.editFormElement = function(editId) {
    var that = this;

    $("#edit-form-elements h1").html("Modify Element");
    $("#labeltext").val(window.data[editId].label);
    $("#helpText").val(window.data[editId].hint);
    $("#slugValue").val(window.data[editId].slug);
    $("#select1 option[value="+window.data[editId].type+"]").attr("selected","selected");
    $("#textproperty option[value="+window.data[editId].subtype+"]").attr("selected","selected");
    $("#noOfRows").val(window.data[editId].noOfRows);
    $("#noOfCols").val(window.data[editId].noOfCols);
    $("#default").val(window.data[editId]['default']);
    $("#minimum").val(window.data[editId]['min-length']);
    $("#maximum").val(window.data[editId]['max-length']);
    $("#optiontext").val(window.data[editId].optiontext);
    $("#optionvalue").val(window.data[editId].optionvalue);

    // $("#edit-form-elements").css("display","block");
    $("#select1").change();
    that.doneElements(editId);
    }

    this.doneElements = function(current_element) {
        var that =this;
        $("#noOfRows").unbind("blur");
        $("#noOfCols").unbind("blur");
        $("#maximum").unbind("blur");
        $("#minimum").unbind("blur");
        $("#labeltext").unbind("blur");
        $("#slugValue").unbind("blur");
        $("#edit").unbind("click");
        $("#edit").click( function(e) {
            var check = [];
            //console.log($("#select1").val());
            if($("#select1").val() === "textarea"){
                    var check = [];
                    check.push(that.validate_value("noOfRows"));
                    check.push(that.validate_empty("noOfCols"));
                    check.push(that.validate_empty("noOfRows"));
                    check.push(that.validate_value("noOfCols"));
                    check.push(that.validate_value("minimum"));
                    check.push(that.validate_value("maximum"));
                    check.push(that.validate_empty("labeltext"));
                    check.push(that.validate_unique("label","labeltext",current_element));
                    check.push(that.validate_empty("slugValue"));
                    check.push(that.validate_unique("slug","slugValue",current_element));
                    that.noOfRows_error(); 
                    that.noOfCols_error(); 
                    that.maximum_error(); 
                    that.minimum_error(); 
                    that.labeltext_error(current_element); 
                    that.slugValue_error(current_element); 

                if(_.every(check,_.identity) === true) {
                    _.each(window.data, function(a,m) {
                        if(m === parseInt(current_element))  {

                    window.data[m].label = $("#labeltext").val();
                    window.data[m].slug = $("#slugValue").val();
                    window.data[m].hint = $("#helpText").val();
                    window.data[m].type = $("#select1").val();
                    window.data[m].required = $('input[type="checkbox"]:checked').val();
                    window.data[m]['default'] = $("#default").val();
                    window.data[m]['max-length'] = $("#maximum").val();
                    window.data[m]['min-length'] = $("#minimum").val();
                    window.data[m].noOfRows = $("#noOfRows").val();
                    window.data[m].noOfCols = $("#noOfCols").val();
                    window.data[m].value = $("#"+current_element).val();;
                  }
                });
                $("#display-form-elements").empty();
                $("#displaystring").html(JSON.stringify(window.data));
                that.displayFormElements();
                that.clearcache();
                $("#save").css("display","block");
                $("#edit").css("display","none");
                }
              else {
                $("#data1").html("Invalid Form Element");
              }
            } else if($("#select1").val() === "boolean") {

                    var check = [];
                    check.push(that.validate_value("minimum"));
                    check.push(that.validate_value("maximum"));
                    check.push(that.validate_empty("labeltext"));
                    check.push(that.validate_unique("label","labeltext",current_element));
                    check.push(that.validate_empty("slugValue"));
                     
                     that.maximum_error(); 
                       
                     that.minimum_error(); 
                      
                     that.labeltext_error(current_element); 
                      
                     that.slugValue_error(); 
                  if(_.every(check,_.identity) === true){
                    _.each(window.data, function(a,m){
                      if(m === parseInt(current_element)){
                        window.data[m].label = $("#labeltext").val();
                        window.data[m].slug = $("#slugValue").val();
                        window.data[m].hint = $("#helpText").val();
                        window.data[m].type = $("#select1").val();
                        window.data[m].required = $('input[type="checkbox"]:checked').val();
                        window.data[m]['default'] = $("#default").val();
                        window.data[m].value = $("#yesnovalue").val();
                      }
                    });
                    $("#display-form-elements").empty();
                    $("#displaystring").html(JSON.stringify(window.data));
                    that.displayFormElements();
                    that.clearcache();
                    $("#save").css("display","block");
                    $("#edit").css("display","none");
                   
                  }
                  else{
                    $("#data1").html("Invalid Form Element");
                  }
            } else if($("#select1").val() === "text") {
                    var check = [];
                    check.push(that.validate_value("minimum"));
                    check.push(that.validate_value("maximum"));
                    check.push(that.validate_empty("labeltext"));
                    check.push(that.validate_unique("label","labeltext",current_element));
                    check.push(that.validate_empty("slugValue"));
                    check.push(that.validate_unique("slug","slugValue",current_element));
                    //console.log(check+"----"+current_element+"---");
                     that.maximum_error(); 
                      
                     that.minimum_error(); 
                      
                     that.labeltext_error(current_element); 
                       
                     that.slugValue_error(current_element); 
                    if(_.every(check,_.identity) === true){
                         _.each(window.data, function(a,m){
                            if(m === parseInt(current_element)){
                                window.data[m].label = $("#labeltext").val();
                                window.data[m].slug = $("#slugValue").val();
                                window.data[m].hint = $("#helpText").val();
                                window.data[m].type = $("#select1").val();
                                window.data[m].subtype = $("#textproperty").val();
                                window.data[m].required = $('input[type="checkbox"]:checked').val();
                                window.data[m]['default'] = $("#default").val();
                                window.data[m]['max-length'] = $("#maximum").val();
                                window.data[m]['min-length'] = $("#minimum").val();
                                window.data[m].value = $("#"+current_element).val();;
                            }
                        });
                        $("#display-form-elements").empty();
                        $("#displaystring").html(JSON.stringify(window.data));
                        that.displayFormElements();
                        that.clearcache();
                        $("#save").css("display","block");
                        $("#edit").css("display","none");
                                
                            }
                    else {
                        $("#data1").html("Invalid Form Element");
                    }
            } else if($("#select1").val() === "option") {
                    var check = [];
                    check.push(that.validate_value("minimum"));
                    check.push(that.validate_value("maximum"));
                    check.push(that.validate_empty("labeltext"));
                    check.push(that.validate_unique("label","labeltext"));
                    check.push(that.validate_empty("slugValue"));
                    check.push(that.validate_unique("slug","slugValue"));
                    that.maximum_error(); 
                    that.minimum_error(); 
                    that.labeltext_error(); 
                    that.slugValue_error();
                      var abc = $("#optiontext").val().split(";");
                      var xyz = $("#optionvalue").val().split(";");
                      if(_.every(check,_.identity) === true){
                        _.each(window.data, function(a,m){
                          if(m === parseInt(current_element)){
                            window.data[m].label = $("#labeltext").val();
                            window.data[m].slug = $("#slugValue").val();
                            window.data[m].hint = $("#helpText").val();
                            window.data[m].type = $("#select1").val();
                            window.data[m].subtype = "";
                            window.data[m].required = $('input[type="checkbox"]:checked').val();
                            window.data[m]['default'] = $("#default").val();
                            window.data[m]['max-length'] = "";
                            window.data[m]['min-length'] = "";
                            window.data[m].noOfRows = "";
                            window.data[m].noOfCols = "";
                            window.data[m].optiontext = _.unique(abc);
                            window.data[m].optionvalue = xyz;
                            window.data[m].value = $("#"+current_element).val();
                          }
                        });
                      $("#display-form-elements").empty();
                        $("#displaystring").html(JSON.stringify(window.data));
                        that.displayFormElements();
                        that.clearcache();
                        $("#save").css("display","block");
                        $("#edit").css("display","none");
                        
                      }
                      else{
                        $("#data1").html("Invalid Form Element");
                      }
            }

        });

    }

      

}

PykAce.showPage = function() {

    this.showElements = function () {

        var that = this;
        that.boolSlugArr = [];
        that.obj = window.data;
        $("#display-form-elements").empty();
        // Displaying elements
        _.each(that.obj, function (d, i) {
        that.str = "";
        $("#display-form-elements").append("<div id='div"+i+"' class='form-group'></div>");
            $("#div"+i).append("<label id='label"+i+"' class='col-sm-2 control-label' value='"+d.label+"'>"+d.label+"</label>");
            $("#div"+i).append("<div id='indiv"+i+"' class='col-sm-7'></div>");
        if(d.type === "text") {
            if(d.required === "true") {
              $("#indiv"+i).append("<input type='"+d.subtype+"' id='"+d.id+"' name='"+d.slug+"' value=\""+d.value+"\" class='form-control' placeholder='"+d.hint+"' maxlength='"+d["max-length"]+"' minlength='"+d["min-length"]+"' required >");
            }
            else{
              $("#indiv"+i).append("<input type='"+d.subtype+"' id='"+d.id+"' name='"+d.slug+"' value=\""+d.value+"\" class='form-control' placeholder='"+d.hint+"' maxlength='"+d["max-length"]+"' minlength='"+d["min-length"]+"'>");
            }
        }
        else if (d.type === "textarea") {
            
            if(d.required === "true"){
             $("#indiv"+i).append("<textarea id='"+d.id+"' name='"+d.slug+"' value='"+d.value+"' class='form-control' placeholder='"+d.hint+"' maxlength='"+d["max-length"]+"' minlength='"+d["min-length"]+"' rows='"+d.noOfRows+"' cols='"+d.noOfCols+"'>"+d.value+"</textarea>");
            }
            else{
                $("#indiv"+i).append("<textarea id='"+d.id+"' name='"+d.slug+"' value='"+d.value+"' class='form-control' placeholder='"+d.hint+"' maxlength='"+d["max-length"]+"' minlength='"+d["min-length"]+"' rows='"+d.noOfRows+"' cols='"+d.noOfCols+"'>"+d.value+"</textarea>");
            }
        } else if (d.type === "option") {

            $("#indiv"+i).append("<select id='"+d.id+"' class='form-control' name='"+d.slug+"'></div>");

            _.each(d.optiontext,function (p,j) {
              if(d.default === d.optionvalue[j]){
                $("#"+d.id).append("<option value='"+d.optionvalue[j]+"' selected='selected'>"+p+"</option>");
              }
              else{
                $("#"+d.id).append("<option value='"+d.optionvalue[j]+"'>"+p+"</option>");
              }
            });
        } else if (d.type === "boolean") {
            if(d.value === "yes") {
                    $("#indiv"+i).append("<input type=radio id='"+d.id+"' name='"+d.slug+"'checked ='"+"true"+"'value ='"+"yes"+"'>"+"YES");
                    $("#indiv"+i).append("<input type=radio id='"+d.id+"' name='"+d.slug+"'value ='"+"no"+"'>"+'NO');
                } else {
                    $("#indiv"+i).append("<input type=radio id='"+d.id+"' name='"+d.slug+"'value ='"+"yes"+"'>"+"YES");
                    $("#indiv"+i).append("<input type=radio id='"+d.id+"' name='"+d.slug+"'checked ='"+"true"+"'value ='"+"no"+"'>"+'NO');
                }
          } 
        });
        that.updateValue();
    }

    this.updateValue = function() {
        var that =this;
        $("#pressbutton").click(function() {      
        _.each(that.obj, function (d, i) { 
            if(d.type !== "boolean"){ 
                d.value = $("#"+d.id).val();
            } else {
                d.value = $("input[type='radio'][name='"+"hope_so"+"']:checked").val();
            }
            

            
        });
        $("#content").val(JSON.stringify(window.data));
        });  
       // console.log(JSON.stringify(window.data));


    } 

}