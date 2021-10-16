public class JSONContacts {
    public static void JSONContactsMethod (){
        List<Contact> conList = [SELECT ID, firstName, lastName, Phone FROM Contact Limit 5];
        if(!conList.isEmpty()){
            JSONGenerator jsonGen = JSON.createGenerator(true);
            jsonGen.writeStartObject();
            jsonGen.writeFieldName('ContactList');
            jsonGen.writeStartArray();
            for(Contact con : conList){
                jsonGen.writeStartObject();
                jsonGen.writeStringField('ID',con.Id);
                String firstName = String.isNotBlank(con.firstName) ? con.firstName : 'fisrtNameTest'; 
                jsonGen.writeStringField('FirstName',firstName);
                String lastName = String.isNotBlank(con.lastName) ? con.lastName : 'lastNameTest'; 
                jsonGen.writeStringField('LastName',lastName);
                String phone = String.isNotBlank(con.Phone) ? con.Phone : 'PhoneTest'; 
                jsonGen.writeStringField('Phone',phone);
                jsonGen.writeEndObject();
            }
            jsonGen.writeEndArray();
            jsonGen.writeEndObject();
            String jsonData = jsonGen.getAsString();
            System.debug('Json Data - ' + jsonData);
        }
    }
}