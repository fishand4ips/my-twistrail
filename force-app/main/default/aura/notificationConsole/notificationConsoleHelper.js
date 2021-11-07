({
  subscribe: function (component, event, helper) {
    const empApi = component.find('empApi');
    const channel = component.get('v.channel');
    const replayId = -1;
    const callback = function (message) {
      console.log('Event Received : ' + JSON.stringify(message));
      helper.onReceiveNotification(component, message);
    };
    empApi.subscribe(channel, replayId, $A.getCallback(callback)).then($A.getCallback(function (newSubscription) {
      console.log('Subscribed to channel ' + channel);
      component.set('v.subscription', newSubscription);
    }));
  },
  unsubscribe: function (component, event, helper) {
    const empApi = component.find('empApi');
    const channel = component.get('v.subscription').channel;
    const callback = function (message) {
      console.log('Unsubscribed from channel ' + message.channel);
    };
    empApi.unsubscribe(component.get('v.subscription'), $A.getCallback(callback));
  },
  onReceiveNotification: function (component, message) {
    const newNotification = {
      time: $A.localizationService.formatDateTime(
        message.data.payload.CreatedDate, 'HH:mm'),
      message: message.data.payload.Message__c
    };
    const notifications = component.get('v.notifications');
    notifications.push(newNotification);
    component.set('v.notifications', notifications);
    this.displayToast(component, 'info', newNotification.message);
  },
  displayToast: function (component, type, message) {
    const toastEvent = $A.get('e.force:showToast');
    toastEvent.setParams({
      type: type,
      message: message
    });
    toastEvent.fire();
  }
})