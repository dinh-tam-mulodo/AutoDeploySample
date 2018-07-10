@isTest
private class CLP_LoggerDeleteSchedulerTest {
    static testMethod void loggerDeleteSchedulerTest() {
        CLP_Logger.log('Test case 1', CLP_Logger.L_ACCESS, 'CMN_LoggerDeleteBatchTest');
        CLP_Logger.log('Test case 2', CLP_Logger.L_ACCESS, 'CMN_LoggerDeleteBatchTest');
        CLP_Logger.log('Test case 3', CLP_Logger.L_ACCESS, 'CMN_LoggerDeleteBatchTest');
        CLP_Logger.flush();

        CLP_LoggerDeleteScheduler scheduler = new CLP_LoggerDeleteScheduler();
        scheduler.execute(null);
        
        Integer i = [select count() FROM Logger__c];
        
        System.Debug('point1');
        
        System.assertEquals(0, i);
        
        System.Debug('point2');
        //Test.stopTest();
        // Test.stopTest();
    }
}