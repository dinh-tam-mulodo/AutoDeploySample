global class NTT_DemoGridInlineEditCC {
	@remoteAction
    global static JsonData getData(Integer cnt){    	
        try{
        	system.debug(cnt);
        	JsonData retJson = new JsonData();
        	Boolean isNext = false;
        	Integer pageSize = cnt == 0 ? 100 : 10;        	
			Integer offset = pageSize * cnt;
        	List<Beer__c> bs = new List<Beer__c>();
        	Integer i = 0;
        	Integer cntGet = 0;
        	for(Beer__c b : [Select Id,Name,Brewery__c,Test1__c,Test2__c,Test3__c,Test4__c,Test5__c,Test6__c,Test7__c,Test8__c,Test9__c,Test10__c,Test11__c,Test12__c,Test13__c,Test14__c,Test15__c,Test16__c,Test17__c,Test18__c,Test19__c,Test20__c,Test21__c,Test22__c,Test23__c,Test24__c,Test25__c,Test26__c,Test27__c,Test28__c,Test29__c,Test30__c,Test31__c,Test32__c,Test33__c,Test34__c,Test35__c,Test36__c,Test37__c,Test38__c,Test39__c,Test40__c,Test41__c,Test42__c,Test43__c,Test44__c,Test45__c,Test46__c,Test47__c,Test48__c,Test49__c,Test50__c,Test51__c,Test52__c,Test53__c,Test54__c,Test55__c,Test56__c,Test57__c,Test58__c,Test59__c,Test60__c,Test61__c,Test62__c,Test63__c,Test64__c,Test65__c,Test66__c,Test67__c,Test68__c,Test69__c,Test70__c,Test71__c,Test72__c,Test73__c,Test74__c,Test75__c,Test76__c,Test77__c,Test78__c,Test79__c,Test80__c,Test81__c,Test82__c,Test83__c,Test84__c,Test85__c,Test86__c,Test87__c,Test88__c,Test89__c,Test90__c,Test91__c,Test92__c,Test93__c,Test94__c,Test95__c,Test96__c,Test97__c,Test98__c,Test99__c,Test100__c from Beer__c order by Test1__c limit 4000 ])
			{
				if(i<offset){
					i++;
					continue;
				}else if(i > offset && cntGet < pageSize){
					bs.add(b);
					cntGet++;
				}else if(i>offset + cntGet){
					isNext = true;
					break;
				}
				i++;
			}	
			retJson.isNext = isNext;
			retJson.data = bs;
			system.debug(retJson + 'i' + i);
			return retJson;
    	}catch(LimitException ex){
    		system.debug(ex.getMessage());
    		return null;
    	}
    }
    // insert attactment file
    @remoteAction
    global static String insertAttachFile(String jsonString){
    	Account acc = [Select Id from Account limit 1];
    	Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(jsonString);
        attachment.Name = 'csv Data';
        attachment.ParentId = acc.Id; 
        attachment.ContentType = 'text/csv';
        insert attachment;
        return '';
    }

    public List<Beer__c> getAccs(){
        return [Select Id,Name,Brewery__c,Test1__c,Test2__c,Test3__c,Test4__c,Test5__c,Test6__c,Test7__c,Test8__c,Test9__c,Test10__c,Test11__c,Test12__c,Test13__c,Test14__c,Test15__c,Test16__c,Test17__c,Test18__c,Test19__c,Test20__c,Test21__c,Test22__c,Test23__c,Test24__c,Test25__c,Test26__c,Test27__c,Test28__c,Test29__c,Test30__c,Test31__c,Test32__c,Test33__c,Test34__c,Test35__c,Test36__c,Test37__c,Test38__c,Test39__c,Test40__c,Test41__c,Test42__c,Test43__c,Test44__c,Test45__c,Test46__c,Test47__c,Test48__c,Test49__c,Test50__c,Test51__c,Test52__c,Test53__c,Test54__c,Test55__c,Test56__c,Test57__c,Test58__c,Test59__c,Test60__c,Test61__c,Test62__c,Test63__c,Test64__c,Test65__c,Test66__c,Test67__c,Test68__c,Test69__c,Test70__c,Test71__c,Test72__c,Test73__c,Test74__c,Test75__c,Test76__c,Test77__c,Test78__c,Test79__c,Test80__c,Test81__c,Test82__c,Test83__c,Test84__c,Test85__c,Test86__c,Test87__c,Test88__c,Test89__c,Test90__c,Test91__c,Test92__c,Test93__c,Test94__c,Test95__c,Test96__c,Test97__c,Test98__c,Test99__c,Test100__c from Beer__c order by Test1__c limit 1000];
    }
    public   List<String> getFields(){
        List<String> fields = new List<String>();
            for(Integer  i=1; i<=100;i++){
                    fields.add('Test'+i+'__c');
            }
            system.debug(fields);
            return fields;
    }

    global class JsonData{
    	public Boolean isNext {get;set;}
    	public Object data {get;set;}
    }
}