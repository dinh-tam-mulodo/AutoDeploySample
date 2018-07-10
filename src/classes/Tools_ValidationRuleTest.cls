@IsTest
public class Tools_ValidationRuleTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String jsonString = '{'+
		'  \"size\": 15,'+
		'  \"totalSize\": 15,'+
		'  \"done\": true,'+
		'  \"queryLocator\": null,'+
		'  \"entityTypeName\": \"ValidationRule\",'+
		'  \"records\": ['+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000lq8NQAQ\"'+
		'      },'+
		'      \"Id\": \"03d6F000000lq8NQAQ\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000001sykb\"'+
		'        },'+
		'        \"QualifiedApiName\": \"CSIRT_Incidents__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000lqTlQAI\"'+
		'      },'+
		'      \"Id\": \"03d6F000000lqTlQAI\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000001t0DY\"'+
		'        },'+
		'        \"QualifiedApiName\": \"CSIRT_IncidentProgress__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000lpp5QAA\"'+
		'      },'+
		'      \"Id\": \"03d6F000000lpp5QAA\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000001t0DY\"'+
		'        },'+
		'        \"QualifiedApiName\": \"CSIRT_IncidentProgress__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000lr79QAA\"'+
		'      },'+
		'      \"Id\": \"03d6F000000lr79QAA\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000001ssRz\"'+
		'        },'+
		'        \"QualifiedApiName\": \"EmergencyPart__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000lqBMQAY\"'+
		'      },'+
		'      \"Id\": \"03d6F000000lqBMQAY\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000001t0DY\"'+
		'        },'+
		'        \"QualifiedApiName\": \"CSIRT_IncidentProgress__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000lqTqQAI\"'+
		'      },'+
		'      \"Id\": \"03d6F000000lqTqQAI\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000001ssRz\"'+
		'        },'+
		'        \"QualifiedApiName\": \"EmergencyPart__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000lwvdQAA\"'+
		'      },'+
		'      \"Id\": \"03d6F000000lwvdQAA\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000002Vqil\"'+
		'        },'+
		'        \"QualifiedApiName\": \"VulnerabilityProgress__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000lxWeQAI\"'+
		'      },'+
		'      \"Id\": \"03d6F000000lxWeQAI\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000001sr28\"'+
		'        },'+
		'        \"QualifiedApiName\": \"Assets__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000lxt3QAA\"'+
		'      },'+
		'      \"Id\": \"03d6F000000lxt3QAA\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000002VqfS\"'+
		'        },'+
		'        \"QualifiedApiName\": \"CSIRT_VulnerabilityTicket__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000lwmuQAA\"'+
		'      },'+
		'      \"Id\": \"03d6F000000lwmuQAA\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000002Vqil\"'+
		'        },'+
		'        \"QualifiedApiName\": \"VulnerabilityProgress__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000lwmzQAA\"'+
		'      },'+
		'      \"Id\": \"03d6F000000lwmzQAA\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000002VqfS\"'+
		'        },'+
		'        \"QualifiedApiName\": \"CSIRT_VulnerabilityTicket__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000lxWZQAY\"'+
		'      },'+
		'      \"Id\": \"03d6F000000lxWZQAY\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000001sr28\"'+
		'        },'+
		'        \"QualifiedApiName\": \"Assets__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000ltT6QAI\"'+
		'      },'+
		'      \"Id\": \"03d6F000000ltT6QAI\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000001sykb\"'+
		'        },'+
		'        \"QualifiedApiName\": \"CSIRT_Incidents__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000ltX3QAI\"'+
		'      },'+
		'      \"Id\": \"03d6F000000ltX3QAI\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000001tEOH\"'+
		'        },'+
		'        \"QualifiedApiName\": \"OtherResponse__c\"'+
		'      }'+
		'    },'+
		'    {'+
		'      \"attributes\": {'+
		'        \"type\": \"ValidationRule\",'+
		'        \"url\": \"/services/data/v37.0/tooling/sobjects/ValidationRule/03d6F000000ltUsQAI\"'+
		'      },'+
		'      \"Id\": \"03d6F000000ltUsQAI\",'+
		'      \"EntityDefinition\": {'+
		'        \"attributes\": {'+
		'          \"type\": \"EntityDefinition\",'+
		'          \"url\": \"/services/data/v37.0/tooling/sobjects/EntityDefinition/01I6F000001ssRz\"'+
		'        },'+
		'        \"QualifiedApiName\": \"EmergencyPart__c\"'+
		'      }'+
		'    }'+
		'  ]'+
		'}';
		Tools_ValidationRule r = (Tools_ValidationRule)(JSON.deserialize(jsonString, Tools_ValidationRule.class));
		r.error = '';
        r.error_description = '';
        r.name = '';
        r.done = true;
        r.entityTypeName = '';
        r.queryLocator = '';
        for(Tools_ValidationRule.Records rd : r.records){
            rd.Id = '';  
            rd.attributes.type_Z = '';
            rd.attributes.url = '';
            rd.entityDefinition.QualifiedApiName = '';
            rd.entityDefinition.attributes = rd.attributes;
        }
        system.assertEquals(r.Records.size(),15);
        system.assertEquals(r.size,15);
        system.assertEquals(r.totalSize,15);
	}
}