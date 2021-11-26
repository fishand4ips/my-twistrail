({
	doInitHelper : function(component, helper, recordId, objectName, fieldsName) {
		var isEditable = component.get('v.isEditable');
        var action = component.get('c.fetchRecords');
        action.setParams({
            'parentRecordId' : recordId,
            'sObjectName' : objectName,
            'fieldsList' : fieldsName,
            'isEdit' : component.get('v.isEditable')
        });
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
                if(!$A.util.isEmpty(result)) {
                    var records = [];
					var fieldToDTMap = new Map();
					var fieldToLDTMap = new Map();
					var fieldToEditMap = new Map();
					var fieldToPicklistValMap = new Map();
                    for(var j = 0; j < result.fieldsList.length; j++) {
						fieldToEditMap.set(result.fieldsList[j]['value'], isEditable ? result.fieldsList[j]['isEditable'] : false);
						fieldToDTMap.set(result.fieldsList[j]['value'], result.fieldsList[j]['dataType']);
						fieldToLDTMap.set(result.fieldsList[j]['value'], result.fieldsList[j]['ltngType']);
						if(result.fieldsList[j]['ltngType'] == 'picklist')
							fieldToPicklistValMap.set(result.fieldsList[j]['value'], result.fieldsList[j]['picklistValues']);
                    }
                    for(var i = 0; i < result.recordList.length; i++) {
						var cell = [];
						for(var j = 0; j < result.fieldsList.length; j++) {
							var value = '';
							var fieldAPI = result.fieldsList[j]['value'];
							for(var key in result.recordList[i]) {
								if(key == fieldAPI) {
									if(result.fieldsList[j]['dataType'] == 'TIME') {
										value = helper.convertTime(result.recordList[i][key]);
									} else {
										value = result.recordList[i][key];
									}
								}
							}
							if(fieldToLDTMap.has(result.fieldsList[j]['value']))
								cell.push({ 'label':fieldAPI, 'value':value,'isEdit':fieldToEditMap.get(fieldAPI), 'dataType':result.fieldsList[j]['dataType'], 'ltngType': result.fieldsList[j]['ltngType'], 'picklistOptions': fieldToPicklistValMap.get(fieldAPI) });
						}
                        records.push({'Id': result.recordList[i].Id, 'record':cell});
					}
                    component.set('v.fields', result.fieldsList);
                    component.set('v.records', JSON.parse(JSON.stringify(records)));
                    component.set('v.recordsCopy', JSON.parse(JSON.stringify(records)));
                }
        	} else {
				console.log(response.getError());
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
					helper.showToast('error', errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
	},

	saveRowHelper : function(component, recordId, recordObj) {
		var self = this;
		
		var recordData = {};
		recordData['Id'] = recordId;
		for(var i = 0; i < recordObj.record.length; i++) {
			if(recordObj.record[i].isEdit)
				recordData[recordObj.record[i].label] = recordObj.record[i].value;
		}

		var action = component.get('c.saveRecord');
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'recordData' : JSON.stringify(recordData)
        });
        action.setCallback(this,function(response) {
			if(response.getState() === 'SUCCESS') {
				self.showToast('Success', 'Record Updated Successfully');

				for(var i = 0; i < recordObj.record.length; i++) {
					if(recordObj.record[i].dataType == 'DATETIME') {
						recordObj.record[i].value = $A.localizationService.formatDate(recordObj.record[i].value, "yyyy-MM-ddTHH:mm:ss.000Z");
					}
				}

				var recordsCopy = component.get('v.recordsCopy');
				var rowIndex = recordsCopy.findIndex(x => x.Id === recordId);
                if (rowIndex != -1) {
                    recordObj.editMode = false;
					recordsCopy[rowIndex] = JSON.parse(JSON.stringify(recordObj));
                }
				component.set('v.recordsCopy', recordsCopy);

				var records = component.get('v.records');
				var index = records.findIndex(x => x.Id === recordId);
				if (index != -1)
				records[index].editMode = false;
				component.set('v.records', records);
			} else {
				console.log(response.getError());
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
					self.showToast('error', errors[0].message);
                }
            }
		});
        $A.enqueueAction(action);
	},

	convertTime : function(time) {
		var convertedTime = time/3600000;
		var hour = convertedTime.toString().split('.')[0];
		var minute = $A.util.isEmpty(convertedTime.toString().split('.')[1]) ? '00' : (Number(convertedTime.toString().split('.')[1]) * 60 ) / 100;
		return ((hour.length == 1) ? '0' + hour : hour) +':'+ ((minute.toString().length == 1) ? minute + '0' : minute) +':00.000Z';
	},

	showToast : function(type, message) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({ "type": type, "message": message }).fire();
	}
})