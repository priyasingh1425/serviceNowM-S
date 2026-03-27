public with sharing class ApiResponseHelper {

    public static HttpRequestResponseModel.CRCreateResponse processApiResponse(MulesoftApiClient.HttpDetails result, String logContext, String recordId) {
        Integer statusCode = result.response.getStatusCode();
        Boolean isSuccess = (statusCode == 200 || statusCode == 201);

        API_APIResponse_INS.createAPIResponse(
            result.request.getEndpoint(),
            result.request.getBody(),
            result.response.getBody(),
            true,
            result.request.getMethod(),
            logContext,
            isSuccess ? 'true' : 'false',
            String.valueOf(statusCode),
            result.response.getStatus(),
            null,
            recordId,
            null
        );

        if (!isSuccess) {
            return null;
        }

        return (HttpRequestResponseModel.CRCreateResponse) JSON.deserialize(result.response.getBody(), HttpRequestResponseModel.CRCreateResponse.class);
    }

    public static void logException(String logPrefix, String methodName, Exception e) {
        String errorMessage = 'An error occurred in ' + logPrefix + '.' + methodName + ' at line ' + e.getLineNumber() + ': ' + e.getMessage();
        System.debug(LoggingLevel.ERROR, errorMessage);
        CustomException cx = new CustomException();
        cx.message = errorMessage;
        //CustomException.sendErrorNotification(cx);
    }
}
