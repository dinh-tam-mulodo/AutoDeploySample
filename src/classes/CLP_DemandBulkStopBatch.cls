/**
 * CLP_DemandBulkStopBatch.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_DemandBulkStopBatch class
 */
global with sharing class CLP_DemandBulkStopBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
	global Boolean shouldStop = false;	
	global Boolean raiseError = false;
    global String sql;
    global String cntsql;

	public CLP_DemandBulkStopBatch() {
		
	}

	// start batch with check duplicate running 
	public static Id startBatch(Boolean checkRunning)
    {
        if (checkRunning)
        {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_DemandBulkStopBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            if (aajList.size() != 0) {
                return null;
            }
        }
        
        CLP_DemandBulkStopBatch processor = new CLP_DemandBulkStopBatch();
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }
    /*
        Start Batch Bulk Stop Demand
        Query condition:
        1. ManipulateStatus__c = 2 (CLP_MikataConstant.DEMAND_LINK_AWAITING)
        2. StopFlg__c = 0 (CLP_MikataConstant.FLG_STOP)
        3. AwaitingGetNewInfo__c = false
    */
    global Database.querylocator start(Database.BatchableContext BC)
    {
    	String[] fieldsArray = new String[]{
    		'Id','Name','Account__r.SeikyusakiCode__c','StopFlg__c','DemandDetailCode__c','IsStop__c','LastModifiedById'
    	};
    	String fields = String.join(fieldsArray,',');
    	this.sql = String.format('Select {0} from DemandDetail__c where ManipulateStatus__c = \'\'{1}\'\' and StopFlg__c = \'\'{2}\'\' and AwaitingGetNewInfo__c = false order by LastModifiedDate  asc'
    			,new String[]{String.escapeSingleQuotes(fields),String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING),String.escapeSingleQuotes(CLP_MikataConstant.FLG_STOP)});
    	this.cntsql = String.format('Select count() from DemandDetail__c where ManipulateStatus__c = \'\'{0}\'\' and StopFlg__c = \'\'{1}\'\' and AwaitingGetNewInfo__c = false'
                ,new String[]{String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING),String.escapeSingleQuotes(CLP_MikataConstant.FLG_STOP)});
    	 //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_DemandBulkStopBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            shouldStop=true;
        }
    	return Database.getQueryLocator(this.sql);
    }
    /*
        Execute Batch Bulk Stop Demand
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	try{
	    	List<DemandDetail__c> demandList = (List<DemandDetail__c>) scope;
	    	system.debug('demandList: '+ demandList);
	    	if(!demandList.isEmpty()){
	    		CLP_MikataApi mikataApi = new CLP_MikataApi();
	    		//  call to api stop
	    		CLP_BulkDemandWrapper result = CLP_MikataDemandAPI.demandBulkStop(demandList);
	    		// call api success
	    		if(result.success){
                    // map data from api into demand List 
                    changeDemandStatus(demandList, result.demand);
    			}else{ // error HTTP Interface
    			    for(DemandDetail__c dd : demandList){
                        Logger__c log = createLogger(dd,null);
                        log.Operation__c = CLP_Logger.L_ACCESS;

                        dd.ErrorMessage__c = result.error_message;
                        dd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                        // reset stop flag
                        dd.StopFlg__c = null;
                        // add log
                        CLP_Logger.log(log);
                    }
    			}
    			// update demand
                updateDemandList(demandList);	    	
	    	}	    	
		}catch(Exception ex){
			raiseError = true;
			CLP_Logger.log(ex.getMessage(),Label.CLP_DemandBulkStopBatchLabel);
		}
        // insert log
        CLP_Logger.flush();
    }
    /*
        finish this batch send email and recall batch if was exist batch in queue
    */
    global void finish(Database.BatchableContext BC)
    {
    	CLP_MikataAPI.sendEmailComplete('CLP_SendLogEmail',Label.CLP_DemandBulkStopBatchLabel);
    	if(raiseError){            
    		return;
    	}
    	// if exist record need to register to mikata ==> call batch again
    	if(Database.countQuery(this.cntsql)>0){
    	 	// run batch again
    	 	if(!Test.isRunningTest() && !shouldStop) {
                startBatch(true);
            }
    	}

    	// if more than 2 job started at the same time ==> abort all job
    	if(shouldStop){
    		for(AsyncApexJob aaj : [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_DemandBulkStopBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
    	}

    	// send email
    }    
    /* 
        PRIVATE METHOD
    */
    //update demand status with mapping data from api
    private void changeDemandStatus(List<DemandDetail__c> demandList,List<CLP_BulkDemandWrapper.Demand> apiDemands){
        // loop demand and update demandDetail to success
        for(CLP_BulkDemandWrapper.Demand apiDemand : apiDemands){                        
            for(DemandDetail__c sfdcDemand : demandList){
                if(apiDemand.number_Z== sfdcDemand.DemandDetailCode__c){
                    // create log
                    Logger__c log = createLogger(sfdcDemand,apiDemand);
                    // register success
                    if(String.isBlank(apiDemand.error_code))
                    {
                        sfdcDemand.ErrorMessage__c = '';
                        sfdcDemand.IsStop__c = true;
                        sfdcDemand.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
                        // add log sucess
                        //log.Operation__c = CLP_Logger.L_SUCCESS;
                        //CLP_Logger.log(log);
                    }else{ 
                        if(apiDemand.error_message.toLowerCase().contains(CLP_MikataApi.HTTP_CONNECTION_ERROR)){
                            log.Operation__c = CLP_Logger.L_ACCESS;
                            sfdcDemand.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                        }// data error
                        else{
                            log.Operation__c = CLP_Logger.L_OUTBOUND;
                            sfdcDemand.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                        }
                        // get api error
                        //sfdcDemand.ErrorMessage__c = apiDemand.error_message;
                        //reset stop flag when integrated bulk stop failed
                        sfdcDemand.StopFlg__c = null;
                        CLP_Logger.log(log); 
                    }                                                               
                    break;
                }
            }
        }
    }
    // create logger
    private Logger__c createLogger(DemandDetail__c sfdcDemand,CLP_BulkDemandWrapper.Demand apiDemand){
        Logger__c log = new Logger__c();                                
        log.LK_RelatedUser__c = sfdcDemand.LastModifiedById;
        log.LK_DemandDetail__c = sfdcDemand.Id;
        log.Content__c = apiDemand != null ? apiDemand.error_message : '';
        log.Origin__c  = Label.CLP_DemandBulkStopBatchLabel;
        log.Request__c = sfdcDemand !=null ? CLP_MikataDemandAPI.getApiRequest(sfdcDemand,CLP_MikataApi.ApiType.F_STOP) : '';
        log.Response__c = apiDemand != null ? CLP_MikataDemandAPI.getApiResponse(apiDemand) : '';
        log.Operation__c = CLP_Logger.L_OUTBOUND;
        return log;
    }
    // update demand detail list
    private void updateDemandList(List<DemandDetail__c> demandList){
        String[] listField = new String[]{'ErrorMessage__c','IsStop__c', 'ManipulateStatus__c','StopFlg__c'};
        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_DEMAND_DETAIL,listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){                
            // update demand
            Database.SaveResult[] resultList = Database.update(demandList,false);
            for (Integer i=0; i<resultList.size(); i++){
                if (!resultList[i].isSuccess()) { 
                    // add log
                    Logger__c log = createLogger(demandList[i],null);
                    String errMessage = '';
                    for(Database.Error e : resultList[i].getErrors()){
                        errMessage+= e.getMessage() + '\n';
                    }
                    log.Content__c = errMessage;
                    log.Operation__c = CLP_Logger.L_OUTBOUND;
                    CLP_Logger.log(log);               
                }  
            }
        }else{
            raiseError = true;
            for(DemandDetail__c demand : demandList){
                Logger__c log = createLogger(demand,null);
                log.Content__c = CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION;
                log.Operation__c = CLP_Logger.L_OUTBOUND;
                CLP_Logger.log(log);
            }  
        }
    }
}