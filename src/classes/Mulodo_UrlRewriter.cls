global with sharing class Mulodo_UrlRewriter implements Site.UrlRewriter {   
    global PageReference mapRequestUrl(PageReference
            myFriendlyUrl){             
         
            String url = myFriendlyUrl.getUrl().toLowerCase();                     
            if(!url.contains('Mulodo_') && !String.isEmpty(url) && url.startsWith('/') && url.length()==1){    
                return new PageReference('apex/mulodoSite');
            }   
            if(url.startsWith('/')){                
                if(!url.substring(1,url.length()).startsWith('Mulodo_') && 
                    !String.isEmpty(url.substring(1,url.length())) && !url.contains('apexremote')
                    && !url.contains('apexrest')){
                    return new PageReference('apex/Mulodo_'+url.substring(1,url.length()));
                }    
            }
            else{
                if(!url.startsWith('Mulodo_') && !String.isEmpty(url) && !url.contains('apexremote')
                    && !url.contains('apexrest')){
                    return new PageReference('apex/Mulodo_'+url);
                }                   
            }                     
            
        return null;
    }
    
    global List<PageReference> generateUrlFor(List<PageReference> 
            mySalesforceUrls){                           
        return mySalesforceUrls;
    }
}