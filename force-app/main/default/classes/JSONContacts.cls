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
                String firstName = String.isNotBlank(con.firstName) ? con.firstName : 'fisrtNameTest'; 
                String lastName = String.isNotBlank(con.lastName) ? con.lastName : 'lastNameTest'; 
                String phone = String.isNotBlank(con.Phone) ? con.Phone : 'PhoneTest'; 
                jsonGen.writeStringField('ID',con.Id);
                jsonGen.writeStringField('FirstName',firstName);
                jsonGen.writeStringField('LastName',lastName);
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