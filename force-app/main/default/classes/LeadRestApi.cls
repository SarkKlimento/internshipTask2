@RestResource(urlMapping='/LeadRest/*')//Имя обычно просто namespace с которым работаем, это плохое имя
global class LeadRestApi {	
    @HttpPost
    global static Lead getLeadByIdOrEmail(){
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Lead returnLead;//нэйминг страдает
        try{//отступы (полетели везде, оставляю коммент только тут)
        String findLead = req.requestBody.tostring();// findLead != requestBody parameter ) 
        
        Map<String, Object> parMap = (Map<String, Object>) JSON.deserializeUntyped(findLead); // А проверить на пустоту?
        String leadId = parMap.get('id').toString();
        String leadEmail = parMap.get('email').toString();
        if(leadId != null && leadId.length() == 18){// А если есть и айдишка и email?
             returnLead = [SELECT Id, Name, OwnerId// можно было бы накидать чуть больше информации)
                      FROM Lead
                      WHERE Id = :leadId//Почитай про SOQL Injections
                      LIMIT 1];
        }
        else if(leadEmail != null && leadEmail.contains('@')){
             returnLead = [SELECT Id, Name, OwnerId//Same
                      FROM Lead
                      WHERE Email = :leadEmail//Same
                      LIMIT 1];
        }
        else {
            System.debug('Cannot find the Lead!');// Если выводим лог такого формата - применяем уровни соотв. лога 
            returnLead =  null;//Не имеет смысла - изначально null
        }
        
        System.debug(returnLead);// Лишнее)
        res.statusCode = 200;// По текущему подходу применен не будет
        return returnLead;//Подход Web Service не Rest! && Не возвращаешь ошибку если нет лида найденного
    }catch(NullPointerException e){
        e.getStackTraceString();
        System.debug('Null pointer exception!!!');// Уровни!
        return null;//А вернуть ошибку?!
    }
        
    }
    @HttpPut
    global static Task createTaskForLead(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;                         

        Lead targetLead;
        
        try {
        String findLead = req.requestBody.tostring();//Куча таких же ошибок как в прошлом, оставлять не буду
        
        Map<String, Object> parMap = (Map<String, Object>) JSON.deserializeUntyped(findLead); // Дублируешь код из прошлого метода!!! Отвратительно!
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
        
        Task newTask = new Task(Subject = 'Other' ,//Перечитай условие задачи
                               Status = 'Not Started',
                               WhoID = targetLead.Id, //А если Лид пустой или null? Метод упадет! 
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
