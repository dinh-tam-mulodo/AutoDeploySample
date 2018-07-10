@isTest
private class CLP_DocumentBulkDeleteScheduleBatchTest {
	@testSetup static void commonSetupTest() {
		// query folder
		List<Folder> folderList = [select Id from Folder where DeveloperName = 'FolderCustomLog'];

		// create document
		Document doc = new Document();
		doc.FolderId = folderList[0].Id;
		doc.Name = 'TestDoc';
		doc.Body = EncodingUtil.convertFromHex('');
		insert doc;

		system.assert(doc.Id != null);
	}

	@isTest static void documentBulkDeleteScheduleBatchTest() {
		CLP_DocumentBulkDeleteScheduleBatch schBatch = new CLP_DocumentBulkDeleteScheduleBatch();
		Datetime dt = Datetime.now().addMinutes(1);
		String timer = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

		Test.startTest();
		System.schedule('CLP_DocumentBulkDeleteScheduleBatch', timer, schBatch);
		Test.stopTest();
		system.assert(timer != null);
	}
}