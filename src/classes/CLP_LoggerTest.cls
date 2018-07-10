@isTest
private class CLP_LoggerTest {
    static testMethod void test_method_one() {
        CLP_Logger.log('Test Message.', CLP_Logger.L_ACCESS, 'Test class');
        CLP_Logger.flush();
        Logger__c log = [SELECT Content__c, Operation__c, Origin__c
                             FROM Logger__c ORDER BY Name DESC];
        
        System.debug('Content__c:' + log.Content__c);
        System.assertEquals(log.Content__c, 'Test Message.');
        System.debug('Operation__c:' + log.Operation__c);
        System.assertEquals(log.Operation__c, CLP_Logger.L_ACCESS);
        System.debug('Origin__c:' + log.Origin__c);
        System.assertEquals(log.Origin__c, 'Test class');   
    }
    
    static testMethod void testLogException() {
        try {
            Integer bad = 0;
            bad = bad / 0;
        } catch (Exception ex) {
            CLP_Logger.log('Exception class','Divide by 0');
            CLP_Logger.flush();
        }
        
        Logger__c log = [SELECT Content__c, Operation__c, Origin__c
                             FROM Logger__c ORDER BY Name DESC];
        System.assertEquals(log.Operation__c, CLP_Logger.L_EXCEPTION);
    }
}