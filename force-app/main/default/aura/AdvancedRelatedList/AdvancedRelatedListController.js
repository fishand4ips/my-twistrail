({
	doInit : function(component, event, helper) {
        var objectName = component.get('v.objectName');
        var fieldsName = component.get('v.fieldsName');
        var recordId = component.get('v.recordId');
        if(!$A.util.isEmpty(objectName) && !$A.util.isEmpty(fieldsName) && !$A.util.isEmpty(recordId)) {
            helper.doInitHelper(component, helper, recordId, objectName, fieldsName);
        }
	},
    
    editRow: function (component, event, helper) {
		var rowId = event.getSource().get('v.name');
		var records = component.get('v.records');
		var rowIndex = records.findIndex(x => x.Id === rowId);
		if (rowIndex != -1) {
			records[rowIndex].editMode = true;
		}
		component.set('v.records', records);
	},

	resetRow: function (component, event, helper) {
        var rowId = event.getSource().get('v.name');
		var resetRow;

        var recordsCopy = component.get('v.recordsCopy');
        var rowIndex = recordsCopy.findIndex(x => x.Id === rowId);
		if (rowIndex != -1)
			resetRow = JSON.parse(JSON.stringify(recordsCopy[rowIndex]));
		
		var records = component.get('v.records');
        var index = records.findIndex(x => x.Id === rowId);
		if (index != -1)
			records[index] = resetRow;

		component.set('v.records', records);
	},

	saveRow: function (component, event, helper) {
		var recordObj;
		var recordId = event.getSource().get('v.name');
		var records = component.get('v.records');
		var index = records.findIndex(x => x.Id === recordId);
		if (index != -1)
			recordObj = records[index];

		for(var i = 0; i < recordObj.record.length; i++) {
			if(recordObj.record[i].dataType == 'DATETIME') {
				recordObj.record[i].value = $A.localizationService.formatDate(recordObj.record[i].value, "yyyy-MM-dd HH:mm:ss");
			}
		}
		helper.saveRowHelper(component, recordId, recordObj);
	},
})