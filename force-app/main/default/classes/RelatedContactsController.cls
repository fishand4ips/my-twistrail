public with sharing class RelatedContactsController {

    @AuraEnabled
    public static List<ContactWrapper> getRelatedList(String recordId) {
        List<ContactWrapper> contactsWrapper = new List<ContactWrapper>();
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Title, Email, Phone, AccountId, Account.Name
            FROM Contact
            WHERE AccountId = :recordId
            WITH SECURITY_ENFORCED
        ];
        if (!contacts.isEmpty()) {
            for (Contact contact : contacts) {
                contactsWrapper.add(new ContactWrapper(contact));
            }
        }
        return contactsWrapper;
    }

    @AuraEnabled
    public static String saveContacts(Object contactsInfo) {
        try {
            List<ContactWrapper> cWraps = (List<ContactWrapper>) JSON.deserialize(JSON.serialize(contactsInfo), List<ContactWrapper>.class);
            List<Contact> contactsToUpdate = new List<Contact>();

            for (ContactWrapper w : cWraps) {
                contactsToUpdate.add(w.toContact());
            }

            if (Schema.sObjectType.Contact.isUpdateable()) {
                update contactsToUpdate;
            } else {
                return 'Don\'t updateable';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return 'OK';
    }

    public class ContactWrapper {
        @AuraEnabled
        public String id;

        @AuraEnabled
        public String firstName;

        @AuraEnabled
        public String lastName;

        @AuraEnabled
        public String title;

        @AuraEnabled
        public String email;

        @AuraEnabled
        public String phone;

        @AuraEnabled
        public String accountName;

        @AuraEnabled
        public String accountId;

        public ContactWrapper(Contact contact) {
            this.id = contact.Id;
            this.firstName = contact.FirstName;
            this.lastName = contact.LastName;
            this.title = contact.Title;
            this.email = contact.email;
            this.phone = contact.Phone;
            this.accountName = contact.Account.Name;
            this.accountId = contact.AccountId;
        }

        public Account toAccount() {
            return new Account(
                Id = this.accountId,
                Name = this.accountName
            );
        }

        public Contact toContact() {
            return new Contact(
                Id = this.id,
                FirstName = this.firstName,
                LastName = this.lastName,
                Title = this.title,
                Email = this.email,
                Phone = this.phone,
                AccountId = this.accountId
            );
        }
    }
}