var app = angular.module('GeneralBatchApp', []);
// create factory service for App
app.factory('sf', BaseFactory);

app.directive('jsonValidation', function(){
	// Runs during compile
	return {
		
		require: 'ngModel',
		link: function(scope, element, attr, ngModel) {
			ngModel.$parsers.push(function(data) {
				var jsonString;

				try{
					jsonString = JSON.parse(data);
				}
				catch (e) {
					ngModel.$setValidity('invalid_json', false);
				}

				if (jsonString && typeof jsonString === 'object') {
					ngModel.$setValidity('invalid_json', true);
					return data;
				}
				
			});
		}
	};
});

// call action from controller
app.controller('GeneralBatchController', function ($scope, sf) {
	$scope.errMsgs = [];

	$scope.showModalConfirm = false;

	$scope.steps = ['general-json','select-key','select-field'];
	$scope.flagChange = false;
	$scope.currentStep= 1;

	$scope.obj = {};
	$scope.obj.jsonString = null;
	$scope.obj.className = 'API_Wrapper';
	$scope.obj.batchName = 'migrateDataApiBatch';
    $scope.editorOptions = {
        lineWrapping: true,
        lineNumbers: true,
        mode: 'scheme',
    };
    $scope.showError = false;
    $scope.isLoading = false;
    $scope.divField = [1];
    $scope.divFieldItem = 1;

    //Block mapping key
    $scope.lastMappingKey = 1;
    $scope.divMappingKey = {};
    $scope.keyMappingField = [];
    $scope.operator = 'AND';
    $scope.showMappingCondition = false;

    //Block mapping field
    $scope.lastMappingField = 1;
    $scope.divMappingField = {};
    $scope.lstMappingField = [];

    //List Sobject
   	$scope.sObject = [];
   	$scope.jsonObject = [];
   	//Mapping object
   	$scope.mappingObj = null;
   	$scope.mappingLstField = [];
    // List field Key for async
    $scope.fieldData3th = [];

    $scope.generalBatchCall = function () {
    	$scope.isLoading = true;
    	$scope.flagChange = true;

    	if ($scope.general_form.$invalid) {
    		$scope.isLoading = false;
    		return;
    	}

    	if ($scope.obj.className == '' || $scope.obj.jsonString == '') {
    		$scope.showError = true;
    		$scope.isLoading = false;
    		return false;
    	}

    	sf.callRemoteActionWithParameter('Tools_GeneralBatchCC.getGeneralJson',JSON.stringify($scope.obj)).then(function(result){
            if (result.isSuccess) {
            	$scope.isLoading = false;
            	$scope.fieldData3th = result.data.jsonData;
            	$scope.sObject = result.data.currentObjOrg;
            	$scope.jsonObject = result.data.jsonObj;

    			$scope.changeStep(1);	
            } else {
            	$scope.errMsgs = result.errorMessage;
            	$scope.showError = true;
            	$scope.isLoading = false;
            }
        });
    }

    $scope.getlstFields = function () {
    	$scope.mappingObj = $('#select-sobject').val();
    	
    	if ($scope.mappingObj != null) {
    		$scope.isLoading = true;
    		sf.callRemoteActionWithParameter('Tools_GeneralBatchCC.getCurrentLstField',$scope.mappingObj).then(function(result){
            	if (result.isSuccess) {
	            	$scope.isLoading = false;
	            	$scope.mappingLstField = result.data;
	            	$scope.mappingJsonField = fillJsonField($('#select-json-object').val());
	    			$scope.divMappingKey['key-'+$scope.lastMappingKey] = {};
	            } else {
	            	$scope.errMsgs = result.errorMessage;
	            	$scope.showError = true;
	            	$scope.isLoading = false;
	            }
        	});
    	}
    }

    //Add div mapping key
    $scope.addDivMapping = function() {
    	$scope.lastMappingKey = $scope.lastMappingKey + 1;
    	$scope.divMappingKey['key-'+$scope.lastMappingKey] = {};

    	$scope.showMappingCondition = true;
    }

    //Delete div mapping key
    $scope.deleteDivMapping = function(key) {
    	delete $scope.divMappingKey[key];

    	if (Object.keys($scope.divMappingKey).length == 1) {
    		$scope.showMappingCondition = false;
    	}
    }

    //Add div mapping field
    $scope.addDivMappingField = function() {
    	$scope.lastMappingField = $scope.lastMappingField + 1;
    	$scope.divMappingField['field-'+$scope.lastMappingField] = {};
    }

    //Delete div mapping field
    $scope.deleteDivMappingField = function(key) {
    	delete $scope.divMappingField[key];
    }

    $scope.getAsyncKeyMapLst = function () {
    	$scope.flagChange = true;
    	var isError = false;
    	$scope.keyMappingField = [];
    	if ($scope.mappingObj == '') {
    		isError = true;
    	}
    	angular.forEach($scope.divMappingKey, function(value, key) {
			if (value.jsonKey == undefined || value.objKey == undefined) {
				isError = true;
				value.errMsg = 'Please select at least one key to perform the mapping data';
			} else if (JSON.parse(value.jsonKey).dataType != JSON.parse(value.objKey).dataType) {
				isError = true;
				value.errMsg = 'datatype does not coincide with each other';
			} else if (value.jsonKey != null || value.objKey != null) {
				value.errMsg = null;
				$scope.keyMappingField.push({'jsonKey': value.jsonKey, 'objKey': JSON.parse(value.objKey).apiName});
			}
		});
    	
    	if (!isError) {
    		$scope.divMappingField['field-'+$scope.lastMappingField] = {};
    		$scope.changeStep(1); 
    	}
    }


    $scope.getAsyncFieldMapLst = function () {
    	$scope.flagChange = true;
    	var isError = false;
    	$scope.lstMappingField = [];
    	angular.forEach($scope.divMappingField, function(value, key) {
			if (value.jsonField == undefined || value.objField == undefined) {
				isError = true;
				value.errMsg = 'Please select at least one field to perform the mapping data';
			} else if (JSON.parse(value.jsonField).dataType != JSON.parse(value.objField).dataType) {
				isError = true;
				value.errMsg = 'datatype does not coincide with each other';
			} else if (value.jsonField != null || value.objField != null) {
				value.errMsg = null;
				$scope.lstMappingField.push({'jsonField': value.jsonField, 'objField': JSON.parse(value.objField).apiName});
			}
		});
    	
    	if (!isError) {
    		$scope.showModalConfirm = true; 
    	}
    }

    $scope.closeErrorBox = function () {
    	$scope.showError = false;
    }

    $scope.hideModalConfirm = function() {
    	$scope.showModalConfirm = false; 
    }

    $scope.setValueOperator = function (value) {
    	$scope.operator = value;
    }

    $scope.finalStep = function() {
    	var re = new RegExp("^[a-zA-Z]([a-zA-z0-9_]){2,}$");
		if (re.test($scope.obj.batchName)) {
		    $scope.batchNameErr = null;
		    var param = {
		    	'wrapperClass' : $scope.obj.className,
		    	'jsonObjMapping' : $('#select-json-object').val(),
		    	'objMapping' : $scope.mappingObj,
		    	'className' : $scope.obj.batchName,
		    	'isRunAfterGen' : true,
		    	'mappingCondition' : $scope.operator,
		    	'lstMappingObj' : $scope.keyMappingField,
		    	'lstMappingField' : $scope.lstMappingField
		    };

		    sf.callRemoteActionWithParameter('Tools_GeneralBatchCC.generalBatchClass',JSON.stringify(param)).then(function(result){
            	if (result.isSuccess) {
	            	$scope.isLoading = false;
	            	$scope.showModalConfirm = false;
	            	alert('Create batch success');
	            } else {
	            	$scope.errMsgs = result.errorMessage;
	            	$scope.showError = true;
	            	$scope.isLoading = false;
	            }
        	});
		} else {
		    $scope.batchNameErr = 'Batch name Invalid';
		}
    }

	$scope.getCurrentStep = function(){
		var next = true;
		var current = $('.slds-is-current').attr('class');
		angular.forEach($scope.steps,function(v,k){
			if(next){
				if(current.indexOf(v)>-1){
					next = false;
					$scope.currentStep = k;
				}
			}
		});
	}

	//switch to next step
	$scope.changeStep = function(i){
		$scope.getCurrentStep();
		var index = $scope.currentStep;
		$scope.orgSelected = false;	
		$scope.flagChange = false;
		if(index+i==0){
			$(".btnBack").prop("disabled", true);
		}else{
			$(".btnBack").prop("disabled", false);
		}
		if(index+i==4){
			$scope.orgSelected = true;
			$(".btnNext").prop("disabled", true);
		}else{
			$(".btnNext").prop("disabled", false);
		}				
		angular.forEach($scope.steps,function(v,k){
			if(k<index + i){
				// complete current step				
				$('.'+v).removeClass('slds-is-current');
				$('.'+v).addClass('slds-is-complete');
				// hide all step
				$('#'+v).addClass('slds-hide');
				$('#'+v).removeClass('slds-show');								
			}
		});
		// if back clear current step
		if(i==-1){
			var current = $scope.steps[index];
			//clear currentstep
			$('.'+current).removeClass('slds-is-current');
			$('.'+current).addClass('slds-is-incomplete');
			$('#'+current).addClass('slds-hide');
			$('#'+current).removeClass('slds-show');
		}
		// swith to target step
		var step = $scope.steps[index+i];
		$('.'+step).removeClass('slds-is-incomplete');
		$('.'+step).removeClass('slds-is-complete');
		$('.'+step).addClass('slds-is-current');
		$('#'+step).removeClass('slds-hide');
		$('#'+step).addClass('slds-show');
		$('.showStep').show();
		$('.step-title').html(step);
	}

	function fillJsonField(jsonObj){
		var lstItem = [];
		angular.forEach($scope.fieldData3th,function(v,k){
			if (jsonObj.indexOf(v.jsonType) !== -1) {
				if (v.dataType != 'List' && v.dataType != 'Object') {
					lstItem[v.key] = v;
				} else if ( v.dataType == 'Object') {} {
					lstItem.push.apply(lstItem,fillJsonField([v.jsonVariable]));
				}
			}
		});

		return lstItem;
	}
});