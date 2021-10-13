({
    packItem: function(component, event, helper) {
        var btn = event.getSource();
        var BtnMessage = btn.get("v.label");
        component.set("v.item", BtnMessage);
        var btnClicked = event.getSource();
        btnClicked.set("v.disabled", true);
    }
})