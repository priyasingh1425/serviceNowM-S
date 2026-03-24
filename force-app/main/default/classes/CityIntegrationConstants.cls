public class CityIntegrationConstants {

    public static final String ACCOUNT_NAME = 'City of Minneapolis';
    public static final String CONTACT_NAME = 'City Of Minneapolis Service Desk';
    public static final String ACCOUNT_STATUS_ACTIVE = 'Active';
    public static final String ACCOUNT_RT_CUSTOMER = 'Customer';

    public static final String QUEUE_TOC = 'TOC Queue';
    public static final String SUPPORT_QUEUE_TOC = 'TOC Support';

    public static final String RT_CHANGE_REQUEST = 'Change_Request';
    public static final String RT_EXTERNAL_CUSTOMER_SUPPORT = 'External_Customer_Support';
    public static final String RT_CHANGE_REQUEST_LABEL = 'Change Request';
    public static final String RT_EXTERNAL_CUSTOMER_SUPPORT_LABEL = 'External Customer Support';

    public static final String ORIGIN_API = 'API';

    public static final String PREFIX_INCIDENT = 'INC';
    public static final String PREFIX_CHANGE = 'CHG';
    public static final String PREFIX_CHANGE_TASK = 'CTASK';

    public static final String STATUS_NEW = 'New';
    public static final String STATUS_RESOLVED = 'Resolved';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String STATUS_REOPEN = 'Reopen';
    public static final String STATUS_PARKED = 'Parked';
    public static final String STATUS_REASON_WAITING = 'Waiting for Customer';

    public static final Map<String, String> PRIORITY_NUMBER_TO_LABEL = new Map<String, String>{
        '1' => 'Urgent',
        '2' => 'High',
        '3' => 'Medium',
        '4' => 'Low'
    };

    public static final Map<String, String> PRIORITY_LABEL_TO_NUMBER = new Map<String, String>{
        'low' => '4',
        'medium' => '3',
        'high' => '2',
        'urgent' => '1'
    };

    public static final Integer MAX_FEEDITEMS_PER_QUEUEABLE = 90;

    public static final Set<String> ELIGIBLE_PRIORITIES = new Set<String>{'Medium', 'High', 'Urgent'};

    public static String getPriorityLabel(String priorityNumber) {
        if (String.isBlank(priorityNumber)) {
            return '';
        }
        String mappedValue = PRIORITY_NUMBER_TO_LABEL.get(priorityNumber.trim());
        return String.isNotBlank(mappedValue) ? mappedValue : '';
    }

    public static String getPriorityNumber(String priorityLabel) {
        if (String.isBlank(priorityLabel)) {
            return '';
        }
        String mappedValue = PRIORITY_LABEL_TO_NUMBER.get(priorityLabel.toLowerCase());
        return String.isNotBlank(mappedValue) ? mappedValue : '';
    }
}
