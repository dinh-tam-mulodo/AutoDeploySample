/**
 * Class: SP_Survey
 * Author: tran.binh
 * Description: process save data survey and question
 */
@RestResource(urlMapping='/SP_Survey/*')
global with sharing class SP_Survey {
    @HttpPost
    global static String createSurvey(FormSurvey dataSurvey){
        //Instance class SP_Survey__c for setting data
        SP_Survey__c surveyTarget = new SP_Survey__c();
        DataSurveyInfo dataSurveyInfo = new DataSurveyInfo();
        //Instance list Questions for upsert data
        List<SP_Question__c> lstdataQuestionUpsert = new List<SP_Question__c>();
        SP_Question__c targetQuestion;

        //Instance class wapper for output data
        DataOutput dataOutput = new DataOutput();
        //Instance list Questions for Output data
        List<DataQuestionsOutput> lstDataQuestionsOutput = new List<DataQuestionsOutput>();
        List<DataQuestionsOutput> lstDataQuestionsOutputUpsert = new List<DataQuestionsOutput>();
        DataQuestionsOutput dataQuestionsOutput;
        String idSurveyTarget;
        dataOutput.status = '200';
        dataOutput.errorMessage = '';
        String ip = '192.168.1.1';
        List<String> filelines = new List<String>{};
        dataSurveyInfo = dataSurvey.data;
        dataOutput.surveyId = dataSurveyInfo.surveyId;
        dataOutput.surveySalesforceId = dataSurveyInfo.surveySalesforceId;
        List<DataQuestions> lstdataQuestion = dataSurvey.data.questions;

        //declare variable Savepoint for rollback data when the problem occurred
        Savepoint sp = Database.setSavepoint();

        //loop list data question for setting values data output
        for(DataQuestions item : lstdataQuestion){
            //Instance data output
            dataQuestionsOutput = new DataQuestionsOutput();
            //setting values of data output: questionId and questionSalesforceId
            dataQuestionsOutput.questionId = item.questionId;
            dataQuestionsOutput.questionSalesforceId = item.questionSalesforceId;
            lstDataQuestionsOutput.add(dataQuestionsOutput);
        }
        //set values of list question
        dataOutput.questions = lstDataQuestionsOutput;

        SP_SettingSurveyAPI__c surveyAPI = [SELECT Id, SP_Token__c, SP_IPAddress__c FROM SP_SettingSurveyAPI__c];
        filelines = surveyAPI.SP_IPAddress__c.split('\\n');

        Boolean existsFlg = false;
        for(String item : filelines){
            if(item.equals(ip)){
                existsFlg = true;
            }
        }

        if(dataSurvey.token != surveyAPI.SP_Token__c){
            dataOutput.errorMessage = 'Unauthorized access. (token) token='+ dataSurvey.token;
            dataOutput.status = '302';
            return JSON.serialize(dataOutput);
        } else
            if(!existsFlg){
                dataOutput.errorMessage = 'Unauthorized access. (IPAddress)='+ ip;
                dataOutput.status = '303';
                return JSON.serialize(dataOutput);
            } else
                if(dataSurvey.processing != 'survey'){
                    dataOutput.errorMessage = 'Unauthorized access. ('+ dataSurvey.processing +')';
                    dataOutput.status = '304';
                    return JSON.serialize(dataOutput);
                } else {

                    try{

                        try {
                            //if surveySalesforceId is not empty then set Id of SP_Survey__c is surveySalesforceId
                            //else get Id default of SP_Survey__c when insert data
                            if(!String.isEmpty(dataSurveyInfo.surveySalesforceId)){
                                surveyTarget.Id = dataSurveyInfo.surveySalesforceId;
                            }
                            //set data survey
                            surveyTarget.SP_SurveyId__c = dataSurveyInfo.surveyId;
                            DateTime testDate = DateTime.valueOfGmt((dataSurveyInfo.surveyCloseDate).replaceAll('/','-'));
                            surveyTarget.SP_SurveyCloseDate__c = testDate;
                            surveyTarget.SP_SurveyDescription__c = dataSurveyInfo.surveyDescription;
                            surveyTarget.SP_SurveyDuplicate__c = Boolean.valueOf(dataSurveyInfo.surveyDuplicate);
                            surveyTarget.SP_SurveyOpenDate__c = DateTime.valueOfGmt((dataSurveyInfo.surveyOpenDate).replaceAll('/','-'));
                            surveyTarget.SP_SurveyTitle__c = dataSurveyInfo.surveyTitle;
                            surveyTarget.SP_SurveyUrl__c = dataSurveyInfo.surveyUrl;
                            //upsert data survey
                            upsert surveyTarget;
                        } catch(Exception ex){
                            //setting errorMessage and status when error
                            dataOutput.errorMessage = ex.getMessage();
                            dataOutput.status = '901';
                            throw ex;
                        }

                        try {
                            idSurveyTarget = surveyTarget.Id;
                            dataOutput.surveySalesforceId = idSurveyTarget;
                            // Loop for setting data
                            for(DataQuestions item : lstdataQuestion){
                                targetQuestion = new SP_Question__c();
                                if(!String.isEmpty(item.questionSalesforceId)){
                                    targetQuestion.Id = item.questionSalesforceId;
                                }
                                //setting data question for upsert to database
                                targetQuestion.SP_QuestionId__c = item.questionId;
                                targetQuestion.SP_QuestionTitle__c = item.questionTitle;
                                targetQuestion.SP_QuestionDescription__c = item.questionDescription;
                                targetQuestion.SP_QuestionRequire__c = Boolean.valueOf(item.questionRequired);
                                targetQuestion.SP_QuestionType__c = item.questionType;
                                targetQuestion.SP_QuestionSort__c = item.questionSort;
                                targetQuestion.SP_SurveyID__c = idSurveyTarget;
                                //add to list need upsert
                                lstdataQuestionUpsert.add(targetQuestion);
                            }

                            //upsert list data question
                            upsert lstdataQuestionUpsert;
                        } catch(Exception ex){
                            //setting errorMessage and status when error
                            dataOutput.errorMessage = ex.getMessage();
                            dataOutput.status = '902';
                            throw ex;
                        }
                    } catch(Exception exAll){
                        //rollback data when upsert error.
                        Database.rollback(sp);
                        return JSON.serialize(dataOutput);
                    }
                }
            //loop list data question for setting values data output
            for(SP_Question__c item : lstdataQuestionUpsert){
                //Instance data output
                dataQuestionsOutput = new DataQuestionsOutput();
                //setting values of data output: questionId and questionSalesforceId
                dataQuestionsOutput.questionId = item.SP_QuestionId__c;
                dataQuestionsOutput.questionSalesforceId = item.Id;
                lstDataQuestionsOutputUpsert.add(dataQuestionsOutput);
            }
            //set values of list question
            dataOutput.questions = lstDataQuestionsOutputUpsert;
        //return serialize data output
        return JSON.serialize(dataOutput);
    }

    /**
     * Description: class wapper FormSurvey
     * declare variable contains form data of survey and question
     */
    global class FormSurvey {
        global String token {get;set;}
        global DataSurveyInfo data {get;set;}
        global String processing {get;set;}
    }

    /**
     * Description: class wapper DataSurveyInfo
     * declare variable contains data of survey and list question
     */
    global class DataSurveyInfo {
        global String surveyId {get;set;}
        global String surveySalesforceId {get;set;}
        global String surveyTitle {get;set;}
        global String surveyDescription {get;set;}
        global String surveyOpenDate {get;set;}
        global String surveyCloseDate {get;set;}
        global String surveyUrl {get;set;}
        global String surveyDuplicate {get;set;}
        global List<DataQuestions> questions {get;set;}
    }

    /**
     * Description: class wapper DataQuestions
     * declare variable contains information of question
     */
    global class DataQuestions {
        global String questionId {get;set;}
        global String questionSalesforceId {get;set;}
        global String questionTitle {get;set;}
        global String questionDescription {get;set;}
        global String questionRequired {get;set;}
        global String questionType {get;set;}
        global String questionSort {get;set;}
    }

    /**
     * Description: class wapper DataOutput
     * declare variable contains information data need output.
     * data: status, errorMessage, surveyId, surveySalesforceId and list questions
     */
    global class DataOutput {
        global String status {get;set;}
        global String errorMessage {get;set;}
        global String surveyId {get;set;}
        global String surveySalesforceId {get;set;}
        global List<DataQuestionsOutput> questions {get;set;}
    }

    /**
     * Description: class wapper DataQuestionsOutput
     * declare variable contains information of question need output.
     * data: questionId and questionSalesforceId
     */
    global class DataQuestionsOutput {
        global String questionId {get;set;}
        global String questionSalesforceId {get;set;}
    }
}