public class TriggerBypass {
    
    private static Boolean bypassFeedItemTrigger = false;
    
    public static void setBypassFeedItemTrigger(Boolean bypass) {
        bypassFeedItemTrigger = bypass;
    }
    
    public static Boolean isFeedItemTriggerBypassed() {
        return bypassFeedItemTrigger;
    }
}