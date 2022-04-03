global class InformContactOwners implements Database.Batchable<sObject>, Schedulable {// Сразу вижу что ты его не запускал) 

    List<String> owners = new List<String>();// Всегда пустой на начале
    Map<Contact,String> ownersAndContacts = new Map<Contact,String>();// Всегда пустой на начале

    global database.querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(
            'SELECT ID, LastName, OwnerId '+//Форматирование
            ' FROM Contact WHERE Possible_Outdated__c="True"'
        );
    }
    global void execute(SchedulableContext ctx) {//Это уже вызов а не конструктор код ниже не имеет смысла
        InformContactOwners informContactOwners = new InformContactOwners();
        String cronStr = '0 0 12 * * ?';//Нужно такое выносить в константы
        String jobID = System.schedule('Send Notifications', cronStr, informContactOwners); // Название джобы должно так же ссылатся на объект/ы с которым работаем
 	}
 
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {
		List<Contact> contacts = new List<Contact>();        
        for (Contact contact : scope) {
            if (owners.contains(contact.OwnerId)) {//В данной реализации класса никогда не отработает
                ownersAndContacts.put(contact,(String)contact.OwnerId);//Может использовать в мапе не String а Id ? 
            }
            else {
                owners.add((String)contact.OwnerId);
                ownersAndContacts.put(contact,(String)contact.OwnerId);
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
       
        AsyncApexJob a = [SELECT a.TotalJobItems, 
                                 a.Status
                          FROM AsyncApexJob a 
                          WHERE id = :BC.getJobId()]; // а зачем?

        for (String owner : owners) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String [] ownerArray = new String [] {owner};
            mail.setToAddresses(ownerArray);// Посылать email на айдишку? Хммм
            mail.setSenderDisplayName('Apex Batch Processing Module');
            mail.setSubject('Batch Processing '+ a.Status + 
            '\nThe list of possible outdated Contacts that needs review!');
            String body = 'Contacts that need review: ';
            for (Contact con : ownersAndContacts.keySet()) {// Что бы не листать весь цикл сквозь все контакты стоит инвертировать мапу - Owner -> List<Contact>
                if(ownersAndContacts.get(con)==owner){
                    body += '['+ con.LastName +
                    '](https://senla8-dev-ed.lightning.force.com/lightning/r/Contact/'+
                    con.Id + '/view)' + ' ';//Ссылку включающую домен бокса НИКОГДА не делаем статическим, для этого есть Системная переменка
			//Перенос на новую строку забыл) 
                }
            /*    for (Contact con : contactsOfCurrentOwner) {//Wut
                    body += '['+ con.LastName +
                    '](https://senla8-dev-ed.lightning.force.com/lightning/r/Contact/'+
                    con.Id + '/view)' + ' ';  
                }*/
            }
            mail.setPlainTextBody(body);
            mailsToSend.add(mail);
        }
        //String[] email = owners;
        //mail.setReplyTo('Your email for reply'); 
        Messaging.sendEmail(mailsToSend);

    }
    
}
