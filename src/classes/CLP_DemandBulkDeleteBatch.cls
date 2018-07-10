/**
 * CLP_DemandBulkDeleteBatch.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_DemandBulkDeleteBatch class
 */
global with sharing class CLP_DemandBulkDeleteBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	global Boolean shouldStop = false;	
	global Boolean raiseError = false;
    global String sql;
    global String cntsql;

	public CLP_DemandBulkDeleteBatch() {
		
	}

	// start batch with check duplicate running 
	public static Id startBatch(Boolean checkRunning)
    {
        if (checkRunning)
        {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_DemandBulkDeleteBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            system.debug(aajList);
            if (aajList.size() != 0) {
                return null;
            }
        }
        
        CLP_DemandBulkDeleteBatch processor = new CLP_DemandBulkDeleteBatch();
        Id batchprocessid=null;   
        batchprocessid = Database.executeBatch(processor, 100);  

        return batchprocessid;
    }

    global Database.querylocator start(Database.BatchableContext BC)
    {
    	String[] fieldsArray = new String[]{
    		'Id','Name','StopFlg__c','IsStop__c','LastModifiedById'
    	};
    	String fields = String.join(fieldsArray,',');
    	this.sql = String.format('Select {0} from DemandDetail__c where ManipulateStatus__c = \'\'{1}\'\' and StopFlg__c = \'\'{2}\'\' order by LastModifiedDate  asc ALL ROWS'
    			,new String[]{String.escapeSingleQuotes(fields),String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING),String.escapeSingleQuotes(CLP_MikataConstant.FLG_DELETE)});
    	this.cntsql = String.format('Select count() from DemandDetail__c where ManipulateStatus__c = \'\'{0}\'\' and StopFlg__c = \'\'{1}\'\' ALL ROWS',new String[]{String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING),String.escapeSingleQuotes(CLP_MikataConstant.FLG_DELETE)});
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

    // execute callout bulk upsert mikata
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	try{
	    	List<DemandDetail__c> demandList = (List<DemandDetail__c>) scope;
	    	system.debug('demandList: '+ demandList);
	    	if(!demandList.isEmpty()){
                // validation demandList at here
		    	//  call to api upsert
		    	CLP_BulkDemandWrapper result = CLP_MikataDemandAPI.demandBulkStop(demandList);
		    	system.debug(result);

		    	// restore this demandList
		    	undelete demandList;
		    	system.debug(demandList);

		    	if(result.success){                    
		    		// loop demand and update demandDetail to success
		    		
		    		for(CLP_BulkDemandWrapper.Demand d : result.demand){
                        
		    			for(DemandDetail__c dd : demandList){
		    				// check is exist demand in reponse
		    				if(d.code == dd.Id){
		    					// create new log
                                Logger__c log = new Logger__c();		    					
		    					log.LK_RelatedUser__c = dd.LastModifiedById;
		    					log.LK_DemandDetail__c = dd.Id;
                                log.Origin__c  = 'CLP_DemandBulkDeleteBatch';
		    					log.Content__c = d.error_message;
                                log.Request__c = CLP_MikataDemandAPI.getApiRequest(dd,CLP_MikataApi.ApiType.F_DELETE);
                                log.Response__c = CLP_MikataDemandAPI.getApiResponse(d);
		    					// register success
		    					if(String.isBlank(d.error_message))
		    					{
                                    dd.ErrorMessage__c = '';
		    						dd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
		    					}// connection error
		    					else if(d.error_message.toLowerCase().contains(CLP_MikataApi.HTTP_CONNECTION_ERROR)){
		    						log.Operation__c = CLP_Logger.L_ACCESS;
		    						dd.ErrorMessage__c = d.error_message;
		    						dd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                                    CLP_Logger.log(log);
	    						}// data error
	    						else{
	    							log.Operation__c = CLP_Logger.L_OUTBOUND;
	    							dd.ErrorMessage__c = d.error_message;
	    							dd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                                    CLP_Logger.log(log);
	    						}	    						
                                break;
		    				}
		    			}
		    		}
		    	}else{
		    		for(DemandDetail__c dd : demandList){		    			
                        Logger__c log = new Logger__c();    
                        log.Origin__c  = 'CLP_DemandBulkDeleteBatch';
                        log.Request__c = CLP_MikataDemandAPI.getApiRequest(dd,CLP_MikataApi.ApiType.F_DELETE);
                        log.Operation__c = CLP_Logger.L_ACCESS;
                        log.LK_DemandDetail__c = dd.Id;
                        log.LK_RelatedUser__c = dd.LastModifiedById;
                        dd.ErrorMessage__c = result.error_message;
                        dd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                        // add log
                        CLP_Logger.log(log);
                    }
		    	}
		    	system.debug('after update:' + demandList);
                // update demand
                update demandList;
                // delete again
                delete demandList;
		    	// insert log
		    	CLP_Logger.flush();
	    	}	    	
		}catch(Exception ex){
			raiseError = true;
			CLP_Logger.log(ex.getMessage(),'CLP_DemandBulkDeleteBatch');
			CLP_Logger.flush();
		}
    } 

    // finish this batch send email and recall batch if was exist batch in queue
    global void finish(Database.BatchableContext BC)
    {
        CLP_MikataAPI.sendEmailComplete('CLP_SendLogEmail','CLP_DemandBulkDeleteBatch');
    	//system.debug('raiseError');
    	if(raiseError){
    		return;
    	}        
    	// if exist record need to register to mikata ==> call batch again
    	if(Database.countQuery(this.cntsql)>0){
    	 	// run batch again
    	 	if(!Test.isRunningTest() && !shouldStop) {
                //startBatch(true);
            }
    	}

    	// if more than 2 job started at the same time ==> abort all job
    	if(shouldStop){
    		for(AsyncApexJob aaj : [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_DemandBulkDeleteBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
    	}
    }
}