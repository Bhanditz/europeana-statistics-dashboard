Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};
//finding distinct values of the attributes from the array that is being passed.
var findDistinct = function(data,attribute_name){
	var value = [];
	value = _.map(data, function(obj){ return obj[attribute_name] });
	value = _.uniq(value);
	return value;
}
//rendering filter common function
var renderFilter = function(data,metric,id){
	var values,html_string,i,length;
	values = findDistinct(data,metric);
	length = values.length;

	if(length >= 5){
		html_string = smallDropDown(id,values,length);
	}
	else{
		html_string = largeDropDown(id,values,length);	
	}
	return html_string;
} 
//Render dropdown less than or equal to 5
var smallDropDown = function(id,values,length){
	var html_string = '<select id='+id+' class="filter">';
		for(i=0;i<length;i++){
			html_string += '<option value="'+values[i]+'">'+values[i];
		}
		html_string += '</select>';
		return html_string;
}

//Render dropdown greater than 5
var largeDropDown = function(id,values,length){
	var html_string = '<select id='+id+' class="filter">';
		for(i=0;i<length;i++){
			html_string += '<option value="'+values[i]+'">'+values[i];
		}
		html_string += '</select>';
		return html_string;
}	
