<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>demo deploy2</fullName>
        <active>false</active>
        <criteriaItems>
            <field>demoDeploy__c.Demo_Deploy__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>demoTestFlow</fullName>
        <active>false</active>
        <formula>ISBLANK( Demo_Deploy__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
