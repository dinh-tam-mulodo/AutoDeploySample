global with sharing class CLP_CreatingDemandDetail {
    webService static string createDemandDetail(Id oppId){
            
            List<OpportunityLineItem> oppProducts= [SELECT Product2Id,Opportunity.AccountId,Opportunity.PaymentMethodId__c,
            Opportunity.BillingSourceOwnerId__c,Opportunity.Seikyuusakibusho__c,Opportunity.Bill_Method__c,Product2.ProductCode,
            Product2.Item_Code__c,Product2.Name,Product2.TaxCategory__c,Product2.Unit__c,Product2.DemandType__c,
            Quantity,UnitPrice,IsCreated__c 
            FROM OpportunityLineItem
            WHERE Opportunity.Id = :oppId
            ];
            List<DemandDetail__c> dds = new List<DemandDetail__c>();

            for(OpportunityLineItem product : oPPproducts){

                if(product.IsCreated__c != true){
                    DemandDetail__c dd = new DemandDetail__c();
                    dd.Account__c = product.Opportunity.AccountId;
                    dd.OpportunityId__c  = oppId;
                    //商談関連
                    dd.PaymentMethod__c = product.Opportunity.PaymentMethodId__c;
                    dd.BillingSourceOwner__c = product.Opportunity.BillingSourceOwnerId__c;
                    dd.Seikyuusakibusho__c  = product.Opportunity.Seikyuusakibusho__c;
                    dd.PaymentProcess__c = product.Opportunity.Bill_Method__c;
                    //商品関連
                    dd.GoodsCode__c =( String.ISBLANK(product.Product2.ProductCode))?product.Product2.ProductCode:
                    product.Product2.ProductCode.left(33);//集計用
                    dd.Item_code__c = product.Product2.Item_Code__c;//連携用
                    dd.Product__c = product.Product2Id ;
                    dd.ProductName__c = product.Product2.Name.left(60);
                    dd.TaxCategory__c = product.Product2.TaxCategory__c;//税区分
                    //商談商品関連
                    dd.Quantity__c = product.Quantity;
                    dd.Price__c = product.UnitPrice; //単価
                    dd.Unit__c = product.Product2.Unit__c; //単位
                    dd.DemandType__c = product.Product2.DemandType__c;//請求タイプ 

                    dd.StartDate__c = date.today();
                    dd.ManipulateStatus__c='0';
                    /*dd.BillSendScheduleCriteria_Month__c = '0';
                    dd.BillIssueCriteria_Month__c = '1';
                    dd.SlipDeadline_Month__c = '1';
                    dd.TransferDeadline_Month__c = '';

                    dd.BillSendScheduleCriteria_Day__c = '99';
                    dd.BillIssueCriteria_Date__c = '1';
                    dd.SlipDeadline_Day__c = '1';
                    dd.TransferDeadline_Day__c = '';*/

                    product.IsCreated__c = true;                    
                    dds.add(dd);
                    //system.debug(dds);

                }

            }
            CLP_JsonResult result = new CLP_JsonResult(); 
            result.success = true;
            result.errorMessage = '';
            Savepoint sp = Database.setSavepoint();
            try{                
                Boolean isUpdate = updateProductList(oppProducts);
                Boolean isInsert = insertDemandList(dds);
            }
            catch(DmlException ex){            
                Database.rollback(sp);    
                result.success = false;
                result.errorMessage = ex.getMessage();            
            }
            return JSON.serialize(result);
        }

        private static Boolean updateProductList(List<OpportunityLineItem> products){
            Boolean isSuccess = false;
            String[] fields = new String[]{'IsCreated__c'};
            if(CLP_CommonUtil.checkFLS('OpportunityLineItem',fields, CLP_CommonUtil.FLSType.UPDATE_OBJECT)) 
            {
                update products;
                isSuccess = true;
            }
            return isSuccess;
        }
        private static Boolean insertDemandList(List<DemandDetail__c> demands){
            Boolean isSuccess = false;
            CLP_JsonResult result = new CLP_JsonResult(); 
            String[] fields = new String[]{'Account__c','OpportunityId__c','PaymentMethod__c','BillingSourceOwner__c'
                                        ,'Seikyuusakibusho__c','PaymentProcess__c','GoodsCode__c'
                                        ,'Item_code__c','ProductName__c','TaxCategory__c','DemandType__c'
                                        ,'Quantity__c','Price__c','Unit__c','StartDate__c','BillSendScheduleCriteria_Month__c'
                                        ,'BillIssueCriteria_Month__c','SlipDeadline_Month__c','TransferDeadline_Month__c'
                                        ,'BillSendScheduleCriteria_Day__c','BillIssueCriteria_Date__c','SlipDeadline_Day__c'
                                        ,'TransferDeadline_Day__c'};
            if(CLP_CommonUtil.checkFLS('DemandDetail__c',fields, CLP_CommonUtil.FLSType.CREATE_OBJECT)) 
            {                
                insert demands;
                isSuccess = true;                              
            }
            return isSuccess;
        }
    }