@RestResource(urlMapping='/LeadRest/*')
global class LeadRestApi {	
    @HttpPost
    global static Lead getLeadByIdOrEmail(){
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Lead returnLead;
        try{
        String findLead = req.requestBody.tostring();
        
        Map<String, Object> parMap = (Map<String, Object>) JSON.deserializeUntyped(findLead);
        String leadId = parMap.get('id').toString();
        String leadEmail = parMap.get('email').toString();
        if(leadId != null && leadId.length() == 18){
             returnLead = [SELECT Id, Name, OwnerId
                      FROM Lead
                      WHERE Id = :leadId
                      LIMIT 1];
        }
        else if(leadEmail != null && leadEmail.contains('@')){
             returnLead = [SELECT Id, Name, OwnerId
                      FROM Lead
                      WHERE Email = :leadEmail
                      LIMIT 1];
        }
        else {
            System.debug('Cannot find the Lead!');
            returnLead =  null;
        }
        
        System.debug(returnLead);
        res.statusCode = 200;
        return returnLead;
    }catch(NullPointerException e){
        e.getStackTraceString();
        System.debug('Null pointer exception!!!');
        return null;
    }
        
    }
    @HttpPut
    global static Task createTaskForLead(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;                         

        Lead targetLead;
        
        try {
        String findLead = req.requestBody.tostring();
        
        Map<String, Object> parMap = (Map<String, Object>) JSON.deserializeUntyped(findLead);
        String leadId = parMap.get('id').toString();
        String leadEmail = parMap.get('email').toString();
        if(leadId != null && leadId.length() == 18){
             targetLead = [SELECT Id, Name, OwnerId
                      FROM Lead
                      WHERE Id = :leadId
                      LIMIT 1];
        }
        else if(leadEmail != null && leadEmail.contains('@')){
             targetLead = [SELECT Id, Name, OwnerId
                      FROM Lead
                      WHERE Email = :leadEmail
                      LIMIT 1];
        }
        else {
            System.debug('Cannot find the Lead!');
            targetLead =  null;
        }
        
        Task newTask = new Task(Subject = 'Other' ,
                               Status = 'Not Started',
                               WhoID = targetLead.Id, 
                               OwnerId = targetLead.OwnerId);
        insert newTask;
        System.debug(newTask);
        res.statusCode = 200;
        return newTask;
    }catch(NullPointerException e){
        e.getStackTraceString();
        System.debug('Null pointer exception!!!');
        return null;
    }
    }
}