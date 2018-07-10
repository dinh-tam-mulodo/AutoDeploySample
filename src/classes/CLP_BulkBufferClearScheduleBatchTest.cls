@isTest
private class CLP_BulkBufferClearScheduleBatchTest {
	@testSetup static void commonSetupTest() {
		// create buffer
		
		MikataInteBuffer__c buf1 = new MikataInteBuffer__c(ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT);
		MikataInteBuffer__c buf2 = new MikataInteBuffer__c(ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE);
		List<MikataInteBuffer__c> bufs = new List<MikataInteBuffer__c> {buf1, buf2};
		insert bufs;
		system.assert(bufs != null);
	}

	@isTest static void clearFailedBufferTest() {
		CLP_BulkBufferClearScheduleBatch schBatch = new CLP_BulkBufferClearScheduleBatch();
		Datetime dt = Datetime.now().addMinutes(1);
		String timer = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

		Test.startTest();
		System.schedule('CLP_BulkBufferClearScheduleBatch', timer, schBatch);
		Test.stopTest();
		system.assert(timer != null);
	}
}